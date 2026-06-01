@description('Create banking compliance policies for the landing zone')

var policies = [
  {
    name: 'enforce-https-storage'
    displayName: 'Enforce HTTPS for Storage Accounts'
    description: 'Blocks creation of storage accounts without HTTPS enforced'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly'
            notEquals: 'true'
          }
        ]
      }
      then: {}
    }
    parameters: {}
  }
  {
    name: 'deny-public-blob-access'
    displayName: 'Deny Public Blob Access'
    description: 'Prevents public access to blob containers'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts/blobServices/containers'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/blobServices/containers/publicAccess'
            notEquals: 'None'
          }
        ]
      }
      then: {}
    }
    parameters: {}
  }
  {
    name: 'enforce-nsg-subnets'
    displayName: 'Enforce NSG on Subnets'
    description: 'Requires Network Security Group on all subnets'
    mode: 'All'
    effect: 'Audit'
    conditions: {
      if: {
        field: 'type'
        equals: 'Microsoft.Network/virtualNetworks/subnets'
      }
      then: {}
    }
    parameters: {}
  }
  {
    name: 'enforce-mandatory-tags'
    displayName: 'Enforce Mandatory Tags'
    description: 'Requires Environment, CostCenter, and Owner tags on all resources'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'tags[Environment]'
            exists: 'false'
          }
          {
            field: 'tags[CostCenter]'
            exists: 'false'
          }
          {
            field: 'tags[Owner]'
            exists: 'false'
          }
        ]
      }
      then: {}
    }
    parameters: {
      requiredTags: {
        type: 'Array'
        metadata: {
          description: 'List of required tags'
        }
        defaultValue: [
          'Environment'
          'CostCenter'
          'Owner'
        ]
      }
    }
  }
  {
    name: 'enforce-sql-encryption'
    displayName: 'Enforce SQL Database Encryption'
    description: 'Enables Transparent Data Encryption on SQL databases'
    mode: 'All'
    effect: 'DeployIfNotExists'
    conditions: {
      if: {
        field: 'type'
        equals: 'Microsoft.Sql/servers/databases'
      }
      then: {
        details: {
          type: 'Microsoft.Sql/servers/databases/transparentDataEncryption'
          name: 'current'
          existenceCondition: {
            field: 'Microsoft.Sql/transparentDataEncryption.status'
            equals: 'Enabled'
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                resources: [
                  {
                    type: 'Microsoft.Sql/servers/databases/transparentDataEncryption'
                    apiVersion: '2017-03-01-preview'
                    name: '[concat(parameters(\'dbServerName\'), \'/\', parameters(\'dbName\'), \'/current\')]'
                    properties: {
                      status: 'Enabled'
                    }
                  }
                ]
              }
              parameters: {
                dbServerName: {
                  value: '[field(\'fullName\')]'
                }
                dbName: {
                  value: '[field(\'name\')]'
                }
              }
            }
          }
        }
      }
    }
    parameters: {}
  }
  {
    name: 'deny-expensive-vm-skus'
    displayName: 'Deny Expensive VM SKUs'
    description: 'Restricts VM sizes to approved list for cost control'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'Microsoft.Compute/virtualMachines/sku.name'
            in: [
              'Standard_D4s_v3'
              'Standard_D5s_v3'
              'Standard_E4s_v3'
              'Standard_E5s_v3'
              'Standard_E8s_v3'
              'Standard_M128s'
            ]
          }
        ]
      }
      then: {}
    }
    parameters: {}
  }
  {
    name: 'enforce-tls-1-2'
    displayName: 'Enforce TLS 1.2 Minimum'
    description: 'Requires TLS 1.2 or higher for all services'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Storage/storageAccounts'
          }
          {
            field: 'Microsoft.Storage/storageAccounts/minimumTlsVersion'
            notEquals: 'TLS1_2'
          }
        ]
      }
      then: {}
    }
    parameters: {}
  }
  {
    name: 'restrict-approved-locations'
    displayName: 'Restrict Approved Locations'
    description: 'Allows resources only in approved regions'
    mode: 'All'
    effect: 'Deny'
    conditions: {
      if: {
        allOf: [
          {
            field: 'location'
            notIn: [
              'southafricanorth'
              'eastus'
              'westeurope'
            ]
          }
          {
            field: 'location'
            notEquals: 'global'
          }
        ]
      }
      then: {}
    }
    parameters: {}
  }
]

@description('Output all policy definitions')
output policyDefinitions array = policies
