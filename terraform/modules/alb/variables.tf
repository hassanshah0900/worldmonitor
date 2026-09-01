variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM cert ARN for the HTTPS listener. Left empty, only HTTP:80 is created (no TLS at the edge yet — ingress-nginx can still do its own TLS if you're not ready to attach a cert here)."
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "Path the ALB health-checks on port 80. Adjust once the app exposes a real health endpoint."
}
