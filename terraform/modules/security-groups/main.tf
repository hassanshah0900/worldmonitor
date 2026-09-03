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

resource "aws_security_group_rule" "workers_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.workers.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
