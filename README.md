# Weblacer_AI_infra

Terraform infrastructure for deploying `Weblacer_AI` to AWS in **us-east-1** using:

- ECS Fargate
- ECR
- ALB
- VPC with public/private subnets
- CloudWatch Logs
- IAM
- ACM certificate resource enabled (not attached to ALB because no custom domain is configured)
- Terraform remote state with S3 + DynamoDB
- GitHub Actions CI/CD

## Repos

- App repo: `Sujaltalreja04/Weblacer_AI`
- Infra repo: `Sujaltalreja04/Weblacer_AI_infra`

## Region / Environment

- Region: `us-east-1`
- Environment: `prod`

---

## 1) Bootstrap remote state

The bootstrap stack creates:
- S3 bucket for Terraform state
- DynamoDB table for state locking

Run:

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

After apply, copy the output values into `environments/prod/backend.tf` if you change names.

---

## 2) Deploy infrastructure

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

---

## 3) Build and push first app image

This stack expects a container image in ECR.

After infra apply, get the repo URL:

```bash
terraform output ecr_repository_url
```

Then from your app repo build and push:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t weblacer-ai:latest .
docker tag weblacer-ai:latest <ecr-repo-url>:latest
docker push <ecr-repo-url>:latest
```

Then force a new deployment or let GitHub Actions do it.

---

## 4) Notes on ACM

ACM is included, but because there is **no custom domain** and **no Route53 record**, the certificate is **not bound to the ALB listener**.
AWS ACM public certificates require DNS validation for real HTTPS custom domains.

So currently:
- ALB serves **HTTP on port 80**
- ACM resource is prepared only as an optional extension path

If later you add a domain, you can:
- request/validate ACM cert for that domain
- add HTTPS listener on 443
- attach cert to ALB
- create Route53 alias record

---

## 5) GitHub Actions secrets / variables

For this repo (`Weblacer_AI_infra`) set:
- `AWS_ROLE_ARN` = output `github_actions_role_arn`
- `AWS_REGION` = `us-east-1`

For app repo (`Weblacer_AI`) set:
- `AWS_ROLE_ARN` = same role or a separate app deploy role
- `AWS_REGION` = `us-east-1`
- `ECR_REPOSITORY` = output `ecr_repository_name`
- `ECS_CLUSTER_NAME` = output `ecs_cluster_name`
- `ECS_SERVICE_NAME` = output `ecs_service_name`
- `CONTAINER_NAME` = `weblacer-ai`

---

## 6) Suggested next step

After provisioning, update your app Dockerfile if needed and confirm:
- container port
- health endpoint
- CPU/memory requirements
- environment variables / secrets

Defaults in this stack:
- container port: `3000`
- health check path: `/`
- ECS CPU: `512`
- ECS memory: `1024`

Adjust in `terraform.tfvars` if your app needs something else.
