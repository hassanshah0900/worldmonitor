variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC's CIDR block, used to scope NodePort access to same-VPC traffic."
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH (22) and the Kubernetes API (6443). No default on purpose — must be set explicitly, never left open to 0.0.0.0/0."
}
