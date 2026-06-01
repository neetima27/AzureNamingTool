# Implementation Guide

## Overview

This guide provides step-by-step instructions for implementing the banking sector landing zone design.

## Pre-Implementation Checklist

- [ ] Executive Approval
  - [ ] Architecture review completed
  - [ ] Budget approved
  - [ ] Timeline agreed
  - [ ] RACI matrix defined

- [ ] Team Setup
  - [ ] Platform engineering team assigned
  - [ ] Security team engaged
  - [ ] Network team assigned
  - [ ] Finance team aligned

- [ ] Tools & Access
  - [ ] Azure Subscription(s) created
- [ ] Bicep installed locally
  - [ ] GitHub self-hosted runner repository created

- [ ] Compliance & Governance
  - [ ] Compliance requirements documented
  - [ ] Audit requirements confirmed
  - [ ] Data classification policy defined
  - [ ] Naming conventions agreed

---

## Phase 1: Foundation (Weeks 1-4)

### Week 1: Setup & Planning

**Tasks:**
1. Create Azure Management Groups hierarchy
   ```bash
   az account management-group create --name Root
   az account management-group create --name Management --parent Root
   az account management-group create --name Projects --parent Root
   az account management-group create --name SharedServices --parent Root
   ```

2. Create Subscriptions
   ```bash
   # Management Subscription
   az account create --offer MS-AZR-0148P --product Microsoft.Azure.Subscriptions
   
   # Connectivity Subscription
   az account create --offer MS-AZR-0148P --product Microsoft.Azure.Subscriptions
   
   # Monitoring Subscription
   az account create --offer MS-AZR-0148P --product Microsoft.Azure.Subscriptions
   
   # Project A Subscriptions (Prod & Dev)
   # Project B Subscriptions (Prod & Dev)
   ```

3. Setup Azure AD Groups
   ```bash
   # Platform Engineers
   az ad group create --display-name "Platform Engineers" --mail-nickname platform-engineers
   
   # Security Team
   az ad group create --display-name "Security Team" --mail-nickname security-team
   
   # Project A Owners
   az ad group create --display-name "Project A Owners" --mail-nickname project-a-owners
   
   # Project B Owners
   az ad group create --display-name "Project B Owners" --mail-nickname project-b-owners
   ```

4. Configure RBAC
   ```bash
   # Platform Engineers - Owner at Management MG
   az role assignment create \
     --role "Owner" \
     --assignee-object-id <platform-engineers-group-id> \
     --scope /providers/Microsoft.Management/managementGroups/Management
   
   # Security Team - Security Admin at Root
   az role assignment create \
     --role "Security Admin" \
     --assignee-object-id <security-team-group-id> \
     --scope /providers/Microsoft.Management/managementGroups/Root
   ```

**Deliverables:**
- ✓ Management Group hierarchy created
- ✓ Subscriptions provisioned
- ✓ Azure AD groups configured
- ✓ RBAC assignments completed

### Week 2: Network Foundation

**Tasks:**
1. Deploy Hub VNet with Bicep
   ```bash
   az bicep build --file bicep/landing-zone/hub-vnet.bicep
   az deployment group create \
     --resource-group rg-hub-prod \
     --template-file bicep/landing-zone/hub-vnet.json
   ```

2. Deploy Firewall and Bastion
   - Included in `bicep/landing-zone/hub-vnet.bicep`
   - Verify Azure Firewall and Bastion health

3. Setup Private DNS Zones
   - Key Vault: privatelink.vaultcore.azure.net
   - SQL Database: privatelink.database.windows.net
   - Storage: privatelink.blob.core.windows.net

4. Configure Bastion access
   - Test connectivity from Bastion to VM in app tier

**Deliverables:**
- ✓ Hub VNet (10.19.0.0/16) created
- ✓ Azure Firewall deployed and configured
- ✓ Bastion host operational
- ✓ Private DNS zones linked

### Week 3: Monitoring Infrastructure

**Tasks:**
1. Deploy Log Analytics Workspace
   ```bash
   az bicep build --file monitoring/monitoring-setup.bicep
   az deployment group create \
     --resource-group rg-monitoring-prod \
     --template-file monitoring-setup.json
   ```

