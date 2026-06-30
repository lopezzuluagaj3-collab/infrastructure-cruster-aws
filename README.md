# Infrastructure Cluster AWS — MVP Deployment

Infrastructure as Code (IaC) project provisioning a complete AWS environment for an MVP application, including a public-facing reverse proxy, a backend service, a local AI inference server, a frontend, and a PostgreSQL database. The infrastructure is fully managed with Terraform across isolated public and private subnets.

## Overview

This project was built to deploy a Minimum Viable Product (MVP) requested by a client, consisting of four core components running on dedicated EC2 instances within a custom VPC:

- **Reverse Proxy** — public-facing entry point handling HTTP/HTTPS traffic and routing to internal services
- **Backend** — application server exposing the API consumed by the frontend and the apk client
- **AI Server** — local inference service running machine learning workloads
- **Database** — PostgreSQL instance for persistent application data

All compute resources, networking, and security groups are defined as code and version-controlled, enabling reproducible deployments and auditable infrastructure changes.

## Architecture

```
                              Internet
                                  |
                          [ Internet Gateway ]
                                  |
                    ┌─────────────────────────┐
                    │   Public Subnet          │
                    │   10.0.1.0/24            │
                    │                          │
                    │   ┌──────────────────┐   │
                    │   │  Proxy (EC2)     │   │
                    │   │  Elastic IP      │   │
                    │   └────────┬─────────┘   │
                    └────────────┼─────────────┘
                                 |
                    ┌────────────┼─────────────┐
                    │   Private Subnet          │
                    │   10.0.2.0/24             │
                    │                           │
                    │  ┌──────────┐ ┌─────────┐ │
                    │  │ Backend  │ │Frontend │ │
                    │  └────┬─────┘ └─────────┘ │
                    │       │                    │
                    │  ┌────┴─────┐ ┌──────────┐ │
                    │  │ AI Server│ │ Database │ │
                    │  └──────────┘ └──────────┘ │
                    └───────────────────────────┘
                                 |
                          [ NAT Gateway ]
                                 |
                              Internet
                       (outbound only, private subnet)
```

The public subnet hosts only the reverse proxy, which is the sole entry point reachable from the internet. All other services live in the private subnet and are reachable exclusively through security group references, never via public IP. Outbound internet access for the private subnet (package installs, updates) is routed through a NAT Gateway.

## Infrastructure Components

| Resource | Description |
|---|---|
| VPC | Custom VPC, CIDR `10.0.0.0/16` |
| Public Subnet | `10.0.1.0/24` — hosts the proxy |
| Private Subnet | `10.0.2.0/24` — hosts backend, frontend, AI server, database |
| Internet Gateway | Provides public subnet internet access |
| NAT Gateway | Provides outbound-only internet access for the private subnet |
| Elastic IP | Static public IP attached to the proxy instance, bound to existing DNS records |
| 5x EC2 Instances | Proxy, Backend, Frontend, AI Server, Database |
| 5x Security Groups | One per service, least-privilege ingress rules |

## Security Groups

Access between services is controlled exclusively through security group references (not CIDR blocks), ensuring that only the intended services can communicate with each other.

| Security Group | Purpose | Key Ingress Rules |
|---|---|---|
| `sg-proxy` | Public entry point | HTTP (80), HTTPS (443), Proxy UI (81), SSH from admin IP |
| `sg-front` | Frontend service | Port 8080 from proxy, SSH from proxy |
| `sg-back` | Backend / message broker | Port 5000 from proxy (web and apk clients), SSH from proxy |
| `sg-ia` | AI inference server | Port 8080 from proxy, SSH from proxy |
| `sg-db` | PostgreSQL database | Port 5432 from backend and AI server, SSH from proxy |

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5
- AWS CLI configured with valid credentials (`aws configure`)
- An existing AWS key pair for SSH access to the instances
- Appropriate IAM permissions to manage EC2, VPC, and related networking resources

## Project Structure

```
infrastructure-cruster-aws/
├── main.tf                    # Root module: providers, data sources, module composition
├── variables.tf                # Input variable declarations
├── outputs.tf                  # Output values (IPs, IDs)
├── terraform.tfvars             # Environment-specific values (not committed)
└── modules/
    ├── networking/              # VPC, subnets, route tables, gateways
    ├── security_groups/         # Security group definitions
    └── compute/                 # EC2 instances, Elastic IP association
```

## Getting Started

### 1. Clone the repository

```bash
git clone <repository-url>
cd infrastructure-cruster-aws
```

### 2. Configure variables

Create a `terraform.tfvars` file in the project root with your environment-specific values:

```hcl
aws_region       = "us-east-1"
environment      = "dev"
owner            = "your-team-name"
allowed_ssh_cidr = "your.admin.ip/32"

KEY_PROXY   = "your-proxy-key-pair-name"
KEY_GENERAL = "your-general-key-pair-name"
```

> **Note:** `terraform.tfvars` is excluded from version control via `.gitignore`, as it may contain environment-specific or sensitive values.

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the execution plan

```bash
terraform plan
```

Always review the plan output before applying. Pay particular attention to any action marked `-/+` (destroy and recreate) on EC2 instances or security groups — these actions can cause downtime and should never be applied to running production infrastructure without explicit review.

### 5. Apply the configuration

```bash
terraform apply
```

Confirm with `yes` once the plan matches your expectations.

## State Management

> **Current setup:** this project uses **local Terraform state** (`terraform.tfstate`). Remote backend (S3 + DynamoDB) has not yet been implemented.

This is an accepted limitation for the current MVP stage, with the following operational implications:

- The `terraform.tfstate` file is the single source of truth linking this codebase to the real AWS resources. It must **not** be deleted, and it is intentionally excluded from version control via `.gitignore` for security reasons (it may contain sensitive attribute values in plaintext).
- Running `terraform init`, `plan`, and `apply` from a fresh clone of this repository **without the existing state file present** will cause Terraform to attempt to recreate all infrastructure from scratch, resulting in duplicate or conflicting resources.
- Until a remote backend is implemented, infrastructure changes must be applied from the machine holding the current `terraform.tfstate` file, or that file must be securely transferred before running Terraform commands elsewhere.
- **Planned improvement:** migrating to an S3 backend with DynamoDB state locking is the recommended next step to enable safe multi-operator collaboration and prevent state file loss.

## Operational Notes

- Instance types, AMIs, and storage configurations are pinned in code to match the currently running infrastructure. Any manual change made directly in the AWS Console must be reflected back into the corresponding `.tf` file as soon as possible to prevent configuration drift.
- Root volumes are provisioned as `gp3` with `delete_on_termination = true`.
- The reverse proxy holds a static Elastic IP with existing DNS records pointing to it; this IP must never be deallocated or reassigned without prior DNS migration.

## Outputs

After a successful `apply`, Terraform exposes the following outputs:

| Output | Description |
|---|---|
| `proxy_public_ip` | Public IP of the reverse proxy |
| `back_private_ip` | Private IP of the backend instance |
| `front_private_ip` | Private IP of the frontend instance |
| `ia_private_ip` | Private IP of the AI server instance |
| `db_private_ip` | Private IP of the database instance |
| `vpc_id` | ID of the provisioned VPC |
| `vpc_cidr` | CIDR block of the VPC |
| `sg_proxy_id` | Security group ID for the proxy |

## License

Private repository. All rights reserved.