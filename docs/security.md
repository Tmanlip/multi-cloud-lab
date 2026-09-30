# MultiCloud Forge Security

## 1. Overview

MultiCloud Forge applies security controls across infrastructure
provisioning, CI/CD authentication, cloud identity, network
segmentation, application transport, Terraform state, and source
control.

The project intentionally favors short-lived federated CI/CD credentials
over permanent cloud secrets.

The implemented security model includes:

-   GitHub Actions OIDC authentication to AWS
-   Microsoft Entra workload identity federation for Azure
-   AWS IAM roles and policies
-   Azure RBAC
-   Azure Function system-assigned managed identity
-   HTTPS enforcement
-   AWS Security Groups
-   Azure Network Security Groups
-   Remote Terraform state
-   Source-control exclusions for local secrets and generated files
-   Controlled observability failure endpoints
-   Infrastructure and application validation

------------------------------------------------------------------------

## 2. Security Goals

The design aims to:

1.  Minimize long-lived CI/CD credentials.
2.  Restrict cloud permissions to required deployment actions.
3.  Keep infrastructure configuration reproducible and reviewable.
4.  Separate network security boundaries.
5.  Keep sensitive local files out of Git.
6.  Encrypt application transport using HTTPS.
7.  Validate security-relevant infrastructure automatically.
8.  Avoid claiming controls that have not been implemented.

------------------------------------------------------------------------

## 3. CI/CD Identity Architecture

The CI/CD identity flow is:

``` text
GitHub Actions
      |
      | OIDC token
      |
      +-----------------------+
      |                       |
      v                       v
     AWS                     Azure
      |                       |
      v                       v
IAM OIDC Provider       Microsoft Entra ID
      |                       |
      v                       v
IAM Role                Federated Credential
      |                       |
      v                       v
AWS Permissions          Azure RBAC
```

GitHub Actions does not require a permanent AWS access key or Azure
client secret for the deployed CI/CD authentication path.

------------------------------------------------------------------------

## 4. GitHub Actions Permissions

The workflow grants the GitHub job permission to request an OIDC token:

``` yaml
permissions:
  id-token: write
  contents: read
```

`id-token: write` allows GitHub Actions to request the short-lived
identity token required for federation.

`contents: read` allows the workflow to check out and read the
repository.

These permissions are preferable to unnecessarily broad repository
permissions.

------------------------------------------------------------------------

## 5. AWS OIDC Federation

AWS trusts GitHub's OIDC issuer:

``` text
https://token.actions.githubusercontent.com
```

The CI/CD workflow assumes a dedicated deployment role using:

``` text
sts:AssumeRoleWithWebIdentity
```

The deployed role used by the pipeline is:

``` text
multicloud-forge-github-actions
```

The trust relationship should remain restricted to the intended GitHub
repository and branch/ref conditions.

------------------------------------------------------------------------

## 6. AWS Deployment Authorization

The GitHub Actions AWS role requires only the actions necessary to
inspect and manage the resources controlled by Terraform.

During implementation, missing permissions were surfaced by Terraform
rather than bypassed. Examples included read access needed during Lambda
refresh and write access required to create CloudWatch alarms.

This is a useful least-privilege workflow:

``` text
Terraform operation
      |
      v
AccessDenied
      |
      v
Identify required API action
      |
      v
Add narrowly scoped permission
      |
      v
Retry and validate
```

The objective is to expand permissions only when a legitimate Terraform
operation requires them.

------------------------------------------------------------------------

## 7. AWS Lambda Execution Role

The Lambda workload uses its own execution role rather than the GitHub
deployment identity.

This separates:

``` text
CI/CD identity
     !=
Runtime identity
```

The Lambda execution role contains the permissions required by the
function at runtime, including logging permissions for CloudWatch.

Keeping deployment and runtime identities separate reduces unnecessary
privilege sharing.

------------------------------------------------------------------------

## 8. Azure Workload Identity Federation

Azure CI/CD authentication uses Microsoft Entra workload identity
federation.

The GitHub token issuer is:

