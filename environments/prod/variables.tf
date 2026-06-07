variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_owner" {
  type        = string
  description = "GitHub owner"
}

variable "app_repo" {
  type        = string
  description = "Application repository name"
}

variable "infra_repo" {
  type        = string
  description = "Infrastructure repository name"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR"
}

variable "availability_zones" {
  type        = list(string)
  description = "AZs"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "container_name" {
  type        = string
  description = "Container name"
}

variable "container_port" {
  type        = number
  description = "Application container port"
}

variable "health_check_path" {
  type        = string
  description = "ALB health check path"
}

variable "cpu" {
  type        = number
  description = "Task CPU"
}

variable "memory" {
  type        = number
  description = "Task memory"
}

variable "desired_count" {
  type        = number
  description = "Desired ECS tasks"
}

variable "log_retention_in_days" {
  type        = number
  description = "CloudWatch retention"
}

variable "ecr_repository_name" {
  type        = string
  description = "ECR repository name"
}

variable "enable_acm_placeholder" {
  type        = bool
  description = "Create optional ACM placeholder resources pattern"
  default     = true
}
