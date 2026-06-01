# Quick Reference Guide

## Design at a Glance

### Landing Zone Summary
- **Organization Type**: Banking Sector (Multi-project, Multi-application)
- **Governance Model**: Centralized with delegated administration
- **Regions**: South Africa North (single region, no multi-region DR)
- **Network Model**: Hub-and-Spoke with Azure Firewall
- **Security Model**: Zero-Trust with Private Endpoints
- **Deployment Model**: GitHub-based Infrastructure-as-Code
- **Operations Model**: Azure-native tools with Monitoring-as-Code

### Architecture Snapshot

```
Organization
├── Management Subscriptions (Policies, Identity, Audit)
├── Shared Services (Hub VNet, Firewall, Monitoring)
│   └── Hub VNet (10.0.0.0/16)
│       ├── Azure Firewall (L3-L7 filtering)
│       ├── Bastion Host (secure access)
│       └── Private Endpoints (10.0.4.0/24)
├── Project A (App 1, App 2, Database)
│   ├── Prod VNet (10.1.0.0/16)
│   └── Dev VNet (10.2.0.0/16)
└── Project B (App 3, App 4, Database)
    └── Prod VNet (10.3.0.0/16)
```

---

## Checklist for Implementation

### Before You Start
- [ ] Executive approval obtained
- [ ] Budget allocated
- [ ] Azure subscriptions created
- [ ] GitHub organization setup
- [ ] Team assigned (Platform, Security, Network)

### Week 1-4: Foundation
- [ ] Management Groups created
- [ ] Azure AD groups configured
- [ ] RBAC assignments completed
- [ ] Hub VNet deployed with Firewall
- [ ] Log Analytics Workspace created
- [ ] Key Vault deployed
- [ ] Audit logging enabled

### Week 5-8: Governance & Deployment
- [ ] Azure Policies deployed
- [ ] GitHub Actions workflows created
- [ ] Self-hosted runner deployed
- [ ] Terraform/Bicep templates validated
- [ ] CI/CD pipeline tested

### Week 9-10: Project Onboarding
- [ ] Spoke VNets created
- [ ] Application resources deployed
- [ ] Teams onboarded
- [ ] Monitoring dashboards created
- [ ] First deployments completed

### Week 11-12: Optimization & Handoff
- [ ] Performance baseline established
- [ ] Cost tracking validated
- [ ] Operations runbooks created
- [ ] Team training completed
- [ ] Go-live approved

---

## Quick Navigation

### I Need to...

#### Understand the Architecture
→ [README.md](./README.md) → [Architecture Diagrams](./diagrams/ARCHITECTURE_DIAGRAMS.md)

#### Deploy Network Infrastructure
→ [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) → [hub-vnet.tf](./iac/hub-vnet.tf)

#### Set Up Policies
→ [GOVERNANCE_POLICIES.md](./GOVERNANCE_POLICIES.md) → [banking-compliance.bicep](./policies/banking-compliance.bicep)

#### Configure Monitoring
→ [MONITORING_OBSERVABILITY.md](./MONITORING_OBSERVABILITY.md) → [monitoring-setup.bicep](./monitoring/monitoring-setup.bicep)

#### Create CI/CD Pipeline
→ [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) → See GitHub Actions workflows section

#### Manage Costs
→ [COST_MANAGEMENT.md](./COST_MANAGEMENT.md)

#### Implement Step-by-Step
→ [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md)

---

## Key Decisions & Rationale

| Decision | Choice | Why |
|----------|--------|-----|
| **Network Model** | Hub-and-Spoke | Scalability, centralized control, cost efficiency |
| **Security** | Private Endpoints | Zero-trust, prevent public exposure |
| **Governance** | Centralized via Policies | Consistent enforcement, compliance |
| **IaC Tool** | Terraform + Bicep | Best of both worlds - multi-cloud + Azure-native |
| **Deployment** | GitHub Actions | Version control, automation, audit trail |
| **Monitoring** | Azure-native (LAW, AI) | Integrated, no vendor lock-in, cost-effective |
| **Region** | South Africa North only | Data residency, compliance |
| **Backup Strategy** | Azure native (no DR) | Cost optimization per requirement |

---

## Common Commands

### Azure CLI Commands
```bash
# List subscriptions
az account list --output table

# Set active subscription
az account set --subscription "subscription-id"

# Create resource group
az group create --name rg-example --location southafricanorth

# Deploy Bicep template
az deployment group create \
  --resource-group rg-example \
  --template-file template.bicep

# Check policy compliance
az policy state list --resource-group rg-example
```

### Terraform Commands
```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive .

# Validate syntax
terraform validate

# Plan changes
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Show current state
terraform show

# Destroy resources
terraform destroy
```

### GitHub Commands
```bash
# Clone repository
gh repo clone banking-org/infrastructure

# Create pull request
gh pr create --title "Deploy Hub VNet" --body "Implementation of hub network"

# List workflows
gh workflow list

# View workflow runs
gh run list --workflow validate-infrastructure.yml
```

