locals {
  cluster_autoscaler_tags = {
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "node" {
  name_prefix        = "${var.project}-${var.environment}-node-"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_launch_template" "node" {
  name_prefix   = "${var.project}-${var.environment}-node-"
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.security_group_id, var.cluster_security_group_id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project}-${var.environment}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name           = var.cluster_name
  node_group_name_prefix = "${var.project}-${var.environment}-"
  node_role_arn          = aws_iam_role.node.arn
  subnet_ids             = var.subnet_ids

  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  tags = local.cluster_autoscaler_tags

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
