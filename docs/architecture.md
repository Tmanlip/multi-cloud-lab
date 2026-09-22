# MultiCloud Forge — Architecture

## 1. Overview

MultiCloud Forge is a portfolio-focused multi-cloud Infrastructure as
Code project deployed across Microsoft Azure and Amazon Web Services.

The infrastructure is provisioned using Terraform and designed around
four primary engineering objectives:

- Reproducibility
- Security
- Automation
- Cost efficiency

The project deploys comparable workloads to Azure and AWS while using
cloud-native services from each provider.

The application workload is intentionally minimal so that the primary
focus remains on cloud architecture, networking, Infrastructure as Code,
DevOps, security, observability, and cost engineering.

---

## 2. Architecture Principles

The architecture follows these principles:

1. Infrastructure must be provisioned using Terraform.
2. Manual cloud portal configuration should be minimized.
3. Azure and AWS should implement comparable architectures.
4. Long-lived cloud credentials should be avoided.
5. Workloads should use cloud-native identities.
6. Access should follow the principle of least privilege.
7. Infrastructure should be inexpensive to operate.
8. Resources should be easy to destroy and recreate.
9. Infrastructure changes should pass automated validation.
10. Security and networking decisions should be documented.

---

## 3. Cloud Regions

### Microsoft Azure

Region:

    Southeast Asia

Primary network:

    10.10.0.0/16

### Amazon Web Services

Region:

    ap-southeast-1

Primary network:

    10.20.0.0/16

Both regions are geographically located in Southeast Asia and provide
an appropriate regional deployment model for this lab.

---

## 4. High-Level Architecture

                         GitHub Repository
                                |
                                v
                         GitHub Actions
                                |
                    +-----------+-----------+
                    |                       |
                 OIDC                    OIDC
                    |                       |
                    v                       v
             Azure Identity            AWS IAM
                    |                       |
                    +---------+-------------+
                              |
                           Terraform
                              |
                +-------------+-------------+
                |                           |
                v                           v
              Azure                        AWS
                |                           |
          +-----+-----+               +-----+-----+
          |   VNet    |               |    VPC    |
          |10.10/16   |               |10.20/16   |
          +-----+-----+               +-----+-----+
                |                           |
                v                           v
        Azure Functions                 Lambda
                |                           |
        Managed Identity                 IAM Role
                |                           |
                v                           v
         Blob Storage                       S3
                |                           |
                v                           v
         Azure Monitor                  CloudWatch

---

## 5. Workload Architecture

Each cloud provider hosts a small health API.

### Azure

Endpoint:

    GET /api/health

Expected response:

    {
      "status": "healthy",
      "provider": "azure",
      "region": "southeastasia"
    }

The workload will use Azure Functions.

Where access to other Azure services is required, the Function should
use Managed Identity rather than embedded credentials.

### AWS

Endpoint:

    GET /api/health

Expected response:

    {
      "status": "healthy",
      "provider": "aws",
      "region": "ap-southeast-1"
    }

The workload will use AWS Lambda.

Access to other AWS services will be granted using an IAM role attached
to the Lambda function.

---

## 6. Cloud Service Mapping

| Capability | Azure | AWS |
|---|---|---|
| Network | VNet | VPC |
| Network segment | Subnet | Subnet |
| Network security | NSG | Security Group |
| Serverless compute | Azure Functions | Lambda |
| Object storage | Blob Storage | S3 |
| Workload identity | Managed Identity | IAM Role |
| Authorization | Azure RBAC | IAM Policies |
| Secrets | Key Vault | Secrets Manager / Parameter Store |
| Monitoring | Azure Monitor | CloudWatch |

---

## 7. Environment Strategy

The initial implementation contains one environment:

    dev

Production infrastructure will not initially be deployed.

This reduces unnecessary cost and complexity while the infrastructure
modules and deployment process are being developed.

The Terraform structure will nevertheless be designed so additional
environments can be introduced later.

---

## 8. Infrastructure Lifecycle

The infrastructure lifecycle is:

    Code
      |
      v
    Git
      |
      v
    Pull Request
      |
      +--> terraform fmt
      +--> terraform validate
      +--> security scanning
      +--> terraform plan
      |
      v
    Review
      |
      v
    Merge
      |
      v
    terraform apply
      |
      v
    Azure + AWS

Infrastructure should also support:

    terraform destroy

This ensures the lab can be removed when it is not required.

---

## 9. Cost Architecture

The target cloud expenditure is:

    < US$10/month

The architecture therefore prioritizes:

- Serverless compute
- Object storage
- Low-volume telemetry
- Short log retention
- Free or low-cost service tiers
- Automatic/manual teardown when resources are unnecessary

The architecture avoids persistent high-cost infrastructure such as:

- Always-on virtual machines
- NAT gateways
- Managed firewalls
- Large managed databases
- VPN gateways unless temporarily required

---

## 10. Security Architecture

Security controls include:

- GitHub OIDC authentication
- Azure RBAC
- AWS IAM
- Azure Managed Identity
- AWS workload IAM roles
- Least-privilege permissions
- Network access controls
- Infrastructure security scanning
- No credentials stored in source control
- Protected Terraform state

No long-lived cloud credentials should be committed to the repository.

---

## 11. Design Decision: No Azure-AWS Private Connection

The initial architecture does not establish a VPN or other private
network connection between Azure and AWS.

The workloads operate independently and do not require private
cross-cloud communication.

Avoiding a VPN also reduces:

- Cost
- Operational complexity
- Routing complexity
- Additional security configuration

Cross-cloud networking can be implemented later as a separate
architecture experiment if required.

---

## 12. Architecture Goals

The completed architecture should demonstrate:

- Multi-cloud infrastructure design
- Terraform Infrastructure as Code
- Reusable Terraform modules
- Cloud networking
- Identity and access management
- Workload identity
- CI/CD
- Infrastructure security scanning
- Monitoring
- Cost governance
- Infrastructure lifecycle management