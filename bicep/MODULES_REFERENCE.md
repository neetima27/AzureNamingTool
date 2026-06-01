# Policy, Monitoring & Dashboards Modules Documentation

Comprehensive reference for Bicep modules enabling Policy as Code, Monitoring as Code, and Dashboards as Code in the Azure banking landing zone.

## Module Organization

```
bicep/modules/
├── policy/                      # Policy as Code modules
│   ├── policy-definition.bicep       # Generic policy definition
│   ├── policy-initiative.bicep       # Policy initiative/set
│   ├── policy-assignment.bicep       # Policy assignment to scope
│   └── banking-compliance-policies.bicep  # Pre-built banking policies
├── monitoring/                  # Monitoring as Code modules
│   ├── diagnostic-settings.bicep     # Enable diagnostics on resources
│   ├── metric-alerts.bicep           # Create metric-based alerts
│   ├── action-groups.bicep           # Alert notification routing
│   ├── log-analytics.bicep (existing)
│   └── application-insights.bicep (existing)
└── dashboards/                  # Dashboards as Code modules
    ├── workbooks.bicep               # Generic workbook/dashboard
    └── banking-operational-dashboard.bicep  # Pre-built operational dashboard
```

---

## Policy Modules

### policy-definition.bicep

**Purpose**: Generic reusable module for creating Azure Policy definitions

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| policyName | string | Unique policy name | Yes |
| displayName | string | User-friendly policy name | Yes |
| description | string | Policy purpose | Yes |
| mode | string | 'All' or 'Indexed' | No (default: 'All') |
| effect | string | Audit, Deny, DeployIfNotExists, etc. | No (default: 'Audit') |
| conditions | object | Policy rule conditions (if/then) | Yes |
| parameters | object | Policy parameters | No (default: {}) |
| identityType | string | 'SystemAssigned', 'UserAssigned', or 'None' | No (default: 'None') |

**Example Usage**:

```bicep
module enforcedHttpsStorage 'modules/policy/policy-definition.bicep' = {
  name: 'enforceHttpsStoragePolicy'
  params: {
    policyName: 'enforce-https-storage'
    displayName: 'Enforce HTTPS for Storage Accounts'
    description: 'Blocks creation of non-HTTPS storage accounts'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly'
            notEquals: 'true'
          }
        ]
      }
      then: {}
    }
  }
}
```

**Outputs**:
- `policyDefinitionId`: Full policy definition resource ID
- `policyName`: Policy name for reference

---

### policy-initiative.bicep

**Purpose**: Group related policies into initiatives/policy sets for coherent enforcement

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| initiativeName | string | Unique initiative name | Yes |
| displayName | string | User-friendly name | Yes |
| description | string | Initiative purpose | Yes |
| policyDefinitions | array | Array of policies to include | Yes |
| parameters | object | Initiative-level parameters | No |
| policyGroups | array | Group definitions for organization | No |

**Example Usage**:

```bicep
module bankingComplianceInitiative 'modules/policy/policy-initiative.bicep' = {
  name: 'bankingComplianceInit'
  params: {
    initiativeName: 'banking-compliance-initiative'
    displayName: 'Banking Compliance Initiative'
    description: 'Comprehensive policy set for banking compliance'
    policyDefinitions: [
      {
        policyDefinitionId: httpsStoragePolicyId
        referenceId: 'enforceHttpsStorage'
        parameters: {}
      }
      {
        policyDefinitionId: denyPublicBlobPolicyId
        referenceId: 'denyPublicBlob'
        parameters: {}
      }
    ]
  }
}
```

**Outputs**:
- `policySetDefinitionId`: Full policy set definition resource ID
- `initiativeName`: Initiative name for reference

---

### policy-assignment.bicep

