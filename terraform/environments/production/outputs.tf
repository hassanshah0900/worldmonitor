output "control_plane_public_ip" {
  value = module.control_plane.public_ip
}

output "control_plane_private_ip" {
  value = module.control_plane.private_ip
}

output "kubeconfig_ssm_parameter" {
  description = "Fetch with: aws ssm get-parameter --with-decryption --name <this> --query Parameter.Value --output text | base64 -d > kubeconfig"
  value       = local.ssm_kubeconfig_param
}

output "join_command_ssm_parameter" {
  value = local.ssm_join_command_param
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  description = "Point your app's DNS record here (CNAME/ALIAS)."
  value       = module.alb.dns_name
}
