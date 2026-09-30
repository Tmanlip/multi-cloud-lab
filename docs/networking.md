# MultiCloud Forge Networking

## 1. Overview

MultiCloud Forge provisions separate network foundations in Amazon Web
Services (AWS) and Microsoft Azure using reusable Terraform modules.

The networking layer is intentionally simple. Its purpose is to
demonstrate multi-cloud network design, segmentation, routing, security
controls, Infrastructure as Code, and comparable cloud architecture
without introducing unnecessary always-on networking services.

The implemented network modules are:

``` text
terraform/modules/aws-network/
terraform/modules/azure-network/
```

The development environment composes both modules from:

``` text
terraform/environments/dev/
```

------------------------------------------------------------------------

## 2. Network Design Goals

The network architecture was designed to:

1.  Provide non-overlapping address spaces for AWS and Azure.
2.  Separate application-facing and private network segments.
3.  Apply network security controls at the subnet/workload boundary.
4.  Keep routing understandable and auditable.
5.  Use Terraform for repeatable provisioning.
6.  Avoid unnecessary fixed-cost networking components.
7.  Provide a foundation that can later support private workloads or
    cross-cloud connectivity.

The project does not currently implement direct AWS-to-Azure private
connectivity. The two cloud networks are independent environments.

------------------------------------------------------------------------

## 3. High-Level Network Architecture

``` text
                         Internet
                            |
              +-------------+-------------+
              |                           |
              v                           v
             AWS                         Azure
              |                           |
              v                           v
        VPC 10.20.0.0/16           VNet 10.10.0.0/16
              |                           |
        +-----+-----+               +-----+-----+
        |           |               |           |
        v           v               v           v
      Public      Private       Application    Private
      Subnet      Subnet          Subnet       Subnet
        |           |               |           |
        +-----+-----+               +-----+-----+
              |                           |
       Security Groups                    NSGs
```

AWS and Azure use separate CIDR ranges so the environments can later be
connected without immediate address-space overlap.

------------------------------------------------------------------------

## 4. Addressing Strategy

The development environment uses the following top-level address spaces:

  Provider   Network           CIDR
  ---------- ----------------- ----------------
  Azure      Virtual Network   `10.10.0.0/16`
  AWS        VPC               `10.20.0.0/16`

The address spaces are intentionally different.

This design provides room for subnet expansion while avoiding overlap
between the two providers.

------------------------------------------------------------------------

## 5. AWS Network

The AWS network is defined in:

``` text
terraform/modules/aws-network/
```

The deployed foundation includes:

-   AWS VPC
-   Public subnet
-   Private subnet
-   Internet Gateway
-   Public route table
-   Private route table
-   Route-table associations
-   Application security group
-   Private security group

Terraform infrastructure validation confirmed that the AWS VPC, subnets,
route table, Internet Gateway, and security groups are present in state.

------------------------------------------------------------------------

## 6. AWS VPC

The AWS environment uses:

``` text
VPC: 10.20.0.0/16
Region: ap-southeast-1
```

The VPC provides the isolation boundary for the AWS network resources.

The network is divided into public and private segments rather than
placing all future workloads into a single subnet.

------------------------------------------------------------------------

## 7. AWS Subnet Segmentation

The current AWS design separates:

``` text
10.20.0.0/16
      |
      +-- Public subnet
      |
      +-- Private subnet
```

The public subnet is intended for resources that require a route toward
the public Internet.

The private subnet establishes a separate network segment for workloads
that should not require direct public exposure.

This is an architectural foundation; the current Lambda health workload
is serverless and is not dependent on deployment into these subnets.

------------------------------------------------------------------------

## 8. AWS Internet Connectivity

An Internet Gateway is attached to the VPC.

The public route table provides the Internet-facing routing path for the
public network segment and is associated with the public subnet.

Conceptually:

``` text
Public Subnet
     |
     v
Public Route Table
     |
     v
Internet Gateway
     |
     v
Internet
```