2. Configure Diagnostic Settings
   - Enable for all resources
   - Route to Log Analytics

3. Deploy Application Insights
   - Connected to LAW
   - Private endpoint enabled

4. Setup Alert Rules
   - High CPU
   - Low availability
   - Authentication failures

**Deliverables:**
- ✓ Log Analytics Workspace (730-day retention)
- ✓ Application Insights configured
- ✓ Diagnostic settings enabled
- ✓ Alert rules deployed

### Week 4: Security & Identity

**Tasks:**
1. Deploy Key Vault
   - Private endpoint enabled
   - Purge protection on
   - HSM-backed keys

2. Configure Managed Identities
   - System-assigned for Azure services
   - User-assigned for applications

3. Enable MFA
   - All users require MFA
   - Conditional access policies

4. Setup Audit Logging
   - Azure Activity Log → LAW
   - Azure AD Audit Logs → LAW

**Deliverables:**
- ✓ Key Vault (Premium SKU) deployed
- ✓ Managed identities configured
- ✓ MFA enabled organization-wide
- ✓ Audit logging operational

---

## Phase 2: Governance & Policies (Weeks 5-6)

### Week 5: Policy Implementation

**Tasks:**
1. Deploy Banking Compliance Initiative
   ```bash
   az bicep build --file policies/banking-compliance.bicep
   az deployment mg create \
     --location southafricanorth \
     --management-group-id Root \
     --template-file banking-compliance.json
   ```

2. Apply Policy Assignments
   - Assign to Management Groups
   - Verify compliance status
   - Create exception requests as needed

3. Test Policy Enforcement
   - Create test resource without tags → Should be denied
   - Create resource in different region → Should be denied
   - Create public endpoint → Should be denied

**Deliverables:**
- ✓ Azure Policy definitions created
- ✓ Policy initiatives assigned
- ✓ Compliance baseline established
- ✓ Policy exceptions documented

### Week 6: Governance Enforcement

**Tasks:**
1. Configure Cost Analysis
   - Set up tagging strategy
   - Create cost center mappings
   - Enable anomaly detection

2. Setup Budgets & Alerts
   ```bash
   az billing budget create \
     --name budget-project-a \
     --amount 10000 \
     --time-period monthly
   ```

3. Document Governance Processes
   - Resource request process
   - Policy exception workflow
   - Change management procedure

**Deliverables:**
- ✓ Cost tracking configured
- ✓ Budgets and alerts set
- ✓ Governance documentation finalized

---

## Phase 3: Deployment Pipeline (Weeks 7-8)

### Week 7: GitHub Setup & Runner Configuration

**Tasks:**
1. Create GitHub Repository
   - Initialize with infrastructure code
   - Setup branch protection rules
   - Configure code owners

2. Deploy Self-Hosted Runner
   ```bash
   # On VM in Hub VNet
   mkdir actions-runner && cd actions-runner
   
   # Download runner
   curl -o actions-runner-linux-x64-2.310.0.tar.gz \
     -L https://github.com/actions/runner/releases/download/v2.310.0/actions-runner-linux-x64-2.310.0.tar.gz
   
   tar xzf ./actions-runner-linux-x64-2.310.0.tar.gz
   
   # Configure with GitHub token
   ./config.sh --url https://github.com/banking-org/infrastructure \
     --token {GITHUB_TOKEN} \
     --labels "self-hosted,private-network"
   
   # Install and start service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```

3. Configure GitHub Secrets
   ```bash
   # Add secrets via GitHub UI or CLI
   gh secret set AZURE_CLIENT_ID -b "client-id"
   gh secret set AZURE_TENANT_ID -b "tenant-id"
   gh secret set AZURE_SUBSCRIPTION_ID -b "sub-id"
   ```

4. Test Runner Connectivity
   - Push test workflow
   - Verify successful execution

**Deliverables:**
- ✓ GitHub repository created and configured
- ✓ Self-hosted runner deployed
- ✓ GitHub secrets configured
- ✓ Runner connectivity verified

### Week 8: CI/CD Pipeline Implementation

**Tasks:**
1. Create GitHub Actions Workflows
   - validate-infrastructure.yml
   - plan-infrastructure.yml
   - deploy-infrastructure.yml

