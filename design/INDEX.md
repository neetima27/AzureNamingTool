# Design Documentation Index

Comprehensive reference for the Azure Banking Landing Zone covering Network Architecture, Policy as Code, Monitoring as Code, Dashboards as Code, and Infrastructure deployment.

## Overview

This directory contains detailed design documentation organized into three core frameworks:
- **🔒 Policy as Code** - Governance and compliance
- **📊 Monitoring as Code** - Observability and alerting
- **📈 Dashboards as Code** - Visualization and insights

## Document Structure

### Core Design Documents

| Document | Purpose | Key Sections |
|----------|---------|--------------|
| [README.md](./README.md) | **Executive Summary & Architecture Overview** | Landing zone design, organizational structure, security, governance, deployment, monitoring, cost management, implementation roadmap |
| [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) | **Detailed Network Design** | Hub-spoke topology (10.19.0.0/16), subnet design, routing, NSGs, Firewall, Private endpoints, VNet peering |
| **[POLICY_AS_CODE.md](./POLICY_AS_CODE.md)** | **Policy & Governance Framework** | 24 policies, 7 initiatives, compliance mapping (PCI-DSS, HIPAA, SOC 2), compliance monitoring, remediation strategies |
| **[MONITORING_AS_CODE.md](./MONITORING_AS_CODE.md)** | **Monitoring & Alerting Framework** | 40+ metrics with thresholds, 15+ KQL queries, 10+ alert rules, action groups, 3-tier data collection |
| **[DASHBOARDS_AS_CODE.md](./DASHBOARDS_AS_CODE.md)** | **Dashboards & Visualization** | 6 pre-designed workbooks, operational/security/performance/cost/network/executive dashboards |
| **[GOVERNANCE_MONITORING_DASHBOARDS.md](./GOVERNANCE_MONITORING_DASHBOARDS.md)** | **Complete Integration Framework** | 5-phase implementation roadmap, architecture overview, compliance mappings, operational procedures, cost estimation |
| [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) | **Infrastructure as Code & CI/CD** | Bicep-only strategy, stage-based deployment, GitHub Actions pipeline, self-hosted runner configuration |
| [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) | **Step-by-Step Implementation** | Deployment checklist, prerequisite setup, infrastructure sequence, validation steps, troubleshooting |

### Supporting Resources

#### Diagrams & Visuals
- [diagrams/ARCHITECTURE_DIAGRAMS.md](./diagrams/ARCHITECTURE_DIAGRAMS.md)
  - Overall landing zone architecture
  - Management group hierarchy
  - Network topology (hub-and-spoke)
  - Security layers
  - Data flow diagrams
  - Policy enforcement flow
  - Monitoring data flow
  - CI/CD pipeline flow
  - Cost allocation model
  - Deployment topology

#### Infrastructure as Code Templates
- [bicep/landing-zone/hub-vnet.bicep](./bicep/landing-zone/hub-vnet.bicep)
  - Hub VNet (10.19.0.0/16)
  - Firewall deployment
  - Bastion configuration
  - Private endpoint subnet
  - NSG configuration
  - Private DNS zones

#### Policy Definitions (Bicep)
- [policies/banking-compliance.bicep](./policies/banking-compliance.bicep)
  - Policy definitions for banking compliance
  - Encryption at rest enforcement
  - Private endpoint requirement
  - Mandatory tagging
  - Location restrictions
  - Policy initiatives and assignments

#### Monitoring Setup (Bicep)
- [monitoring/monitoring-setup.bicep](./monitoring/monitoring-setup.bicep)
  - Log Analytics Workspace configuration
  - Application Insights setup
  - Alert rules (CPU, availability, authentication)
  - Action groups for notifications
  - Private endpoint for monitoring resources

---

## Quick Start Guide