The private subnet uses a separate route table.

This separation prevents the project from treating public and private
network segments as equivalent.

------------------------------------------------------------------------

## 9. AWS Cost-Aware Routing

The project deliberately keeps the network suitable for a low-cost lab.

A continuously provisioned NAT Gateway can introduce a fixed hourly cost
plus data-processing charges. MultiCloud Forge therefore avoids making a
NAT Gateway a required part of the current baseline architecture.

If a future private workload requires outbound Internet access, NAT or
another controlled egress design can be introduced as a documented
architecture change.

------------------------------------------------------------------------

## 10. AWS Security Groups

The AWS network module creates separate security groups for application
and private roles.

This creates a logical separation between:

``` text
Application security boundary
             |
             v
Private security boundary
```

Security groups are stateful controls. Rules should remain limited to
traffic required by the workload rather than being expanded for
convenience.

The Terraform module is the source of truth for the exact ingress and
egress rules.

------------------------------------------------------------------------

## 11. Azure Network

The Azure network is defined in:

``` text
terraform/modules/azure-network/
```

The deployed foundation includes:

-   Resource group
-   Virtual Network
-   Application subnet
-   Private subnet
-   Application Network Security Group
-   Private Network Security Group
-   NSG-to-subnet associations

Infrastructure validation confirmed that the Azure resource group, VNet,
subnets, and NSGs are represented in Terraform state.

------------------------------------------------------------------------

## 12. Azure Virtual Network

The Azure development environment uses:

``` text
VNet: 10.10.0.0/16
Region: southeastasia
```

The VNet provides the primary Azure network boundary.

Its address space is intentionally distinct from the AWS VPC:

``` text
Azure: 10.10.0.0/16
AWS:   10.20.0.0/16
```

This avoids CIDR overlap and leaves open the possibility of future
routed connectivity between the clouds.

------------------------------------------------------------------------

## 13. Azure Subnet Segmentation

The Azure VNet is separated into:

``` text
10.10.0.0/16
      |
      +-- Application subnet
      |
      +-- Private subnet
```

The application subnet represents the network segment intended for
application-facing resources.

The private subnet provides a separate segment for resources that should
have a more restricted network role.

The current Azure Function is deployed as a serverless Function App and
the presence of these subnets should not be interpreted as proof that
the Function App is VNet-integrated.

------------------------------------------------------------------------

## 14. Azure Network Security Groups

Separate NSGs are associated with the application and private subnets.

Conceptually:

``` text
Application NSG
      |
      v
Application Subnet

Private NSG
      |
      v
Private Subnet
```

This makes network policy part of the Terraform-managed architecture
rather than an undocumented portal configuration.

The exact NSG rules remain defined by the Terraform module.

------------------------------------------------------------------------

## 15. AWS and Azure Network Mapping

  -----------------------------------------------------------------------------
  Networking Concept      AWS                           Azure
  ----------------------- ----------------------------- -----------------------
  Network boundary        VPC                           VNet

  Address space           `10.20.0.0/16`                `10.10.0.0/16`

  Application segment     Public/application-oriented   Application subnet
                          subnet                        

  Restricted segment      Private subnet                Private subnet

  Traffic control         Security Groups               Network Security Groups

  Public routing          Route table + Internet        Azure platform routing
                          Gateway                       / configured subnet
                                                        policy

  IaC module              `aws-network`                 `azure-network`
  -----------------------------------------------------------------------------

The implementations are not forced to be identical. Each provider uses
its native networking model while following the same architectural
principles.

------------------------------------------------------------------------

## 16. Serverless Workloads and Networking

The project currently runs:

``` text
AWS Lambda
Azure Function
```

The health APIs are exposed using cloud-native serverless HTTP
endpoints.

The networking modules demonstrate the network foundation independently
of those serverless endpoints.

This distinction is important:

