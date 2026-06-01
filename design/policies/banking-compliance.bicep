// Banking Sector Compliance Policy Initiative
// This Bicep template deploys Azure Policy definitions and initiatives for banking compliance

param location string = deployment().location
param environment string
param policyDescription string = 'Banking sector compliance requirements'

// Policy Definition: Require Private Endpoints
resource policyPrivateEndpoints 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-private-endpoints-banking'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Require Private Endpoints for Banking PaaS Services'
    description: 'Ensures all PaaS services use private endpoints to prevent public access'
    metadata: {
      category: 'Banking Compliance'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            in: [
              'Microsoft.Sql/servers'
              'Microsoft.Storage/storageAccounts'
              'Microsoft.KeyVault/vaults'
              'Microsoft.ContainerRegistry/registries'
              'Microsoft.ServiceBus/namespaces'
            ]
          }
          {
            field: 'Microsoft.Sql/servers/publicNetworkAccess'
            equals: 'Enabled'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// Policy Definition: Require Encryption at Rest
resource policyEncryption 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-encryption-at-rest-banking'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Require Encryption at Rest for Banking Data'
    description: 'Enforces encryption at rest for all storage and database resources'
    metadata: {
      category: 'Banking Compliance'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            in: [
              'Microsoft.Sql/servers/databases'
              'Microsoft.Storage/storageAccounts'
              'Microsoft.Cosmos/databaseAccounts'
            ]
          }
          {
            field: 'Microsoft.Sql/servers/databases/transparentDataEncryption/status'
            notEquals: 'Enabled'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// Policy Definition: Require Mandatory Tags
resource policyMandatoryTags 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-mandatory-tags-banking'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Require Mandatory Tags for Banking Resources'
    description: 'All resources must have required tags for cost tracking and governance'
    metadata: {
      category: 'Banking Compliance'
      version: '1.0.0'
    }
    parameters: {
      requiredTags: {
        type: 'Array'
        defaultValue: [
          'Environment'
          'Project'
          'Owner'
          'CostCenter'
          'ApplicationName'
          'DataClassification'
        ]
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            notEquals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            count: {
              field: 'tags[*]'
              where: {
                field: 'tags.key'
                in: '[parameters(\'requiredTags\')]'
              }
            }
            less: '[length(parameters(\'requiredTags\'))]'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// Policy Definition: Allowed Locations (South Africa North only)
resource policyAllowedLocations 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'allowed-locations-south-africa-banking'
  properties: {
    policyType: 'Custom'
    mode: 'All'
    displayName: 'Allowed Locations for Banking Resources'
    description: 'Resources must be deployed only to South Africa North region'
    metadata: {
      category: 'Banking Compliance'
      version: '1.0.0'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            notEquals: 'Microsoft.Resources/subscriptions/resourceGroups'
          }
          {
            field: 'location'
            notIn: [
              'southafricanorth'
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}

// Policy Initiative: Banking Sector Compliance
resource policyInitiativeBanking 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'banking-sector-compliance-initiative'
  properties: {
    policyType: 'Custom'
    displayName: 'Banking Sector Compliance Initiative'
    description: 'Comprehensive compliance framework for banking organizations'
    metadata: {
      category: 'Banking Compliance'
      version: '1.0.0'
    }
    policyDefinitions: [
      {
        policyDefinitionId: policyPrivateEndpoints.id
        parameters: {}
      }
      {
        policyDefinitionId: policyEncryption.id
        parameters: {}
      }
      {
        policyDefinitionId: policyMandatoryTags.id
        parameters: {
          requiredTags: {
            value: [
              'Environment'
              'Project'
              'Owner'
              'CostCenter'
              'ApplicationName'
              'DataClassification'
            ]
          }
        }
      }
      {
        policyDefinitionId: policyAllowedLocations.id
        parameters: {}
      }
    ]
  }
}

// Policy Assignment: Assign initiative to management group
resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: 'banking-compliance-assignment-${environment}'
  scope: subscription()
  properties: {
    policyDefinitionId: policyInitiativeBanking.id
    displayName: 'Banking Sector Compliance Assignment - ${environment}'
    description: 'Enforce banking compliance policies in ${environment} environment'
    enforcementMode: 'Default'
    parameters: {
      requiredTags: {
        value: [
          'Environment'
          'Project'
          'Owner'
          'CostCenter'
          'ApplicationName'
          'DataClassification'
        ]
      }
    }
  }
}

// Output policy assignment ID
output policyAssignmentId string = policyAssignment.id
output policyInitiativeId string = policyInitiativeBanking.id
