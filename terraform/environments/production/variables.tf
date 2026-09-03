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
  default = ["10.60.1.0/24", "10.60.2.0/24", "10.60.3.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Must match length/order of public_subnet_cidrs and azs. Worker nodes live here."
  default     = ["10.60.11.0/24", "10.60.12.0/24", "10.60.13.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "Must match length/order of public_subnet_cidrs and private_subnet_cidrs, and be valid AZs for aws_region."
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the EKS cluster's public API endpoint (e.g. [\"203.0.113.4/32\"] for your own IP). Required, no default — never leave this at 0.0.0.0/0."
}

variable "key_name" {
  type        = string
  description = "Name of an existing EC2 key pair in this region."
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"
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
  description = "AWS Secrets Manager secret backing kubernetes/infrastructure/configs/secret-store/cluster-secret-store.yaml, read via IRSA."
}
