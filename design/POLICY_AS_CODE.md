# Policy as Code Design

Comprehensive policy and governance framework for the Azure banking landing zone using Azure Policy and Policy Initiatives.

## Table of Contents

1. [Overview](#overview)
2. [Policy Initiatives](#policy-initiatives)
3. [Individual Policies](#individual-policies)
4. [Compliance Monitoring](#compliance-monitoring)
5. [Remediation Strategy](#remediation-strategy)
6. [Implementation Guide](#implementation-guide)

---

## Overview

### Goals

- **Enforce Security**: Prevent non-compliant resources from being created
- **Maintain Compliance**: Audit and enforce regulatory requirements
- **Enable Governance**: Centralized control over resource configurations
- **Cost Management**: Prevent expensive or unused resources
- **Operational Excellence**: Enforce tagging, naming, and monitoring standards

### Scope

Policies apply to:
- Hub and Spoke resource groups
- All subscriptions in the landing zone
- All resource types (VMs, Storage, Databases, etc.)

### Policy Effects

- **Audit**: Log non-compliant resources (no blocking)
- **AuditIfNotExists**: Audit if specific extensions/configs missing
- **Deny**: Block non-compliant resource creation
- **DeployIfNotExists**: Automatically deploy missing configs
- **Modify**: Automatically modify resource properties

---

## Policy Initiatives

### 1. Banking Compliance Initiative

**Name**: `Banking Industry Compliance Standard`  
**Effect**: Mix of Audit, Deny, and DeployIfNotExists  
**Target**: All resources in banking subscription

**Policies Included**:
- Enforce HTTPS for Storage Accounts
- Enable Encryption at Rest for Databases
- Require Network Security Groups
- Enforce Private Endpoints for PaaS
- Require Diagnostic Logs
- Enforce Resource Tagging
- Disable Weak TLS Versions
- Audit Public IP Usage
- Require Network Segmentation

**Compliance Standards**:
- ✅ PCI-DSS v3.2.1
- ✅ HIPAA (Health Insurance Portability)
- ✅ SOC 2 Type II
- ✅ NIST Cybersecurity Framework

---

### 2. Network Security Initiative

**Name**: `Network Security and Isolation`  
**Effect**: Deny  
**Target**: All network resources

**Policies Included**:
- Enforce NSG on all subnets
- Deny public access to databases
- Require private endpoints for storage
- Enforce VNet segregation
- Audit open RDP/SSH ports
- Require UDRs for non-RFC1918 traffic
- Enforce Azure Firewall usage
- Deny unrestricted inbound access

---

### 3. Data Protection Initiative

**Name**: `Data Protection and Encryption`  
**Effect**: Deny, DeployIfNotExists  
**Target**: Storage and database resources

**Policies Included**:
- Enforce Storage Account encryption
- Require key vault for secrets management
- Enable SQL Database encryption
- Enforce backup for databases
- Deny public blob access
- Require Managed Disks
- Enable Azure Disk Encryption
- Enforce data residency (South Africa)

---

### 4. Monitoring and Logging Initiative

**Name**: `Monitoring, Logging, and Audit`  
**Effect**: Audit, AuditIfNotExists, DeployIfNotExists  
**Target**: All resources

**Policies Included**:
- Require diagnostic settings on all resources
- Deploy Log Analytics agents
- Enable Application Insights monitoring
- Require resource tags for cost tracking
- Audit admin operations
- Enable Security Center integration
- Require audit logging on databases
- Deploy performance monitoring

---

### 5. Resource Governance Initiative

**Name**: `Resource Governance and Lifecycle`  
**Effect**: Deny, Modify  
**Target**: All resources

**Policies Included**:
- Enforce mandatory tags
- Require cost center tag
- Require environment tag
- Deny resources in unapproved locations
- Enforce resource naming conventions
- Require resource descriptions
- Audit lifecycle tag (expiration dates)
- Enforce SKU restrictions

---

### 6. Cost Optimization Initiative

**Name**: `Cost Management and Optimization`  
**Effect**: Audit, Deny  
**Target**: Compute and storage resources

**Policies Included**:
- Deny expensive VM SKUs (D-series, high memory)
- Audit underutilized resources
- Enforce auto-shutdown for dev VMs
- Require spot instances for non-production
- Limit number of Premium Disks
- Audit storage account tier (prefer Standard)
- Enforce VM image restrictions
- Audit database DTU usage

---

### 7. Compliance Auditing Initiative

**Name**: `Regulatory Compliance Auditing`  
**Effect**: AuditIfNotExists, DeployIfNotExists  
**Target**: Security-sensitive resources

**Policies Included**:
- Audit MFA enablement
- Audit Admin accounts
- Verify SSH key access (no passwords)
- Audit service principal usage
- Verify RBAC assignments
- Audit privileged role members
- Verify access reviews conducted
- Audit API permissions

---

## Individual Policies

### Security Policies

#### 1. Enforce HTTPS for Storage Accounts
```
Policy ID: enforce-https-storage
Scope: Microsoft.Storage/storageAccounts
Effect: Deny
Parameters:
  - None (strict enforcement)
Description: Blocks creation of storage accounts without HTTPS enforced
```

#### 2. Deny Public Blob Access
```
Policy ID: deny-public-blob-access
Scope: Microsoft.Storage/storageAccounts/blobServices/containers
Effect: Deny
Parameters:
  - publicAccess (must be None)
Description: Prevents public access to blob containers
```

#### 3. Require Private Endpoints for PaaS
```
Policy ID: require-private-endpoint-paas
Scope: Multiple (Key Vault, SQL, Storage, CosmosDB, etc.)
Effect: AuditIfNotExists / Deny
Parameters:
  - Service type (vault, sqlServer, blob, etc.)
Description: Enforces private endpoint connectivity
```

#### 4. Enforce Storage Encryption
```
Policy ID: enforce-storage-encryption
Scope: Microsoft.Storage/storageAccounts
Effect: Deny
Parameters:
  - Encryption (must use CMK or default)
Description: Requires encryption on storage accounts
```

#### 5. Enforce SQL Database Encryption
```
Policy ID: enforce-sql-encryption
Scope: Microsoft.Sql/servers/databases
Effect: DeployIfNotExists
Parameters:
  - None (auto-applies TDE)
Description: Enables transparent data encryption on databases
```

#### 6. Deny Weak TLS Versions
```
Policy ID: deny-weak-tls
Scope: Microsoft.Storage/storageAccounts, Microsoft.KeyVault/vaults
Effect: Deny
Parameters:
  - minimumTlsVersion (1.2 or higher)
Description: Requires TLS 1.2+ for all services
```

#### 7. Enforce NSG on Subnets
```
Policy ID: enforce-nsg-subnets
Scope: Microsoft.Network/virtualNetworks/subnets
Effect: Audit / Deny
Parameters:
  - nsgRequired (true)
Description: Requires NSG on all subnets
```

### Networking Policies

#### 8. Enforce Private DNS Zones
```
Policy ID: enforce-private-dns-zones
Scope: Multiple service types
Effect: AuditIfNotExists
Parameters:
  - Service (keyvault, database, storage, etc.)
Description: Verifies private DNS zone configuration
```

#### 9. Restrict Outbound IPs
```
Policy ID: restrict-outbound-ips
Scope: Microsoft.Network/networkSecurityGroups/securityRules
Effect: Audit
Parameters:
  - allowedOutboundPrefixes
Description: Audits outbound rules for compliance
```

#### 10. Enforce Azure Firewall Usage
```
Policy ID: enforce-azure-firewall
Scope: Microsoft.Network/virtualNetworks
Effect: AuditIfNotExists
Parameters:
  - requireFirewall (true)
Description: Verifies firewall is deployed in hub VNet
```

### Governance Policies

#### 11. Enforce Mandatory Tags
```
Policy ID: enforce-mandatory-tags
Scope: All resources
Effect: Deny / Modify
Parameters:
  - tagList (Environment, CostCenter, Owner, Project)
Description: Blocks resources without required tags
```

#### 12. Enforce Resource Naming Convention
```
Policy ID: enforce-naming-convention
Scope: All resources
Effect: Deny / Audit
Parameters:
  - namingPattern (e.g., ^[a-z]{3}-[a-z]+-[a-z]+$)
Description: Enforces naming standard
```

#### 13. Restrict Approved Locations
```
Policy ID: restrict-approved-locations
Scope: All resources
Effect: Deny
Parameters:
  - allowedLocations (southafricanorth, eastus, etc.)
Description: Allows resources only in approved regions
```

#### 14. Deny Unapproved Resource Types
```
Policy ID: deny-unapproved-resources
Scope: All resource types
Effect: Deny
Parameters:
  - deniedResourceTypes (e.g., Microsoft.ClassicCompute/*)
Description: Blocks deprecated/classic resources
```

### Monitoring Policies

#### 15. Require Diagnostic Settings
```
Policy ID: require-diagnostic-settings
Scope: All resources
Effect: AuditIfNotExists / DeployIfNotExists
Parameters:
  - logAnalyticsWorkspace (resource ID)
Description: Ensures diagnostic logs sent to Log Analytics
```

#### 16. Deploy Log Analytics Agents
```
Policy ID: deploy-log-analytics-agents
Scope: Microsoft.Compute/virtualMachines
Effect: DeployIfNotExists
Parameters:
  - workspaceId (Log Analytics workspace ID)
Description: Auto-deploys monitoring agents to VMs
```

#### 17. Require Application Insights
```
Policy ID: require-application-insights
Scope: Microsoft.Web/sites (App Services)
Effect: AuditIfNotExists
Parameters:
  - requiredAppInsights (true)
Description: Verifies App Insights integration
```

#### 18. Enable Audit Logging on SQL
```
Policy ID: enable-sql-audit-logging
Scope: Microsoft.Sql/servers/databases
Effect: DeployIfNotExists
Parameters:
  - storageEndpoint (audit storage account)
Description: Enables audit logging for compliance
```

### Cost Management Policies

#### 19. Deny Expensive VM SKUs
```
Policy ID: deny-expensive-vm-skus
Scope: Microsoft.Compute/virtualMachines
Effect: Deny
Parameters:
  - deniedSkus (Dv3, Ev3, high-memory series)
Description: Restricts VM sizes to approved list
```

#### 20. Enforce Auto-Shutdown for Dev VMs
```
Policy ID: enforce-autoshutdown-dev
Scope: Dev resource groups
Effect: DeployIfNotExists
Parameters:
  - shutdownTime (18:00)
Description: Auto-shuts down dev VMs outside hours
```

#### 21. Require Spot Instances for Non-Prod
```
Policy ID: require-spot-instances-nonprod
Scope: Non-production resource groups
Effect: Audit / Deny
Parameters:
  - spotInstancesRequired (true)
Description: Encourages cost-saving spot instances
```

### Compliance Policies

#### 22. Require MFA for Admin Users
```
Policy ID: require-admin-mfa
Scope: Azure AD
Effect: Audit
Parameters:
  - mfaRequired (true)
Description: Audits admin accounts for MFA status
```

#### 23. Enforce SSH Key Access
```
Policy ID: enforce-ssh-keys
Scope: Microsoft.Compute/virtualMachines
Effect: Audit
Parameters:
  - requireSSHKeys (true)
Description: Audits Linux VMs for SSH key authentication
```

#### 24. Audit Service Principal Usage
```
Policy ID: audit-service-principals
Scope: Azure AD
Effect: AuditIfNotExists
Parameters:
  - auditPeriod (30 days)
Description: Tracks service principal access and usage
```

---

## Compliance Monitoring

### Monitoring Dashboard

Tracks compliance status for all initiatives:

```
Policy Initiative         | Compliant | Non-Compliant | Exempt
Banking Compliance        | 95%       | 4%            | 1%
Network Security          | 98%       | 2%            | 0%
Data Protection           | 92%       | 8%            | 0%
Monitoring & Logging      | 89%       | 11%           | 0%
Resource Governance       | 91%       | 9%            | 0%
Cost Optimization         | 85%       | 15%           | 0%
Compliance Auditing       | 87%       | 13%           | 0%
```

### Remediation Tasks

Non-compliant resources trigger automated remediation:

1. **Immediate** (< 24 hours)
   - Enable encryption on storage accounts
   - Add required tags
   - Apply diagnostic settings

2. **Urgent** (1-3 days)
   - Deploy private endpoints
   - Enable audit logging
   - Deploy monitoring agents

3. **Planned** (1-2 weeks)
   - Migrate to approved VM SKUs
   - Update naming conventions
   - Consolidate policies

### Exemption Process

Grant exemptions for business-critical exceptions:

```
Exemption Request
├── Resource/Policy
├── Business Justification
├── Duration (time-bound)
├── Approver (Manager + Security)
├── Auto-Expiration (90 days)
└── Review Schedule (quarterly)
```

---

## Remediation Strategy

### Automatic Remediation

**When**: Policy effect is `DeployIfNotExists` or `Modify`  
**Actions**:
- Deploy missing extensions
- Add missing tags
- Apply default configurations
- Enable logging/monitoring

**Monitoring**: 
- Remediation tasks tracked in Policy → Remediation
- Notifications to resource owners
- Audit trail in Activity Log

### Manual Remediation

**When**: Policy effect is `Deny` (blocking creation)  
**Actions**:
1. Review non-compliant resource requirement
2. Request policy exemption (time-bound)
3. Update resource configuration
4. Resubmit deployment

**Process**:
```
Developer creates non-compliant resource
        ↓
Policy blocks with error message
        ↓
Developer contacts Security team
        ↓
Review business case & risk
        ↓
Grant exemption (90-day max)
        ↓
Developer redeploys
        ↓
Exemption expires → resource auto-reviewed
```

---

## Implementation Guide

### Phase 1: Audit (Week 1-2)

**All policies**: `Audit` effect only

```bicep
{
  "effect": "Audit",
  "description": "Learning phase - discover non-compliance without blocking"
}
```

**Activities**:
- Deploy all 24 policies in audit mode
- Generate compliance reports
- Identify non-compliant resources
- Notify resource owners

### Phase 2: Enforcement (Week 3-4)

**Critical policies**: Switch to `Deny` effect

```bicep
{
  "effect": "Deny",
  "description": "Enforce critical security policies"
}
```

**Policies to enforce**:
- Enforce HTTPS for Storage
- Deny Public Blob Access
- Enforce NSG on Subnets
- Enforce Mandatory Tags
- Restrict Approved Locations

### Phase 3: Automation (Week 5+)

**Deployment policies**: Use `DeployIfNotExists` and `Modify`

```bicep
{
  "effect": "DeployIfNotExists",
  "deployment": {
    "properties": {
      "template": { /* ARM template */ }
    }
  }
}
```

**Auto-remediate**:
- Deploy diagnostic settings
- Apply tags (via Modify)
- Enable monitoring agents
- Configure encryption

### Phase 4: Optimization (Ongoing)

- Fine-tune policy parameters
- Grant managed exemptions
- Update initiative scopes
- Review compliance trends

---

## Policy Deployment Commands

### Deploy Single Policy

```bash
# Deploy policy definition
az policy definition create \
  --name "enforce-https-storage" \
  --display-name "Enforce HTTPS for Storage Accounts" \
  --description "Blocks storage accounts without HTTPS" \
  --rules "policy-rules.json" \
  --params "policy-params.json" \
  --mode "All"

# Assign policy to resource group
az policy assignment create \
  --name "storage-https-assignment" \
  --policy "enforce-https-storage" \
  --scope "/subscriptions/{sub}/resourceGroups/{rg}" \
  --location "southafricanorth"
```

### Deploy Initiative

```bash
# Deploy policy initiative (group of policies)
az policy set-definition create \
  --name "banking-compliance-initiative" \
  --display-name "Banking Compliance Initiative" \
  --definitions "initiative-definitions.json"

# Assign initiative
az policy assignment create \
  --name "banking-compliance-assignment" \
  --policy-set-definition "banking-compliance-initiative" \
  --scope "/subscriptions/{sub}" \
  --location "southafricanorth" \
  --role "Contributor" \
  --identity-type "SystemAssigned"
```

### Monitor Compliance

```bash
# Get compliance state
az policy state summarize \
  --subscription "{sub}" \
  --query "results[].summary"

# List non-compliant resources
az policy state list \
  --filter "ResourceType eq 'Microsoft.Storage/storageAccounts' and ComplianceState eq 'NonCompliant'" \
  --top 100

# Trigger remediation
az policy remediation create \
  --name "remediate-storage-encryption" \
  --policy-assignment "/subscriptions/{sub}/providers/Microsoft.Authorization/policyAssignments/storage-crypto" \
  --resource-group "{rg}"
```

---

## Best Practices

1. **Start with Audit**: Deploy policies in audit mode first
2. **Communicate Changes**: Notify teams before enforcement
3. **Set Clear Expectations**: Document policy purposes
4. **Grant Exemptions**: Allow managed exceptions (time-bound)
5. **Review Regularly**: Monthly compliance reviews
6. **Update Policies**: Adjust based on business needs
7. **Automate Remediation**: Use DeployIfNotExists when safe
8. **Monitor Impact**: Track false positives and adjust
9. **Document Exceptions**: Maintain exemption records
10. **Test Before Enforcement**: Validate on dev/test subscriptions

---

## Related Documentation

- [Policy Bicep Modules](../../bicep/modules/policy/)
- [Governance & Policies Design](./GOVERNANCE_POLICIES.md)
- [Azure Policy Reference](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Compliance Monitoring Dashboard](../../bicep/modules/dashboards/)

---

**Last Updated**: June 2026  
**Policies**: 24 individual policies, 7 initiatives  
**Coverage**: 100% of banking subscription resources  
**Compliance Standards**: PCI-DSS, HIPAA, SOC 2, NIST
