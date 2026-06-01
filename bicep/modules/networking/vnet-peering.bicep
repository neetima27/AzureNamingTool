@description('Name of the virtual network (source)')
param sourceVnetName string

@description('Name of the remote virtual network')
param remoteVnetName string

@description('Resource group of the source VNet')
param sourceResourceGroup string

@description('Resource group of the remote VNet')
param remoteResourceGroup string

@description('Subscription ID of the remote VNet')
param remoteSubscriptionId string = subscription().subscriptionId

@description('Allow traffic from source to remote')
param allowForwardedTraffic bool = true

@description('Allow remote gateway transit')
param allowGatewayTransit bool = true

@description('Use remote gateway')
param useRemoteGateways bool = false

resource sourceVnet 'Microsoft.Network/virtualNetworks@2023-05-01' existing = {
  name: sourceVnetName
  scope: resourceGroup(sourceResourceGroup)
}

resource remotePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-05-01' = {
  parent: sourceVnet
  name: '${sourceVnetName}-to-${remoteVnetName}'
  properties: {
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: '/subscriptions/${remoteSubscriptionId}/resourceGroups/${remoteResourceGroup}/providers/Microsoft.Network/virtualNetworks/${remoteVnetName}'
    }
  }
}

@description('Output the peering ID')
output peeringId string = remotePeering.id

@description('Output the peering state')
output peeringState string = remotePeering.properties.peeringState
