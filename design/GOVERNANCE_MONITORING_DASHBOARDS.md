# Governance, Monitoring & Dashboards Comprehensive Design

Complete framework for Policy as Code, Monitoring as Code, and Dashboards as Code in the Azure banking landing zone.

## Document Organization

This comprehensive design spans three complementary frameworks:

### 1. Policy as Code Design
**File**: [POLICY_AS_CODE.md](./POLICY_AS_CODE.md)

Governance framework with:
- 24 individual policies across 7 initiatives
- Banking compliance mapping (PCI-DSS, HIPAA, SOC 2, NIST)
- Compliance monitoring and scoring
- Remediation strategies (automatic and manual)
- 4-phase deployment approach (Audit → Enforcement → Automation → Optimization)

**Key Initiatives**:
- Banking Compliance Initiative
- Network Security Initiative
- Data Protection Initiative
- Monitoring & Logging Initiative
- Resource Governance Initiative
- Cost Optimization Initiative
- Compliance Auditing Initiative

---

### 2. Monitoring as Code Design
**File**: [MONITORING_AS_CODE.md](./MONITORING_AS_CODE.md)

Observability framework with:
- 3-tier data collection strategy (critical, standard, audit)
- 40+ metric definitions with thresholds
- 15+ Log Analytics saved queries
- 10+ alert rule examples
- Alert routing via action groups
- Compliance and performance metrics

**Key Components**:
- Firewall, Gateway, and Network metrics
- Storage and Database performance tracking
- Application performance monitoring
- Security threat detection
- Compliance auditing

---

### 3. Dashboards as Code Design
**File**: [DASHBOARDS_AS_CODE.md](./DASHBOARDS_AS_CODE.md)

Visualization framework with:
- 6 pre-designed dashboard templates
- KPI tiles, trend charts, and detailed tables
- Operational, security, performance, cost, and executive dashboards
- Network topology visualization
- Mobile-friendly layouts

**Key Dashboards**:
1. Banking Operational Dashboard - Real-time ops status
2. Security & Compliance Dashboard - Threat and policy monitoring
3. Application Performance Dashboard - App health metrics
4. Cost & Resource Dashboard - Spending and utilization
5. Network Topology Dashboard - Network visualization
6. Executive Summary Dashboard - High-level metrics

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Azure Landing Zone                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Resource Deployment (IaC)                   │  │
│  │  - Hub & Spoke VNets                                     │  │
│  │  - PaaS Services (Storage, SQL, Key Vault)               │  │
│  │  - Compute (VMs, App Services)                           │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                     │
│  ┌────────────────────────▼─────────────────────────────────┐  │
│  │          Policy as Code (Governance Layer)               │  │
│  │  - 24 Policies, 7 Initiatives                            │  │
│  │  - Compliance monitoring & scoring                       │  │
│  │  - Automatic & manual remediation                        │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                     │
│  ┌────────────────────────▼─────────────────────────────────┐  │
│  │      Monitoring as Code (Observability Layer)            │  │
│  │  - Log Analytics Workspace                               │  │
│  │  - Diagnostic Settings on all resources                  │  │
│  │  - 40+ metrics & thresholds                              │  │
│  │  - 10+ alert rules with escalation                       │  │
│  └────────────────────────┬─────────────────────────────────┘  │
│                           │                                     │
│  ┌────────────────────────▼─────────────────────────────────┐  │
│  │       Dashboards as Code (Visualization Layer)           │  │
│  │  - 6 pre-built workbooks                                 │  │
│  │  - Real-time operational dashboards                      │  │
│  │  - Security, performance, cost, executive views          │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Roadmap

### Phase 1: Foundation (Week 1-2)

**Objectives**: Establish logging and monitoring infrastructure

**Deliverables**:
- ✅ Log Analytics Workspace deployed
- ✅ Diagnostic settings enabled on all resources
- ✅ Application Insights configured
- ✅ Log retention policies (90 days detailed, 1 year summary)

**Tasks**:
1. Deploy Log Analytics workspace (30-day retention minimum)
2. Enable diagnostic settings on all PaaS services
3. Deploy Application Insights for app monitoring
4. Configure data ingestion from Azure services

**Validation**:
```bash
# Verify diagnostic settings
az monitor diagnostic-settings list --resource {resourceId}

# Check workspace ingestion
az monitor log-analytics workspace show --resource-group {rg} --workspace-name {name}
```

---

### Phase 2: Governance Layer (Week 3-4)

**Objectives**: Deploy policy framework for compliance enforcement

**Deliverables**:
- ✅ All 24 policies deployed in Audit mode
- ✅ Policy initiatives created and assigned
- ✅ Compliance baseline established
- ✅ Policy exemption process documented

**Tasks**:
1. Deploy all policies in Audit mode first
2. Generate baseline compliance reports
3. Identify and document exceptions
4. Create exemption approval workflow

**Compliance Timeline**:
```
Week 3:
- Day 1-2: Deploy 8 security policies (Audit)
- Day 3-4: Deploy 6 network policies (Audit)
- Day 5: Deploy 5 governance policies (Audit)

Week 4:
- Day 1-2: Deploy 3 monitoring policies (Audit)
- Day 3-4: Generate compliance reports
- Day 5: Review findings and plan enforcement
```

