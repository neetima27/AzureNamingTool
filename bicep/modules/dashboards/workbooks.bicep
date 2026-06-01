@description('Name of the workbook')
param workbookName string

@description('Display name for the workbook')
param displayName string

@description('Workbook description')
param workbookDescription string

@description('Resource group name')
param resourceGroupName string

@description('Location for the workbook')
param location string

@description('Log Analytics workspace resource ID')
param workspaceResourceId string

@description('Workbook category')
param category string = 'Banking Monitoring'

@description('Workbook source type')
param sourceType string = 'Azure Monitor'

@description('Workbook content (JSON)')
param workbookContent object

@description('Share workbook with group')
param shareWithGroup bool = true

@description('Workbook tags')
param tags object = {}

resource workbook 'Microsoft.Insights/workbooks@2021-03-08' = {
  name: guid(resourceGroup().id, workbookName)
  location: location
  kind: 'shared'
  tags: union(tags, {
    category: category
    environment: 'Production'
  })
  properties: {
    displayName: displayName
    serializedData: string(workbookContent)
    description: workbookDescription
    version: '1.0'
    sourceId: workspaceResourceId
    category: category
    identity: {
      type: 'UserAssigned'
    }
  }
}

@description('Output the workbook ID')
output workbookId string = workbook.id

@description('Output the workbook name')
output workbookName string = workbook.name

@description('Output the workbook resource ID')
output resourceId string = workbook.id
