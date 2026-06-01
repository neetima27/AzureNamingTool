// Log Analytics Workspace with Private Endpoint
// Bicep template for monitoring infrastructure setup

param location string = 'southafricanorth'
param environment string
param workspaceName string = 'law-banking-${environment}'
param privateLinkEnabled bool = true

var commonTags = {
  Environment: environment
  Project: 'Platform'
  Owner: 'platform-team@banking.com'
  ManagedBy: 'Terraform'
  DataClassification: 'Confidential'
}

// Resource Group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-monitoring-${environment}'
  location: location
  tags: commonTags
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  parent: resourceGroup
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 730
    publicNetworkAccessForIngestion: privateLinkEnabled ? 'Disabled' : 'Enabled'
    publicNetworkAccessForQuery: privateLinkEnabled ? 'Disabled' : 'Enabled'
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      immediatePurgeDataOn30Days: false
    }
  }
  tags: commonTags
}

// Application Insights connected to Log Analytics
resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  parent: resourceGroup
  name: 'ai-banking-${environment}'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccessForIngestion: privateLinkEnabled ? 'Disabled' : 'Enabled'
    publicNetworkAccessForQuery: privateLinkEnabled ? 'Disabled' : 'Enabled'
  }
  tags: commonTags
}

// Action Group for Alerts
resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  parent: resourceGroup
  name: 'ag-banking-${environment}'
  location: 'global'
  properties: {
    groupShortName: 'banking-ag'
    enabled: true
    emailReceivers: [
      {
        name: 'EmailNotification'
        emailAddress: 'platform-team@banking.com'
        useCommonAlertSchema: true
      }
    ]
  }
  tags: commonTags
}

// Alert Rule: High CPU Usage
resource alertHighCpu 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  parent: resourceGroup
  name: 'alert-high-cpu-${environment}'
  location: 'global'
  properties: {
    description: 'Alert when CPU usage exceeds 85%'
    severity: 2
    enabled: true
    scopes: [
      subscription().id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HighCpuUsage'
          metricName: 'Percentage CPU'
          operator: 'GreaterThan'
          threshold: 85
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
  tags: commonTags
}

// Alert Rule: Service Availability
resource alertAvailability 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  parent: resourceGroup
  name: 'alert-availability-${environment}'
  location: 'global'
  properties: {
    description: 'Alert when availability drops below 99%'
    severity: 1
    enabled: true
    scopes: [
      applicationInsights.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT30M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'LowAvailability'
          metricName: 'availabilityResults/availabilityPercentage'
          operator: 'LessThan'
          threshold: 99
          timeAggregation: 'Average'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
  tags: commonTags
}

// Scheduled Query Alert: Failed Authentication
resource alertAuthFailure 'Microsoft.Insights/scheduledQueryRules@2021-08-01' = {
  parent: resourceGroup
  name: 'alert-auth-failures-${environment}'
  location: location
  properties: {
    description: 'Alert on 5+ failed login attempts in 5 minutes'
    severity: 1
    enabled: true
    scopes: [
      logAnalyticsWorkspace.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    query: '''
    AuditLogs
    | where OperationName == "Sign-in activity"
    | where Result == "failure"
    | summarize Count = count() by UserPrincipalName
    | where Count >= 5
    '''
    criteria: {
      allOf: [
        {
          query: 'succeeded'
          threshold: 0
          operator: 'GreaterThan'
          timeAggregation: 'Count'
          dimensions: []
        }
      ]
    }
    actions: {
      actionGroups: [
        actionGroup.id
      ]
    }
  }
  tags: commonTags
}

// Diagnostic Setting for monitoring key vault
// This would be created for each resource that needs monitoring
output workspaceId string = logAnalyticsWorkspace.id
output applicationInsightsId string = applicationInsights.id
output actionGroupId string = actionGroup.id
output workspaceKey string = logAnalyticsWorkspace.listKeys().primarySharedKey
