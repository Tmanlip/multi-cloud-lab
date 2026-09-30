# MultiCloud Forge Architecture

## 1. Overview

MultiCloud Forge is a multi-cloud infrastructure engineering project
that provisions, deploys, monitors, and validates cloud infrastructure
across Amazon Web Services (AWS) and Microsoft Azure.

The project uses Terraform as the Infrastructure as Code (IaC) layer and
GitHub Actions as the CI/CD platform. GitHub Actions authenticates to
both cloud providers using OpenID Connect (OIDC), avoiding long-lived
cloud credentials in the CI/CD environment.

The current development environment contains:

-   AWS networking infrastructure
-   Azure networking infrastructure
-   AWS Lambda serverless application
-   Azure Functions serverless application
-   AWS CloudWatch monitoring and alerting
-   Azure Application Insights and Log Analytics monitoring
-   Multi-cloud health validation
-   Infrastructure validation
-   Automated failover simulation
-   GitHub Actions CI/CD deployment and validation

------------------------------------------------------------------------

## 2. Architecture Goals

The architecture was designed around the following objectives:

1.  Provision infrastructure consistently using Terraform.
2.  Demonstrate comparable workloads across AWS and Azure.
3.  Avoid long-lived CI/CD cloud credentials through OIDC federation.
4.  Implement health monitoring and failure detection on both providers.
5.  Validate infrastructure and application availability automatically
    after deployment.
6.  Demonstrate multi-cloud failover decision logic without requiring a
    paid global traffic-management service.
7.  Keep the environment suitable for a low-cost portfolio lab.
8.  Maintain modular infrastructure that can be extended with additional
    cloud services later.

------------------------------------------------------------------------

## 3. Repository Architecture

The project separates infrastructure, application code, tests,
documentation, diagrams, and CI/CD configuration.

``` text
multicloud-forge/
|
+-- .github/
|   +-- workflows/
|       +-- terraform.yml
|
+-- application/
|   +-- aws-lambda/
|   |   +-- lambda_function.py
|   |
|   +-- azure-function/
|       +-- function_app.py
|       +-- host.json
|       +-- requirements.txt
|
+-- diagrams/
|   +-- architecture.png
|   +-- architecture.txt
|   +-- network.txt
|
+-- docs/
|   +-- architecture.md
|   +-- cost-analysis.md
|   +-- deployment.md
|   +-- networking.md
|   +-- observability.md
|   +-- security.md
|
+-- terraform/
|   +-- environments/
|   |   +-- dev/
|   |
|   +-- modules/
|       +-- aws-network/
|       +-- aws-lambda/
|       +-- azure-network/
|       +-- azure-function/
|
+-- tests/
    +-- connectivity/
    |   +-- test_health.py
    |
    +-- failover/
    |   +-- test_failover.py
    |
    +-- infrastructure/
        +-- test_terraform.py
```

------------------------------------------------------------------------

## 4. High-Level Architecture

The project deploys equivalent serverless workloads into AWS and Azure
while Terraform manages the underlying infrastructure.

``` text
                         GitHub Repository
                                |
                                v
                         GitHub Actions
                                |
                      OIDC Authentication
                         /             \
                        /               \
                       v                 v
                     AWS               Azure
                      |                  |
                 Terraform          Terraform
                      |                  |
             +--------+-------+   +------+--------+
             |                |   |               |
             v                v   v               v
           AWS VPC          Lambda Azure VNet   Function App
             |                |   |               |
      Public + Private     Function             /api/health
         Subnets             URL                /api/fail
                              |                   |
                           /health                |
                           /fail                  |
                              |                   |
                              v                   v
                         CloudWatch        Application Insights
                              |                   |
                         Metric Alarm       Log Analytics
                                                  |
                                             Log Query Alert
```

The two cloud environments are independently deployed but expose
comparable application health functionality.

------------------------------------------------------------------------

## 5. Terraform Architecture

Terraform is the control plane for the infrastructure.

The development environment is defined under:

``` text
terraform/environments/dev/
```

