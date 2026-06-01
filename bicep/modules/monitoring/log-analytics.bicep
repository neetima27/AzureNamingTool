@description('Name of the Log Analytics Workspace')
param workspaceName string

@description('Location for the workspace')
param location string

@description('SKU for the workspace (PerGB2018, Free, Standalone, PerNode)')
param sku string = 'PerGB2018'

@description('Daily cap in GB')
param dailyCapGb int = 0

@description('Resource tags')
param tags object = {}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: 30
    dailyQuotaGb: dailyCapGb
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
  }
  tags: tags
}

// Enable solutions for monitoring
resource containerInsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: 'ContainerInsights(${workspaceName})'
  location: location
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: 'ContainerInsights(${workspaceName})'
    publisher: 'Microsoft'
    product: 'OMSGallery/ContainerInsights'
    promotionCode: ''
  }
  tags: tags
}

@description('Output the Log Analytics Workspace ID')
output workspaceId string = logAnalyticsWorkspace.id

@description('Output the Log Analytics Workspace name')
output workspaceName string = logAnalyticsWorkspace.name

@description('Output the Log Analytics Workspace customer ID')
output workspaceCustomerId string = logAnalyticsWorkspace.properties.customerId

@description('Output the Log Analytics Workspace resource ID')
output workspaceResourceId string = logAnalyticsWorkspace.id
