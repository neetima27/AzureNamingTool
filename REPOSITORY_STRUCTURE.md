# Azure Banking Landing Zone - Complete Repository Structure

This document provides a comprehensive overview of the complete repository structure including design documentation, IaC templates, and CI/CD pipelines.

## Repository Root Structure

```
AzureNamingTool/
├── README.md                    # Main repository README
├── LICENSE                      # License file
├── CONTRIBUTING.md              # Contribution guidelines
├── SECURITY.md                  # Security policy
├── CODEOWNERS                   # Code ownership
│
├── design/                      # Architecture & Design Documentation
│   ├── README.md               # Design overview
│   ├── INDEX.md                # Design index and navigation
│   ├── QUICK_REFERENCE.md      # Quick reference guide
│   ├── NETWORK_ARCHITECTURE.md # Network design details
│   ├── GOVERNANCE_POLICIES.md  # Policy design
│   ├── MONITORING_OBSERVABILITY.md
│   ├── COST_MANAGEMENT.md
│   ├── IAC_DEPLOYMENT.md       # IaC strategy
│   ├── IMPLEMENTATION_GUIDE.md # Step-by-step implementation
│   ├── DELIVERY_SUMMARY.md
│   ├── diagrams/
│   │   └── ARCHITECTURE_DIAGRAMS.md  # Mermaid diagrams
│   ├── monitoring/
│   │   └── monitoring-setup.bicep
│   ├── policies/
│   │   └── banking-compliance.bicep
│   ├── iac/
│   │   ├── hub-vnet.bicep      # Bicep hub network (current)
│   │   └── hub-vnet.tf         # Legacy Terraform (reference only)
│   ├── archive/                # Legacy templates
│   └── README.md
│
├── bicep/                       # Infrastructure as Code (Bicep)
│   ├── README.md               # Bicep IaC documentation
│   ├── MODULES.md              # Module reference guide
│   │
│   ├── landing-zone/           # Orchestration Templates
│   │   ├── main.bicep          # Entry point - orchestrates all modules
│   │   └── hub-vnet.bicep      # Hub VNet deployment
│   │
│   ├── modules/                # Reusable Bicep Modules
│   │   ├── networking/
│   │   │   ├── vnet.bicep                    # VNet with subnets
│   │   │   └── vnet-peering.bicep           # VNet peering
│   │   ├── security/
│   │   │   ├── keyvault.bicep               # Key Vault (private)
│   │   │   └── nsg.bicep                    # Network Security Groups
│   │   ├── storage/
│   │   │   └── storage-account.bicep        # Storage (private)
│   │   ├── database/
│   │   │   └── sql-database.bicep           # SQL Database (private)
│   │   ├── monitoring/
│   │   │   ├── log-analytics.bicep          # Log Analytics
│   │   │   └── application-insights.bicep   # App Insights
│   │   └── shared/
│   │       ├── private-endpoint.bicep       # Private Endpoint
│   │       └── private-dns-zone.bicep       # Private DNS Zone
│   │
│   ├── parameters/             # Environment Parameters
│   │   ├── dev.parameters.json
│   │   ├── staging.parameters.json
│   │   └── prod.parameters.json
│   │
│   ├── scripts/                # Deployment & Maintenance Scripts
│   │   ├── deploy.sh           # Deploy landing zone
│   │   ├── cleanup.sh          # Remove resources
│   │   └── validate.sh         # Validate deployment
│   │
│   └── build/                  # Build output (generated)
│       └── *.json              # Compiled ARM templates
│
├── .github/
│   └── workflows/              # CI/CD Pipelines
│       └── deploy-bicep.yml    # Bicep deployment workflow
│
├── src/                        # Application Source Code
│   ├── appsettings.*.json
│   ├── Program.cs
│   ├── AzureNamingTool.csproj
│   ├── AzureNamingTool.sln
│   ├── Dockerfile
│   ├── Components/
│   ├── Controllers/
│   ├── Services/
│   ├── Models/
│   ├── Helpers/
│   ├── Attributes/
│   ├── Properties/
│   └── wwwroot/
│
└── tests/                      # Test Projects
    ├── AzureNamingTool.UnitTests/
    └── AzureNamingTool.UiTests/
```

## Component Overview

### Design Documentation (`design/`)

**Purpose**: High-level architecture, design decisions, and implementation guidance.

**Key Files**:
- `NETWORK_ARCHITECTURE.md`: Hub-and-spoke network with 10.19.0.0/16 CIDR
- `GOVERNANCE_POLICIES.md`: Azure Policy definitions for compliance
- `IAC_DEPLOYMENT.md`: Bicep-only strategy with stage-based pipeline
- `IMPLEMENTATION_GUIDE.md`: Step-by-step deployment instructions
- `diagrams/ARCHITECTURE_DIAGRAMS.md`: Mermaid diagrams with Azure icons

