resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.project}-${var.environment}"
  retention_in_days = var.retention_in_days

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