**Purpose**: Assign policies to resource groups, subscriptions, or management groups

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| assignmentName | string | Assignment resource name | Yes |
| policyDefinitionId | string | Policy/initiative definition ID | Yes |
| assignmentScope | string | Scope (/subscriptions/{sub}/...) | Yes |
| location | string | Azure region | No (default: southafricanorth) |
| parameters | object | Policy parameters for this assignment | No |
| identityType | string | Managed identity type for DeployIfNotExists | No |
| roleDefinitionId | string | Role ID for identity RBAC | No |
| displayName | string | Assignment display name | No |
| description | string | Assignment description | No |
| enforcementMode | string | 'Default' or 'DoNotEnforce' | No (default: 'Default') |
| notScopes | array | Resources/RGs to exempt | No |

**Example Usage**:

```bicep
module bankingComplianceAssignment 'modules/policy/policy-assignment.bicep' = {
  name: 'bankingComplianceAssign'
  params: {
    assignmentName: 'banking-compliance-assignment'
    policyDefinitionId: initiativeId
    assignmentScope: '/subscriptions/${subscriptionId}'
    location: 'southafricanorth'
    displayName: 'Banking Compliance Assignment'
    description: 'Enforce banking compliance policies subscription-wide'
    enforcementMode: 'Default'
    identityType: 'SystemAssigned'
  }
}
```

**Outputs**:
- `assignmentId`: Full assignment resource ID
- `assignmentName`: Assignment name
- `identityPrincipalId`: Managed identity principal ID (for RBAC role assignment)

---

### banking-compliance-policies.bicep

**Purpose**: Pre-configured banking compliance policies ready to deploy

**Contains**: 8 critical policies:
1. enforce-https-storage
2. deny-public-blob-access
3. enforce-nsg-subnets
4. enforce-mandatory-tags
5. enforce-sql-encryption
6. deny-expensive-vm-skus
7. enforce-tls-1-2
8. restrict-approved-locations

**Example Usage**:

```bicep
module bankingPolicies 'modules/policy/banking-compliance-policies.bicep' = {
  name: 'bankingPolicies'
}

output policies array = bankingPolicies.outputs.policyDefinitions
```

---

## Monitoring Modules

### diagnostic-settings.bicep

**Purpose**: Enable diagnostic logging for any Azure resource to Log Analytics, Storage, or Event Hub

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| diagnosticSettingName | string | Diagnostic setting name | Yes |
| resourceId | string | Resource ID to enable diagnostics for | Yes |
| workspaceResourceId | string | Log Analytics workspace ID | Yes |
| storageAccountId | string | Storage account for audit logs | No |
| eventHubAuthorizationRuleId | string | Event Hub auth rule ID | No |
| eventHubName | string | Event Hub name | No |
| enabledLogCategories | array | Log categories to enable | No (default: Audit, Operational, Security) |
| enabledMetrics | array | Metrics to enable | No (default: AllMetrics) |
| retentionDays | int | Log retention days | No (default: 90) |

**Example Usage**:

```bicep
module sqlDiagnostics 'modules/monitoring/diagnostic-settings.bicep' = {
  name: 'sqlDiagnostics'
  params: {
    diagnosticSettingName: 'diag-sql-prod'
    resourceId: sqlDatabaseId
    workspaceResourceId: logAnalyticsWorkspaceId
    enabledLogCategories: [
      'Audit'
      'Error'
      'Deadlock'
    ]
    enabledMetrics: [
      'AllMetrics'
    ]
    retentionDays: 90
  }
}
```

**Outputs**:
- `diagnosticSettingId`: Diagnostic setting resource ID

---

### metric-alerts.bicep

**Purpose**: Create metric-based alerts for resource thresholds

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| alertName | string | Alert resource name | Yes |
| displayName | string | Alert display name | Yes |
| description | string | Alert description | Yes |
| scopes | array | Resource IDs to monitor | Yes |
| metricName | string | Metric to monitor (e.g., "Percentage CPU") | Yes |
| metricNamespace | string | Metric namespace (e.g., "Microsoft.Compute/virtualMachines") | Yes |
| operator | string | Equals, GreaterThan, LessThan, etc. | Yes |
| threshold | int | Threshold value | Yes |
| severity | int | 0-4 (0=Critical, 4=Informational) | No (default: 2) |
| evaluationFrequency | int | Check frequency in minutes | No (default: 1) |
| windowSize | int | Evaluation window in minutes | No (default: 5) |
| actionGroupId | string | Action group resource ID | Yes |
| autoMitigate | bool | Auto-resolve when condition clears | No (default: true) |

