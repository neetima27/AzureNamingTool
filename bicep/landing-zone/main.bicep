targetScope = 'subscription'

@description('Environment name (dev, staging, prod)')
param environment string = 'prod'

@description('Azure region')
param location string = 'southafricanorth'

@description('Project name for naming resources')
param projectName string

@description('Tenant ID')
param tenantId string

@description('Principal ID for Key Vault access')
param principalId string

@description('Spoke VNet address space')
param spokeAddressSpace string = '10.19.16.0/20'

var commonTags = {
  Environment: environment
  Project: projectName
  ManagedBy: 'Bicep'
  CreatedDate: utcNow('u')
}

// Create resource groups
resource hubResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-hub-${environment}-${location}'
  location: location
  tags: commonTags
}

resource projectResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${projectName}-${environment}-${location}'
  location: location
  tags: commonTags
}

// Deploy hub network using existing hub-vnet.bicep
module hubVnet 'hub-vnet.bicep' = {
  scope: hubResourceGroup
  name: 'hub-vnet-deployment'
  params: {
    environment: environment
    location: location
  }
}

// Deploy spoke VNet with app, data, and integration subnets
module spokeVnet '../modules/networking/vnet.bicep' = {
  scope: projectResourceGroup
  name: 'spoke-vnet-deployment'
  params: {
    vnetName: 'vnet-${projectName}-${environment}'
    location: location
    addressSpace: [spokeAddressSpace]
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: '10.19.16.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'snet-data'
        addressPrefix: '10.19.17.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'snet-integration'
        addressPrefix: '10.19.18.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
      }
    ]
    tags: commonTags
  }
}

// Deploy peer hub to spoke
module hubToSpokePeering '../modules/networking/vnet-peering.bicep' = {
  scope: hubResourceGroup
  name: 'hub-to-spoke-peering'
  params: {
    sourceVnetName: 'vnet-hub-${environment}'
    remoteVnetName: 'vnet-${projectName}-${environment}'
    sourceResourceGroup: hubResourceGroup.name
    remoteResourceGroup: projectResourceGroup.name
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}

// Deploy peer spoke to hub
module spokeToHubPeering '../modules/networking/vnet-peering.bicep' = {
  scope: projectResourceGroup
  name: 'spoke-to-hub-peering'
  params: {
    sourceVnetName: 'vnet-${projectName}-${environment}'
    remoteVnetName: 'vnet-hub-${environment}'
    sourceResourceGroup: projectResourceGroup.name
    remoteResourceGroup: hubResourceGroup.name
    allowForwardedTraffic: true
    useRemoteGateways: true
  }
}

// Deploy monitoring resources
module logAnalytics '../modules/monitoring/log-analytics.bicep' = {
  scope: hubResourceGroup
  name: 'log-analytics-deployment'
  params: {
    workspaceName: 'law-${projectName}-${environment}'
    location: location
    tags: commonTags
  }
}

module applicationInsights '../modules/monitoring/application-insights.bicep' = {
  scope: projectResourceGroup
  name: 'app-insights-deployment'
  params: {
    appInsightsName: 'appi-${projectName}-${environment}'
    location: location
    workspaceResourceId: logAnalytics.outputs.workspaceResourceId
    tags: commonTags
  }
}

// Deploy Key Vault with private endpoint
module keyVault '../modules/security/keyvault.bicep' = {
  scope: hubResourceGroup
  name: 'keyvault-deployment'
  params: {
    vaultName: 'kv-${replace(projectName, '-', '')}-${environment}'
    location: location
    resourceGroupName: hubResourceGroup.name
    tenantId: tenantId
    principalId: principalId
    tags: commonTags
  }
}

// Deploy private DNS zone for Key Vault
module keyVaultDnsZone '../modules/shared/private-dns-zone.bicep' = {
  scope: hubResourceGroup
  name: 'keyvault-dns-zone-deployment'
  params: {
    zoneName: 'privatelink.vaultcore.azure.net'
    vnetIds: [
      hubVnet.outputs.hubVnetId
      spokeVnet.outputs.vnetId
    ]
    tags: commonTags
  }
}

// Deploy private endpoint for Key Vault
module keyVaultPrivateEndpoint '../modules/shared/private-endpoint.bicep' = {
  scope: hubResourceGroup
  name: 'keyvault-pe-deployment'
  params: {
    privateEndpointName: 'pe-kv-${replace(projectName, '-', '')}-${environment}'
    location: location
    subnetId: '${hubVnet.outputs.hubVnetId}/subnets/snet-private-endpoints'
    privateLinkServiceConnectionName: 'pls-kv-${replace(projectName, '-', '')}'
    resourceId: keyVault.outputs.vaultId
    groupIds: [
      'vault'
    ]
    tags: commonTags
  }
}

@description('Output hub VNet ID')
output hubVnetId string = hubVnet.outputs.hubVnetId

@description('Output spoke VNet ID')
output spokeVnetId string = spokeVnet.outputs.vnetId

@description('Output Key Vault ID')
output keyVaultId string = keyVault.outputs.vaultId

@description('Output Log Analytics Workspace ID')
output logAnalyticsWorkspaceId string = logAnalytics.outputs.workspaceId

@description('Output Application Insights ID')
output applicationInsightsId string = applicationInsights.outputs.appInsightsId

@description('Output hub resource group name')
output hubResourceGroupName string = hubResourceGroup.name

@description('Output project resource group name')
output projectResourceGroupName string = projectResourceGroup.name
