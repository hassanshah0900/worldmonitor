output "eks_cluster_name" {
  description = "Fetch kubeconfig with: aws eks update-kubeconfig --name <this> --region <aws_region>"
  value       = module.eks_cluster.cluster_name
}

output "cluster_autoscaler_role_arn" {
  description = "Also written to the flux-system/terraform-outputs ConfigMap, which Flux substitutes into cluster-autoscaler's HelmRelease values."
  value       = module.eks_cluster.cluster_autoscaler_role_arn
}

output "external_secrets_role_arn" {
  description = "Also written to the flux-system/terraform-outputs ConfigMap, which Flux substitutes into external-secrets' HelmRelease values."
  value       = module.eks_cluster.external_secrets_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "Also written to the flux-system/terraform-outputs ConfigMap, which Flux substitutes into aws-load-balancer-controller's HelmRelease values."
  value       = module.eks_cluster.aws_load_balancer_controller_role_arn
}

output "vpc_id" {
  description = "Also written to the flux-system/terraform-outputs ConfigMap, which Flux substitutes into aws-load-balancer-controller's HelmRelease values."
  value       = module.network.vpc_id
}