The environment composes reusable Terraform modules rather than defining
every resource directly in a single configuration.

Conceptually:

``` text
dev environment
      |
      +-- aws-network
      |
      +-- aws-lambda
      |
      +-- azure-network
      |
      +-- azure-function
```

This separation provides clearer ownership of resources and allows
individual infrastructure components to evolve independently.

------------------------------------------------------------------------

## 6. AWS Architecture

The AWS environment consists of a networking layer and serverless
application layer.

### Networking

The AWS networking module provisions resources including:

-   VPC
-   Public subnet
-   Private subnet
-   Internet Gateway
-   Route tables
-   Route table associations
-   Security groups

The development VPC uses:

``` text
10.20.0.0/16
```

with separate public and private address spaces.

The network architecture provides a foundation for future workloads even
though the current Lambda health workload does not require deployment
inside the VPC.

### Serverless Application

The AWS workload runs on AWS Lambda.

The application exposes a Lambda Function URL that provides:

``` text
/health
/fail
```

`/health` returns workload metadata and is used for automated health
validation.

`/fail` intentionally produces an application failure for controlled
observability testing.

The health response includes information such as:

``` text
status
provider
region
environment
timestamp
version
```

------------------------------------------------------------------------

## 7. Azure Architecture

The Azure environment similarly separates networking and serverless
application resources.

### Networking

The Azure networking module provisions:

-   Resource Group
-   Virtual Network
-   Application subnet
-   Private subnet
-   Network Security Groups
-   NSG-to-subnet associations

The network is designed as the Azure equivalent of the AWS network
foundation.

As with the AWS Lambda workload, the current Azure Function does not
depend on private VNet integration.

### Serverless Application

The Azure workload runs as a Linux Azure Function App using Python.

Supporting resources include:

-   Azure Storage Account
-   Azure Service Plan
-   Application Insights
-   System-assigned managed identity

The application exposes:

``` text
/api/health
/api/fail
```

The `/api/health` endpoint performs the same logical role as the AWS
`/health` endpoint.

The `/api/fail` endpoint generates a controlled HTTP 500 response for
observability testing.

------------------------------------------------------------------------

## 8. Multi-Cloud Application Model

The AWS and Azure workloads intentionally expose similar health
information.

AWS reports:

``` text
provider: aws
region: ap-southeast-1
environment: dev
version: <application-version>
```

Azure reports:

``` text
provider: azure
region: southeastasia
environment: dev
version: <application-version>
```

This provides a simple common workload that can be used to validate
deployment consistency between providers.

Application versions are controlled through Terraform using the
`APP_VERSION` environment setting.

A version update therefore provides a simple way to verify that CI/CD
successfully updates workloads on both clouds.

------------------------------------------------------------------------

## 9. Terraform State Architecture

Terraform uses remote state rather than relying on local state as the
authoritative source.

The backend is configured using AzureRM.

Conceptually:

``` text
Developer / GitHub Actions
           |
           v
       Terraform
           |
           v
   AzureRM Backend
           |
           v
   Remote State File
```

Remote state provides a shared infrastructure state for local
administration and GitHub Actions.

State locking prevents concurrent Terraform operations from modifying
the same infrastructure state simultaneously.

------------------------------------------------------------------------

## 10. CI/CD Architecture

GitHub Actions provides the automated deployment pipeline.

The workflow is defined in:

``` text
.github/workflows/terraform.yml
```

The main workflow stages are:

``` text
Git Push / Pull Request
          |
          +----------------------+
          |                      |
          v                      v
   Terraform Checks      Application Checks
          |                      |
          +----------+-----------+
                     |
              +------+------+
              |             |
              v             v
          AWS OIDC      Azure OIDC
              |             |
              +------+------+
                     |
                     v
              Terraform Plan
                     |
             push to main only
                     |
                     v
              Terraform Apply
                     |
                     v
         Infrastructure Validation
                     |
                     v
             Endpoint Discovery
                     |
                     v
              Health Validation
                     |
                     v
             Failover Validation
```

