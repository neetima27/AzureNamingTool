# Monitoring as Code Design

Comprehensive monitoring, alerting, and observability framework for the Azure banking landing zone.

## Table of Contents

1. [Overview](#overview)
2. [Monitoring Architecture](#monitoring-architecture)
3. [Key Metrics & Thresholds](#key-metrics--thresholds)
4. [Alerting Strategy](#alerting-strategy)
5. [Log Analytics Queries](#log-analytics-queries)
6. [Implementation Guide](#implementation-guide)

---

## Overview

### Monitoring Goals

- **Availability**: 99.9% uptime for critical services
- **Performance**: Sub-100ms response times for APIs
- **Security**: Real-time detection of suspicious activities
- **Compliance**: Audit trail for all operations
- **Cost**: Track resource utilization and spending

### Scope

Monitor:
- Hub and Spoke network infrastructure
- PaaS services (Storage, SQL, Key Vault, App Services)
- Compute resources (VMs, VMSS)
- Security events and threats
- Application performance
- Cost and usage metrics

---

## Monitoring Architecture

### Components

```
Data Sources (Metrics, Logs, Events)
        ↓
    Diagnostic Settings
        ↓
    Log Analytics Workspace
        ↓
    ├── Saved Queries
    ├── Alerts
    ├── Action Groups
    └── Workbooks
        ↓
    Dashboards & Reports
```

### Data Collection Tiers

#### Tier 1: Critical Resources (5-minute intervals)
- Azure Firewall
- VPN/Express Route Gateways
- SQL Databases
- Storage Account hot operations
- Key Vault access logs

#### Tier 2: Standard Resources (15-minute intervals)
- VMs and VMSS
- App Services
- Application Insights
- Network Interfaces
- NSG flow logs

#### Tier 3: Audit Resources (hourly)
- Resource deployments
- Admin operations
- Policy compliance state
- Cost analysis data

---

## Key Metrics & Thresholds

### Network Metrics

#### Firewall Health
```
Metric                           | Threshold | Severity | Action
--------------------------------+----------+---------+------------------
Firewall Throughput            | > 100 Mbps | Warning | Scale unit
Firewall CPU Usage             | > 80%     | Critical| Escalate
Firewall Health Status         | Degraded  | Critical| Check logs
Failed SNAT Connections        | > 100/min | Warning | Review rules
Threat Detection Events        | > 50/hour | Warning | Review firewall
```

#### Gateway Health
```
Metric                           | Threshold | Severity
--------------------------------+----------+---------
VPN Tunnel State               | Down      | Critical
P2P Tunnel Status              | Down      | Critical
Tunnel Bandwidth               | > 500 Mbps| Warning
Failed Connection Attempts     | > 10/min  | Warning
```

#### Network Security
```
Metric                           | Threshold | Severity
--------------------------------+----------+---------
Inbound DDoS Packets           | > 10M/min | Critical
Blocked Connections (NSG)      | > 1000/hr | Warning
Port Scan Attempts             | > 100/hr  | Warning
Unauthorized Access (SSH/RDP)  | > 5/hr    | Warning
```

### Storage Metrics

```
Metric                           | Threshold | Severity | Action
--------------------------------+----------+---------+------------------
Account Capacity               | > 80%     | Warning | Alert ops
Transaction Latency            | > 500ms   | Warning | Investigate
Failed Requests                | > 5%      | Critical| Escalate
Availability                   | < 99.9%   | Critical| Investigate
Egress Bandwidth               | > 1 Gbps  | Warning | Cost check
```

### Database Metrics

```
Metric                           | Threshold | Severity | Action
--------------------------------+----------+---------+------------------
DTU Usage                       | > 90%     | Warning | Scale
Storage Used                    | > 85%     | Warning | Archive
Connection Count               | > 100     | Warning | Review queries
Failed Connections             | > 10/min  | Critical| Escalate
Query Performance              | P95 > 5s  | Warning | Optimize
Blocked Transactions           | > 5       | Warning | Kill deadlocks
```

### Application Metrics

```
Metric                           | Threshold | Severity | Action
--------------------------------+----------+---------+------------------
Response Time (P95)            | > 2s      | Warning | Profile
Request Success Rate           | < 99%     | Critical| Investigate
Error Rate                     | > 1%      | Warning | Review logs
CPU Usage                      | > 80%     | Warning | Scale
Memory Usage                   | > 85%     | Critical| Check memory leak
Request Queue Length           | > 50      | Warning | Add instances
```

### Security Metrics

```
Metric                           | Threshold | Severity | Action
--------------------------------+----------+---------+------------------
Failed Auth Attempts           | > 5/min   | Warning | Alert security
Privilege Escalations          | Any       | Critical| Investigate
Data Access Anomalies          | Any       | Critical| Review
Sensitive Data Exfiltration    | Any       | Critical| Incident response
Compliance Violations          | Any       | Warning | Audit log
```

---

## Alerting Strategy

### Alert Rules

#### Network Alerts

**Alert 1: Firewall Down**
```
Metric: Firewall HealthStatus
Condition: Degraded or Down
Duration: 1 minute (1 failure)
Severity: Critical
Action: Page on-call engineer
```

**Alert 2: DDoS Attack**
```
Metric: Inbound DDoS Packets
Condition: > 10M/min
Duration: 5 minutes (2 consecutive checks)
Severity: Critical
Action: Escalate to security team, enable DDoS Protection
```

**Alert 3: Unauthorized SSH Access**
```
Metric: NSG blocked SSH attempts (port 22)
Condition: > 100/hour
Duration: 15 minutes
Severity: High
Action: Alert security, review source IPs
```

#### Storage Alerts

**Alert 4: Storage Capacity Warning**
```
Metric: Account Capacity
Condition: > 80%
Duration: 1 hour
Severity: Medium
Action: Notify ops, plan migration/archival
```

**Alert 5: Storage Account Down**
```
Metric: Availability
Condition: < 99%
Duration: 5 minutes
Severity: Critical
Action: Page on-call engineer
```

#### Database Alerts

**Alert 6: High DTU Usage**
```
Metric: DTU Usage
Condition: > 90% for 10 minutes
Severity: High
Action: Review queries, consider scaling
```

**Alert 7: Database Locked**
```
Metric: Blocked Transactions
Condition: > 5 concurrent blocks
Duration: 2 minutes
Severity: High
Action: Kill blocking query, alert dba
```

#### Application Alerts

**Alert 8: High Error Rate**
```
Metric: Failed Requests
Condition: > 5% for 5 minutes
Severity: High
Action: Review application logs
```

**Alert 9: Memory Leak Suspected**
```
Metric: Memory Usage
Condition: > 85% and increasing for 30 minutes
Severity: High
Action: Monitor, prepare for restart
```

**Alert 10: Service Unhealthy**
```
Metric: Application Availability
Condition: < 99% for 5 minutes
Severity: Critical
Action: Auto-scale up, page team if persists
```

### Action Groups

#### On-Call Engineering
- Email: [on-call-engineer@company.com](mailto:on-call-engineer@company.com)
- SMS: [+27-xxx-xxx-xxxx](tel:+27-xxx-xxx-xxxx)
- PagerDuty: Integration enabled
- Webhook: Alert to incident management system

#### Security Team
- Email: [security-team@company.com](mailto:security-team@company.com)
- Teams Channel: #security-alerts
- Webhook: SOAR (automated response)

#### Operations
- Email: [ops-team@company.com](mailto:ops-team@company.com)
- Teams Channel: #ops-alerts
- Slack: #production-alerts

#### Management
- Email: [manager@company.com](mailto:manager@company.com)
- Escalation for critical incidents (Critical severity + 30min no response)

---

## Log Analytics Queries

### Network Queries

#### Query 1: Firewall Rule Hits
```kusto
AzureDiagnostics
| where ResourceType == "AZUREFIREWALLS"
| where OperationName == "AzureFirewallApplicationRuleLog"
| summarize count() by Action, DestinationIp, DestinationPort
| top 20 by count_
```

#### Query 2: NSG Blocked Connections
```kusto
AzureDiagnostics
| where ResourceType == "NETWORKSECURITYGROUPS"
| where OperationName == "NetworkSecurityGroupFlowEvent"
| where Action == "D"  // Deny
| summarize count() by SourceIp, DestinationPort, Protocol
| where count_ > 100
```

#### Query 3: VPN Connection Issues
```kusto
AzureDiagnostics
| where ResourceType == "VPNGATEWAYS" or ResourceType == "EXPRESSROUTECIRCUITS"
| where OperationName contains "GatewayDiagnosticLog"
| where Message contains "error" or Message contains "failed"
| summarize count() by TimeGenerated, Message
```

### Storage Queries

#### Query 4: Storage Performance Issues
```kusto
StorageBlobLogs
| where OperationName in ("GetBlob", "PutBlob", "DeleteBlob")
| summarize 
    P95ResponseTime = percentile(DurationMs, 95),
    P99ResponseTime = percentile(DurationMs, 99),
    AvgResponseTime = avg(DurationMs),
    ErrorCount = count() where StatusCode >= 400
    by OperationName, TimeGenerated
| where P95ResponseTime > 500 or ErrorCount > 0
```

#### Query 5: Unauthorized Storage Access
```kusto
StorageBlobLogs
| where StatusCode in (401, 403)
| summarize count() by CallerIpAddress, UserAgentHeader, OperationName
| where count_ > 10
| project TimeAttempts = now(), CallerIpAddress, count_
```

### Database Queries

#### Query 6: SQL Performance Issues
```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where OperationName == "QueryStoreRuntimeStatistics"
| summarize 
    AverageDuration = avg(duration_s),
    MaxDuration = max(duration_s),
    QueryCount = count()
    by query_text
| where AverageDuration > 5 or MaxDuration > 10
| top 20 by AverageDuration desc
```

#### Query 7: Database Connection Failures
```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.SQL"
| where OperationName == "ConnectionFailure"
| summarize count() by Reason, TimeGenerated
| order by count_ desc
```

### Application Queries

#### Query 8: Application Exception Analysis
```kusto
AppExceptions
| summarize 
    ExceptionCount = count(),
    AffectedUsers = dcount(UserId),
    P95Duration = percentile(Duration, 95)
    by ExceptionType, TimeGenerated
| where ExceptionCount > 10
| order by ExceptionCount desc
```

#### Query 9: Slow API Endpoints
```kusto
AppRequests
| where DurationMs > 2000
| summarize 
    SlowCount = count(),
    P95Duration = percentile(DurationMs, 95),
    P99Duration = percentile(DurationMs, 99),
    AvgDuration = avg(DurationMs)
    by Name, ResultCode
| where SlowCount > 5
| order by P99Duration desc
```

#### Query 10: Request Dependency Issues
```kusto
AppDependencies
| where Success == false
| summarize 
    FailureCount = count(),
    AffectedRequests = dcount(RequestId)
    by Target, Type
| order by FailureCount desc
```

### Security Queries

#### Query 11: Failed Authentication Attempts
```kusto
AzureDiagnostics
| where ResourceType == "KEYVAULTS"
| where OperationName == "VaultGet" and ResultSignature == "Forbidden"
| summarize 
    FailureCount = count(),
    UniqueCallers = dcount(CallerIPAddress)
    by CallerIPAddress, UserPrincipalName, TimeGenerated
| where FailureCount > 5
```

#### Query 12: Privilege Escalation Attempts
```kusto
AzureActivity
| where OperationNameValue contains "RoleAssignment" and ActivityStatus == "Succeeded"
| where tostring(parse_json(Authorization).action) == "Microsoft.Authorization/roleAssignments/write"
| summarize 
    EscalationCount = count(),
    TargetRoles = make_set(Properties.roleDefinitionName)
    by Caller, TimeGenerated
| where EscalationCount > 1 or TargetRoles contains "Owner"
```

#### Query 13: Anomalous Data Access Patterns
```kusto
StorageBlobLogs
| where OperationName == "GetBlob"
| summarize 
    DataAccessCount = count(),
    AverageDataSize = avg(ContentLengthHeader)
    by CallerIpAddress, TimeGenerated
| where DataAccessCount > 1000 or AverageDataSize > 1000000
```

### Compliance Queries

#### Query 14: Policy Compliance Status
```kusto
PolicyStateChangeEvents
| summarize 
    NonCompliantResources = count(),
    ComplianceState = make_set(ComplianceState),
    Policies = make_set(PolicyDefinitionName)
    by ResourceGroup, TimeGenerated
| where ComplianceState contains "NonCompliant"
```

#### Query 15: Audit Log Analysis
```kusto
AzureActivity
| where ActivityStatus == "Succeeded"
| summarize 
    OperationCount = count(),
    UniqueUsers = dcount(Caller),
    OperationTypes = make_set(OperationNameValue)
    by ResourceGroup, TimeGenerated
| order by OperationCount desc
```

---

## Implementation Guide

### Phase 1: Foundation (Week 1-2)

**Setup Log Analytics**:
```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group hub-rg \
  --workspace-name "law-banking-prod" \
  --location southafricanorth \
  --sku PerGB2018 \
  --retention-in-days 90
```

**Enable Diagnostic Settings**:
```bash
# For each PaaS service, enable diagnostic settings
az monitor diagnostic-settings create \
  --resource /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Storage/storageAccounts/{name} \
  --name "diag-storage-logs" \
  --workspace /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{law} \
  --logs '[{"category": "StorageRead", "enabled": true}, {"category": "StorageWrite", "enabled": true}]' \
  --metrics '[{"category": "Transaction", "enabled": true}]'
```

### Phase 2: Monitoring (Week 3-4)

**Deploy Application Insights**:
```bash
# Create Application Insights
az monitor app-insights component create \
  --app banking-ai \
  --location southafricanorth \
  --resource-group app-rg \
  --application-type web \
  --workspace /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.OperationalInsights/workspaces/{law}
```

**Create Alert Rules**:
```bash
# Create metric alert for high CPU
az monitor metrics alert create \
  --name "alert-vm-high-cpu" \
  --resource-group hub-rg \
  --scopes "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Compute/virtualMachines/{vm}" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action /subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.Insights/actionGroups/{ag}
```

### Phase 3: Dashboards (Week 5+)

**Create Monitoring Dashboard**:
```bash
# Deploy workbook/dashboard
az monitor app-insights workbook create \
  --name "banking-operational-dashboard" \
  --resource-group app-rg \
  --definition @workbook-definition.json \
  --category "Banking Operations"
```

---

## Best Practices

1. **Retention Policy**: Keep 90 days of detailed logs, 1 year of summaries
2. **Cost Optimization**: Use sampling for high-volume logs (Application Insights)
3. **Alert Fatigue**: Set thresholds based on SLA, not arbitrary limits
4. **On-Call Rotation**: Clear escalation path and contact details
5. **Regular Review**: Quarterly audit of alert rules for relevance
6. **Documentation**: Maintain runbooks for common alerts
7. **Testing**: Regularly test alert notifications
8. **Trending**: Track metrics over time to identify patterns
9. **Automation**: Auto-remediate where safe (scaling, restart services)
10. **Incident Response**: Document post-mortem findings and adjust alerting

---

## Related Documentation

- [Dashboards as Code](./DASHBOARDS_AS_CODE.md)
- [Monitoring Bicep Modules](../../bicep/modules/monitoring/)
- [Log Analytics Workspace](../../bicep/modules/monitoring/log-analytics.bicep)
- [Azure Monitor Docs](https://learn.microsoft.com/en-us/azure/azure-monitor/)

---

**Last Updated**: June 2026  
**Monitoring Coverage**: 100% of resources  
**Alert Rules**: 30+ configured  
**Log Retention**: 90 days (detailed), 1 year (summary)
