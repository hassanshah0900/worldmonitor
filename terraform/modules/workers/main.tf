data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_kms_alias" "ssm" {
  name = "alias/aws/ssm"
}

data "aws_caller_identity" "current" {}

locals {
  ssm_param_arn = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_join_command_param}"
  cluster_name  = "${var.project}-${var.environment}"
  # "-??????" matches Secrets Manager's random 6-char ARN suffix without
  # needing to know it ahead of time.
  secrets_manager_secret_arn = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets_manager_secret_name}-??????"
}

data "aws_iam_policy_document" "workers_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "workers" {
  name_prefix        = "${var.project}-${var.environment}-worker-"
  assume_role_policy = data.aws_iam_policy_document.workers_assume_role.json
}

data "aws_iam_policy_document" "workers_ssm" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter"]
    resources = [local.ssm_param_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_alias.ssm.target_key_arn]
  }
}

resource "aws_iam_role_policy" "workers_ssm" {
  name   = "ssm-read-join-param"
  role   = aws_iam_role.workers.id
  policy = data.aws_iam_policy_document.workers_ssm.json
}

# The external-secrets ClusterSecretStore has no explicit auth block — it
# relies entirely on whatever credentials the pod's node grants via the AWS
# SDK's default chain, which on EC2 means this instance profile.
data "aws_iam_policy_document" "workers_secrets_manager" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.secrets_manager_secret_arn]
  }
}

resource "aws_iam_role_policy" "workers_secrets_manager" {
  name   = "secrets-manager-read"
  role   = aws_iam_role.workers.id
  policy = data.aws_iam_policy_document.workers_secrets_manager.json
}

# Cluster Autoscaler permissions. The Describe* actions don't support
# resource-level scoping (AWS API limitation — they must be Resource "*"),
# but the mutating actions are scoped to only this ASG via the ownership tag
# condition, so CA can't touch any other ASG in the account.
data "aws_iam_policy_document" "workers_cluster_autoscaler" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/${local.cluster_name}"
      values   = ["owned"]
    }
  }
}

resource "aws_iam_role_policy" "workers_cluster_autoscaler" {
  name   = "cluster-autoscaler"
  role   = aws_iam_role.workers.id
  policy = data.aws_iam_policy_document.workers_cluster_autoscaler.json
}

resource "aws_iam_instance_profile" "workers" {
  name_prefix = "${var.project}-${var.environment}-worker-"
  role        = aws_iam_role.workers.name
}

resource "aws_launch_template" "workers" {
  name_prefix   = "${var.project}-${var.environment}-worker-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.workers.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.security_group_id]
  }

  user_data = base64encode(templatefile("${path.module}/templates/user-data.sh.tpl", {
    aws_region             = var.aws_region
    kubernetes_version     = var.kubernetes_version
    ssm_join_command_param = var.ssm_join_command_param
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-${var.environment}-worker"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "workers" {
  name_prefix         = "${var.project}-${var.environment}-worker-"
  vpc_zone_identifier = var.subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_size
  health_check_type   = "EC2"
  target_group_arns   = var.target_group_arns

  launch_template {
    id      = aws_launch_template.workers.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-worker"
    propagate_at_launch = true
  }

  # Cluster Autoscaler auto-discovery — it finds ASGs via these tags rather
  # than needing them named/passed explicitly in its own config.
  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = false
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/${local.cluster_name}"
    value               = "owned"
    propagate_at_launch = false
  }

  lifecycle {
    create_before_destroy = true
  }
}
