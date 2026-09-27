# MultiCloud Forge — Network Architecture

## Overview

MultiCloud Forge uses isolated Azure and AWS networks managed through Terraform.

The development environment does not implement direct cross-cloud connectivity.
Azure and AWS therefore operate as independent network domains.

---

## Azure Network

### Virtual Network

| Resource | Value |
|---|---|
| VNet | `vnet-mcf-dev-sea` |
| Region | Southeast Asia |
| Address Space | `10.10.0.0/16` |

### Subnets

| Subnet | CIDR | Purpose |
|---|---|---|
| `snet-mcf-app-dev-sea` | `10.10.1.0/24` | Application/serverless integration |
| `snet-mcf-private-dev-sea` | `10.10.2.0/24` | Private/service resources |
| Reserved | `10.10.10.0/24` | Future expansion |

### Network Security Groups

- `nsg-mcf-app-dev-sea`
- `nsg-mcf-private-dev-sea`

No custom inbound rules are currently configured.

Custom rules will only be introduced when a workload has a documented
network requirement.

---

## AWS Network

### VPC

| Resource | Value |
|---|---|
| VPC | `mcf-dev-vpc` |
| Region | `ap-southeast-1` |
| Address Space | `10.20.0.0/16` |

### Subnets

| Subnet | CIDR | Type |
|---|---|---|
| `mcf-dev-public-subnet` | `10.20.1.0/24` | Public/Application |
| `mcf-dev-private-subnet` | `10.20.2.0/24` | Private/Service |
| Reserved | `10.20.10.0/24` | Future expansion |

### Public Routing

The public subnet is associated with a dedicated public route table.

Traffic path:

Public Subnet
→ Public Route Table
→ `0.0.0.0/0`
→ Internet Gateway
→ Internet

Resources must still have an appropriate public IP and security-group
rules before they can receive traffic from the Internet.

### Private Routing

The private subnet uses a dedicated private route table.

There is no default Internet route and no NAT Gateway.

This keeps the development environment inexpensive while maintaining
clear public/private network separation.

### Security Groups

- `mcf-dev-app-sg`
- `mcf-dev-private-sg`

No inbound rules are currently configured.

Outbound traffic is permitted by the security groups, but the private
subnet does not have an Internet route.

---

## Cross-Cloud Connectivity

There is currently no:

- Site-to-Site VPN
- VNet-to-VPC peering
- Transit Gateway
- Virtual WAN
- Direct Connect
- ExpressRoute

Azure and AWS therefore have no direct private network route between
`10.10.0.0/16` and `10.20.0.0/16`.

Cross-cloud communication introduced by later application components
will use authenticated application/API communication rather than direct
private network routing.

---

## CIDR Allocation

| Cloud | Network | CIDR |
|---|---|---|
| Azure | VNet | `10.10.0.0/16` |
| Azure | Application | `10.10.1.0/24` |
| Azure | Private | `10.10.2.0/24` |
| Azure | Reserved | `10.10.10.0/24` |
| AWS | VPC | `10.20.0.0/16` |
| AWS | Public/Application | `10.20.1.0/24` |
| AWS | Private | `10.20.2.0/24` |
| AWS | Reserved | `10.20.10.0/24` |

The Azure and AWS CIDR ranges do not overlap, leaving the architecture
compatible with future private cross-cloud connectivity if required.

---

## Cost Considerations

The development network intentionally avoids cost-heavy networking
components such as:

- AWS NAT Gateway
- AWS Transit Gateway
- Azure VPN Gateway
- Azure Firewall

The network therefore demonstrates segmentation, routing, and security
controls while keeping recurring lab costs low.

---

## Terraform Management

The Azure and AWS networks are managed through reusable Terraform
modules:

`terraform/modules/azure-network`

`terraform/modules/aws-network`

Both modules are instantiated from:

`terraform/environments/dev`

Terraform state is stored remotely in Azure Blob Storage.