**Network Design**:
- Hub VNet: 10.19.0.0/16
  - Firewall: 10.19.0.0/24
  - Bastion: 10.19.1.0/24
  - Gateway: 10.19.2.0/24
  - Private Endpoints: 10.19.3.0/24
  - Shared Services: 10.19.4.0/24
  - Management: 10.19.5.0/24
- Spoke VNets:
  - Dev: 10.19.16.0/20
  - Staging: 10.19.32.0/20
  - Prod: 10.19.48.0/20

### Bicep IaC (`bicep/`)

**Purpose**: Infrastructure as Code using Bicep with private endpoint enforcement.

**Architecture**:
```
Landing Zone (main.bicep)
  ├── Hub VNet (hub-vnet.bicep)
  │   ├── Firewall
  │   ├── Bastion
  │   └── Key Vault (private)
  ├── Spoke VNet (vnet.bicep)
  │   ├── App Subnet
  │   ├── Data Subnet
  │   └── Integration Subnet
  ├── VNet Peering
  ├── Log Analytics
  ├── Application Insights
  └── Private Endpoints + DNS Zones
```

**Modules**:

1. **Networking**
   - `vnet.bicep`: VNet with configurable subnets
   - `vnet-peering.bicep`: Hub-spoke peering

2. **Security**
   - `keyvault.bicep`: Private Key Vault (public access disabled)
   - `nsg.bicep`: Network Security Groups

3. **Storage**
   - `storage-account.bicep`: Private Storage Account (public access denied)

4. **Database**
   - `sql-database.bicep`: SQL Database (public endpoint disabled)

5. **Monitoring**
   - `log-analytics.bicep`: Log Analytics Workspace (private)
   - `application-insights.bicep`: App Insights (private)

6. **Shared**
   - `private-endpoint.bicep`: Reusable private endpoint
   - `private-dns-zone.bicep`: Private DNS zones

**Deployment Parameters**:
- `dev.parameters.json`: Dev environment (10.19.16.0/20)
- `staging.parameters.json`: Staging (10.19.32.0/20)
- `prod.parameters.json`: Production (10.19.48.0/20)

**Scripts**:
- `deploy.sh`: Interactive deployment with what-if validation
- `cleanup.sh`: Resource deletion with safety confirmation
- `validate.sh`: Deployment verification and checks

### CI/CD Pipeline (`.github/workflows/`)

**Workflow**: `deploy-bicep.yml`

**Stages**:
1. **Validate**: Bicep syntax and linting
2. **Build**: Compile Bicep to ARM templates
3. **Plan**: Generate what-if plans for all environments
4. **Deploy Dev**: Auto-deploy to dev on main push
5. **Deploy Staging**: Auto-deploy to staging (requires dev success)
6. **Deploy Prod**: Manual approval required, concurrency control

**Features**:
- Self-hosted runner with private network
- Environment-based approvals
- Artifact retention (5 days)
- Deployment reports in GitHub Summary
- Stage-based orchestration

### Application Source (`src/`)

**Purpose**: Azure Naming Tool application (not modified by IaC).

Contains:
- ASP.NET Core application
- API controllers
- Razor components
- Configuration management
- Deployment files

## Key Security & Design Principles

### 1. Private Access by Default

All PaaS services deny public network access:
- ✅ Key Vault: `publicNetworkAccess: Disabled`
- ✅ Storage Account: `publicNetworkAccess: Disabled`
- ✅ SQL Database: `publicNetworkAccess: Disabled`
- ✅ Log Analytics: Public ingestion/query disabled
- ✅ Application Insights: Public access disabled

### 2. Private Endpoints & Private DNS

Services accessed via:
- Private Endpoints in 10.19.3.0/24 subnet
- Private DNS zones (privatelink.*)
- Internal VNet routing

**Example - SQL Database Access**:
```
App VM (10.19.16.x)
  → DNS: projecta-sql.database.windows.net
  → Private DNS: 10.19.3.x
  → Private Endpoint (10.19.3.x)
  → SQL Database (private)
```

### 3. Hub-and-Spoke Network

Centralized security:
- Hub: Firewall, Bastion, Gateway
- Spokes: Application workloads
- All traffic through firewall
- Gateway for hybrid connectivity

### 4. Stage-Based Deployment

Progressive validation:
- Dev → Staging → Production
- Each stage has approval gates
- What-if validation before deployment
- Rollback via resource group deletion

