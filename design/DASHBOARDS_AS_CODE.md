# Dashboards as Code Design

Azure Monitor Workbooks and dashboards for visualizing banking infrastructure operations and compliance status.

## Table of Contents

1. [Overview](#overview)
2. [Dashboard Architecture](#dashboard-architecture)
3. [Dashboard Designs](#dashboard-designs)
4. [Implementation Guide](#implementation-guide)

---

## Overview

### Goals

- **Real-time Visibility**: Monitor infrastructure status at a glance
- **Decision Support**: Data-driven operational decisions
- **Compliance Reporting**: Visual proof of compliance status
- **Incident Response**: Quick identification of issues
- **Trend Analysis**: Identify patterns and anomalies

### Dashboard Types

1. **Operational Dashboards** - Real-time status for daily ops
2. **Security Dashboards** - Threat and compliance monitoring
3. **Performance Dashboards** - Application and infrastructure health
4. **Cost Dashboards** - Resource utilization and spending
5. **Executive Dashboards** - High-level business metrics

---

## Dashboard Architecture

### Dashboard Components

```
Metrics (Azure Monitor)
        ↓
    Logs (Log Analytics)
        ↓
    Application Data (App Insights)
        ↓
    Policy State
        ↓
    Workbooks/Dashboards
        ↓
    Visualizations
```

### Visualization Types

| Type | Use Case | Example |
|------|----------|---------|
| **Timeseries Chart** | Trends over time | CPU usage, request count |
| **Bar Chart** | Comparison | Resource utilization by service |
| **Pie Chart** | Distribution | Traffic by protocol |
| **Heatmap** | Patterns | Hourly traffic patterns |
| **Map** | Geographic | Data center regions |
| **KPI Tile** | Key metrics | Availability %, SLA status |
| **Table** | Details | Non-compliant resources |
| **Alert Status** | Health | Current alerts firing |

---

## Dashboard Designs

### 1. Banking Operational Dashboard

**Purpose**: Real-time operational status for on-call engineers  
**Audience**: Operations team, on-call rotations

**Components**:

#### Row 1: System Health Overview
```
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│ Hub Firewall    │ VPN Gateway     │ SQL Databases   │ Storage Status  │
│ Status: Healthy │ Status: Healthy │ Status: Healthy │ Status: Healthy │
│ Throughput:     │ Connections:    │ DTU Usage:      │ Capacity:       │
│ 42.3 Mbps       │ 127 active      │ 65%             │ 72%             │
└─────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

#### Row 2: Network Traffic Analysis
```
Firewall Rule Hits (24h)           |  Gateway Connections (24h)
- Allowed: 95%                     |  - Point-to-Site: 43 active
- Denied: 4%                       |  - Site-to-Site: 12 active
- Total: 2.3M packets              |  - ExpressRoute: 8 active
```

#### Row 3: Resource Utilization
```
Top Resource Consumers:
1. Storage Account (storage-prod): 85% capacity
2. SQL Database (db-prod): 78% DTU
3. VM app-server-01: 62% CPU average
4. Key Vault: 45% API throttling
```

#### Row 4: Active Alerts
```
Priority | Alert Name | Severity | Duration | Status
---------|-----------|----------|----------|--------
1        | High DTU Usage | High | 15min | Investigating
2        | Firewall CPU > 80% | Medium | 8min | Alerting
3        | Storage Capacity | Medium | 2h | Acknowledged
```

### 2. Security & Compliance Dashboard

**Purpose**: Monitor security threats and policy compliance  
**Audience**: Security team, compliance officers

**Components**:

#### Row 1: Threat Summary
```
┌──────────────────────────────────────────────────────┐
│ Threat Status: 🟢 SECURE                            │
│ Last 24 Hours:                                       │
│ - Failed Auth Attempts: 23 (baseline: 18)           │
│ - Port Scans Detected: 5 (blocked by firewall)     │
│ - DDoS Attempts: 0 (DDOS Protection: Enabled)      │
│ - Anomalous Data Access: 0                          │
└──────────────────────────────────────────────────────┘
```

#### Row 2: Policy Compliance Status
```
Initiative                    | Compliant | Non-Compliant | Exempt
------------------------------|-----------|---------------|-------
Banking Compliance            | 95%       | 4%            | 1%
Network Security              | 98%       | 2%            | 0%
Data Protection               | 92%       | 8%            | 0%
Monitoring & Logging          | 89%       | 11%           | 0%
Resource Governance           | 91%       | 9%            | 0%
```

#### Row 3: Failed Authentication Attempts (24h)
```
Timeline showing:
- Failed SSH attempts: 23
- Failed SQL auth: 8
- Failed API calls: 3
- Geographic origin: All from South Africa
```

#### Row 4: Access Control
```
Admin Activities (24h):
- Role Assignments: 2 (Principal: admin@company.com)
- Password Resets: 1 (Principal: user@company.com)
- MFA Status: 98% compliant
- Service Principals: 12 active (3 unused)
```

### 3. Application Performance Dashboard

**Purpose**: Monitor app health, performance, and dependencies  
**Audience**: Application development teams, SREs

**Components**:

#### Row 1: Application Status
```
┌────────────────────────────────────────┐
│ Banking API - Production               │
│ Status: 🟢 HEALTHY                    │
│ Uptime: 99.94% (24h)                  │
│ Response Time (P95): 287ms             │
│ Error Rate: 0.12%                      │
└────────────────────────────────────────┘
```

#### Row 2: Performance Metrics
```
Request Success Rate:          Response Times:
- Total Requests: 2.4M         - P50: 142ms
- Succeeded: 2.39M (99.88%)    - P95: 287ms
- Failed: 2,880 (0.12%)        - P99: 523ms
```

#### Row 3: Dependency Performance
```
Dependency                | Avg (ms) | P95 (ms) | Error %
--------------------------|----------|----------|--------
Database (SQL)            | 45       | 120      | 0.05%
Storage Account (Blob)    | 89       | 234      | 0.02%
Key Vault                 | 12       | 28       | 0.00%
External API (Payment)    | 567      | 1200     | 0.15%
```

#### Row 4: Exception Analysis
```
Top Exceptions (24h):
1. Timeout Exception: 1,234 (42%)
   - Source: External payment API timeout
   - Trend: Increasing
   
2. Database Deadlock: 456 (15%)
   - Source: Concurrent order updates
   - Trend: Stable
   
3. Authentication Failure: 234 (8%)
   - Source: Token expiration
   - Trend: Decreasing
```

### 4. Cost & Resource Dashboard

**Purpose**: Monitor spending and resource optimization opportunities  
**Audience**: Finance, operations, architects

**Components**:

#### Row 1: Cost Summary
```
┌─────────────────────────────────────────────┐
│ Monthly Costs (YTD)                        │
│ Current Month: R 2,430,550 (45 days)      │
│ Projected Monthly: R 1,620,000            │
│ vs Budget: 92% (On track)                 │
│ vs Last Month: -3.2% (Improving)          │
└─────────────────────────────────────────────┘
```

#### Row 2: Cost Breakdown by Resource
```
Service Type      | Cost (R) | % of Total | Trend
------------------|----------|-----------|-------
Compute (VMs)     | 640,000  | 39.5%     | ↓ -2.1%
Storage           | 380,000  | 23.4%     | ↑ +1.3%
Networking        | 320,000  | 19.7%     | → Stable
Databases         | 180,000  | 11.1%     | ↓ -0.5%
Other             | 100,000  | 6.2%      | → Stable
```

#### Row 3: Resource Utilization
```
Underutilized Resources:
- vm-app-test-01: 8% CPU average (candidate for shutdown)
- Premium Disks (3): Only 45% capacity used
- App Service Plan: 15% CPU average (downsize?)

Overutilized Resources:
- SQL Database: 92% DTU (consider scaling)
- Storage Account: 88% capacity (archive old data)
```

#### Row 4: Optimization Opportunities
```
Recommendation               | Potential Saving | ROI
-----------------------------|-----------------|-------
Shutdown unused VMs          | R 45,000/month  | Immediate
Scale down test environments | R 28,000/month  | Quick
Archive old storage data     | R 15,000/month  | Medium
Switch to spot instances     | R 38,000/month  | Quick
Consolidate databases        | R 22,000/month  | Medium
```

### 5. Network Topology Dashboard

**Purpose**: Visualize network architecture and traffic flows  
**Audience**: Network engineers, architects

**Components**:

#### Row 1: Network Diagram
```
                    ┌─────────────┐
                    │   Internet  │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │  Azure VPN  │
                    │  Express ER │
                    └──────┬──────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
     ┌──────▼──────┐            ┌────────▼──────┐
     │   HUB VNet  │            │  Spoke VNet   │
     │  10.19.0.0  │            │  Dev/Stage    │
     │             │◄──────────►│  /Prod        │
     └─────────────┘  Peering   └───────────────┘
```

#### Row 2: Traffic Flow (24h)
```
Ingress Traffic:
- VPN: 4.2 Gbps
- ExpressRoute: 12.8 Gbps
- Internet: 1.3 Gbps

Egress Traffic:
- On-premises: 10.2 Gbps
- Internet: 2.1 Gbps
- Inter-VNet: 3.4 Gbps
```

#### Row 3: Firewall Activity
```
Top Blocked Traffic:
- SSH attempts (port 22): 1,234 packets
- RDP attempts (port 3389): 892 packets
- HTTPS non-standard: 456 packets
```

#### Row 4: VPN/ER Status
```
Connection      | Status | Bandwidth | Latency | Packet Loss
----------------|--------|-----------|---------|-------------
VPN P2S         | 🟢 Up  | 12.3 Mbps | 45ms    | 0.01%
VPN S2S         | 🟢 Up  | 234 Mbps  | 52ms    | 0.00%
ExpressRoute    | 🟢 Up  | 1.2 Gbps  | 8ms     | 0.00%
```

### 6. Executive Summary Dashboard

**Purpose**: High-level status for leadership  
**Audience**: CTO, CFO, board members

**Components**:

#### Row 1: Key Metrics
```
┌────────────┬────────────┬────────────┬────────────┐
│ Uptime     │ Security   │ Compliance │ Cost       │
│ 99.94%     │ 98% Secure │ 94.7%      │ On Budget  │
│ ✓ Above    │ ✓ Threats  │ ✓ 15 days  │ ✓ 92% of   │
│ 99.9% SLA  │ Controlled │ to Review  │ budget    │
└────────────┴────────────┴────────────┴────────────┘
```

#### Row 2: Incidents (Last 30 Days)
```
Severity | Count | MTTR | Status
---------|-------|------|-------
Critical | 2     | 18m  | Resolved
High     | 8     | 45m  | Resolved
Medium   | 23    | 2h   | Resolved
Low      | 45    | 4h   | Resolved

Trend: ↓ Critical incidents down 50% vs previous month
```

#### Row 3: Budget Status
```
Category          | Budget      | Actual      | %Used | Trend
-----------------|-------------|-------------|-------|-------
Compute          | R 1.8M      | R 1.65M     | 92%   | ↓
Storage          | R 400K      | R 385K      | 96%   | ↑
Networking       | R 350K      | R 324K      | 93%   | ↓
Databases        | R 220K      | R 198K      | 90%   | ↓
```

#### Row 4: Strategic Initiatives
```
Initiative                    | Status    | % Complete | On Track
-------------------------------|-----------|-----------|----------
Migration to Private Endpoints | 🟡In Progress | 75%  | Yes
Zero-Trust Implementation      | 🟢Planned    | 0%   | Preparing
Disaster Recovery Setup        | 🟢Planned    | 0%   | Preparing
Cost Optimization              | 🟢Running    | 45%  | Yes
```

---

## Implementation Guide

### Creating Workbooks

#### Step 1: Define Structure
```bicep
// Define dashboard sections
var dashboardConfig = {
  title: 'Banking Operational Dashboard'
  description: 'Real-time status for banking infrastructure'
  tabs: [
    {
      name: 'Overview'
      sections: ['Health Status', 'Alerts', 'Trends']
    }
    {
      name: 'Details'
      sections: ['Resources', 'Performance', 'Costs']
    }
  ]
}
```

#### Step 2: Create Workbook
```bash
# Create workbook in portal
az resource create \
  --resource-group app-rg \
  --resource-type "Microsoft.Insights/workbooks" \
  --name "banking-dashboard" \
  --properties @workbook.json
```

#### Step 3: Add Visualizations
```bicep
// Add metric chart
{
  type: 'Metric'
  metrics: [
    {
      name: 'Percentage CPU'
      resourceId: vmId
    }
  ]
  visualization: 'timeseries'
  timeRange: 'Last 24 hours'
}
```

### Dashboard as Code (Bicep)

```bicep
resource workbook 'Microsoft.Insights/workbooks@2021-03-08' = {
  name: guid(resourceGroup().id)
  location: location
  kind: 'shared'
  properties: {
    displayName: 'Banking Operational Dashboard'
    description: 'Real-time monitoring and operational insights'
    sourceId: workspaceId
    category: 'Banking'
    priority: 100
    content: {
      version: 'Notebook/1.0'
      items: [
        // Dashboard components as JSON
      ]
    }
  }
}
```

---

## Best Practices

1. **Real-time Updates**: Refresh intervals of 5-15 minutes for operational dashboards
2. **Mobile-Friendly**: Design for tablet and mobile viewing
3. **Dark Mode**: Support both light and dark themes
4. **Sharing**: Use shared workbooks for team access
5. **Pinning**: Pin frequently-used dashboards to favorites
6. **Alerting**: Add drill-through capabilities to alert details
7. **Caching**: Cache expensive queries for performance
8. **Documentation**: Add descriptions to all visualizations
9. **Regular Review**: Update thresholds based on SLA changes
10. **Permissions**: Restrict sensitive dashboards (finance, security)

---

## Related Documentation

- [Monitoring as Code](./MONITORING_AS_CODE.md)
- [Dashboard Bicep Modules](../../bicep/modules/dashboards/)
- [Azure Workbooks](https://learn.microsoft.com/en-us/azure/azure-monitor/visualize/workbooks-overview)
- [KQL Cheat Sheet](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/scalar-data-types/string)

---

**Last Updated**: June 2026  
**Dashboards**: 6 configured  
**Update Frequency**: Real-time (5-15 min intervals)  
**Access**: Role-based via Azure RBAC