``` text
https://token.actions.githubusercontent.com
```

The expected audience is:

``` text
api://AzureADTokenExchange
```

GitHub repository variables supply identifiers such as:

``` text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

No Azure client secret is required by the workflow.

------------------------------------------------------------------------

## 9. Azure RBAC

The federated Azure identity receives Azure permissions through RBAC.

Terraform operations must have access to the resources they manage and
any linked resources they need to inspect.

A concrete example occurred when the scheduled query alert targeted the
managed Log Analytics workspace. The deployment identity could create
the alert resource but initially lacked:

``` text
Microsoft.OperationalInsights/workspaces/read
```

on the linked workspace.

The required read permission was then added and the deployment
succeeded.

This demonstrates why linked-resource permissions must be considered in
least-privilege designs.

------------------------------------------------------------------------

## 10. Azure Managed Identity

The Azure Function App is configured with:

``` hcl
identity {
  type = "SystemAssigned"
}
```

This creates a workload identity tied to the Function App.

The identity provides a secure foundation for future access to Azure
services without embedding credentials in application code.

The current documentation should not imply that Key Vault or another
protected service is already consumed through this identity unless that
integration is added to Terraform.

------------------------------------------------------------------------

## 11. Network Security

AWS and Azure use separate provider-native network controls.

AWS:

``` text
Security Groups
```

Azure:

``` text
Network Security Groups
```

The environments also separate application/public-oriented and private
subnets.

The network modules remain the source of truth for exact rules.

See:

``` text
docs/networking.md
```

for the network architecture and segmentation model.

------------------------------------------------------------------------

## 12. Transport Security

The Azure Function App is configured with:

``` hcl
https_only = true
```

The health and failure endpoints are therefore accessed through HTTPS.

AWS Lambda Function URLs are likewise consumed through HTTPS endpoints.

Application validation uses HTTPS URLs for both providers.

------------------------------------------------------------------------

## 13. Azure Storage Security

The Azure Function requires a storage account as part of its runtime
architecture.

The Terraform configuration includes:

``` hcl
min_tls_version = "TLS1_2"
allow_nested_items_to_be_public = false
```

These controls establish a TLS baseline and prevent nested storage items
from being made publicly accessible through that setting.

The Function App uses the storage account required for Azure Functions
operation.

------------------------------------------------------------------------

## 14. Terraform State Security

Terraform uses a remote AzureRM backend.

Remote state provides a centralized state location for local and CI/CD
Terraform operations.

State must be treated as sensitive because Terraform state can contain
resource metadata and, depending on resource types, potentially
sensitive values.

Security practices include:

-   Do not commit Terraform state to Git.
-   Restrict access to the backend storage.
-   Avoid simultaneous applies.
-   Keep backend authorization separate from source code.
-   Review outputs before marking them non-sensitive.

------------------------------------------------------------------------

## 15. Source-Control Hygiene

Local secrets and generated artifacts should remain outside version
control.

Relevant exclusions include:

``` gitignore
**/.terraform/*
*.tfplan
terraform.tfvars

*accessKeys*.csv
*credentials*.csv

__pycache__/
*.pyc

application/azure-function/.python_packages/
```

Local PowerShell history can be retained on the developer machine for
project traceability while remaining ignored by Git.

The `.terraform.lock.hcl` file is intentionally suitable for source
control because it records provider dependency selections and checksums.

------------------------------------------------------------------------

## 16. Local Credentials vs CI/CD Credentials

Local administration and CI/CD use different authentication models.

``` text
Local administration
    |
    +--> AWS CLI credentials/profile where required
    +--> Azure CLI interactive authentication

GitHub Actions
    |
    +--> AWS OIDC federation
    +--> Azure workload identity federation
```

This allows local development without forcing permanent cloud keys into
GitHub Actions.

Local credential files must never be committed to the repository.

------------------------------------------------------------------------

## 17. Application Security Boundary

The project intentionally keeps the serverless application small.

The public endpoints return operational metadata such as:

-   status
-   provider
-   region
-   environment
-   timestamp
-   application version

They do not need database credentials or application secrets for the
current workload.

This reduces the secret-management requirements of the lab.

------------------------------------------------------------------------

## 18. Controlled Failure Endpoints

Both cloud implementations include a controlled failure path for
observability validation.

AWS uses an intentional runtime failure.

Azure exposes:

``` text
/api/fail
```

and intentionally returns HTTP 500.

These routes exist only to test:

``` text
failure
  |
  v
telemetry
  |
  v
monitoring
  |
  v
alert
```

They should not expose credentials, stack secrets, or sensitive user
information.

------------------------------------------------------------------------

## 19. Monitoring as a Security/Operations Control

AWS errors are monitored through a CloudWatch metric alarm.

Azure HTTP 5xx requests are monitored using Application Insights, Log
Analytics, and an Azure Monitor scheduled query rule.

The Azure path was validated through an actual controlled HTTP 500 and a
fired `Sev2` Log Alerts V2 alert.

Monitoring does not replace preventive controls, but it provides
detection and operational evidence when failures occur.

------------------------------------------------------------------------

## 20. Infrastructure Validation

The infrastructure test is:

``` text
tests/infrastructure/test_terraform.py
```

It validates the Terraform configuration and checks for expected
resource types in Terraform state.

Security-relevant validated resources include:

``` text
aws_security_group
aws_cloudwatch_log_group
aws_cloudwatch_metric_alarm

azurerm_network_security_group
azurerm_application_insights
azurerm_monitor_scheduled_query_rules_alert_v2
```

The test is a configuration/deployment quality gate rather than a
penetration test.

------------------------------------------------------------------------

## 21. CI/CD Quality Gates

The GitHub Actions workflow performs:

``` text
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

It also compiles the AWS and Azure Python application files before
deployment.

Separate authentication jobs verify AWS and Azure OIDC access before the
Terraform deployment job runs.

After deployment, health and resilience tests provide additional
validation.

------------------------------------------------------------------------

## 22. Least-Privilege Lessons

The project demonstrated several practical least-privilege lessons:

-   Terraform refresh requires read permissions as well as create/update
    permissions.
-   Monitoring resources may require permissions on linked telemetry
    resources.
-   Deployment identities and workload identities should be separate.
-   A failed deployment caused by missing authorization is preferable to
    granting broad permissions pre-emptively.
-   Permissions should be expanded from observed requirements and then
    revalidated.

------------------------------------------------------------------------

## 23. Controls Not Currently Claimed

The original project design considered additional security capabilities.
They should remain future work unless explicitly implemented.

The current project does not claim completed deployment of:

-   Azure Key Vault secret consumption
-   AWS Secrets Manager integration
-   AWS S3 application storage
-   Azure Blob application storage
-   Automated Checkov/TFLint security scanning
-   Web Application Firewall
-   Managed cloud firewall
-   Private endpoints for the serverless applications
-   Production-grade SIEM integration

Keeping these separate from implemented controls makes the portfolio
documentation more credible.

------------------------------------------------------------------------

## 24. Security Responsibility Boundaries

MultiCloud Forge is a portfolio lab rather than a production security
baseline.

Cloud providers secure the underlying managed service infrastructure,
while this project remains responsible for configuration such as:

``` text
Identity
Authorization
Network policy
Terraform state
Application settings
Source-control hygiene
Monitoring configuration
```

A production system would require additional controls based on its data
classification, threat model, compliance requirements, and user
population.

------------------------------------------------------------------------

## 25. Future Security Improvements

Potential improvements include:

-   Add IaC security scanning to pull requests.
-   Add explicit branch protection and deployment environments.
-   Add notification action groups/topics for monitoring alerts.
-   Add Key Vault or Secrets Manager only when the workload needs
    secrets.
-   Add private service connectivity.
-   Add network flow logging.
-   Add automated IAM/RBAC policy checks.
-   Add dependency and source-code security scanning.
-   Add security-focused infrastructure tests.
-   Document a lightweight threat model.

These should be implemented incrementally rather than documented as
existing controls before deployment.
