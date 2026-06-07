data "aws_caller_identity" "current" {}

module "vpc" {
  source               = "../../modules/vpc"
  project              = var.project
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "cloudwatch" {
  source            = "../../modules/cloudwatch"
  project           = var.project
  environment       = var.environment
  retention_in_days = var.log_retention_in_days
}

module "ecr" {
  source          = "../../modules/ecr"
  project         = var.project
  environment     = var.environment
  repository_name = var.ecr_repository_name
}

module "alb" {
  source            = "../../modules/alb"
  project           = var.project
  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  container_port    = var.container_port
  health_check_path = var.health_check_path
}

module "ecs" {
  source                = "../../modules/ecs"
  project               = var.project
  environment           = var.environment
  aws_region            = var.aws_region
  private_subnet_ids    = module.vpc.private_subnet_ids
  vpc_id                = module.vpc.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_name        = var.container_name
  container_port        = var.container_port
  cpu                   = var.cpu
  memory                = var.memory
  desired_count         = var.desired_count
  ecr_repository_url    = module.ecr.repository_url
  log_group_name        = module.cloudwatch.log_group_name
}

module "github_oidc" {
  source       = "../../modules/github_oidc"
  project      = var.project
  environment  = var.environment
  github_owner = var.github_owner
  github_repo  = var.app_repo
  infra_repo   = var.infra_repo
  aws_region   = var.aws_region
}

# ACM note:
# Public ACM certs require a real domain + validation.
# Since custom_domain = no, we cannot create a usable validated public cert.
# This placeholder local value preserves the architecture intent without causing failed issuance.
locals {
  acm_status_note = var.enable_acm_placeholder ? "ACM requested as architecture option but not provisioned because no custom domain was provided." : "ACM disabled."
}
