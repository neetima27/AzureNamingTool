@description('Name of the storage account')
param storageAccountName string

@description('Location for the storage account')
param location string

@description('Storage account kind (StorageV2, BlobStorage, etc.)')
param kind string = 'StorageV2'

@description('Replication type (LRS, GRS, RAGRS, etc.)')
param replication string = 'GRS'

@description('Minimum TLS version (TLS1_2, TLS1_3)')
param minimumTlsVersion string = 'TLS1_2'

@description('Resource tags')
param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: kind
  sku: {
    name: 'Standard_${replication}'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: true
    // Deny public network access - enforce private endpoints
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
  tags: tags
}

// Create blob service for private endpoint support
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

// Create file service for private endpoint support
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
}

@description('Output the storage account ID')
output storageAccountId string = storageAccount.id

@description('Output the storage account name')
output storageAccountName string = storageAccount.name

@description('Output the primary blob endpoint')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('Output the storage account access key')
output storageAccountKey string = storageAccount.listKeys().keys[0].value
