@description('Name of the Application Insights instance')
param appInsightsName string

@description('Location for the application insights')
param location string

@description('Resource ID of the Log Analytics Workspace')
param workspaceResourceId string

@description('Application type (web, other)')
param applicationType string = 'web'

@description('Disable public network access')
param disablePublicAccess bool = true

@description('Resource tags')
param tags object = {}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    applicationId: appInsightsName
    applicationType: applicationType
    workspaceResourceId: workspaceResourceId
    publicNetworkAccessForIngestion: disablePublicAccess ? 'Disabled' : 'Enabled'
    publicNetworkAccessForQuery: disablePublicAccess ? 'Disabled' : 'Enabled'
    retentionInDays: 30
  }
  tags: tags
}

@description('Output the Application Insights ID')
output appInsightsId string = applicationInsights.id

@description('Output the Application Insights name')
output appInsightsName string = applicationInsights.name

@description('Output the Application Insights instrumentation key')
output appInsightsKey string = applicationInsights.properties.InstrumentationKey

@description('Output the Application Insights connection string')
output appInsightsConnectionString string = applicationInsights.properties.ConnectionString
