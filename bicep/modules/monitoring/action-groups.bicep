@description('Name of the action group')
param actionGroupName string

@description('Display name for the action group')
param displayName string

@description('Resource group name')
param resourceGroupName string

@description('Location for the action group')
param location string = 'eastus' // Action groups must be in East US

@description('Email receivers')
param emailReceivers array = []

@description('SMS receivers')
param smsReceivers array = []

@description('Webhook receivers')
param webhookReceivers array = []

@description('Automation runbook receivers')
param runbookReceivers array = []

@description('Azure Function receivers')
param azureFunctionReceivers array = []

@description('Email subject for notifications')
param emailSubject string = 'Azure Alert: Banking Infrastructure Alert'

@description('Enable notifications')
param enabled bool = true

var emailActions = [for receiver in emailReceivers: {
  name: receiver.name
  emailAddress: receiver.email
  useCommonSchema: true
}]

var smsActions = [for receiver in smsReceivers: {
  name: receiver.name
  countryCode: receiver.countryCode
  phoneNumber: receiver.phoneNumber
}]

var webhookActions = [for receiver in webhookReceivers: {
  name: receiver.name
  serviceUri: receiver.serviceUri
  useCommonSchema: true
}]

var runbookActions = [for receiver in runbookReceivers: {
  name: receiver.name
  automationAccountId: receiver.automationAccountId
  runbookName: receiver.runbookName
  webhookResourceId: receiver.webhookResourceId
  isGlobalRunbook: false
  useCommonSchema: true
}]

var functionActions = [for receiver in azureFunctionReceivers: {
  name: receiver.name
  functionAppResourceId: receiver.functionAppId
  functionName: receiver.functionName
  httpTriggerUrl: receiver.httpTriggerUrl
  useCommonSchema: true
}]

resource actionGroup 'Microsoft.Insights/actionGroups@2021-09-01' = {
  name: actionGroupName
  location: location
  properties: {
    enabled: enabled
    groupShortName: take(displayName, 12) // Max 12 characters
    displayName: displayName
    emailReceivers: emailActions
    smsReceivers: smsActions
    webhookReceivers: webhookActions
    itsmReceivers: []
    azureAppPushReceivers: []
    automationRunbookReceivers: runbookActions
    azureFunctionReceivers: functionActions
    logicAppReceivers: []
    voiceReceivers: []
    armRoleReceivers: []
  }
}

@description('Output the action group ID')
output actionGroupId string = actionGroup.id

@description('Output the action group name')
output actionGroupName string = actionGroup.name

@description('Output the resource ID for reference in alerts')
output resourceId string = actionGroup.id
