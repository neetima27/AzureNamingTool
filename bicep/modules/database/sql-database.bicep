@description('Name of the SQL Server')
param sqlServerName string

@description('Name of the SQL Database')
param databaseName string

@description('Location for the resources')
param location string

@description('SQL Server administrator login')
param adminLogin string

@description('SQL Server administrator password')
@secure()
param adminPassword string

@description('Database SKU (Basic, Standard, Premium)')
param databaseSku string = 'Standard'

@description('Resource tags')
param tags object = {}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: adminLogin
    administratorLoginPassword: adminPassword
    // Deny public endpoint
    publicNetworkAccess: 'Disabled'
    version: '12.0'
  }
  tags: tags
}

// Disable server firewall rules to enforce private endpoints
resource firewallRule 'Microsoft.Sql/servers/firewallRules@2021-11-01' = {
  parent: sqlServer
  name: 'AllowAllWindowsAzureIps'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: databaseSku
    tier: databaseSku
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
  }
  tags: tags
}

@description('Output the SQL Server ID')
output sqlServerId string = sqlServer.id

@description('Output the SQL Server FQDN')
output sqlServerFqdn string = sqlServer.properties.fullyQualifiedDomainName

@description('Output the SQL Database ID')
output databaseId string = sqlDatabase.id

@description('Output the SQL Database name')
output databaseName string = sqlDatabase.name
