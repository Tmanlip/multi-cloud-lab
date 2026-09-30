# MultiCloud Forge Deployment Guide

## 1. Overview

MultiCloud Forge uses Terraform 1.16.2 and GitHub Actions to deploy
infrastructure and serverless workloads across AWS and Microsoft Azure.

The deployment process consists of:

1.  Local environment preparation
2.  Cloud authentication
3.  Terraform initialization
4.  Infrastructure deployment
5.  Serverless application deployment
6.  GitHub Actions OIDC configuration
7.  Automated CI/CD deployment
8.  Post-deployment validation

The development environment is located under:

``` text
terraform/environments/dev
```

------------------------------------------------------------------------

## 2. Prerequisites

The following tools are required for local administration and testing:

-   Git
-   Terraform
-   AWS CLI
-   Azure CLI
-   Python
-   Azure Functions Core Tools

Verify the installations:

``` powershell
git --version
terraform version
aws --version
az version
python --version
func --version
```

------------------------------------------------------------------------

## 3. Repository Setup

Clone the repository and enter the project directory:

``` powershell
git clone <repository-url>
cd multicloud-forge
```

The main Terraform development environment is:

``` text
terraform/environments/dev
```

------------------------------------------------------------------------

## 4. Terraform Configuration

Environment-specific Terraform configuration is stored under:

``` text
terraform/environments/dev/
```

Important files include:

``` text
backend.tf
locals.tf
main.tf
outputs.tf
providers.tf
terraform.tfvars.example
variables.tf
versions.tf
```

Create your local variable file from the example:

``` powershell
Copy-Item `
  terraform\environments\dev\terraform.tfvars.example `
  terraform\environments\dev\terraform.tfvars
```

Populate the required values locally.

`terraform.tfvars` should not be committed to source control.

------------------------------------------------------------------------

## 5. AWS Authentication for Local Deployment

Configure an AWS CLI profile with the credentials required for
Terraform.

Verify the authenticated identity:

``` powershell
aws sts get-caller-identity
```

If a named profile is used, configure the appropriate profile before
running Terraform.

Long-lived AWS credentials are used only for local administration where
necessary.

GitHub Actions uses OIDC instead.

------------------------------------------------------------------------

## 6. Azure Authentication for Local Deployment

Authenticate using the Azure CLI:

``` powershell
az login
```

Verify the active subscription:

``` powershell
az account show --output table
```

If required, select the appropriate subscription:

``` powershell
az account set --subscription "<subscription-id>"
```

------------------------------------------------------------------------

## 7. Terraform Remote State

Terraform uses an AzureRM backend for remote state storage.

From:

``` text
terraform/environments/dev
```

initialize Terraform:

``` powershell
terraform init
```

When migrating an existing local state to the remote backend:

``` powershell
terraform init -migrate-state
```

Terraform state locking protects the state from concurrent modification.

------------------------------------------------------------------------

## 8. Terraform Validation

Before deploying infrastructure, format and validate the Terraform
configuration:

``` powershell
terraform fmt -recursive
terraform validate
```

Generate an execution plan:

``` powershell
terraform plan
```

Review the plan before applying changes.

------------------------------------------------------------------------

## 9. Infrastructure Deployment

The environment composes the following Terraform modules:

### AWS

``` text
terraform/modules/aws-network
terraform/modules/aws-lambda
```

### Azure

``` text
terraform/modules/azure-network
terraform/modules/azure-function
```

For an initial local deployment:

``` powershell
terraform apply
```

Terraform will display the proposed changes before requesting
confirmation.

For established deployments, infrastructure changes should normally be
deployed through the GitHub Actions pipeline.

------------------------------------------------------------------------

## 10. AWS Application

The AWS serverless application is located at:

``` text
application/aws-lambda/lambda_function.py
```

Terraform packages and deploys the application to AWS Lambda.

The application provides:

``` text
/health
/fail
```

`/health` is used for deployment validation.

`/fail` is an intentional failure endpoint used for observability
testing.

------------------------------------------------------------------------

## 11. Azure Application

The Azure Function application is located at:

``` text
application/azure-function/
```

Important files include:

``` text
function_app.py
host.json
requirements.txt
```

The Function App provides:

``` text
/api/health
/api/fail
```

The health endpoint is used for automated deployment validation.

The failure endpoint is used only for controlled observability testing.

------------------------------------------------------------------------

## 12. GitHub Actions Authentication

GitHub Actions uses OIDC federation for both cloud providers.

This avoids storing permanent AWS access keys or Azure client secrets in
the CI/CD pipeline.

### AWS OIDC

AWS contains an OIDC identity provider for:

``` text
https://token.actions.githubusercontent.com
```

A dedicated IAM role trusts the GitHub repository and permitted branch.

GitHub Actions assumes the role using:

``` text
sts:AssumeRoleWithWebIdentity
```

The workflow requires:

``` yaml
permissions:
  id-token: write
  contents: read
```

The AWS role ARN and region are configured through GitHub repository
variables.

------------------------------------------------------------------------

## 13. Azure Workload Identity Federation

Azure authentication uses Microsoft Entra workload identity federation.

The federated credential uses GitHub's token issuer:

