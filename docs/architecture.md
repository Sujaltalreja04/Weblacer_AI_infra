# Architecture Guide

This document explains the `Weblacer_AI_infra` architecture in a clean, human-readable way.

---

## High-level intent

The goal of this repository is to provide a production-friendly AWS platform for `Weblacer_AI` using Terraform.

It separates:
- **application delivery** from
- **infrastructure ownership**

That means app engineers can ship code while platform/infrastructure changes stay controlled and auditable.

---

## High-level architecture

```text
Internet
   │
   ▼
Application Load Balancer (public)
   │
   ▼
ECS Fargate Service (private subnets)
   │
   ├── pulls images from ECR
   ├── sends logs to CloudWatch
   └── uses IAM roles for AWS access
```

---

## Why ECS Fargate?

ECS Fargate is a good fit here because it gives:
- container-based deployment
- managed compute without EC2 node management
- simpler scaling path than self-managed Docker hosts
- clean integration with ECR, ALB, IAM, and CloudWatch

---

## Networking model

### Public subnets
Used for:
- ALB
- NAT Gateway

### Private subnets
Used for:
- ECS tasks

This is a standard pattern because it keeps app containers off the public internet while still allowing inbound traffic through the load balancer.

---

## Traffic flow

```text
User request
   │
   ▼
ALB (port 80)
   │
   ▼
Target Group
   │
   ▼
ECS task container (port 3000 by default)
```

---

## State and automation model

Terraform state is stored remotely in:
- **S3** for the state file
- **DynamoDB** for state locking

This avoids local-state drift and supports safer team collaboration.

---

## GitHub to AWS trust model

GitHub Actions uses **OIDC** to assume an AWS IAM role.

That means:
- no long-lived AWS keys in GitHub
- safer CI/CD authentication
- easier secret management

---

## Current known limitation

The stack does **not** enable real HTTPS yet because there is no custom domain configured.

To enable HTTPS later, add:
- domain name
- ACM certificate
- validation DNS records
- ALB HTTPS listener
- Route53 alias record

---

## Future improvements

Recommended future enhancements:
- ECS auto scaling
- WAF
- Secrets Manager / SSM
- blue/green deployments
- HTTPS with ACM
- multi-environment expansion (`dev`, `staging`, `prod`)
