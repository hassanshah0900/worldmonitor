variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair."
}

variable "aws_region" {
  type = string
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes minor version, e.g. 1.30, must match a pkgs.k8s.io stable channel."
}

variable "pod_network_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "ssm_join_command_param" {
  type        = string
  description = "SSM parameter name the control plane writes the kubeadm join command to."
}

variable "ssm_kubeconfig_param" {
  type        = string
  description = "SSM parameter name the control plane writes the base64 admin kubeconfig to."
}

variable "secrets_manager_secret_name" {
  type        = string
  description = "AWS Secrets Manager secret holding app config, including the GitHub token control-plane reads once at boot to bootstrap Flux."
}

variable "github_token_secret_key" {
  type        = string
  description = "Property name within secrets_manager_secret_name holding the GitHub PAT."
}

variable "flux_version" {
  type        = string
  description = "Must match the version the flux-system manifests in the repo (kubernetes/clusters/production/flux-system) were generated from."
}

variable "flux_github_owner" {
  type = string
}

variable "flux_github_repo" {
  type = string
}

variable "flux_github_branch" {
  type = string
}

variable "flux_github_path" {
  type        = string
  description = "Path flux bootstrap reconciles, relative to the repo root."
}
