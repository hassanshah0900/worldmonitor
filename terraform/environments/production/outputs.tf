output "eks_cluster_name" {
  description = "Fetch kubeconfig with: aws eks update-kubeconfig --name <this> --region <aws_region>"
  value       = module.eks_cluster.cluster_name
}

output "cluster_autoscaler_role_arn" {
  description = "Copy into kubernetes/infrastructure/controllers/releases.yaml's cluster-autoscaler HelmRelease as rbac.serviceAccount.annotations['eks.amazonaws.com/role-arn'] — Flux can't read Terraform state."
  value       = module.eks_cluster.cluster_autoscaler_role_arn
}

output "external_secrets_role_arn" {
  description = "Copy into kubernetes/infrastructure/controllers/releases.yaml's external-secrets HelmRelease as serviceAccount.annotations['eks.amazonaws.com/role-arn'] — Flux can't read Terraform state."
  value       = module.eks_cluster.external_secrets_role_arn
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns_name" {
  description = "Point your app's DNS record here (CNAME/ALIAS)."
  value       = module.alb.dns_name
}
