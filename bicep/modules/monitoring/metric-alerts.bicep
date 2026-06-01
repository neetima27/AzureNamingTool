@description('Name of the metric alert')
param alertName string

@description('Display name for the alert')
param displayName string

@description('Alert description')
param description string

@description('Resource IDs to monitor')
param scopes array

@description('Metric name (e.g., "Percentage CPU")')
param metricName string

@description('Metric namespace (e.g., "Microsoft.Compute/virtualMachines")')
param metricNamespace string

@description('Operator for threshold comparison')
@allowed([
  'Equals'
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'GreaterThan'

@description('Threshold value')
param threshold int

@description('Severity level')
@allowed([
  0
  1
  2
  3
  4
])
param severity int = 2

@description('Evaluation frequency in minutes')
param evaluationFrequency int = 1

@description('Time window for evaluation in minutes')
param windowSize int = 5

@description('Action group resource ID')
param actionGroupId string

@description('Auto-mitigate when condition no longer exists')
param autoMitigate bool = true

@description('Additional alert rule tags')
param tags object = {}

resource metricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertName
  location: 'global'
  tags: union(tags, {
    category: 'Banking'
    environment: 'Production'
  })
  properties: {
    description: description
    displayName: displayName
    enabled: true
    scopes: scopes
    severity: severity
    evaluationFrequency: 'PT${evaluationFrequency}M'
    windowSize: 'PT${windowSize}M'
    autoMitigate: autoMitigate
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'Metric1'
          metricName: metricName
          metricNamespace: metricNamespace
          operator: operator
          threshold: threshold
          timeAggregation: 'Average'
          criterionType: 'StaticThresholdCriterion'
        }
      ]
    }
    actions: [
      {
        actionGroupId: actionGroupId
      }
    ]
  }
}

@description('Output the metric alert ID')
output alertId string = metricAlert.id

@description('Output the alert name')
output alertName string = metricAlert.name
