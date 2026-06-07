# Operations Guide

This document helps operators and maintainers run the platform smoothly.

---

## Routine operations

### View Terraform outputs
```bash
cd environments/prod
terraform output
```

### Run a manual plan
```bash
cd environments/prod
terraform plan
```

### Apply changes manually
```bash
cd environments/prod
terraform apply
```

---

## Observability

### Where logs go
Application logs are sent to CloudWatch Logs.

Look for the log group named like:

```text
/ecs/weblacer-ai-prod
```

### What to check during incidents
- ALB target health
- ECS service events
- ECS task status
- CloudWatch logs
- ECR image tags used in deployment

---

## Common failure cases

### 1. ALB health checks fail
Possible reasons:
- wrong container port
- wrong health endpoint
- app not starting correctly
- app binding only to localhost instead of `0.0.0.0`

### 2. ECS task cannot pull image
Possible reasons:
- image not pushed to ECR
- wrong repository URL
- wrong task execution role permissions

### 3. Terraform backend init fails
Possible reasons:
- backend bucket name not updated with real account id
- bootstrap was not applied
- insufficient S3/DynamoDB permissions

### 4. GitHub Actions cannot assume AWS role
Possible reasons:
- wrong `AWS_ROLE_ARN`
- OIDC trust policy mismatch
- workflow running from an unexpected repo or branch pattern

---

## Recommended hardening later
- move app secrets to AWS Secrets Manager or SSM Parameter Store
- tighten IAM permissions from broad access to least privilege
- add HTTPS and domain
- add autoscaling
- add alerting and dashboards
- add backup / disaster recovery notes

---

## Owner checklist

When handing this repo to a new engineer, make sure they know:
- where the app repo is
- how Terraform backend works
- where AWS logs live
- how GitHub Actions authenticates to AWS
- what values must be updated for new environments