``` text
Network foundation
      !=
Serverless function automatically attached to subnet
```

A future version could explicitly add Lambda VPC attachment or Azure
Function VNet integration if a private dependency requires it.

------------------------------------------------------------------------

## 17. Cross-Cloud Connectivity

MultiCloud Forge currently does not deploy:

-   Site-to-Site VPN
-   AWS Transit Gateway
-   Azure VPN Gateway
-   Azure Virtual WAN
-   Direct Connect
-   ExpressRoute
-   Cross-cloud private peering

AWS and Azure communicate only at the application/test layer through
public HTTPS endpoints where required.

This keeps the lab inexpensive and avoids presenting simulated failover
as private network-level failover.

------------------------------------------------------------------------

## 18. DNS and Endpoint Access

The health workloads use provider-managed HTTPS endpoints.

AWS exposes the Lambda through a Lambda Function URL.

Azure exposes the Function through its Azure Websites hostname.

The project does not currently operate a custom cross-cloud DNS failover
layer.

Failover behavior is validated by the test logic rather than by changing
production DNS records.

------------------------------------------------------------------------

## 19. Network Validation

Infrastructure validation is performed by:

``` text
tests/infrastructure/test_terraform.py
```

The test verifies that expected Terraform-managed networking resource
types are represented in state.

Validated AWS types include:

``` text
aws_vpc
aws_subnet
aws_route_table
aws_internet_gateway
aws_security_group
```

Validated Azure types include:

``` text
azurerm_virtual_network
azurerm_subnet
azurerm_network_security_group
```

This confirms that the network foundation is part of the deployed
Terraform environment.

------------------------------------------------------------------------

## 20. Availability Validation

Application reachability is validated separately from network-resource
existence.

The health test is:

``` text
tests/connectivity/test_health.py
```

It validates both serverless endpoints and confirms their provider,
region, environment, and application version.

This separates two different questions:

``` text
Infrastructure test -> Were expected resources provisioned?
Health test         -> Are deployed workloads responding?
```

------------------------------------------------------------------------

## 21. Failover Validation

Resilience behavior is tested through:

``` text
tests/failover/test_failover.py
```

The test models AWS as the primary endpoint and Azure as the fallback
endpoint.

The validated paths are:

``` text
AWS healthy
    |
    v
ACTIVE AWS
```

and:

``` text
AWS unavailable
    |
    v
Check Azure
    |
    v
Azure healthy
    |
    v
FAILOVER Azure
```

This is application-level failover simulation. It is not a claim of
automatic network routing or DNS failover.

------------------------------------------------------------------------

## 22. Network Security Principles

The network design follows these principles:

-   Separate cloud address spaces.
-   Separate application/public and private network segments.
-   Use provider-native network security controls.
-   Keep policy managed through Terraform.
-   Avoid unnecessary public exposure.
-   Avoid expensive networking services unless justified.
-   Do not assume subnet placement that is not explicitly configured.
-   Keep future cross-cloud connectivity possible by avoiding CIDR
    overlap.

------------------------------------------------------------------------

## 23. Current Limitations

The current networking implementation does not provide:

-   Private AWS-to-Azure connectivity
-   Centralized cross-cloud routing
-   Managed global load balancing
-   Automatic DNS failover
-   Network firewall appliances
-   Production-grade multi-region routing
-   Confirmed private integration of the serverless workloads with the
    provisioned subnets

These are deliberate boundaries for a low-cost engineering lab.

------------------------------------------------------------------------

## 24. Future Improvements

Possible networking extensions include:

-   Explicit Lambda VPC integration
-   Azure Function VNet integration
-   Private endpoints for supported services
-   Temporary Site-to-Site VPN experimentation
-   Route validation tests
-   Network flow logging
-   DNS-based health routing
-   Multi-region network modules
-   More granular security-group and NSG tests

Any extension should be evaluated against the project's low-cost
objective before deployment.
