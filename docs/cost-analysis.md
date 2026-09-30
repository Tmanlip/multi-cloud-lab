# MultiCloud Forge Cost Analysis

## 1. Overview

MultiCloud Forge was designed as a low-cost multi-cloud engineering lab.

The original project target is:

``` text
Total cloud spending target: < US$10/month
```

The architecture therefore favors serverless and consumption-based
services, small telemetry volume, minimal persistent infrastructure, and
Terraform-managed teardown.

The cost objective is an engineering constraint rather than a guarantee.
Actual charges depend on region, request volume, telemetry ingestion,
storage, data transfer, account free-tier eligibility, and how long
resources remain provisioned.

------------------------------------------------------------------------

## 2. Cost Design Principles

The project follows these principles:

1.  Prefer serverless compute over always-on virtual machines.
2.  Avoid fixed-hourly-cost network appliances where possible.
3.  Keep health-check traffic low.
4.  Keep application payloads and log volume small.
5.  Use low-cost storage configurations.
6.  Create only monitoring needed to demonstrate observability.
7.  Tag resources consistently.
8.  Keep infrastructure easy to destroy and recreate.
9.  Treat free-tier allowances as helpful but not guaranteed.
10. Verify the cloud bill rather than assuming a lab is free.

------------------------------------------------------------------------

## 3. Current Cost-Relevant Architecture

The current environment includes cost-relevant services in both clouds.

### AWS

``` text
VPC
Subnets
Route tables
Internet Gateway
Security Groups
Lambda
Lambda Function URL
CloudWatch Logs
CloudWatch metric alarm
```

### Azure

``` text
Resource Group
VNet
Subnets
Network Security Groups
Linux Function App
Y1 Consumption service plan
Storage Account
Application Insights
Managed Log Analytics workspace
Scheduled Query Alert
```

Most network constructs such as VPC/VNet, route tables, subnets, and
security groups do not by themselves represent the same type of fixed
compute cost as an always-on VM, but traffic and attached services can
still generate charges.

------------------------------------------------------------------------

## 4. AWS Lambda Cost Model

The AWS workload uses Lambda with a small health API.

AWS Lambda pricing is primarily driven by:

``` text
Number of requests
+
Execution duration
+
Allocated memory
```

For a low-traffic portfolio workload, request and compute usage can
remain very small.

AWS currently documents a Lambda free tier that includes monthly request
and compute allowances. Free-tier availability and applicability depend
on the account and current AWS terms, so the project should not
hard-code an assumption that Lambda will always cost zero.

------------------------------------------------------------------------

## 5. AWS Lambda Configuration

The deployed Lambda has been observed with:

``` text
Memory: 128 MB
```

Health requests complete in milliseconds in the observed lab runs.

This combination is cost-efficient for the current workload because the
function performs only lightweight JSON response processing.

The project does not use provisioned concurrency.

------------------------------------------------------------------------

## 6. AWS Networking Cost Decisions

The network foundation includes:

``` text
VPC
Public subnet
Private subnet
Internet Gateway
Route tables
Security Groups
```

The baseline deliberately avoids requiring a continuously running NAT
Gateway.

This is significant because NAT Gateway-style managed egress can create
a fixed hourly charge plus data-processing charges and could dominate
the cost of a small serverless lab.

If NAT is introduced later, the cost analysis must be updated before
deployment.

------------------------------------------------------------------------

## 7. AWS CloudWatch Cost

The AWS workload generates Lambda logs in:

``` text
/aws/lambda/mcf-dev-health
```

The project also maintains one standard Lambda error metric alarm:

``` text
mcf-dev-health-errors
```

CloudWatch charges can be influenced by:

-   log ingestion
-   log storage
-   log queries
-   alarms
-   custom metrics

The current application produces very little log volume, but the alarm
itself may have a small ongoing charge depending on region and pricing.

For a lab, log volume should remain controlled and retention should be
reviewed if the project is left running for long periods.

------------------------------------------------------------------------

## 8. AWS Cost Risk Areas

AWS costs could increase if the project later adds:

-   NAT Gateway
-   high-frequency synthetic requests
-   large CloudWatch log volume
-   long log retention
-   high Lambda invocation volume
-   large response payloads
-   cross-region or Internet data transfer
-   provisioned concurrency
-   additional paid monitoring features

The architecture should be reviewed before adding any of these.

------------------------------------------------------------------------

