@description('Name of the diagnostic setting')
param diagnosticSettingName string

@description('Resource ID to enable diagnostics for')
param resourceId string

@description('Log Analytics workspace resource ID')
param workspaceResourceId string

@description('Storage account resource ID for audit logs (optional)')
param storageAccountId string = ''

@description('Event Hub namespace authorization rule ID (optional)')
param eventHubAuthorizationRuleId string = ''

@description('Event Hub name (optional)')
param eventHubName string = ''

@description('Logs categories to enable')
param enabledLogCategories array = [
  'Audit'
  'Operational'
  'Security'
]

@description('Metrics categories to enable')
param enabledMetrics array = [
  'AllMetrics'
]

@description('Retention days for logs (0 = indefinite)')
param retentionDays int = 90

var diagnosticSettings = {
  name: diagnosticSettingName
  properties: {
    workspaceId: workspaceResourceId
    storageAccountId: !empty(storageAccountId) ? storageAccountId : null
    eventHubAuthorizationRuleId: !empty(eventHubAuthorizationRuleId) ? eventHubAuthorizationRuleId : null
    eventHubName: !empty(eventHubName) ? eventHubName : null
    logs: [for category in enabledLogCategories: {
      category: category
      enabled: true
      retentionPolicy: {
        enabled: retentionDays > 0
        days: retentionDays
      }
    }]
    metrics: [for metric in enabledMetrics: {
      category: metric
      enabled: true
      retentionPolicy: {
        enabled: retentionDays > 0
        days: retentionDays
      }
    }]
  }
}

resource diagnosticSetting 'Microsoft.Insights/diagnosticsSettings@2017-05-01-preview' = {
  name: diagnosticSettingName
  scope: resourceId(replace(resourceId, '/subscriptions/', ''))
  properties: diagnosticSettings.properties
}

@description('Output the diagnostic setting ID')
output diagnosticSettingId string = diagnosticSetting.id