### For Architects/Decision Makers
1. Start with [README.md](./README.md) - Executive Summary
2. Review [diagrams/ARCHITECTURE_DIAGRAMS.md](./diagrams/ARCHITECTURE_DIAGRAMS.md) - Visual Overview
3. Check [GOVERNANCE_POLICIES.md](./GOVERNANCE_POLICIES.md) - Compliance Framework
4. Review [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Timeline & Approach

### For Platform Engineers
1. Review [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Network Design
2. Study [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) - Infrastructure Code
3. Use [bicep/landing-zone/hub-vnet.bicep](./bicep/landing-zone/hub-vnet.bicep) - Bicep Templates
4. Follow [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Phase 1

### For Security/Compliance Teams
1. Review [README.md](./README.md#security-compliance) - Security Overview
2. Study [GOVERNANCE_POLICIES.md](./GOVERNANCE_POLICIES.md) - Policy Framework
3. Review [MONITORING_OBSERVABILITY.md](./MONITORING_OBSERVABILITY.md#security-monitoring) - Security Monitoring
4. Check [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Network Security

### For Operations Teams
1. Review [MONITORING_OBSERVABILITY.md](./MONITORING_OBSERVABILITY.md) - Full Monitoring Guide
2. Study [COST_MANAGEMENT.md](./COST_MANAGEMENT.md) - Cost Tracking
3. Review [diagrams/ARCHITECTURE_DIAGRAMS.md](./diagrams/ARCHITECTURE_DIAGRAMS.md#7-monitoring-data-flow) - Monitoring Flow
4. Follow [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md#phase-5-optimization-weeks-11-12) - Operations Setup

---

## Key Design Principles

---

## Reading Roadmap by Role

### For Architects & Decision Makers
1. [README.md](./README.md) - Design overview (15 min)
2. [GOVERNANCE_MONITORING_DASHBOARDS.md](./GOVERNANCE_MONITORING_DASHBOARDS.md) - Full integration (30 min)
3. [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Network topology (20 min)
4. [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) - Deployment strategy (15 min)

### For Platform/DevOps Engineers
1. [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) - Bicep strategy (20 min)
2. [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Network design (20 min)
3. [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Deployment steps (30 min)
4. [bicep/MODULES_REFERENCE.md](../bicep/MODULES_REFERENCE.md) - Module documentation (reference)

### For Security & Compliance Teams
1. [POLICY_AS_CODE.md](./POLICY_AS_CODE.md) - Policy framework (45 min)
2. [GOVERNANCE_MONITORING_DASHBOARDS.md](./GOVERNANCE_MONITORING_DASHBOARDS.md) - Compliance mappings (30 min)
3. [MONITORING_AS_CODE.md](./MONITORING_AS_CODE.md) - Security monitoring (20 min)
4. [DASHBOARDS_AS_CODE.md](./DASHBOARDS_AS_CODE.md) - Compliance dashboard (15 min)

### For Operations/SRE Teams
1. [GOVERNANCE_MONITORING_DASHBOARDS.md](./GOVERNANCE_MONITORING_DASHBOARDS.md) - Operational procedures (30 min)
2. [MONITORING_AS_CODE.md](./MONITORING_AS_CODE.md) - Alerts and metrics (40 min)
3. [DASHBOARDS_AS_CODE.md](./DASHBOARDS_AS_CODE.md) - Dashboard usage (20 min)
4. [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Network reference (15 min)

---

## Document Details Summary

### 📋 POLICY_AS_CODE.md (560+ lines)
**Complete policy governance framework**
- 24 individual policies organized into 7 initiatives
- Banking Compliance Initiative (PCI-DSS, HIPAA, SOC 2, NIST compliance)
- Network Security, Data Protection, Monitoring, Governance, Cost Optimization initiatives
- Compliance monitoring dashboard and scoring
- Automatic and manual remediation strategies
- Phase-based deployment (Audit → Enforcement → Automation)
- 40+ policy deployment commands

### 📊 MONITORING_AS_CODE.md (600+ lines)
**Comprehensive monitoring and alerting**
- 3-tier data collection strategy (critical, standard, audit resources)
- 40+ metric definitions with specific thresholds
- Alerts for network (firewall, gateway, NSG), storage, database, app, and security
- 15+ Log Analytics KQL saved queries for analysis
- 10+ alert rule examples with severity levels
- Action group configuration for email, SMS, webhooks, runbooks
- 7-week implementation roadmap

### 📈 DASHBOARDS_AS_CODE.md (450+ lines)
**Visualization and operational dashboards**
- 6 pre-designed workbook templates
- Banking Operational Dashboard - Real-time ops status
- Security & Compliance Dashboard - Threat and policy monitoring
- Application Performance Dashboard - App health metrics
- Cost & Resource Dashboard - Spending and optimization
- Network Topology Dashboard - Network visualization
- Executive Summary Dashboard - High-level business metrics
- Workbook creation implementation guide

### 🗺️ GOVERNANCE_MONITORING_DASHBOARDS.md (500+ lines)
**Complete integration and implementation**
- Full architecture overview diagram
- 5-phase implementation roadmap (8+ weeks)
  - Phase 1: Foundation (logging, diagnostics)
  - Phase 2: Governance (policies in audit mode)
  - Phase 3: Alerting (action groups, alerts)
  - Phase 4: Dashboards (deploy all workbooks)
  - Phase 5: Enforcement (switch policies to deny mode)
- Compliance mappings (PCI-DSS, HIPAA, SOC 2)
- Bicep module integration guide
- Operational procedures (daily, weekly, monthly)
- Troubleshooting guide
- Cost estimation and optimization

---

## Key Statistics

| Metric | Count | Details |
|--------|-------|---------|
| **Policies** | 24 | Across 7 initiatives, covering banking compliance |
| **Policy Initiatives** | 7 | Security, Network, Data, Monitoring, Governance, Cost, Audit |
| **Metrics Defined** | 40+ | Network, Storage, Database, Application, Security |
| **Alert Rules** | 10+ | Critical, High, Medium severity with examples |
| **Log Queries** | 15+ | KQL saved queries for analysis and troubleshooting |
| **Dashboards** | 6 | Operational, Security, Performance, Cost, Network, Executive |
| **Documentation** | 2,500+ lines | Across 5 comprehensive design documents |
| **Bicep Modules** | 12+ | Policy, Monitoring, Dashboard modules |
| **Compliance Standards** | 4 | PCI-DSS, HIPAA, SOC 2, NIST |
| **Implementation Time** | 8+ weeks | 5-phase rollout plan |

---

## Architecture Overview

```
┌────────────────────────────────────────────────────────────┐
│            Azure Banking Landing Zone                      │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Layer 1: Infrastructure                                  │
│  ├─ Hub VNet (10.19.0.0/16)                              │
│  ├─ Spoke VNets (Dev, Staging, Prod)                    │
│  ├─ Firewall, Bastion, VPN/ER Gateways                  │
│  └─ PaaS Services (Storage, SQL, Key Vault)             │
│                                                            │
│  Layer 2: Governance (Policy as Code)                    │
│  ├─ 24 Policies, 7 Initiatives                           │
│  ├─ Compliance Monitoring & Scoring                      │
│  ├─ Automatic & Manual Remediation                       │
│  └─ Audit Trail to Log Analytics                         │
│                                                            │
│  Layer 3: Monitoring (Monitoring as Code)                │
│  ├─ Log Analytics Workspace                              │
│  ├─ Diagnostic Settings on all resources                 │
│  ├─ 40+ Metrics & Thresholds                            │
│  ├─ 10+ Alert Rules with escalation                      │
│  └─ Action Groups (Email, SMS, Webhook)                 │
│                                                            │
│  Layer 4: Visualization (Dashboards as Code)             │
│  ├─ 6 Pre-built Workbooks                                │
│  ├─ Real-time Operational Status                         │
│  ├─ Security & Compliance Views                          │
│  ├─ Performance & Cost Metrics                           │
│  └─ Executive Dashboards                                 │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## Implementation Timeline

```
Week 1-2:   Foundation (Logging & Diagnostics)
Week 3-4:   Governance (Policies in Audit Mode)
Week 5-6:   Alerting (Action Groups & Alert Rules)
Week 7:     Dashboards (Deploy All Workbooks)
Week 8+:    Enforcement (Switch Policies to Deny Mode)
```

---

## Bicep Module Integration

### Policy Modules
- `bicep/modules/policy/policy-definition.bicep` - Generic policy creation
- `bicep/modules/policy/policy-initiative.bicep` - Group policies into initiatives
- `bicep/modules/policy/policy-assignment.bicep` - Assign policies to scopes
- `bicep/modules/policy/banking-compliance-policies.bicep` - Pre-built banking policies

### Monitoring Modules
- `bicep/modules/monitoring/diagnostic-settings.bicep` - Enable diagnostics
- `bicep/modules/monitoring/metric-alerts.bicep` - Create metric alerts
- `bicep/modules/monitoring/action-groups.bicep` - Alert routing
- `bicep/modules/monitoring/log-analytics.bicep` (existing)
- `bicep/modules/monitoring/application-insights.bicep` (existing)

### Dashboard Modules
- `bicep/modules/dashboards/workbooks.bicep` - Generic workbook
- `bicep/modules/dashboards/banking-operational-dashboard.bicep` - Pre-built operational dashboard

**Reference**: [bicep/MODULES_REFERENCE.md](../bicep/MODULES_REFERENCE.md) for complete module documentation

---

## Compliance Mappings

### PCI-DSS v3.2.1
- **Policy Initiative**: Data Protection & Network Security
- **Controls Addressed**: 1.x (Firewall), 3.x (Encryption), 6.x (Secure Development)
- **Dashboard**: Security & Compliance

### HIPAA
- **Policy Initiative**: Data Protection & Monitoring
- **Rules Addressed**: §164.312 (Technical safeguards)
- **Dashboard**: Security & Compliance

### SOC 2 Type II
- **Policy Initiative**: Monitoring & Resource Governance
- **Criteria**: CC6.1 (Change control), CC7 (Monitoring)
- **Dashboard**: Operational & Security

### NIST Cybersecurity Framework
- **Policy Initiative**: All 7 initiatives
- **Functions**: Identify, Protect, Detect, Respond
- **Dashboard**: All 6 dashboards

---

## Quick Reference Links

### Policy Documents
- [POLICY_AS_CODE.md](./POLICY_AS_CODE.md) - 24 policies, 7 initiatives
- [Policy Modules](../bicep/modules/policy/) - Bicep implementations

### Monitoring Documents
- [MONITORING_AS_CODE.md](./MONITORING_AS_CODE.md) - Metrics, alerts, queries
- [Monitoring Modules](../bicep/modules/monitoring/) - Bicep implementations

### Dashboard Documents
- [DASHBOARDS_AS_CODE.md](./DASHBOARDS_AS_CODE.md) - 6 workbook templates
- [Dashboard Modules](../bicep/modules/dashboards/) - Bicep implementations

### Integration & Implementation
- [GOVERNANCE_MONITORING_DASHBOARDS.md](./GOVERNANCE_MONITORING_DASHBOARDS.md) - Full roadmap
- [IMPLEMENTATION_GUIDE.md](./IMPLEMENTATION_GUIDE.md) - Step-by-step deployment
- [IAC_DEPLOYMENT.md](./IAC_DEPLOYMENT.md) - Bicep strategy & CI/CD

### Infrastructure & Network
- [NETWORK_ARCHITECTURE.md](./NETWORK_ARCHITECTURE.md) - Hub-spoke topology
- [README.md](./README.md) - Executive overview

---

## Document Maintenance

**Last Updated**: June 2026  
**Next Review**: December 2026  
**Owner**: Architecture & Security Team  
**Version**: 1.0 (Comprehensive)

### Version History
- **1.0 (June 2026)**: Comprehensive documentation
  - Policy as Code framework (24 policies, 7 initiatives)
  - Monitoring as Code framework (40+ metrics, 10+ alerts)
  - Dashboards as Code framework (6 workbooks)
  - Full integration guide (5-phase roadmap)
  - Compliance mappings (PCI-DSS, HIPAA, SOC 2, NIST)

---

## Support & Contact

### For Questions About:
- **Architecture & Design**: Contact Platform Architecture Board
- **Policy & Governance**: Contact Security & Compliance Team
- **Monitoring & Alerts**: Contact Operations/SRE Team
- **Implementation & Deployment**: Contact Platform Engineering Team
- **Cost & Finance**: Contact Finance Team

---

## Related Resources

- [Azure Policy Documentation](https://learn.microsoft.com/en-us/azure/governance/policy/)
- [Azure Monitor Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/)
- [Bicep Language Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/)
- [KQL (Kusto Query Language) Reference](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Azure Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/)

---

**For the latest version, visit the design folder in the repository.**
