# MultiCloud Forge — Cost Analysis

## 1. Objective

MultiCloud Forge is designed to maintain a total cloud expenditure
below:

    US$10/month

Cost efficiency is therefore an architectural requirement rather than
an afterthought.

---

## 2. Cost Strategy

The environment prioritizes consumption-based and serverless services.

Primary cost controls include:

- Serverless compute
- Minimal object storage
- Low telemetry volume
- Short log retention
- No always-on virtual machines
- No NAT gateways
- No managed firewalls
- No managed databases
- No permanent cross-cloud VPN
- Terraform-based teardown
- Budget monitoring
- Consistent resource tagging

---

## 3. Azure Cost Model

Planned Azure services:

| Service | Usage |
|---|---|
| Azure Functions | Small health API |
| Blob Storage | Minimal application/test data |
| Azure Monitor | Low-volume logs and monitoring |
| VNet | Network architecture |
| NSG | Network security |

The workload is intentionally designed for very low request and
storage volumes.

Planning budget:

    Azure Functions:      US$0–1/month
    Blob Storage:         < US$0.25/month
    Monitoring:           US$0–1/month

Estimated Azure planning envelope:

    < US$2.25/month

Actual expenditure will be recorded after deployment.

---

## 4. AWS Cost Model

Planned AWS services:

| Service | Usage |
|---|---|
| AWS Lambda | Small health API |
| Amazon S3 | Minimal application/test data |
| CloudWatch | Logs and monitoring |
| VPC | Network architecture |
| Security Groups | Network security |

The Lambda workload is expected to remain extremely small.

Planning budget:

    AWS Lambda:           US$0–1/month
    Amazon S3:            < US$0.25/month
    CloudWatch:           US$0–1/month

Estimated AWS planning envelope:

    < US$2.25/month

Actual expenditure will be recorded after deployment.

---

## 5. Overall Planning Budget

Azure:

    < US$2.25/month

AWS:

    < US$2.25/month

Initial engineering planning envelope:

    < US$4.50/month

Project hard limit:

    US$10/month

The planning envelope is intentionally below the hard limit to provide
additional room for unexpected telemetry, storage, requests, or data
transfer charges.

These values are planning assumptions rather than guaranteed provider
charges.

---

## 6. Expensive Components Intentionally Avoided

The architecture intentionally avoids:

- Azure Virtual Machines
- Amazon EC2 instances
- NAT gateways
- VPN gateways
- Managed firewalls
- Managed relational databases
- Large telemetry ingestion
- Long log-retention periods

These services are unnecessary for the project's primary learning
objectives and could introduce significant fixed costs.

---

## 7. Cost Governance

Resources will use common cost-management tags.

    Project     = MultiCloudForge
    Environment = Dev
    ManagedBy   = Terraform
    Owner       = Portfolio
    CostCenter  = Lab

Budget alerts should be configured where practical.

---

## 8. Teardown Strategy

Development infrastructure should be destroyable using:

    terraform destroy

Resources that are not required continuously should not remain
deployed simply for demonstration purposes.

Before destroying infrastructure, Terraform state and required project
evidence should be preserved.

---

## 9. Actual Cost

This section will be updated after deployment.

| Provider | Estimated | Actual |
|---|---:|---:|
| Azure | < $2.25 | TBD |
| AWS | < $2.25 | TBD |
| Total | < $4.50 | TBD |

The final project documentation will compare estimated and actual
expenditure.