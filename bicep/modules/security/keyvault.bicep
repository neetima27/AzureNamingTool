@description('Name of the Key Vault')
param vaultName string

@description('Location for the Key Vault')
param location string

@description('Resource group name')
param resourceGroupName string

@description('Tenant ID for the vault')
param tenantId string

@description('Object ID of the principal to grant access')
param principalId string

@description('Resource tags')
param tags object = {}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaultName
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    sku: {
      name: 'premium'
      family: 'A'
    }
    accessPolicies: [
      {
        tenantId: tenantId
        objectId: principalId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
          certificates: [
            'all'
          ]
        }
      }
    ]
    // Deny public network access - enforce private endpoints
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
  tags: tags
}

@description('Output the Key Vault ID')
output vaultId string = keyVault.id

@description('Output the Key Vault name')
output vaultName string = keyVault.name

@description('Output the Key Vault URI')
output vaultUri string = keyVault.properties.vaultUri

@description('Output the resource group name')
output resourceGroupName string = resourceGroupName
