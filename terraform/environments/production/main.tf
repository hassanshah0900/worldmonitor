locals {
  ssm_join_command_param = "/${var.project}/${var.environment}/k8s-join-command"
  ssm_kubeconfig_param   = "/${var.project}/${var.environment}/kubeconfig"
}

module "network" {
  source = "../../modules/network"

  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs
}

module "security_groups" {
  source = "../../modules/security-groups"

  project     = var.project
  environment = var.environment
  vpc_id      = module.network.vpc_id
  vpc_cidr    = var.vpc_cidr
  admin_cidrs = var.admin_cidrs
}

module "control_plane" {
  source = "../../modules/control-plane"

  project                     = var.project
  environment                 = var.environment
  aws_region                  = var.aws_region
  instance_type               = var.control_plane_instance_type
  subnet_id                   = module.network.public_subnet_ids[0]
  security_group_id           = module.security_groups.control_plane_sg_id
  key_name                    = var.key_name
  kubernetes_version          = var.kubernetes_version
  pod_network_cidr            = var.pod_network_cidr
  ssm_join_command_param      = local.ssm_join_command_param
  ssm_kubeconfig_param        = local.ssm_kubeconfig_param
  secrets_manager_secret_name = var.secrets_manager_secret_name
  github_token_secret_key     = var.github_token_secret_key
  flux_version                = var.flux_version
  flux_github_owner           = var.flux_github_owner
  flux_github_repo            = var.flux_github_repo
  flux_github_branch          = var.flux_github_branch
  flux_github_path            = var.flux_github_path
}

module "alb" {
  source = "../../modules/alb"

  project              = var.project
  environment          = var.environment
  vpc_id               = module.network.vpc_id
  public_subnet_ids    = module.network.public_subnet_ids
  security_group_id    = module.security_groups.alb_sg_id
  acm_certificate_arn  = var.acm_certificate_arn
}

module "workers" {
  source = "../../modules/workers"

  project                     = var.project
  environment                 = var.environment
  aws_region                  = var.aws_region
  instance_type               = var.worker_instance_type
  subnet_ids                  = module.network.private_subnet_ids
  security_group_id           = module.security_groups.workers_sg_id
  key_name                    = var.key_name
  kubernetes_version          = var.kubernetes_version
  ssm_join_command_param      = local.ssm_join_command_param
  min_size                    = var.worker_min_size
  max_size                    = var.worker_max_size
  desired_size                = var.worker_desired_size
  target_group_arns           = [module.alb.target_group_arn]
  secrets_manager_secret_name = var.secrets_manager_secret_name

  depends_on = [module.control_plane]
}
