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
  ssm_param_arns = [
    "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_join_command_param}",
    "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_kubeconfig_param}",
  ]
  # "-??????" matches Secrets Manager's random 6-char ARN suffix without
  # needing to know it ahead of time.
  secrets_manager_secret_arn = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.secrets_manager_secret_name}-??????"
}

data "aws_iam_policy_document" "control_plane_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "control_plane" {
  name_prefix        = "${var.project}-${var.environment}-cp-"
  assume_role_policy = data.aws_iam_policy_document.control_plane_assume_role.json
}

data "aws_iam_policy_document" "control_plane_ssm" {
  statement {
    effect    = "Allow"
    actions   = ["ssm:PutParameter", "ssm:GetParameter"]
    resources = local.ssm_param_arns
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = [data.aws_kms_alias.ssm.target_key_arn]
  }
}

resource "aws_iam_role_policy" "control_plane_ssm" {
  name   = "ssm-write-join-params"
  role   = aws_iam_role.control_plane.id
  policy = data.aws_iam_policy_document.control_plane_ssm.json
}

# Used once at boot to fetch the GitHub PAT for `flux bootstrap` — that PAT
# only authenticates the one-time GitHub API call that installs a deploy
# key; it's never written to disk or stored in the cluster afterward.
data "aws_iam_policy_document" "control_plane_secrets_manager" {
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.secrets_manager_secret_arn]
  }
}

resource "aws_iam_role_policy" "control_plane_secrets_manager" {
  name   = "secrets-manager-read"
  role   = aws_iam_role.control_plane.id
  policy = data.aws_iam_policy_document.control_plane_secrets_manager.json
}

resource "aws_iam_instance_profile" "control_plane" {
  name_prefix = "${var.project}-${var.environment}-cp-"
  role        = aws_iam_role.control_plane.name
}

resource "aws_instance" "control_plane" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.control_plane.name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/templates/user-data.sh.tpl", {
    aws_region                  = var.aws_region
    kubernetes_version          = var.kubernetes_version
    pod_network_cidr            = var.pod_network_cidr
    ssm_join_command_param      = var.ssm_join_command_param
    ssm_kubeconfig_param        = var.ssm_kubeconfig_param
    secrets_manager_secret_name = var.secrets_manager_secret_name
    github_token_secret_key     = var.github_token_secret_key
    flux_version                = var.flux_version
    flux_github_owner           = var.flux_github_owner
    flux_github_repo            = var.flux_github_repo
    flux_github_branch          = var.flux_github_branch
    flux_github_path            = var.flux_github_path
  })

  tags = {
    Name = "${var.project}-${var.environment}-control-plane"
  }
}