## 9. Azure Functions Cost Model

The Azure workload runs on a Linux Function App using:

``` text
SKU: Y1
```

This is the Consumption plan model used by the Terraform configuration.

Azure Functions Consumption pricing is based primarily on executions and
resource consumption.

Microsoft documents monthly free grants for Consumption-plan executions
and GB-seconds on eligible pay-as-you-go subscriptions, but the project
should treat those grants as account-dependent rather than guaranteed.

------------------------------------------------------------------------

## 10. Azure Storage Cost

Azure Functions requires a storage account.

MultiCloud Forge provisions a Standard LRS storage account for the
Function App.

Cost depends on factors including:

-   stored data
-   transactions
-   data transfer
-   redundancy choice

The current health application stores little application data, so the
storage footprint is expected to remain small.

The storage account still needs to be included in cost monitoring
because it is a billable service independent of the Functions execution
grant.

------------------------------------------------------------------------

## 11. Azure Application Insights and Log Analytics

The Function App sends telemetry to Application Insights.

The workspace-based Application Insights deployment stores telemetry in
a managed Log Analytics workspace.

Cost can therefore be affected by:

``` text
Telemetry ingestion
Retention
Queries
Alert evaluation
```

The lab currently produces a very small amount of request and trace
telemetry.

Controlled failure tests should be occasional rather than continuously
generated.

------------------------------------------------------------------------

## 12. Azure Scheduled Query Alert

The Azure error alert evaluates Log Analytics telemetry using:

``` text
AppRequests
| where ResultCode startswith "5"
| summarize ErrorCount = count()
```

with a five-minute evaluation frequency and five-minute window.

Log alerts and Log Analytics usage should be considered in the Azure
cost model even when the underlying Function execution volume is very
low.

------------------------------------------------------------------------

## 13. Azure Networking Cost Decisions

The Azure network uses:

``` text
VNet
Application subnet
Private subnet
NSGs
```

The current baseline does not add expensive managed network appliances
such as:

-   Azure Firewall
-   VPN Gateway
-   Virtual WAN hub
-   Application Gateway
-   NAT Gateway as a required baseline component

This keeps the network architecture useful for learning without allowing
networking charges to dominate the lab.

------------------------------------------------------------------------

## 14. Multi-Cloud Failover Cost Strategy

The project does not use a paid global traffic-management layer for the
current failover demonstration.

Instead:

``` text
tests/failover/test_failover.py
```

simulates primary/fallback behavior at the application test layer.

This allows the project to demonstrate resilience logic without paying
continuously for a production-grade global routing service.

The documentation therefore describes this correctly as failover
simulation, not automatic production traffic failover.

------------------------------------------------------------------------

## 15. Cost of CI/CD

GitHub Actions runs Terraform and validation jobs for pull requests and
pushes to `main`.

Cloud cost generated by CI/CD comes mainly from the cloud API operations
and application validation it triggers rather than from Terraform
itself.

Repeated unnecessary pushes can increase:

-   function invocations
-   monitoring telemetry
-   API activity
-   GitHub Actions usage

For this project scale, the cloud impact is expected to be small, but
CI/CD should still be intentional.

------------------------------------------------------------------------

## 16. Resource Tagging

The project uses common tags such as:

``` text
Project     = MultiCloudForge
Environment = dev
ManagedBy   = Terraform
Owner       = Portfolio
CostCenter  = Lab
```

Tagging helps identify lab resources and supports later cost analysis.

Tags also make it easier to distinguish MultiCloud Forge resources from
unrelated resources in the same cloud account or subscription.

------------------------------------------------------------------------

## 17. Estimated Cost Profile

For the current low-traffic design, the expected cost profile is:

  -----------------------------------------------------------------------
  Component                           Expected Cost Behavior
  ----------------------------------- -----------------------------------
  AWS VPC/subnets/routes/security     Minimal baseline; attached
  groups                              traffic/services matter

  AWS Lambda                          Consumption-based; very low for
                                      light lab traffic

  AWS CloudWatch Logs                 Usage-based; low with small log
                                      volume

  AWS CloudWatch alarm                Small ongoing monitoring cost may
                                      apply

  Azure VNet/subnets/NSGs             Minimal baseline; attached
                                      services/traffic matter

  Azure Functions Y1                  Consumption-based

  Azure Storage Account               Small usage-based charge expected

  Application Insights / Log          Usage-based telemetry cost
  Analytics                           

  Azure scheduled query alert         Monitoring cost may apply

  Cross-cloud failover test           No dedicated global traffic-manager
                                      service
  -----------------------------------------------------------------------

