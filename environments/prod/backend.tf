terraform {
  backend "s3" {
    bucket         = "weblacer-ai-prod-tfstate-REPLACE_ACCOUNT_ID"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "weblacer-ai-prod-terraform-locks"
    encrypt        = true
  }
}
