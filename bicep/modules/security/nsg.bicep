@description('Name of the network security group')
param nsgName string

@description('Location for the NSG')
param location string

@description('Array of security rules')
param securityRules array = []

@description('Resource tags')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        description: rule.description
        protocol: rule.protocol
        sourcePortRange: rule.sourcePortRange
        destinationPortRange: rule.destinationPortRange
        sourceAddressPrefix: rule.sourceAddressPrefix
        destinationAddressPrefix: rule.destinationAddressPrefix
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
  tags: tags
}

@description('Output the NSG ID')
output nsgId string = nsg.id

@description('Output the NSG resource')
output nsgResource object = nsg
