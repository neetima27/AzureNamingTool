param environment string = 'prod'
param location string = 'southafricanorth'

var tags = {
  Environment: environment
  Project: 'Platform'
  Owner: 'platform-team@banking.com'
  ManagedBy: 'Bicep'
}

resource hubRg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-hub-${environment}-${location}'
  location: location
  tags: tags
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-hub-${environment}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.19.0.0/16'
      ]
    }
  }
  tags: tags
}

resource firewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'AzureFirewallSubnet'
  properties: {
    addressPrefix: '10.19.0.0/24'
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.19.1.0/24'
  }
}

resource gatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'GatewaySubnet'
  properties: {
    addressPrefix: '10.19.2.0/24'
  }
}

resource privateEndpointsSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'snet-private-endpoints'
  properties: {
    addressPrefix: '10.19.3.0/24'
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource sharedServicesSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'snet-shared-services'
  properties: {
    addressPrefix: '10.19.4.0/24'
  }
}

resource managementSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: hubVnet
  name: 'snet-management'
  properties: {
    addressPrefix: '10.19.5.0/24'
  }
}

resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-firewall-${environment}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

resource azureFirewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: 'fw-${environment}'
  location: location
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          subnet: {
            id: firewallSubnet.id
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
  }
  tags: tags
}

resource bastionPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: 'pip-bastion-${environment}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  tags: tags
}

resource bastionHost 'Microsoft.Network/bastionHosts@2021-05-01' = {
  name: 'bastion-${environment}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: bastionPublicIp.id
          }
        }
      }
    ]
  }
  tags: tags
}

resource keyVaultDnsZone 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: tags
}

resource keyVaultDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: keyVaultDnsZone
  name: 'link-hub-vnet'
  properties: {
    virtualNetwork: {
      id: hubVnet.id
    }
    registrationEnabled: false
  }
}

output hubVnetId string = hubVnet.id
output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
output privateEndpointsSubnetId string = privateEndpointsSubnet.id
output keyVaultDnsZoneId string = keyVaultDnsZone.id
