# MultiCloud Forge

MultiCloud Forge is a multi-cloud infrastructure engineering project that provisions and validates serverless workloads across **Amazon Web Services (AWS)** and **Microsoft Azure**.

The project demonstrates Infrastructure as Code, cloud networking, serverless computing, CI/CD, federated identity, observability, automated testing, and multi-cloud resilience using a low-cost lab architecture.

## Architecture

```text
                         GitHub
                           |
                    GitHub Actions
                           |
                    OIDC Federation
                     /           \
                    v             v
                  AWS            Azure
                   |               |
             AWS Lambda      Azure Functions
                   |               |
             CloudWatch       App Insights
                   |          Log Analytics
                   |               |
                   +-------+-------+
                           |
                    Validation Layer
                           |
                +----------+----------+
                |          |          |
          Infrastructure  Health   Failover
              Tests       Tests     Tests
```

The project uses independent AWS and Azure infrastructure while applying comparable networking, compute, monitoring, identity, and validation patterns across both platforms.

For the complete design, see [`docs/architecture.md`](docs/architecture.md).

---

## Technology Stack

| Area | Technology |
|---|---|
| Infrastructure | Terraform 1.16.2 |
| CI/CD | GitHub Actions |
| AWS | VPC, Lambda, CloudWatch, IAM |
| Azure | VNet, Functions, Application Insights, Log Analytics |
| Authentication | GitHub OIDC |
| Application | Python |
| Testing | Python + Terraform validation |
| Local Administration | PowerShell, AWS CLI, Azure CLI |

---

## What the Project Implements

### Multi-Cloud Infrastructure

Terraform provisions networking and serverless infrastructure across AWS and Azure using reusable modules.

```text
AWS                           Azure
 |                              |
 +-- VPC                       +-- VNet
 +-- Public Subnet             +-- Application Subnet
 +-- Private Subnet            +-- Private Subnet
 +-- Security Groups           +-- NSGs
 +-- Lambda                    +-- Function App
 +-- CloudWatch                +-- Application Insights
                               +-- Log Analytics
```

AWS uses `ap-southeast-1`, while Azure uses `southeastasia`.

See [`docs/networking.md`](docs/networking.md) for the complete networking design.

### CI/CD

GitHub Actions performs:

```text
Terraform Checks
       |
Application Checks
       |
AWS + Azure OIDC Authentication
       |
Terraform Plan
       |
Terraform Apply
       |
Infrastructure Validation
       |
Application Validation
       |
Failover Testing
```

Pushes to `main` deploy the environment, while pull requests validate infrastructure without automatically applying changes.

See [`docs/deployment.md`](docs/deployment.md) for deployment instructions and pipeline details.

### Passwordless Cloud Authentication

GitHub Actions authenticates to both cloud providers using **OpenID Connect (OIDC)**.

This removes the need to store permanent AWS access keys or an Azure client secret inside the CI/CD pipeline.

AWS uses an IAM deployment role with `AssumeRoleWithWebIdentity`, while Azure uses Microsoft Entra workload identity federation.

See [`docs/security.md`](docs/security.md) for the complete security design.

### Observability

AWS uses:

```text
Lambda
  ↓
CloudWatch
  ↓
Metric Alarm
```

Azure uses:

```text
Azure Function
      ↓
Application Insights
      ↓
Log Analytics
      ↓
Scheduled Query Alert
```

Controlled `/fail` endpoints allow monitoring and alert behavior to be tested safely.

See [`docs/observability.md`](docs/observability.md) for monitoring implementation and validation.

### Automated Validation

Three validation layers are included:

```text
tests/
├── infrastructure/
│   └── test_terraform.py
├── connectivity/
│   └── test_health.py
└── failover/
    └── test_failover.py
```

They verify that expected infrastructure exists, AWS and Azure applications respond successfully, and the application-level failover logic behaves correctly.

### Multi-Cloud Resilience

AWS acts as the primary workload during the resilience simulation.

```text
AWS Healthy
    ↓
ACTIVE AWS
```

If AWS becomes unavailable:

```text
AWS Unavailable
      ↓
Check Azure
      ↓
Azure Healthy
      ↓
FAILOVER Azure
```

If both providers are unavailable, the test reports a critical multi-cloud outage.

This demonstrates **failover validation**, rather than production automatic traffic routing.

---

## Repository Structure

```text
multicloud-forge/
├── .github/
│   └── workflows/
├── application/
│   ├── aws-lambda/
│   └── azure-function/
├── diagrams/
├── docs/
├── terraform/
│   ├── environments/
│   └── modules/
└── tests/
    ├── connectivity/
    ├── failover/
    └── infrastructure/
```

---

## Documentation

Detailed engineering documentation is separated from this README.

| Document | Description |
|---|---|
| [Architecture](docs/architecture.md) | Overall multi-cloud architecture, design decisions, components, data flow, CI/CD and resilience |
| [Deployment](docs/deployment.md) | Local setup, Terraform deployment, GitHub Actions and OIDC configuration |
| [Networking](docs/networking.md) | AWS VPC, Azure VNet, subnets, routing and network security |
| [Security](docs/security.md) | IAM, RBAC, OIDC federation, managed identities and security boundaries |
| [Observability](docs/observability.md) | CloudWatch, Application Insights, Log Analytics and alerting |
| [Cost Analysis](docs/cost-analysis.md) | Cost-conscious architecture, service selection and FinOps considerations |

---

## Cost Target

The lab is designed around a target operating cost of:

```text
< US$10/month
```

The architecture favors serverless and consumption-based services rather than always-on virtual machines, managed databases, Kubernetes clusters, or other continuously billed infrastructure.

Actual cost depends on usage, account eligibility, region, telemetry, storage, and current provider pricing.

See [`docs/cost-analysis.md`](docs/cost-analysis.md) for the complete cost analysis.

---

## Project Status

```text
Terraform Infrastructure     Complete
AWS Deployment              Complete
Azure Deployment            Complete
GitHub Actions CI/CD        Complete
OIDC Authentication         Complete
Infrastructure Validation   Complete
Health Validation           Complete
AWS Monitoring              Complete
Azure Monitoring            Complete
Failover Simulation         Complete
Documentation               Complete
```

## Documentation Index

Start with the architecture overview and use the supporting documents for deeper implementation details:

**[Architecture](docs/architecture.md)** · **[Deployment](docs/deployment.md)** · **[Networking](docs/networking.md)** · **[Security](docs/security.md)** · **[Observability](docs/observability.md)** · **[Cost Analysis](docs/cost-analysis.md)**git