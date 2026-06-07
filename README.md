# Weblacer_AI_infra

Beautiful, practical, and production-minded infrastructure documentation for deploying **`Weblacer_AI`** on **AWS** using **Terraform** and **GitHub Actions**.

> This repository owns the **AWS infrastructure and infrastructure automation**.
> The application code lives separately in [`Sujaltalreja04/Weblacer_AI`](https://github.com/Sujaltalreja04/Weblacer_AI).

---

## Overview

This repo provisions and documents the production infrastructure for **Weblacer_AI** in:

- **AWS Region:** `us-east-1` (N. Virginia)
- **Environment:** `prod`
- **Compute:** ECS Fargate
- **Container Registry:** ECR
- **Ingress:** Application Load Balancer (ALB)
- **Networking:** VPC with public and private subnets
- **Logging:** CloudWatch Logs
- **Terraform State:** S3 + DynamoDB lock table
- **CI/CD:** GitHub Actions with AWS OIDC role assumption

---

## Repository Relationship

```text
┌───────────────────────────────┐        ┌────────────────────────────────┐
│  Weblacer_AI                  │        │  Weblacer_AI_infra             │
│  (application repository)     │        │  (infrastructure repository)   │
│                               │        │                                │
│  - app source code            │        │  - terraform modules           │
│  - Docker build               │        │  - env configuration           │
│  - app deployment workflow    │        │  - bootstrap backend           │
│                               │        │  - infra CI/CD workflows       │
└───────────────┬───────────────┘        └───────────────┬────────────────┘
                │                                        │
                └──────────────┬─────────────────────────┘
                               │
                               ▼
                     ┌───────────────────┐
                     │       AWS         │
                     │ ECS / ECR / ALB   │
                     │ VPC / IAM / Logs  │
                     └───────────────────┘
```

### In plain English

- **`Weblacer_AI`** = your product code.
- **`Weblacer_AI_infra`** = the AWS platform that runs it.
- App and infra are separated so teams can safely change infrastructure without mixing it with app features.

---

## Architecture Diagram

```text
                                      GitHub
                    ┌───────────────────────────────────────────┐
                    │                                           │
                    │  Weblacer_AI           Weblacer_AI_infra  │
                    │  App repo              Infra repo         │
                    │                                           │
                    └──────────────┬─────────────────────┬──────┘
                                   │                     │
                    app deploy workflow         terraform plan/apply
                                   │                     │
                                   ▼                     ▼
                          ┌─────────────────────────────────────┐
                          │     GitHub Actions + OIDC to AWS    │
                          └──────────────────┬──────────────────┘
                                             │
                                             ▼
┌────────────────────────────────────────────────────────────────────────────────────┐
│                                      AWS                                           │
│                                                                                    │
│   ┌────────────────────────────── VPC ───────────────────────────────────────────┐ │
│   │                                                                              │ │
│   │   Public Subnet A            Public Subnet B                                │ │
│   │   ┌───────────────┐         ┌───────────────┐                               │ │
│   │   │ ALB           │         │ ALB           │                               │ │
│   │   └──────┬────────┘         └───────────────┘                               │ │
│   │          │                                                                  │ │
│   │          ▼                                                                  │ │
│   │   Private Subnet A           Private Subnet B                               │ │
│   │   ┌───────────────┐         ┌───────────────┐                               │ │
│   │   │ ECS Task      │         │ ECS Task      │                               │ │
│   │   │ (Fargate)     │         │ (Fargate)     │                               │ │
│   │   └───────────────┘         └───────────────┘                               │ │
│   │                                                                              │ │
│   │   NAT Gateway in public subnet for outbound internet access                  │ │
│   └──────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                    │
│   ECR  <---- stores container images                                               │
│   CloudWatch Logs <---- stores application logs                                    │
│   IAM Roles <---- ECS execution/task roles + GitHub OIDC role                      │
│   S3 + DynamoDB <---- Terraform state + locking                                    │
└────────────────────────────────────────────────────────────────────────────────────┘
```

---

## What This Infrastructure Creates

### Core platform
- VPC
- 2 public subnets
- 2 private subnets
- Internet Gateway
- 1 NAT Gateway
- Route tables and associations

### Application runtime
- ECS Cluster
- ECS Task Definition
- ECS Fargate Service
- ECR Repository
- Application Load Balancer
- Target Group
- Security Groups
- CloudWatch Log Group

### Delivery / access
- IAM execution role for ECS tasks
- IAM task role for app runtime permissions
- GitHub Actions OIDC role for secure AWS access without static long-lived keys

### Terraform operations
- S3 bucket for remote state
- DynamoDB table for state locking

---

## Current Deployment Flow

### Infrastructure CI/CD flow

```text
Developer change in infra repo
          │
          ▼
Pull Request opened
          │
          ▼
GitHub Actions: terraform fmt / validate / plan
          │
          ▼
Review + merge to main
          │
          ▼
GitHub Actions: terraform apply
          │
          ▼
AWS infrastructure updated
```

### Application deployment flow

```text
Push to Weblacer_AI main branch
          │
          ▼
GitHub Actions builds Docker image
          │
          ▼
Image pushed to ECR
          │
          ▼
ECS service forced to redeploy
          │
          ▼
New containers start behind ALB
```

---

## Repository Structure

```text
Weblacer_AI_infra/
├── README.md
├── docs/
│   ├── architecture.md
│   ├── deployment-flow.md
│   └── operations.md
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   └── versions.tf
├── modules/
│   ├── alb/
│   ├── cloudwatch/
│   ├── ecr/
│   ├── ecs/
│   ├── github_oidc/
│   └── vpc/
├── environments/
│   └── prod/
│       ├── backend.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── terraform.tfvars
│       ├── variables.tf
│       └── versions.tf
└── .github/
    └── workflows/
        ├── terraform-plan.yml
        ├── terraform-apply.yml
        └── app-deploy.yml
```

---

## Prerequisites

Before using this repo, make sure you have:

### AWS prerequisites
- Access to the target AWS account
- Permissions for:
  - `iam:*`
  - `ecs:*`
  - `ecr:*`
  - `ec2:*`
  - `elasticloadbalancing:*`
  - `logs:*`
  - `s3:*`
  - `dynamodb:*`
  - `acm:*` (if HTTPS/domain is added later)

### Local tooling
- Terraform `>= 1.6.0`
- AWS CLI
- Docker
- Git

### GitHub prerequisites
- Admin/maintainer access to:
  - [`Sujaltalreja04/Weblacer_AI`](https://github.com/Sujaltalreja04/Weblacer_AI)
  - [`Sujaltalreja04/Weblacer_AI_infra`](https://github.com/Sujaltalreja04/Weblacer_AI_infra)
- Ability to add GitHub Actions secrets

---

## Quick Start

## 1. Bootstrap Terraform remote state

This creates:
- S3 bucket for Terraform state
- DynamoDB table for locking

```bash
cd bootstrap
terraform init
terraform apply -auto-approve
```

After bootstrap, note the outputs and update `environments/prod/backend.tf` if required.

---

## 2. Configure backend state

In `environments/prod/backend.tf`, replace:

```hcl
bucket = "weblacer-ai-prod-tfstate-REPLACE_ACCOUNT_ID"
```

with the actual AWS account id-based bucket name created during bootstrap.

---

## 3. Plan and apply the prod infrastructure

```bash
cd environments/prod
terraform init
terraform plan
terraform apply
```

---

## 4. Capture important Terraform outputs

Useful outputs include:
- `alb_dns_name`
- `ecr_repository_name`
- `ecr_repository_url`
- `ecs_cluster_name`
- `ecs_service_name`
- `github_actions_role_arn`

Example:

```bash
terraform output
```

---

## 5. Push the first application image

From the app repository:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t weblacer-ai:latest .
docker tag weblacer-ai:latest <ecr-repo-url>:latest
docker push <ecr-repo-url>:latest
```

Then redeploy ECS or let GitHub Actions handle it.

---

## Configuration Defaults

Current defaults in `environments/prod/terraform.tfvars`:

- **Region:** `us-east-1`
- **Environment:** `prod`
- **Container name:** `weblacer-ai`
- **Container port:** `3000`
- **Health check path:** `/`
- **CPU:** `512`
- **Memory:** `1024`
- **Desired count:** `1`

If your app uses another port or health endpoint, update those values before deploying.

---

## GitHub Actions Setup

### Infra repo secrets
Set these in **`Weblacer_AI_infra`** GitHub Actions secrets:

- `AWS_ROLE_ARN` = Terraform output `github_actions_role_arn`
- `AWS_REGION` = `us-east-1`

### App repo secrets / variables
Set these in **`Weblacer_AI`**:

- `AWS_ROLE_ARN`
- `AWS_REGION`
- `ECR_REPOSITORY`
- `ECS_CLUSTER_NAME`
- `ECS_SERVICE_NAME`
- `CONTAINER_NAME`

---

## Important Note About ACM / HTTPS

You asked for **Route53 + ACM**, but also said **no custom domain**.

That means:
- a real public ACM certificate cannot be fully activated yet
- Route53 also cannot be meaningfully configured yet
- the current setup should be considered **HTTP-first** until a domain exists

### Today
- ALB serves traffic on **HTTP 80**
- ACM is treated as a **future extension path**

### Later, when a domain is available
You can extend this to:
- request ACM certificate
- validate with DNS
- create Route53 alias record
- add ALB HTTPS listener on port 443

---

## Operational Notes

### Scaling
You can later add:
- ECS Service Auto Scaling
- CPU or memory-based scaling policies

### Security
You can later improve with:
- AWS WAF on ALB
- Secrets Manager / SSM Parameter Store for app secrets
- tighter IAM least-privilege policies
- HTTPS with ACM + domain

### Cost awareness
Current baseline includes:
- NAT Gateway
- ALB
- ECS Fargate tasks
- CloudWatch logs

These are solid for production, but keep an eye on AWS costs.

---

## Suggested Team Usage Model

- **Infra changes** go through PRs in this repo
- **Application changes** go through PRs in the app repo
- Infrastructure is applied from GitHub Actions after review
- App deployments happen independently from image builds

This separation helps keep deployment and infrastructure safer and easier to understand.

---

## Documentation Index

Additional docs in this repo:

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/deployment-flow.md`](docs/deployment-flow.md)
- [`docs/operations.md`](docs/operations.md)

---

## Next Recommended Steps

1. Merge the infrastructure PRs into `main`
2. Run bootstrap Terraform
3. Update backend state configuration
4. Apply the prod environment
5. Add GitHub Actions secrets
6. Add/verify the app deployment workflow in `Weblacer_AI`
7. Push the first container image
8. Validate ALB health checks and logs

---

## Maintainer Note

This documentation update was generated by **Aiden** to make the infrastructure easier for engineers, reviewers, and future maintainers to understand.
