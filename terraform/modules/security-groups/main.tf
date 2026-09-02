resource "aws_security_group" "control_plane" {
  name_prefix = "${var.project}-${var.environment}-cp-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-control-plane"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "workers" {
  name_prefix = "${var.project}-${var.environment}-workers-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-workers"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.project}-${var.environment}-alb-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project}-${var.environment}-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- control plane ingress ---

resource "aws_security_group_rule" "cp_ssh_from_admin" {
  type              = "ingress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.admin_cidrs
}

resource "aws_security_group_rule" "cp_api_from_admin" {
  type              = "ingress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = var.admin_cidrs
}

resource "aws_security_group_rule" "cp_api_from_workers" {
  type                     = "ingress"
  security_group_id        = aws_security_group.control_plane.id
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.workers.id
}

# etcd — only self-to-self matters with a single control-plane node, but kept
# so this SG doesn't need edits the day a second control-plane node is added.
resource "aws_security_group_rule" "cp_etcd_self" {
  type              = "ingress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "cp_kubelet_self" {
  type              = "ingress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  self              = true
}

# Flannel VXLAN backend, control-plane <-> workers and control-plane <-> control-plane
resource "aws_security_group_rule" "cp_vxlan_from_workers" {
  type                     = "ingress"
  security_group_id        = aws_security_group.control_plane.id
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = aws_security_group.workers.id
}

resource "aws_security_group_rule" "cp_vxlan_self" {
  type              = "ingress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "cp_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.control_plane.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# --- workers ingress ---

# Workers are private (no public IP) — admin_cidrs can't reach them directly.
# SSH via the control plane as a jump host: ssh -J ec2-user@<cp-public-ip> ec2-user@<worker-private-ip>
resource "aws_security_group_rule" "workers_ssh_from_cp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "workers_kubelet_from_cp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "workers_kubelet_self" {
  type              = "ingress"
  security_group_id = aws_security_group.workers.id
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  self              = true
}

resource "aws_security_group_rule" "workers_webhook_from_cp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 8443
  to_port                  = 8443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "workers_vxlan_from_cp" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 8472
  to_port                  = 8472
  protocol                 = "udp"
  source_security_group_id = aws_security_group.control_plane.id
}

resource "aws_security_group_rule" "workers_vxlan_self" {
  type              = "ingress"
  security_group_id = aws_security_group.workers.id
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = true
}

resource "aws_security_group_rule" "workers_nodeport_from_vpc" {
  type              = "ingress"
  security_group_id = aws_security_group.workers.id
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  description       = "NodePort range for internal/testing access"
}

# Dashboard traffic only reaches workers via the ALB. ingress-nginx runs as a
# hostPort/hostNetwork DaemonSet (no cloud LoadBalancer controller in a
# self-managed cluster), so the ALB targets node ports 80/443 directly.
resource "aws_security_group_rule" "workers_http_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "workers_https_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.workers.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "workers_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.workers.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# --- ALB ingress ---

resource "aws_security_group_rule" "alb_http_from_internet" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_https_from_internet" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
