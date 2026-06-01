@description('Name of the banking operations dashboard')
param dashboardName string = 'banking-operational-dashboard'

@description('Location for the dashboard')
param location string

@description('Resource group name')
param resourceGroupName string

@description('Log Analytics workspace resource ID')
param workspaceResourceId string

@description('Application Insights resource ID')
param appInsightsResourceId string = ''

var dashboardContent = {
  version: 'Notebook/1.0'
  items: [
    {
      type: 1
      content: {
        json: '# Banking Operational Dashboard\n\nReal-time monitoring and operational insights for the Azure banking landing zone infrastructure.'
      }
      name: 'title'
    }
    {
      type: 12
      content: {
        version: '1.4.0'
        items: [
          {
            type: 3
            content: {
              chartType: 'Timeseries'
              legendSettings: {
                isEnabled: true
              }
              timeSettings: {
                absolute: {
                  duration: 86400000
                }
              }
              query: 'Perf\n| where ObjectName == "Processor"\n| where CounterName == "% Processor Time"\n| summarize AvgCPU = avg(CounterValue) by bin(TimeGenerated, 5m), Computer\n| render timechart'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'timechart'
            }
            name: 'CPU Performance Trend'
          }
          {
            type: 3
            content: {
              chartType: 'Pie'
              query: 'AzureDiagnostics\n| where OperationName == "AzureFirewallApplicationRuleLog"\n| summarize count() by Action\n| render piechart'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'piechart'
            }
            name: 'Firewall Rule Distribution'
          }
          {
            type: 3
            content: {
              chartType: 'Bar'
              query: 'AzureDiagnostics\n| where ResourceType == "STORAGEACCOUNTS"\n| summarize TotalTransactions = count() by OperationName\n| top 10 by TotalTransactions\n| render barchart'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'barchart'
            }
            name: 'Storage Operations'
          }
        ]
      }
      name: 'Metrics Section'
    }
    {
      type: 12
      content: {
        version: '1.4.0'
        items: [
          {
            type: 3
            content: {
              chartType: 'Table'
              query: 'AzureDiagnostics\n| where OperationName contains "Error" or Level == "Error"\n| summarize EventCount = count() by OperationName, Level, bin(TimeGenerated, 1h)\n| sort by EventCount desc\n| limit 20'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'table'
            }
            name: 'Recent Errors'
          }
        ]
      }
      name: 'Error Tracking'
    }
    {
      type: 12
      content: {
        version: '1.4.0'
        items: [
          {
            type: 3
            content: {
              chartType: 'Table'
              query: 'AzureDiagnostics\n| where ResourceType == "KEYVAULTS"\n| where OperationName == "VaultGet" and ResultSignature == "Forbidden"\n| summarize FailureCount = count() by CallerIPAddress, UserPrincipalName\n| where FailureCount > 5\n| sort by FailureCount desc'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'table'
            }
            name: 'Failed Key Vault Access Attempts'
          }
        ]
      }
      name: 'Security Monitoring'
    }
    {
      type: 12
      content: {
        version: '1.4.0'
        items: [
          {
            type: 3
            content: {
              chartType: 'Table'
              query: 'Perf\n| where ObjectName == "LogicalDisk"\n| where CounterName == "Free Megabytes"\n| summarize AvailableSpace = avg(CounterValue) by Computer, InstanceName\n| sort by AvailableSpace asc'
              queryType: 0
              resourceType: 'microsoft.operationalinsights/workspaces'
              visualization: 'table'
            }
            name: 'Disk Space Analysis'
          }
        ]
      }
      name: 'Resource Capacity'
    }
  ]
  styleSettings: {}
  fromTemplateId: null
  $schema: 'https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json'
}

resource operationalDashboard 'Microsoft.Insights/workbooks@2021-03-08' = {
  name: guid(resourceGroup().id, dashboardName)
  location: location
  kind: 'shared'
  tags: {
    category: 'Banking Operations'
    environment: 'Production'
    purpose: 'Operational Monitoring'
  }
  properties: {
    displayName: 'Banking Operational Dashboard'
    serializedData: string(dashboardContent)
    description: 'Real-time operational status for banking infrastructure monitoring'
    version: '1.0'
    sourceId: workspaceResourceId
    category: 'Banking Operations'
  }
}

@description('Output the dashboard resource ID')
output dashboardId string = operationalDashboard.id

@description('Output the dashboard name')
output dashboardName string = operationalDashboard.name
