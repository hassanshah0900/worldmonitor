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
  description = "One CIDR per AZ. Holds the control plane and the ALB — anything that needs a public IP."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "One CIDR per AZ, same order as public_subnet_cidrs. Holds the worker nodes — no public IPs, egress only via NAT Gateway."
}

variable "azs" {
  type        = list(string)
  description = "Availability zones, same length/order as public_subnet_cidrs and private_subnet_cidrs."
}