**Validation**:
```bash
# Check compliance state
az policy state summarize --subscription {sub}

# List non-compliant resources
az policy state list --filter "ComplianceState eq 'NonCompliant'"
```

---

### Phase 3: Alerting & Observability (Week 5-6)

**Objectives**: Configure alerts, metrics, and initial dashboards

**Deliverables**:
- ✅ Action groups created for different teams
- ✅ 10+ critical alerts deployed
- ✅ Metric baselines established
- ✅ Operational dashboard live

**Tasks**:
1. Create action groups (Ops, Security, Finance)
2. Deploy alert rules with escalation paths
3. Configure alert notifications
4. Test alert routing

**Alert Deployment**:
```
Critical Alerts (Deploy First):
- Firewall down
- Database unavailable
- Storage account inaccessible
- Security threats detected

Standard Alerts (Deploy Second):
- High CPU/Memory usage
- Storage capacity warning
- Failed transactions
- Slow queries
```

**Validation**:
```bash
# List all alerts
az monitor metrics alert list --resource-group {rg}

# Test alert action group
az monitor action-group test-notifications --resource-group {rg} \
  --action-group-name {name} --receiver-name {receiver}
```

---

### Phase 4: Dashboard Deployment (Week 7)

**Objectives**: Provide operational visibility through dashboards

**Deliverables**:
- ✅ Banking Operational Dashboard live
- ✅ Security & Compliance Dashboard live
- ✅ Application Performance Dashboard live
- ✅ Cost & Resource Dashboard live

**Tasks**:
1. Deploy operational dashboard for daily ops
2. Deploy security dashboard for compliance team
3. Deploy performance dashboard for app teams
4. Deploy cost dashboard for finance

**Dashboard Access**:
```bash
# Get dashboard URL
az resource show --ids {dashboardId} --query "properties.resourceId"

# Share dashboard
az role assignment create --assignee {user@company.com} \
  --role "Monitoring Reader" --scope {dashboardId}
```

---

### Phase 5: Enforcement Mode (Week 8+)

**Objectives**: Transition policies from Audit to enforcement

**Deliverables**:
- ✅ Critical policies switched to Deny effect
- ✅ Automatic remediation configured
- ✅ Compliance score > 95%
- ✅ Incident response playbooks tested

**Enforcement Strategy**:
```
Week 8:
- Policies 1-5: Switch to Deny (most non-compliant: 0-5%)
- Policies 6-15: Keep Audit (moderate non-compliance: 5-15%)
- Policies 16-24: Keep Audit (low non-compliance: 0-5%)

Week 9-10:
- Gradual rollout of remaining Deny policies
- Monitor false positives and adjust
- Auto-remediation for safe policies (DeployIfNotExists)

Week 11+:
- 100% enforcement
- Ongoing compliance monitoring
- Quarterly policy reviews
```

---

## Integration with Bicep IaC

### Module Structure

```
bicep/
├── landing-zone/
│   └── main.bicep (orchestrator - includes policy & monitoring modules)
├── modules/
│   ├── policy/
│   │   ├── policy-definition.bicep
│   │   ├── policy-initiative.bicep
│   │   ├── policy-assignment.bicep
│   │   └── banking-compliance-policies.bicep
│   ├── monitoring/
│   │   ├── diagnostic-settings.bicep
│   │   ├── metric-alerts.bicep
│   │   ├── action-groups.bicep
│   │   ├── log-analytics.bicep (existing)
│   │   └── application-insights.bicep (existing)
│   └── dashboards/
│       ├── workbooks.bicep
│       └── banking-operational-dashboard.bicep
└── parameters/
    ├── dev.parameters.json
    ├── staging.parameters.json
    └── prod.parameters.json
```

### Updated main.bicep Flow

```bicep
1. Create Hub and Spoke resource groups
   ↓
2. Deploy Hub VNet with all subnets
   ↓
3. Deploy Spoke VNets for dev/staging/prod
   ↓
4. Create VNet peering (hub ↔ spokes)
   ↓
5. Deploy Core Services:
   - Key Vault
   - Log Analytics Workspace
   - Application Insights
   ↓
6. Deploy Policy Layer:
   - Policy definitions
   - Policy initiatives
   - Policy assignments
   ↓
7. Deploy Monitoring Layer:
   - Diagnostic settings on all resources
   - Action groups
   - Alert rules
   ↓
8. Deploy Dashboards Layer:
   - Operational dashboard
   - Security dashboard
   - Additional workbooks
   ↓
9. Generate outputs (resource IDs, endpoints)
```

---

## Compliance Mappings

### Banking Compliance Standards

#### PCI-DSS v3.2.1 Mappings
```
Policy Initiative          | PCI-DSS Control | Requirement
--------------------------|-----------------|------------------
Data Protection Initiative | 3.x             | Encrypt sensitive data
Network Security Initiative| 1.x, 6.x        | Firewall & segmentation
Monitoring & Logging      | 10.x            | Logging & monitoring
Resource Governance       | 2.x             | Change management
```

