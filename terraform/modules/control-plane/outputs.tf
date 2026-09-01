output "public_ip" {
  value = aws_instance.control_plane.public_ip
}

output "private_ip" {
  value = aws_instance.control_plane.private_ip
}

output "instance_id" {
  value = aws_instance.control_plane.id
}
