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
