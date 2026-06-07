project                = "weblacer-ai"
environment            = "prod"
aws_region             = "us-east-1"
github_owner           = "Sujaltalreja04"
app_repo               = "Weblacer_AI"
infra_repo             = "Weblacer_AI_infra"

vpc_cidr               = "10.20.0.0/16"
availability_zones     = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs    = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidrs   = ["10.20.11.0/24", "10.20.12.0/24"]

container_name         = "weblacer-ai"
container_port         = 3000
health_check_path      = "/"

cpu                    = 512
memory                 = 1024
desired_count          = 1
log_retention_in_days  = 30

ecr_repository_name    = "weblacer-ai-prod"
enable_acm_placeholder = true