Pull requests can perform validation and planning without automatically
applying infrastructure changes.

Pushes to `main` can deploy the approved infrastructure automatically.

------------------------------------------------------------------------

## 11. OIDC Authentication Architecture

The CI/CD pipeline avoids permanent AWS and Azure secrets by using
GitHub's OIDC identity token.

### AWS

GitHub Actions requests an OIDC token from:

``` text
https://token.actions.githubusercontent.com
```

AWS IAM trusts the configured GitHub repository and branch.

The workflow then performs:

``` text
sts:AssumeRoleWithWebIdentity
```

to obtain temporary AWS credentials.

The trust path is:

``` text
GitHub Actions
      |
      v
GitHub OIDC Token
      |
      v
AWS IAM OIDC Provider
      |
      v
IAM Deployment Role
      |
      v
Temporary AWS Credentials
```

### Azure

Azure uses Microsoft Entra workload identity federation.

The federated credential validates:

-   GitHub token issuer
-   Repository/branch subject
-   `api://AzureADTokenExchange` audience

The authentication path is:

``` text
GitHub Actions
      |
      v
GitHub OIDC Token
      |
      v
Microsoft Entra ID
      |
      v
Federated Identity Credential
      |
      v
Azure Service Principal
      |
      v
Azure Resource Manager
```

Neither deployment path requires a permanent cloud client secret in
GitHub Actions.

------------------------------------------------------------------------

## 12. Observability Architecture

Each cloud uses its native monitoring platform.

### AWS

``` text
Lambda
   |
   +--> CloudWatch Logs
   |
   +--> AWS/Lambda Errors
              |
              v
       CloudWatch Alarm
```

Terraform creates a CloudWatch metric alarm that monitors the Lambda
`Errors` metric.

The alarm triggers when at least one Lambda execution error occurs
within the configured evaluation period.

### Azure

``` text
Azure Function
      |
      v
Application Insights
      |
      v
Log Analytics Workspace
      |
      v
AppRequests
      |
      v
Scheduled Query Alert
```

The Azure alert searches request telemetry for HTTP 5xx responses.

The query is:

``` kusto
AppRequests
| where ResultCode startswith "5"
| summarize ErrorCount = count()
```

An alert is generated when at least one matching server error is
observed during the configured evaluation window.

------------------------------------------------------------------------

## 13. Controlled Failure Testing

Both workloads provide controlled mechanisms for testing observability.

AWS:

``` text
/fail
```

Azure:

``` text
/api/fail
```

These routes are intended only for lab validation.

The failure workflow is:

``` text
Controlled request
       |
       v
Application failure
       |
       v
Cloud telemetry
       |
       v
Monitoring rule
       |
       v
Alert condition
```

This allows monitoring to be tested deliberately instead of relying on
accidental failures.

------------------------------------------------------------------------

## 14. Infrastructure Validation

The project includes an infrastructure validation script:

``` text
tests/infrastructure/test_terraform.py
```

The script validates Terraform and inspects the deployed Terraform
state.

It checks for expected AWS resources including:

-   VPC
-   Subnets
-   Internet Gateway
-   Route tables
-   Security groups
-   Lambda
-   Lambda Function URL
-   CloudWatch Log Group
-   CloudWatch Metric Alarm

It also checks expected Azure resources including:

-   Resource Group
-   Virtual Network
-   Subnets
-   Network Security Groups
-   Storage Account
-   Service Plan
-   Function App
-   Application Insights
-   Scheduled Query Alert

Required Terraform outputs are also validated.

This answers:

``` text
Did Terraform deploy the expected architecture?
```

------------------------------------------------------------------------

## 15. Health Validation

Application availability is tested through:

``` text
tests/connectivity/test_health.py
```

The script calls the health endpoints for both providers.

Expected behavior:

``` text
AWS health endpoint
       |
       +--> HTTP success
       +--> provider = aws

Azure health endpoint
       |
       +--> HTTP success
       +--> provider = azure
```

A successful run confirms that both workloads are operational after
deployment.