``` text
https://token.actions.githubusercontent.com
```

with the audience:

``` text
api://AzureADTokenExchange
```

The federated subject is restricted to the configured GitHub repository
and branch.

GitHub repository variables provide values such as:

``` text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

No Azure client secret is required by the workflow.

------------------------------------------------------------------------

## 14. GitHub Actions Pipeline

The deployment workflow is located at:

``` text
.github/workflows/terraform.yml
```

The pipeline runs on pull requests and pushes targeting `main`.

Major jobs include:

``` text
Terraform Checks
Application Checks
AWS OIDC Authentication
Azure OIDC Authentication
Terraform Plan and Deploy
```

### Terraform Checks

The pipeline performs:

``` text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

### Application Checks

Python compilation checks validate the serverless source files.

### Authentication Tests

Separate jobs verify that GitHub Actions can authenticate successfully
to AWS and Azure.

### Deployment

After the prerequisite jobs succeed:

``` text
terraform init
terraform plan
terraform apply
```

`terraform apply` executes automatically only for pushes to `main`.

Pull requests therefore validate and plan infrastructure without
automatically applying changes.

------------------------------------------------------------------------

## 15. Terraform Variables in CI/CD

Required Terraform variables are passed using the `TF_VAR_` environment
variable convention.

Examples include:

``` text
TF_VAR_azure_subscription_id
TF_VAR_azure_function_app_name
TF_VAR_azure_function_storage_name
```

Cloud authentication variables are supplied separately through
repository variables.

Sensitive credentials should not be committed to Terraform variable
files.

------------------------------------------------------------------------

## 16. Post-Deployment Endpoint Discovery

After Terraform successfully applies the infrastructure, GitHub Actions
retrieves the deployed endpoints using Terraform outputs.

Conceptually:

``` text
terraform output
       |
       +---- AWS Lambda Function URL
       |
       +---- Azure Function health URL
```

These values are then passed to the automated validation scripts.

------------------------------------------------------------------------

## 17. Multi-Cloud Health Validation

The health test is located at:

``` text
tests/connectivity/test_health.py
```

The pipeline invokes the test against both deployed workloads.

A successful deployment produces results equivalent to:

``` text
Testing AWS
[PASS] Endpoint healthy

Testing Azure
[PASS] Endpoint healthy

[PASS] Multi-cloud health validation successful.
```

This ensures infrastructure deployment alone is not treated as
sufficient proof of application availability.

------------------------------------------------------------------------

## 18. Resilience Validation

After health validation, the CI/CD pipeline executes:

``` text
tests/failover/test_failover.py
```

The pipeline verifies:

### Primary operation

``` text
AWS healthy
Azure healthy

Result:
ACTIVE AWS
```

### AWS failure simulation

``` text
AWS unavailable
Azure healthy

Result:
FAILOVER Azure
```

### Total outage simulation

``` text
AWS unavailable
Azure unavailable

Result:
CRITICAL
```

The total-outage test expects the failover program to return a non-zero
exit code. The CI/CD wrapper treats the expected error condition as a
successful test.

------------------------------------------------------------------------

## 19. Deployment Flow

The complete deployment path is:

``` text
Developer
    |
    v
Git Commit / Push
    |
    v
GitHub Actions
    |
    +--> Terraform Checks
    |
    +--> Application Checks
    |
    +--> AWS OIDC Authentication
    |
    +--> Azure OIDC Authentication
    |
    v
Terraform Plan
    |
    v
Terraform Apply
    |
    +--> AWS
    |     +--> Networking
    |     +--> Lambda
    |     +--> Monitoring
    |
    +--> Azure
          +--> Networking
          +--> Function App
          +--> Monitoring
    |
    v
Health Validation
    |
    v
Failover Validation
    |
    v
Deployment Complete
```

------------------------------------------------------------------------

## 20. Safe Change Workflow

For infrastructure changes, use:

``` powershell
terraform fmt -recursive
terraform validate
terraform plan
```

Review the plan carefully.

Then commit the change:

``` powershell
git status
git diff
git add .
git commit -m "<description>"
git push origin main
```

GitHub Actions then performs the authenticated deployment.

Avoid running simultaneous local and CI/CD Terraform applies because
both operate on the same remote state.

------------------------------------------------------------------------

## 21. Destroying the Lab

When the environment is no longer required, review the destruction plan
first:

``` powershell
terraform plan -destroy
```

Then:

``` powershell
terraform destroy
```

Destruction should be performed carefully because shared backend
resources or manually configured identity resources may have different
lifecycles from the Terraform-managed application infrastructure.

------------------------------------------------------------------------

## 22. Deployment Security Considerations

The deployment architecture follows several security practices:

-   GitHub Actions uses OIDC rather than permanent cloud credentials.
-   Terraform state is stored remotely.
-   GitHub identity trust is restricted by repository/branch.
-   AWS IAM permissions are scoped to the deployment requirements.
-   Azure RBAC permissions are granted according to required resources.
-   HTTPS is enforced for the Azure Function.
-   Sensitive local Terraform variable files are excluded from Git.
-   Health and failure endpoints contain no credentials or sensitive
    application data.
