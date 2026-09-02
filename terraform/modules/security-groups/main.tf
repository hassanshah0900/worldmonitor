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

# --- workers ingress ---

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
# hostPort/hostNetwork DaemonSet (no AWS Load Balancer Controller here), so
# the ALB targets node ports 80/443 directly.
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
