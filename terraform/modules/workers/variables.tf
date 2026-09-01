variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs — workers have no public IP."
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "ALB target group ARN(s) the ASG registers instances with."
}

variable "security_group_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "ssm_join_command_param" {
  type = string
}

variable "secrets_manager_secret_name" {
  type        = string
  description = "AWS Secrets Manager secret the external-secrets ClusterSecretStore reads from — workers need read access since that's where its pods run."
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "desired_size" {
  type = number
}
