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

output "aws_load_balancer_controller_role_arn" {
  description = "Copy into kubernetes/infrastructure/controllers/releases.yaml's aws-load-balancer-controller HelmRelease as serviceAccount.annotations['eks.amazonaws.com/role-arn'] — Flux can't read Terraform state."
  value       = module.eks_cluster.aws_load_balancer_controller_role_arn
}

output "vpc_id" {
  description = "Copy into kubernetes/infrastructure/controllers/releases.yaml's aws-load-balancer-controller HelmRelease as values.vpcId — Flux can't read Terraform state."
  value       = module.network.vpc_id
}
