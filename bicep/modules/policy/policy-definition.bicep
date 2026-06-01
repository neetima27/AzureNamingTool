@description('Name of the policy definition')
param policyName string

@description('Display name for the policy')
param displayName string

@description('Policy description')
param description string

@description('Policy mode (All or Indexed)')
param mode string = 'All'

@description('Policy effect (Audit, Deny, DeployIfNotExists, AuditIfNotExists, Modify)')
param effect string = 'Audit'

@description('Policy rule conditions')
param conditions object

@description('Policy parameters (optional)')
param parameters object = {}

@description('Managed identity for policy (for DeployIfNotExists)')
param identityType string = 'None'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: displayName
    description: description
    mode: mode
    policyType: 'Custom'
    policyRule: {
      if: conditions.if
      then: {
        effect: effect
        details: contains(conditions, 'then') ? conditions.then : {}
      }
    }
    parameters: !empty(parameters) ? parameters : {}
    metadata: {
      category: 'Custom'
    }
  }
}

@description('Output the policy definition ID')
output policyDefinitionId string = policyDefinition.id

@description('Output the policy name')
output policyName string = policyDefinition.name
