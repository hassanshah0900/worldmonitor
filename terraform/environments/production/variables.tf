variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS region for the whole cluster. Must match the region of the AWS Secrets Manager secret named by secrets_manager_secret_name, and kubernetes/infrastructure/configs/secret-store/cluster-secret-store.yaml's spec.provider.aws.region."
}

variable "project" {
  type    = string
  default = "worldmonitor"
}

variable "environment" {
  type    = string
  default = "production"
}

variable "vpc_cidr" {
  type    = string
  default = "10.60.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.60.1.0/24", "10.60.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Must match length/order of public_subnet_cidrs and azs. Worker nodes live here."
  default     = ["10.60.11.0/24", "10.60.12.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Must match length/order of public_subnet_cidrs and private_subnet_cidrs, and be valid AZs for aws_region."
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH and reach the Kubernetes API (e.g. [\"203.0.113.4/32\"] for your own IP). Required, no default — never leave this at 0.0.0.0/0."
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair in this region."
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "pod_network_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "control_plane_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_min_size" {
  type    = number
  default = 1
}

variable "worker_max_size" {
  type    = number
  default = 3
}

variable "worker_desired_size" {
  type    = number
  default = 2
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM cert ARN for the ALB's HTTPS listener. Left empty, the ALB only serves HTTP:80 (no TLS at the edge)."
}

variable "secrets_manager_secret_name" {
  type        = string
  default     = "worldmonitor"
  description = "AWS Secrets Manager secret backing kubernetes/infrastructure/configs/secret-store/cluster-secret-store.yaml — also where control plane reads the GitHub PAT for flux bootstrap."
}

variable "github_token_secret_key" {
  type        = string
  default     = "GITHUB_PERSONAL_TOKEN"
  description = "Property name within secrets_manager_secret_name holding the GitHub PAT (repo scope) used once at boot for flux bootstrap."
}

variable "flux_version" {
  type        = string
  default     = "2.9.4"
  description = "Must match the version kubernetes/clusters/production/flux-system's manifests were generated from."
}

variable "flux_github_owner" {
  type    = string
  default = "hassanshah0900"
}

variable "flux_github_repo" {
  type    = string
  default = "worldmonitor"
}

variable "flux_github_branch" {
  type    = string
  default = "kubernetes"
}

variable "flux_github_path" {
  type    = string
  default = "./kubernetes/clusters/production"
}