---

## Naming Conventions

### Resource Naming Pattern
```
{resource-type}-{project}-{environment}-{sequence}

Examples:
- vm-projecta-prod-001           (Virtual Machine)
- vnet-hub-prod                  (Virtual Network)
- fw-prod                        (Firewall)
- sqldb-projecta-prod-001        (SQL Database)
- kv-projecta-prod-001           (Key Vault)
- st-projectaprod-001            (Storage Account)
- law-banking-prod               (Log Analytics Workspace)
```

### Tag Structure
```
Required on every resource:
- Environment: Production, Staging, Development
- Project: Project-A, Project-B, Project-C
- Owner: owner@banking.com
- CostCenter: CC-1001
- ApplicationName: Banking-App-A1
- DataClassification: Confidential
```

---

## Security Checklist

- [ ] All PaaS services have private endpoints
- [ ] Public network access disabled for databases
- [ ] Encryption at rest enabled (TDE, CMK)
- [ ] Encryption in transit (TLS 1.2+)
- [ ] MFA enabled for all users
- [ ] RBAC configured (least privilege)
- [ ] Managed identities used (no service principal secrets)
- [ ] NSGs configured on all subnets
- [ ] Firewall rules reviewed and optimized
- [ ] Audit logging enabled and monitored
- [ ] Network Security Groups on every subnet
- [ ] Azure DDoS Protection enabled
- [ ] Key Vault purge protection on
- [ ] Secrets rotated every 90 days

---

## Monitoring Essentials

### Critical Metrics to Monitor
- Application availability (target: 99.9%)
- Response time P95 (target: < 2 seconds)
- Error rate (target: < 1%)
- Database DTU consumption (target: < 80%)
- CPU utilization (alert: > 85%)
- Memory utilization (alert: > 80%)
- Network throughput (baseline + 20%)

### Alert Thresholds
| Metric | Warning | Critical | Action |
|--------|---------|----------|--------|
| CPU Usage | 70% for 10 min | 85% for 5 min | Scale up / Investigate |
| Memory | 70% | 90% | Scale up / Optimize |
| Errors | 2% rate | 5% rate | Page on-call / Investigate |
| Availability | 99.5% | < 99% | Page on-call immediately |
| Failed Auth | 5 attempts/5min | 20 attempts/5min | Block IP / Investigate |

---

## Cost Targets

| Category | Monthly Budget | Typical Allocation |
|----------|----------------|--------------------|
| Compute | $4,000 | 40% |
| Database | $2,500 | 25% |
| Storage | $2,000 | 20% |
| Networking | $1,000 | 10% |
| Monitoring | $500 | 5% |
| **Total** | **$10,000** | **100%** |

**Cost Optimization Tips:**
- Use 1-year reserved instances for 30%+ savings
- Spot VMs for dev/test (70%+ discount)
- Lifecycle policies for storage (30-80% savings)
- Right-size based on utilization
- Review unused resources monthly

---

## Troubleshooting Quick Links

### Network Issues
- Cannot reach resource? → Check NSGs, Firewall rules, UDRs
- DNS not resolving? → Check Private DNS Zone links
- Latency spikes? → Check Firewall processing, VNet peering

### Policy Issues
- Resource creation denied? → Check Azure Policies, tags
- Policy not applying? → Check assignment scope, MG hierarchy

### Monitoring Issues
- Logs not appearing? → Check diagnostic settings, LAW permissions
- Alerts not firing? → Check alert rule criteria, action group config

### Deployment Issues
- Terraform apply fails? → Check provider auth, state lock
- GitHub Actions stuck? → Check runner status, secrets

---

## Support Matrix

| Issue Type | Response Time | Contact | Escalation |
|-----------|---------------|---------|------------|
| General Questions | 4 hours | platform-team@banking.com | CTO |
| Performance Degradation | 1 hour | ops-team@banking.com | VP Ops |
| Security Incident | 30 minutes | security-team@banking.com | CISO |
| Service Outage | 15 minutes | incident@banking.com | CTO |

---

## Document Versions

| Version | Date | Changes | Owner |
|---------|------|---------|-------|
| 1.0 | June 2026 | Initial design | Platform Architecture |

---

## Quick Links

- [Main Design Document](./README.md)
- [Architecture Diagrams](./diagrams/ARCHITECTURE_DIAGRAMS.md)
- [Implementation Guide](./IMPLEMENTATION_GUIDE.md)
- [Network Details](./NETWORK_ARCHITECTURE.md)
- [Policies & Governance](./GOVERNANCE_POLICIES.md)
- [Monitoring Setup](./MONITORING_OBSERVABILITY.md)
- [Infrastructure Templates](./iac/)

---

**Last Updated**: June 1, 2026  
**Next Review**: September 1, 2026
