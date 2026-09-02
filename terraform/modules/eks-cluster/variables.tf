variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "All subnets (public + private) the control plane's ENIs may use."
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the EKS API's public endpoint."
}

variable "aws_region" {
  type = string
}

variable "secrets_manager_secret_name" {
  type        = string
  description = "AWS Secrets Manager secret external-secrets reads from, via IRSA."
}