2. Test Workflows
   - Create feature branch
   - Push code changes
   - Verify plan and approval workflow

3. Configure Branch Protection
   ```
   - Require PR reviews: 2
   - Require status checks to pass
   - Require workflow approval for main branch
   ```

4. Document Deployment Process
   - How to create PR
   - How to review infrastructure changes
   - How to deploy to production

**Deliverables:**
- ✓ GitHub Actions workflows configured
- ✓ PR review process established
- ✓ Deployment pipeline tested
- ✓ Documentation completed

---

## Phase 4: Project Onboarding (Weeks 9-10)

### Project A Onboarding

**Tasks:**
1. Create Project Subscriptions
   - Project A Prod
   - Project A Dev/Test

2. Setup Project VNets
   - Prod: 10.19.16.0/20
   - Dev: 10.19.32.0/20
   - Configure peering to hub

3. Deploy Application Resources
   - SQL Database (with Private Endpoint)
   - App Service
   - Storage Account
   - Blob containers for data

4. Onboard Application Team
   - Assign RBAC roles
   - Provide access instructions
   - Training on naming conventions

5. Enable Monitoring
   - Application Insights
   - Diagnostic settings
   - Custom dashboards

**Timeline:** Week 9

### Project B Onboarding

**Tasks:** Same as Project A (Week 10)

**Deliverables:**
- ✓ Project subscriptions created
- ✓ Network infrastructure deployed
- ✓ Application resources provisioned
- ✓ Teams onboarded and trained
- ✓ Monitoring configured

---

## Phase 5: Optimization (Weeks 11-12)

### Week 11: Performance Tuning

**Tasks:**
1. Review Monitoring Data
   - Application performance
   - Infrastructure utilization
   - Error patterns

2. Optimize Firewall Rules
   - Remove unnecessary rules
   - Optimize rule order for performance

3. Fine-tune Alerts
   - Adjust thresholds based on baseline
   - Reduce false positives

4. Review Logs
   - Check for expected patterns
   - Investigate anomalies

### Week 12: Knowledge Transfer

**Tasks:**
1. Conduct Training Sessions
   - Platform operations
   - Incident response
   - Deployment procedures

2. Create Runbooks
   - Common troubleshooting steps
   - Escalation procedures
   - Recovery procedures

3. Document Lessons Learned
   - What worked well
   - What to improve
   - Recommendations for phase 2

4. Handoff to Operations Team
   - Provide documentation
   - Confirm support procedures
   - Establish SLAs

**Deliverables:**
- ✓ Performance baseline established
- ✓ Operations team trained
- ✓ Runbooks created
- ✓ Lessons learned documented

---

## Go-Live Readiness Checklist

Before production deployment:

- [ ] All Azure Policies passing
- [ ] Monitoring dashboard operational
- [ ] Alert rules tested
- [ ] Firewall rules verified
- [ ] Backup strategy confirmed
- [ ] Disaster recovery plan documented
- [ ] Change management approved
- [ ] Rollback procedure tested
- [ ] All teams trained
- [ ] Executive sign-off obtained

---

## Rollback Procedure

If issues occur during deployment:

1. **Immediate Actions**
   - Stop all deployments
   - Alert all stakeholders
   - Preserve logs

2. **Rollback Steps**
   - Use Bicep deployment logs and resource group snapshots to rollback
   - Restore from backups if needed
   - Verify data integrity

3. **Root Cause Analysis**
   - Investigate what went wrong
   - Document findings
   - Prevent recurrence

4. **Re-deployment**
   - Fix identified issues
   - Re-test thoroughly
   - Get re-approval
   - Deploy with caution

---

## Support & Escalation

**Tier 1 Support (4-hour response):**
- General questions
- Documentation requests
- Non-urgent issues

**Tier 2 Support (1-hour response):**
- Performance issues
- Service degradation
- Policy violations

**Tier 3 Support (30-minute response):**
- Service outages
- Security incidents
- Critical policy violations

**Escalation Contacts:**
- Platform Engineering: platform-team@banking.com
- Security Team: security-team@banking.com
- Finance: finance-team@banking.com

---

**Document Version**: 1.0  
**Last Updated**: June 2026
