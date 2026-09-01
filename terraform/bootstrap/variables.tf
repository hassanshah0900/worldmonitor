variable "aws_region" {
  description = "AWS region for the state bucket and lock table."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Short project name, used as a resource name prefix."
  type        = string
  default     = "worldmonitor"
}
