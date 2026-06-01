@description('Name of the virtual network')
param vnetName string

@description('Location for the virtual network')
param location string

@description('Address space for the virtual network')
param addressSpace array

@description('Array of subnets to create')
param subnets array

@description('Resource tags')
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'nsgId') ? {
          id: subnet.nsgId
        } : null
        routeTable: contains(subnet, 'routeTableId') ? {
          id: subnet.routeTableId
        } : null
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : 'Enabled'
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : 'Enabled'
      }
    }]
  }
  tags: tags
}

@description('Output the VNet ID')
output vnetId string = vnet.id

@description('Output the VNet name')
output vnetName string = vnet.name

@description('Output all subnet resource IDs')
output subnetIds array = [for (subnet, index) in subnets: {
  name: subnet.name
  id: '${vnet.id}/subnets/${subnet.name}'
}]

@description('Output the VNet resource')
output vnetResource object = vnet
