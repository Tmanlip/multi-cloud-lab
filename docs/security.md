# MultiCloud Forge — Security Architecture

## 1. Security Objectives

The infrastructure follows the principles of:

- Least privilege
- Short-lived authentication
- Workload identity
- Infrastructure as Code
- Defense in depth
- Minimal public exposure
- Secret protection

---

## 2. CI/CD Authentication

GitHub Actions should authenticate to Azure and AWS using OIDC.

    GitHub Actions
           |
           | OIDC
           |
       +---+---+
       |       |
       v       v
     Azure    AWS

This avoids storing permanent cloud access keys in GitHub.

---

## 3. Azure Identity

Azure resources will use:

- Microsoft Entra ID
- Azure RBAC
- Managed Identity

Azure Functions should use Managed Identity when accessing supported
Azure resources.

Permissions should be scoped only to required resources.

---

## 4. AWS Identity

AWS resources will use:

- IAM roles
- IAM policies
- GitHub OIDC federation

Lambda functions should use execution roles instead of static access
keys.

IAM policies should contain only required actions and resources.

---

## 5. Source Control Security

The following must never be committed:

- Cloud credentials
- Access keys
- Client secrets
- Terraform state
- .env files
- Private keys
- Sensitive configuration

Infrastructure changes should eventually pass automated security
scanning before deployment.

---

## 6. Storage Security

Azure Blob Storage and Amazon S3 should:

- Block unnecessary public access
- Require authenticated access where appropriate
- Use workload identities
- Apply least-privilege authorization

Infrastructure testing should verify both successful authorized access
and failed unauthorized access.

---

## 7. Network Security

Network controls should:

- Minimize inbound exposure
- Permit only required application traffic
- Avoid exposing management services
- Separate application and private network segments
- Document every intentional access path

---

## 8. Terraform Security

Terraform state may contain infrastructure information that should not
be publicly exposed.

The project will therefore:

- Exclude state from Git
- Use a remote backend when implemented
- Protect backend access
- Avoid placing secrets directly inside Terraform source files

---

## 9. Security Validation

Security testing will eventually include:

- IaC security scanning
- IAM/RBAC validation
- Public storage checks
- Network access validation
- Unauthorized storage access tests
- Credential leak checks