# MultiCloud Forge — Network Architecture

## 1. Overview

MultiCloud Forge uses separate non-overlapping private address spaces
for Microsoft Azure and AWS.

Azure:

    10.10.0.0/16

AWS:

    10.20.0.0/16

Non-overlapping CIDR ranges allow future connectivity between the two
cloud environments without requiring network renumbering.

---

## 2. Azure Network

### Virtual Network

Name:

    vnet-mcf-dev-sea

CIDR:

    10.10.0.0/16

### Subnets

Application subnet:

    10.10.1.0/24

Purpose:

Application/serverless integration resources where required.

Private/service subnet:

    10.10.2.0/24

Purpose:

Private or service-integrated resources.

Reserved subnet:

    10.10.10.0/24

Purpose:

Reserved for future architecture expansion.

---

## 3. AWS Network

### VPC

Name:

    mcf-dev-vpc

CIDR:

    10.20.0.0/16

### Subnets

Application subnet:

    10.20.1.0/24

Purpose:

Application-facing resources where required.

Private subnet:

    10.20.2.0/24

Purpose:

Resources that should not require direct inbound Internet access.

Reserved subnet:

    10.20.10.0/24

Purpose:

Reserved for future architecture expansion.

---

## 4. CIDR Summary

| Provider | Network | CIDR |
|---|---|---|
| Azure | VNet | 10.10.0.0/16 |
| Azure | Application | 10.10.1.0/24 |
| Azure | Private/Service | 10.10.2.0/24 |
| Azure | Reserved | 10.10.10.0/24 |
| AWS | VPC | 10.20.0.0/16 |
| AWS | Application | 10.20.1.0/24 |
| AWS | Private | 10.20.2.0/24 |
| AWS | Reserved | 10.20.10.0/24 |

---

## 5. Network Security

### Azure

Azure Network Security Groups will control network traffic where
applicable.

Rules should follow these principles:

- Deny unnecessary inbound access.
- Allow only required application traffic.
- Avoid broad management access from the Internet.
- Document the purpose of every custom rule.

### AWS

AWS Security Groups will provide workload-level traffic filtering.

Rules should follow these principles:

- Only required inbound traffic is permitted.
- Outbound permissions should be documented.
- Administrative ports should not be exposed unnecessarily.
- Security groups should be associated with specific workloads.

---

## 6. Public and Private Resources

Internet-facing resources should be limited to components that
explicitly require public access.

The health API must be reachable for infrastructure validation.

Storage services should not be made publicly writable.

Private resources should not receive public exposure unless there is
a documented technical requirement.

---

## 7. Cross-Cloud Connectivity

Azure and AWS will not initially have direct private connectivity.

Current topology:

    Internet
       |
       +----------------+
       |                |
       v                v
     Azure             AWS
    10.10/16          10.20/16

There is no:

- Site-to-site VPN
- Azure VPN Gateway
- AWS Transit Gateway
- Dedicated connection
- Cross-cloud routing

The separate address spaces nevertheless allow these technologies to
be evaluated in a future extension.

---

## 8. Network Validation

Networking tests should eventually verify:

- Expected application connectivity
- Health endpoint availability
- Required outbound communication
- Unauthorized network paths are denied
- Storage is not unintentionally exposed
- Security rules match documented requirements

Expected and actual test results will be recorded under:

    tests/connectivity/