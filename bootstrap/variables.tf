variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "weblacer-ai"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "prod"
}
