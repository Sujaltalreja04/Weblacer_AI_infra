output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecr_repository_name" {
  value = module.ecr.repository_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}

output "ecs_service_name" {
  value = module.ecs.service_name
}

output "cloudwatch_log_group" {
  value = module.cloudwatch.log_group_name
}

output "github_actions_role_arn" {
  value = module.github_oidc.github_actions_role_arn
}

output "acm_note" {
  value = local.acm_status_note
}
