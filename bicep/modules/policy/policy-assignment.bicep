@description('Name of the policy assignment')
param assignmentName string

@description('Policy definition or set definition ID')
param policyDefinitionId string

@description('Scope for the assignment (subscription or resource group)')
param assignmentScope string

@description('Assignment location')
param location string = 'southafricanorth'

@description('Assignment parameters')
param parameters object = {}

@description('Managed identity type for DeployIfNotExists policies')
param identityType string = 'None'

@description('Role definition ID for managed identity (for DeployIfNotExists)')
param roleDefinitionId string = ''

@description('Display name for the assignment')
param displayName string = ''

@description('Description for the assignment')
param description string = ''

@description('Enforcement mode (Default or DoNotEnforce)')
param enforcementMode string = 'Default'

@description('Policy exemptions (optional)')
param notScopes array = []

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: assignmentName
  location: location
  identity: identityType != 'None' ? {
    type: identityType
  } : null
  properties: {
    policyDefinitionId: policyDefinitionId
    scope: assignmentScope
    parameters: !empty(parameters) ? parameters : {}
    description: !empty(description) ? description : assignmentName
    displayName: !empty(displayName) ? displayName : assignmentName
    enforcementMode: enforcementMode
    notScopes: !empty(notScopes) ? notScopes : []
  }
}

@description('Output the policy assignment ID')
output assignmentId string = policyAssignment.id

@description('Output the assignment name')
output assignmentName string = policyAssignment.name

@description('Output the identity ID (for RBAC role assignment)')
output identityPrincipalId string = identityType != 'None' ? policyAssignment.identity.principalId : ''
