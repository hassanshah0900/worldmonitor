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