### 5. Private Network Deployment

GitHub Actions runner:
- Self-hosted on private network
- No internet gateway
- Secure communication via VNet
- Credentials via secrets

## Deployment Flow

```
Developer commits → GitHub Push
  ↓
.github/workflows/deploy-bicep.yml triggered
  ↓
Validate Stage
  ├─ Bicep lint/validation
  └─ Syntax errors detected early
  ↓
Build Stage
  ├─ Compile Bicep → ARM templates
  └─ Upload artifacts
  ↓
Plan Dev/Staging/Prod
  ├─ What-if analysis
  └─ Review changes
  ↓
Deploy Dev (auto-on main push)
  ├─ Subscription deployment
  ├─ Create resource groups
  ├─ Deploy VNets & peering
  ├─ Deploy services
  └─ Create private endpoints
  ↓
Deploy Staging (after dev succeeds)
  ├─ Same process, different parameters
  └─ Different spoke address space
  ↓
Deploy Production (with approval)
  ├─ Manual approval required
  ├─ Concurrency control (one at a time)
  └─ Deployment report generated
```

## Environment Isolation

### Dev Environment
- Resource Group: `rg-hub-dev-southafricanorth`
- Resource Group: `rg-banking-platform-dev-southafricanorth`
- Spoke CIDR: 10.19.16.0/20
- Purpose: Testing and development

### Staging Environment
- Resource Group: `rg-hub-staging-southafricanorth`
- Resource Group: `rg-banking-platform-staging-southafricanorth`
- Spoke CIDR: 10.19.32.0/20
- Purpose: Pre-production validation

### Production Environment
- Resource Group: `rg-hub-prod-southafricanorth`
- Resource Group: `rg-banking-platform-prod-southafricanorth`
- Spoke CIDR: 10.19.48.0/20
- Purpose: Live banking infrastructure

## Quick Start

### 1. Understand the Design
```bash
cd design/
# Read: README.md, NETWORK_ARCHITECTURE.md, IAC_DEPLOYMENT.md
```

### 2. Review Bicep Modules
```bash
cd bicep/
# Read: README.md, MODULES.md
```

### 3. Deploy to Dev
```bash
export AZURE_SUBSCRIPTION_ID="<sub-id>"
export AZURE_TENANT_ID="<tenant-id>"
export AZURE_PRINCIPAL_ID="<principal-id>"

chmod +x bicep/scripts/deploy.sh
bicep/scripts/deploy.sh dev
```

### 4. Validate Deployment
```bash
chmod +x bicep/scripts/validate.sh
bicep/scripts/validate.sh dev
```

### 5. Deploy via CI/CD
```bash
git add .
git commit -m "Deploy landing zone"
git push origin main
# CI/CD pipeline automatically deploys: dev → staging → prod
```

## File Size Summary

| Component | Type | Count | Purpose |
|-----------|------|-------|---------|
| Design Docs | Markdown | 10+ | Architecture & guidance |
| Bicep Modules | Bicep | 12+ | Reusable infrastructure |
| Parameters | JSON | 3 | Environment configs |
| Scripts | Shell | 3 | Deployment automation |
| Workflows | YAML | 1 | CI/CD pipeline |
| Application | C#/.NET | Multiple | Naming tool app |

## Documentation Map

```
Getting Started → design/README.md
                ↓
Architecture    → design/NETWORK_ARCHITECTURE.md
                  design/diagrams/ARCHITECTURE_DIAGRAMS.md
                ↓
Deployment      → design/IAC_DEPLOYMENT.md
                  design/IMPLEMENTATION_GUIDE.md
                ↓
IaC Deep Dive   → bicep/README.md
                  bicep/MODULES.md
                ↓
Deployment      → bicep/scripts/deploy.sh
                  .github/workflows/deploy-bicep.yml
```

## Support & Resources

- **Azure Bicep**: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/
- **Private Endpoints**: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview
- **Hub-Spoke Network**: https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke
- **Landing Zones**: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/

## Next Steps

1. ✅ Review design documentation
2. ✅ Understand Bicep module structure
3. ✅ Deploy to dev environment
4. ✅ Test private endpoint connectivity
5. ✅ Validate monitoring setup
6. ✅ Deploy to staging via pipeline
7. ✅ Approve production deployment
8. ✅ Monitor and maintain infrastructure

---

**Last Updated**: June 2026  
**Status**: Production Ready  
**Region**: South Africa North (southafricanorth)  
**CIDR Range**: 10.19.0.0/16  
**IaC Format**: Bicep (100%)