#### HIPAA Compliance
```
Policy Initiative          | HIPAA Rule      | Requirement
--------------------------|-----------------|------------------
Data Protection Initiative | §164.312(a)(2)  | Encryption
Network Security Initiative| §164.308(a)(4)  | Network controls
Monitoring & Logging      | §164.312(b)     | Audit controls
```

#### SOC 2 Type II
```
Policy Initiative          | SOC 2 Criteria  | Requirement
--------------------------|-----------------|------------------
Monitoring & Logging      | CC7             | System monitoring
Resource Governance       | CC6.1           | Change control
Data Protection Initiative | CC6.5           | Data protection
```

---

## Operational Procedures

### Daily Operations

**Morning Briefing** (09:00 UTC):
1. Review Banking Operational Dashboard
2. Check alert status in Action Groups
3. Review policy compliance score
4. Check for any overnight incidents

**Incident Response**:
1. Alert fires → Escalates to action group
2. Team reviews in dashboard
3. Execute runbook if applicable
4. Update status in Teams
5. Post-mortem after resolution

### Weekly Reviews

**Every Monday**:
1. Review alert effectiveness
2. Analyze false positives
3. Check policy compliance trends
4. Review resource utilization

**Policy Compliance Review**:
- Identify new non-compliant resources
- Approve legitimate exemptions
- Plan remediation for violations

### Monthly Audits

**First week of month**:
1. Generate compliance report
2. Review policy exceptions
3. Update alert thresholds if needed
4. Cost optimization review

---

## Troubleshooting Guide

### Policy Deployment Issues

**Issue**: Policy assignment fails
```bash
# Verify policy exists
az policy definition show --name {policyName}

# Check assignment scope
az policy assignment show --name {assignmentName} \
  --scope /subscriptions/{subscriptionId}

# Validate policy rule syntax
az policy definition validate-rule --rules @policy.json
```

### Monitoring Issues

**Issue**: Diagnostics not appearing in Log Analytics
```bash
# Check diagnostic setting
az monitor diagnostic-settings list --resource {resourceId}

# Verify workspace ingestion
az monitor log-analytics workspace show --resource-group {rg} \
  --workspace-name {name} --query "sku"

# Query recent logs
az monitor log-analytics query --workspace {workspaceId} \
  --analytics-query "AzureDiagnostics | limit 10"
```

### Dashboard Issues

**Issue**: Workbook queries return no data
```bash
# Verify data exists
az monitor log-analytics query --workspace {workspaceId} \
  --analytics-query "{kusto_query}"

# Check workbook permissions
az role assignment list --assignee {principalId} \
  --scope {workbookId}
```

---

## Cost Estimation

### Monthly Infrastructure Costs (Estimate)

```
Service              | SKU/Unit        | Monthly Cost
---------------------|-----------------|-------------
Log Analytics        | 30-50GB/day     | R 2,500-4,500
Application Insights | Basic           | R 1,000
Action Groups        | Per recipient   | R 50-200
Workbooks            | Shared          | R 0 (included)
Policy Evaluations   | Per resource    | R 0 (included)
Alert Rules          | Per rule        | R 0 (included)

Total Monitoring     | 50-100 resources| R 3,550-5,700/month
```

### Cost Optimization Tips

1. **Log Retention**: Archive old logs to storage accounts
2. **Sampling**: Use 50% sampling for high-volume logs
3. **Alert Rules**: Consolidate redundant alerts
4. **Dashboards**: Limit real-time refresh (5-15 min intervals)
5. **Policy**: Free service (included in Azure subscription)

---

## Related Documentation

- [Policy as Code Design](./POLICY_AS_CODE.md)
- [Monitoring as Code Design](./MONITORING_AS_CODE.md)
- [Dashboards as Code Design](./DASHBOARDS_AS_CODE.md)
- [Network Architecture](./NETWORK_ARCHITECTURE.md)
- [IAC Deployment](./IAC_DEPLOYMENT.md)
- [Bicep Modules Reference](../bicep/MODULES_REFERENCE.md)
- [Implementation Guide](./IMPLEMENTATION_GUIDE.md)

---

## Success Criteria

### Phase 1 (Monitoring)
- ✅ All resources sending logs to Log Analytics
- ✅ 90-day log retention configured
- ✅ Query latency < 5 seconds

### Phase 2 (Governance)
- ✅ All 24 policies deployed
- ✅ 7 initiatives assigned
- ✅ Baseline compliance score documented

### Phase 3 (Alerting)
- ✅ 10+ critical alerts deployed
- ✅ Alert routing tested
- ✅ MTTR (Mean Time To Response) < 30 minutes

### Phase 4 (Dashboards)
- ✅ 6 dashboards deployed and shared
- ✅ Dashboard refresh time < 15 seconds
- ✅ User adoption > 80%

### Phase 5 (Enforcement)
- ✅ All policies in Deny mode
- ✅ Compliance score > 95%
- ✅ Auto-remediation < 5 minute response

---

**Last Updated**: June 2026  
**Document Version**: 1.0  
**Status**: Production Ready  
**Reviewed By**: Architecture & Security Team