A precise monthly dollar total should be calculated from the actual AWS
bill and Azure Cost Management data for the account rather than inferred
only from architecture.

------------------------------------------------------------------------

## 18. Why the Architecture Can Stay Below the Target

The architecture supports the sub-US\$10 goal because it avoids the most
obvious fixed-cost components and keeps workloads event-driven.

Conceptually:

``` text
No always-on VM
      +
Serverless compute
      +
Small storage footprint
      +
Low request volume
      +
Low telemetry volume
      +
No required NAT Gateway
      +
No managed firewall
      +
No managed database
      +
No paid global load balancer
      =
Low-cost lab profile
```

The monitoring layer is the area most likely to introduce small
recurring charges even when application traffic is nearly zero.

------------------------------------------------------------------------

## 19. Expensive Components Intentionally Avoided

The baseline avoids:

-   Always-on EC2 instances
-   Azure Virtual Machines
-   AWS NAT Gateway
-   Azure Firewall
-   AWS Network Firewall
-   Azure VPN Gateway
-   AWS Transit Gateway
-   ExpressRoute
-   Direct Connect
-   Managed relational databases
-   Kubernetes clusters
-   Provisioned Lambda concurrency
-   Azure Functions Premium
-   Production global traffic management

These services may be valuable in real systems, but they are unnecessary
for the current project objectives.

------------------------------------------------------------------------

## 20. Cost Monitoring

The project should be checked periodically in both provider billing
consoles.

Useful review categories include:

``` text
AWS
- Lambda
- CloudWatch
- Data transfer
- Any unexpected networking resource

Azure
- Functions
- Storage
- Application Insights / Log Analytics
- Monitor alerts
- Data transfer
```

The purpose is to detect unexpected resources or telemetry growth before
they become material.

------------------------------------------------------------------------

## 21. Cost Validation vs Estimate

This document separates:

``` text
Architecture estimate
        |
        +--> What should be inexpensive?

Actual billing
        |
        +--> What did the providers actually charge?
```

The second is authoritative.

Free-tier status, regional pricing, taxes, currency conversion, and
account-specific offers can change the final amount.

------------------------------------------------------------------------

## 22. Teardown Strategy

Terraform makes the application environment disposable.

Before destroying the environment:

``` powershell
terraform plan -destroy
```

Then:

``` powershell
terraform destroy
```

Resources that are intentionally managed outside the main Terraform
environment---such as identity/bootstrap resources or the remote-state
backend---must be reviewed separately before deletion.

Teardown is an important FinOps control for a portfolio lab that does
not need to run continuously.

------------------------------------------------------------------------

## 23. Cost Optimization Checklist

Before adding a new service, ask:

-   Does it have a fixed hourly charge?
-   Can a serverless alternative meet the learning objective?
-   Does it create significant log or telemetry volume?
-   Does it require NAT or another paid egress service?
-   Can it be deployed only temporarily?
-   Is there a free or low-volume allowance?
-   Can Terraform destroy it cleanly?
-   Does the architecture document explain why it is needed?

This prevents architecture complexity from silently becoming recurring
spend.

------------------------------------------------------------------------

## 24. Current Cost Position

The implemented design remains aligned with the original low-cost
objective:

-   Serverless compute is used on both providers.
-   The Azure Function uses the Y1 Consumption plan.
-   The AWS Lambda uses only 128 MB in observed executions.
-   The baseline does not depend on a NAT Gateway.
-   No always-on VM or managed database is required.
-   Monitoring volume is intentionally small.
-   Failover is tested without a paid global routing layer.
-   Terraform supports teardown.

The exact statement that the environment is **actually below
US\$10/month** should be made only after confirming the current AWS and
Azure billing data.

------------------------------------------------------------------------

## 25. Future FinOps Improvements

Potential improvements include:

-   Export actual monthly AWS cost data.
-   Export Azure Cost Management data.
-   Add budget alerts.
-   Add automated cost estimation to pull requests.
-   Define explicit log-retention periods.
-   Track monthly cost by project tags.
-   Add a documented temporary-resource policy.
-   Compare estimated and actual monthly spend.

These improvements would move the project from cost-aware architecture
toward measurable FinOps governance.
