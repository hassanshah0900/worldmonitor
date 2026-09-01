output "control_plane_sg_id" {
  value = aws_security_group.control_plane.id
}

output "workers_sg_id" {
  value = aws_security_group.workers.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}
