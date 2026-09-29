# MultiCloud Forge Deployment Guide

## 1. Overview

MultiCloud Forge uses Terraform 1.16.2 and GitHub Actions to deploy infrastructure and serverless workloads across AWS and Microsoft Azure.

The deployment process consists of:

1. Local environment preparation
2. Cloud authentication
3. Terraform initialization
4. Infrastructure deployment
5. Serverless application deployment
6. GitHub Actions OIDC configuration
7. Automated CI/CD deployment
8. Post-deployment validation

The development environment is located under:

`terraform/environments/dev`

---

## 2. Prerequisites

The following tools are required for local administration and testing:

- Git
- Terraform
- AWS CLI
- Azure CLI
- Python
- Azure Functions Core Tools

Verify the installations:

```powershell
git --version
terraform version
aws --version
az version
python --version
func --version