------------------------------------------------------------------------

## 16. Failover Simulation

MultiCloud Forge includes:

``` text
tests/failover/test_failover.py
```

The current implementation demonstrates failover **decision logic**
rather than production traffic routing.

The selection process is:

``` text
Check AWS
    |
    +-- Healthy --------> ACTIVE AWS
    |
    +-- Unhealthy
           |
           v
       Check Azure
           |
           +-- Healthy --> FAILOVER Azure
           |
           +-- Unhealthy
                  |
                  v
               CRITICAL
```

For example, when an invalid AWS endpoint is supplied while Azure
remains healthy:

``` text
[UNHEALTHY] AWS

AWS unavailable. Attempting failover...

[HEALTHY] Azure

[FAILOVER] Azure
```

This demonstrates application-level provider selection behavior.

It does **not** currently provide automatic DNS, load-balancer, or
production traffic redirection between AWS and Azure.

A future implementation could integrate DNS health-based routing or
another global traffic-management layer.

------------------------------------------------------------------------

## 17. Validation Layers

The project deliberately separates three types of validation.

``` text
Infrastructure Validation
          |
          | Did Terraform deploy the expected resources?
          v
     test_terraform.py


Connectivity Validation
          |
          | Are both workloads responding correctly?
          v
      test_health.py


Resilience Validation
          |
          | Can the application logic select Azure
          | when AWS is unavailable?
          v
     test_failover.py
```

This separation makes failures easier to identify and demonstrates
different levels of infrastructure validation.

------------------------------------------------------------------------

## 18. Security Architecture

The architecture incorporates several security controls:

-   GitHub Actions OIDC federation
-   Temporary AWS credentials
-   Azure workload identity federation
-   No permanent CI/CD client secrets
-   AWS IAM role-based deployment permissions
-   Azure RBAC
-   HTTPS-only Azure Function access
-   Azure Function managed identity
-   AWS security groups
-   Azure Network Security Groups
-   Remote Terraform state
-   Sensitive local Terraform files excluded from source control

Additional implementation details are documented in:

``` text
docs/security.md
```

------------------------------------------------------------------------

## 19. Cost Architecture

The project is intentionally designed as a low-cost lab.

The primary application workloads use serverless compute:

``` text
AWS
└── Lambda

Azure
└── Functions Consumption Plan
```

This avoids maintaining continuously running virtual machines for the
health workloads.

Networking infrastructure is kept primarily as an architecture and IaC
demonstration foundation.

Detailed cost considerations are documented in:

``` text
docs/cost-analysis.md
```

------------------------------------------------------------------------

## 20. Current Architecture Scope

The current implementation demonstrates:

-   Multi-cloud Infrastructure as Code
-   AWS and Azure networking
-   Modular Terraform architecture
-   Serverless compute
-   Remote Terraform state
-   GitHub Actions CI/CD
-   AWS OIDC federation
-   Azure workload identity federation
-   Infrastructure validation
-   Multi-cloud health validation
-   Cloud-native observability
-   Controlled failure testing
-   Alert validation
-   Failover decision logic

The project intentionally does not claim production-grade automatic
cross-cloud traffic failover.

Instead, it establishes the infrastructure, monitoring, CI/CD, and
resilience-validation foundations required for a more advanced
multi-cloud architecture.

------------------------------------------------------------------------

## 21. Future Architecture

Possible extensions include:

``` text
                         Global Traffic Layer
                              /        \
                             /          \
                           AWS          Azure
                            |             |
                         Lambda       Function App
                            |             |
                         Metrics       Telemetry
                             \           /
                              \         /
                           Unified Dashboard
```

Potential future improvements include:

-   DNS-based health routing
-   Automatic cross-cloud traffic failover
-   Centralized dashboards
-   Alert notification action groups
-   Latency monitoring
-   Availability probes
-   Additional infrastructure tests
-   Production and staging Terraform environments
-   Policy-as-code
-   Security scanning in CI/CD
-   Cost monitoring and budget alerts
