@description('Name of the policy initiative/set')
param initiativeName string

@description('Display name for the initiative')
param displayName string

@description('Initiative description')
param description string

@description('Array of policy definitions to include')
param policyDefinitions array

@description('Initiative parameters')
param parameters object = {}

@description('Policy group definitions')
param policyGroups array = []

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: displayName
    description: description
    policyType: 'Custom'
    metadata: {
      category: 'Banking Compliance'
    }
    policyDefinitions: [for policy in policyDefinitions: {
      policyDefinitionId: policy.policyDefinitionId
      parameters: contains(policy, 'parameters') ? policy.parameters : {}
      policyDefinitionReferenceId: policy.referenceId
      groupNames: contains(policy, 'groupNames') ? policy.groupNames : []
    }]
    parameters: !empty(parameters) ? parameters : {}
    policyGroups: !empty(policyGroups) ? policyGroups : []
  }
}

@description('Output the policy set definition ID')
output policySetDefinitionId string = policySetDefinition.id

@description('Output the initiative name')
output initiativeName string = policySetDefinition.name