**Example Usage**:

```bicep
module highCpuAlert 'modules/monitoring/metric-alerts.bicep' = {
  name: 'highCpuAlert'
  params: {
    alertName: 'alert-vm-high-cpu'
    displayName: 'VM High CPU Usage'
    description: 'Alert when VM CPU exceeds 80%'
    scopes: [
      vmId
    ]
    metricName: 'Percentage CPU'
    metricNamespace: 'Microsoft.Compute/virtualMachines'
    operator: 'GreaterThan'
    threshold: 80
    severity: 2
    evaluationFrequency: 1
    windowSize: 5
    actionGroupId: actionGroupId
  }
}
```

**Outputs**:
- `alertId`: Alert resource ID
- `alertName`: Alert name

---

### action-groups.bicep

**Purpose**: Configure alert notification routing (email, SMS, webhooks, runbooks)

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| actionGroupName | string | Action group resource name | Yes |
| displayName | string | Display name | Yes |
| resourceGroupName | string | Resource group name | Yes |
| location | string | Azure region (must be East US) | No (default: eastus) |
| emailReceivers | array | Email notification list | No |
| smsReceivers | array | SMS notification list | No |
| webhookReceivers | array | Webhook destinations | No |
| runbookReceivers | array | Automation runbooks to trigger | No |
| azureFunctionReceivers | array | Azure Functions to invoke | No |
| enabled | bool | Enable notifications | No (default: true) |

**Email Receiver Format**:
```bicep
{
  name: 'OpsTeam'
  email: 'ops@company.com'
}
```

**Example Usage**:

```bicep
module opsActionGroup 'modules/monitoring/action-groups.bicep' = {
  name: 'opsActionGroup'
  params: {
    actionGroupName: 'ag-ops-team'
    displayName: 'Operations Team Alerts'
    resourceGroupName: resourceGroupName
    emailReceivers: [
      {
        name: 'OpsTeam'
        email: 'ops@company.com'
      }
      {
        name: 'Manager'
        email: 'manager@company.com'
      }
    ]
    webhookReceivers: [
      {
        name: 'PagerDuty'
        serviceUri: 'https://events.pagerduty.com/integration/.../enqueue'
      }
    ]
  }
}
```

**Outputs**:
- `actionGroupId`: Action group resource ID
- `resourceId`: Resource ID for alert references

---

## Dashboard Modules

### workbooks.bicep

**Purpose**: Generic reusable module for creating Azure Monitor Workbooks (dashboards)

**Parameters**:

| Parameter | Type | Description | Required |
|-----------|------|-------------|----------|
| workbookName | string | Workbook resource name | Yes |
| displayName | string | Display name | Yes |
| workbookDescription | string | Description | Yes |
| resourceGroupName | string | Resource group name | Yes |
| location | string | Azure region | Yes |
| workspaceResourceId | string | Log Analytics workspace ID | Yes |
| category | string | Workbook category | No (default: 'Banking Monitoring') |
| sourceType | string | Source type | No (default: 'Azure Monitor') |
| workbookContent | object | Workbook JSON structure | Yes |
| shareWithGroup | bool | Share workbook | No (default: true) |
| tags | object | Resource tags | No |

**Example Usage**:

```bicep
module operationalDashboard 'modules/dashboards/workbooks.bicep' = {
  name: 'opDashboard'
  params: {
    workbookName: 'banking-operational-dashboard'
    displayName: 'Banking Operational Dashboard'
    workbookDescription: 'Real-time operational status'
    location: location
    workspaceResourceId: logAnalyticsWorkspaceId
    workbookContent: workbookContent
    category: 'Banking Operations'
  }
}
```

