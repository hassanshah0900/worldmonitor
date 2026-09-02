variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per AZ. Holds the ALB and EKS control-plane ENIs."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per AZ, same order as public_subnet_cidrs. Holds the worker nodes — no public IPs, egress only via NAT Gateway."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones, same length/order as public_subnet_cidrs and private_subnet_cidrs."
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name, used for the kubernetes.io/cluster/<name> subnet discovery tag."
}
