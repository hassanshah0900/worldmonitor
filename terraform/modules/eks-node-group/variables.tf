variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs — workers have no public IP."
}

variable "security_group_id" {
  type        = string
  description = "The 'workers' SG — ALB target rules, NodePort range, egress."
}

variable "cluster_security_group_id" {
  type        = string
  description = "EKS's own auto-managed cluster SG. A custom launch template's security groups replace, rather than add to, what EKS attaches by default, so this must be included explicitly for control-plane<->node traffic to work at all."
}

variable "key_name" {
  type = string
}

variable "target_group_arns" {
  type        = list(string)
  default     = []
  description = "ALB target group ARN(s) to attach the node group's underlying ASG to."
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