**Outputs**:
- `workbookId`: Workbook resource ID
- `resourceId`: Resource ID for references

---

### banking-operational-dashboard.bicep

**Purpose**: Pre-configured operational dashboard for banking infrastructure

**Features**:
- CPU performance trend
- Firewall rule distribution
- Storage operations metrics
- Error tracking
- Security monitoring
- Resource capacity analysis

**Example Usage**:

```bicep
module dashboard 'modules/dashboards/banking-operational-dashboard.bicep' = {
  name: 'bankingDashboard'
  params: {
    dashboardName: 'banking-operational-dashboard'
    location: location
    resourceGroupName: resourceGroupName
    workspaceResourceId: logAnalyticsWorkspaceId
  }
}
```

**Outputs**:
- `dashboardId`: Dashboard resource ID
- `dashboardName`: Dashboard name

---

## Integration with main.bicep

### Add to Landing Zone Orchestrator

```bicep
// Policy deployment
module bankingCompliancePolicies 'modules/policy/policy-initiative.bicep' = {
  name: 'policyDeployment'
  params: {
    initiativeName: 'banking-compliance'
    displayName: 'Banking Compliance Initiative'
    description: 'Enforce banking compliance policies'
    policyDefinitions: [
      // ... policy array
    ]
  }
}

// Monitoring setup
module diagnosticsSetup 'modules/monitoring/diagnostic-settings.bicep' = {
  name: 'diagnosticsConfig'
  params: {
    diagnosticSettingName: 'diag-all-resources'
    resourceId: logAnalyticsWorkspaceId
    workspaceResourceId: logAnalyticsWorkspaceId
  }
}

// Action groups for alerts
module alertingSetup 'modules/monitoring/action-groups.bicep' = {
  name: 'alertingConfig'
  params: {
    actionGroupName: 'ag-banking-ops'
    displayName: 'Banking Operations Alerts'
    resourceGroupName: resourceGroupName
    emailReceivers: [
      { name: 'OpsTeam', email: 'ops@company.com' }
    ]
  }
}

// Dashboard creation
module dashboards 'modules/dashboards/banking-operational-dashboard.bicep' = {
  name: 'dashboardsDeployment'
  params: {
    location: location
    resourceGroupName: resourceGroupName
    workspaceResourceId: logAnalyticsWorkspaceId
  }
}
```

---

## Deployment Examples

### Deploy All Policies and Monitoring

```bash
#!/bin/bash

# Deploy main landing zone with policies, monitoring, and dashboards
az deployment sub create \
  --location southafricanorth \
  --template-file bicep/landing-zone/main.bicep \
  --parameters bicep/parameters/prod.parameters.json \
  --parameters \
    policyDeployment=true \
    monitoringDeployment=true \
    dashboardDeployment=true
```

### Deploy Just Monitoring

```bash
az deployment group create \
  --resource-group hub-rg \
  --template-file bicep/modules/monitoring/diagnostic-settings.bicep \
  --parameters \
    diagnosticSettingName="diag-prod" \
    resourceId="/subscriptions/{sub}/resourceGroups/hub-rg/providers/Microsoft.OperationalInsights/workspaces/law-prod" \
    workspaceResourceId="/subscriptions/{sub}/resourceGroups/hub-rg/providers/Microsoft.OperationalInsights/workspaces/law-prod"
```

---

## Best Practices

1. **Policy Deployment**: Start with Audit effect, transition to Deny
2. **Action Groups**: Create team-specific action groups (Ops, Security, Finance)
3. **Dashboard Sharing**: Share dashboards via Azure RBAC, not URLs
4. **Alert Tuning**: Review alert rules monthly, adjust thresholds based on SLAs
5. **Dashboard Refresh**: Set 5-15 minute refresh intervals for operational dashboards
6. **Documentation**: Maintain runbooks for each alert type
7. **Testing**: Test action group notifications in non-production first

---

**Last Updated**: June 2026  
**Module Status**: Production-ready  
**Compatibility**: Azure CLI 2.45.0+, Bicep 0.19.0+
