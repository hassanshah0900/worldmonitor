locals {
  cluster_name = "${var.project}-${var.environment}"
}

module "network" {
  source = "../../modules/network"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
  cluster_name         = local.cluster_name
}

module "security_groups" {
  source = "../../modules/security-groups"

  project     = var.project
  environment = var.environment
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "eks_cluster" {
  source = "../../modules/eks-cluster"

  project                     = var.project
  environment                 = var.environment
  aws_region                  = var.aws_region
  kubernetes_version          = var.kubernetes_version
  subnet_ids                  = concat(module.network.public_subnet_ids, module.network.private_subnet_ids)
  admin_cidrs                 = var.admin_cidrs
  secrets_manager_secret_name = var.secrets_manager_secret_name
}

module "eks_node_group" {
  source = "../../modules/eks-node-group"

  project                   = var.project
  environment               = var.environment
  cluster_name              = module.eks_cluster.cluster_name
  instance_type             = var.worker_instance_type
  subnet_ids                = module.network.private_subnet_ids
  security_group_id         = module.security_groups.workers_sg_id
  cluster_security_group_id = module.eks_cluster.cluster_security_group_id
  key_name                  = var.key_name
  min_size                  = var.worker_min_size
  max_size                  = var.worker_max_size
  desired_size              = var.worker_desired_size
}

# Requires the flux-system namespace to already exist (created by `flux bootstrap`).
resource "kubernetes_config_map" "flux_substitutions" {
  metadata {
    name      = "terraform-outputs"
    namespace = "flux-system"
  }

  data = {
    CLUSTER_AUTOSCALER_ROLE_ARN           = module.eks_cluster.cluster_autoscaler_role_arn
    EXTERNAL_SECRETS_ROLE_ARN             = module.eks_cluster.external_secrets_role_arn
    AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN = module.eks_cluster.aws_load_balancer_controller_role_arn
    VPC_ID                                = module.network.vpc_id
  }
}
