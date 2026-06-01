@description('Name of the private endpoint')
param privateEndpointName string

@description('Location for the private endpoint')
param location string

@description('Resource ID of the subnet for private endpoint')
param subnetId string

@description('Name of the private link service connection')
param privateLinkServiceConnectionName string

@description('Resource ID of the resource to connect')
param resourceId string

@description('Group IDs for the service (e.g., blob, vault, sqlServer)')
param groupIds array

@description('Resource tags')
param tags object = {}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: privateLinkServiceConnectionName
        properties: {
          privateLinkServiceId: resourceId
          groupIds: groupIds
        }
      }
    ]
  }
  tags: tags
}

@description('Output the private endpoint ID')
output privateEndpointId string = privateEndpoint.id

@description('Output the private endpoint network interface')
output networkInterfaceIds array = privateEndpoint.properties.networkInterfaces

@description('Output the private endpoint resource')
output privateEndpointResource object = privateEndpoint
