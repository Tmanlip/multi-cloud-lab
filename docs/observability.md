# MultiCloud Forge Observability

## 1. Overview

MultiCloud Forge implements observability independently for its AWS and Azure serverless workloads.

The monitoring architecture is designed to detect application failures while using the monitoring services native to each cloud platform.

The implementation consists of:

- AWS CloudWatch monitoring for AWS Lambda
- Azure Monitor scheduled query alerts
- Application Insights telemetry
- Log Analytics workspace queries
- Controlled failure endpoints for observability testing
- Health endpoints for availability validation

The monitoring resources are managed through Terraform.

---

## 2. Monitoring Architecture

The observability flow can be represented as:

```text
                    MultiCloud Forge
                          |
             +------------+------------+
             |                         |
             v                         v
            AWS                       Azure
             |                         |
             v                         v
        AWS Lambda              Azure Function
             |                         |
             v                         v
       CloudWatch                 Application
       Metrics                    Insights
             |                         |
             |                         v
             |                  Log Analytics
             |                    Workspace
             |                         |
             v                         v
    CloudWatch Metric          Scheduled Query
          Alarm                    Alert