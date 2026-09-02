output "workers_sg_id" {
  value = aws_security_group.workers.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
