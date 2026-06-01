@description('Name of the private DNS zone')
param zoneName string

@description('Resource IDs of virtual networks to link')
param vnetIds array

@description('Resource tags')
param tags object = {}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  tags: tags
}

resource vnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, index) in vnetIds: {
  parent: privateDnsZone
  name: 'link-vnet-${index}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

@description('Output the private DNS zone ID')
output privateDnsZoneId string = privateDnsZone.id

@description('Output the private DNS zone name servers')
output nameServers array = privateDnsZone.properties.nameServers
