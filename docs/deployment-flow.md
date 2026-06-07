# Deployment Flow Guide

This document explains how infrastructure and application delivery work together.

---

## 1. Infrastructure deployment flow

```text
Change Terraform code
      │
      ▼
Open Pull Request
      │
      ▼
Run terraform fmt / validate / plan
      │
      ▼
Review PR
      │
      ▼
Merge to main
      │
      ▼
Run terraform apply
      │
      ▼
AWS infrastructure updated
```

### What happens during infra apply?
Terraform may create or update:
- networking
- load balancing
- ECS service definition
- ECR repository
- IAM roles
- CloudWatch logging

---

## 2. Application deployment flow

```text
Push code to Weblacer_AI
      │
      ▼
GitHub Actions builds Docker image
      │
      ▼
Push image to ECR
      │
      ▼
Trigger ECS rolling deployment
      │
      ▼
New version becomes live behind ALB
```

---

## 3. Rolling deployment behavior

ECS service updates are designed to replace tasks gradually instead of dropping everything at once.

This reduces downtime risk and gives ALB health checks time to validate new containers.

---

## 4. Health checks

The ALB health check currently uses:
- path: `/`
- expected success codes: `200-399`

If your app does not respond correctly on `/`, update the Terraform variables.

---

## 5. First deployment checklist

Before first live deployment:
- verify Dockerfile works
- verify container port is correct
- verify health endpoint is correct
- verify ECR login works
- verify ECS service can pull from ECR
- verify logs appear in CloudWatch
- verify ALB DNS opens correctly
