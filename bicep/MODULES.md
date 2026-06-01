# Bicep Modules Documentation

Detailed documentation for all reusable Bicep modules in the landing zone.

## Table of Contents

1. [Networking Modules](#networking-modules)
2. [Security Modules](#security-modules)
3. [Storage Modules](#storage-modules)
4. [Database Modules](#database-modules)
5. [Monitoring Modules](#monitoring-modules)
6. [Shared Modules](#shared-modules)

---

## Networking Modules

### vnet.bicep

Creates a virtual network with configurable subnets, NSGs, and route tables.

**Parameters:**
- `vnetName` (string): Name of the VNet
- `location` (string): Azure region
- `addressSpace` (array): CIDR blocks for the VNet
- `subnets` (array): Array of subnet configurations
- `tags` (object): Resource tags

**Subnet Configuration:**
```bicep
subnets: [
  {
    name: 'snet-app'
    addressPrefix: '10.19.16.0/24'
    nsgId: '<nsg-resource-id>'  // Optional
    routeTableId: '<route-table-id>'  // Optional
    privateEndpointNetworkPolicies: 'Disabled'  // Optional
  }
]
```

**Outputs:**
- `vnetId`: Resource ID of the VNet
- `subnetIds`: Array of subnet resource IDs
- `vnetResource`: Complete VNet resource object

**Example Usage:**
```bicep
module vnet 'modules/networking/vnet.bicep' = {
  scope: resourceGroup
  name: 'spoke-vnet'
  params: {
    vnetName: 'vnet-projecta-prod'
    location: location
    addressSpace: ['10.19.16.0/20']
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: '10.19.16.0/24'
      }
      {
        name: 'snet-data'
        addressPrefix: '10.19.17.0/24'
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
    tags: tags
  }
}
```

---

### vnet-peering.bicep

Creates VNet peering between two virtual networks.

**Parameters:**
- `sourceVnetName` (string): Name of the source VNet
- `remoteVnetName` (string): Name of the remote VNet
- `sourceResourceGroup` (string): RG of source VNet
- `remoteResourceGroup` (string): RG of remote VNet
- `remoteSubscriptionId` (string): Subscription ID of remote VNet
- `allowForwardedTraffic` (bool): Allow forwarded traffic
- `allowGatewayTransit` (bool): Allow gateway transit
- `useRemoteGateways` (bool): Use remote gateways

**Outputs:**
- `peeringId`: Resource ID of the peering
- `peeringState`: Current state of the peering

**Example Usage:**
```bicep
// Hub to Spoke peering
module hubToSpokePeering 'modules/networking/vnet-peering.bicep' = {
  scope: hubResourceGroup
  name: 'hub-to-spoke-peer'
  params: {
    sourceVnetName: 'vnet-hub-prod'
    remoteVnetName: 'vnet-projecta-prod'
    sourceResourceGroup: hubResourceGroup.name
    remoteResourceGroup: spokeResourceGroup.name
    allowForwardedTraffic: true
    allowGatewayTransit: true
    useRemoteGateways: false
  }
}

// Spoke to Hub peering
module spokeToHubPeering 'modules/networking/vnet-peering.bicep' = {
  scope: spokeResourceGroup
  name: 'spoke-to-hub-peer'
  params: {
    sourceVnetName: 'vnet-projecta-prod'
    remoteVnetName: 'vnet-hub-prod'
    sourceResourceGroup: spokeResourceGroup.name
    remoteResourceGroup: hubResourceGroup.name
    allowForwardedTraffic: true
    useRemoteGateways: true
    allowGatewayTransit: false
  }
}
```

---

## Security Modules

### keyvault.bicep

Creates an Azure Key Vault with public access denied and private endpoint support.

**Security Features:**
- Public network access: Disabled
- Network ACLs: Default Deny, Bypass AzureServices
- Premium SKU for enhanced security
- Support for keys, secrets, and certificates

**Parameters:**
- `vaultName` (string): Name of the Key Vault (3-24 alphanumeric chars)
- `location` (string): Azure region
- `resourceGroupName` (string): Resource group name
- `tenantId` (string): Tenant ID
- `principalId` (string): Principal ID with access permissions
- `tags` (object): Resource tags

**Outputs:**
- `vaultId`: Resource ID of the Key Vault
- `vaultName`: Name of the Key Vault
- `vaultUri`: URI of the Key Vault
- `resourceGroupName`: Resource group name

**Access Control:**
```bicep
// Default access policy grants all permissions
// Customize by adding more principals:
accessPolicies: [
  {
    tenantId: tenant().tenantId
    objectId: principalId1
    permissions: { keys: ['all'], secrets: ['all'] }
  }
  {
    tenantId: tenant().tenantId
    objectId: principalId2
    permissions: { certificates: ['get', 'list'] }
  }
]
```

**Example Usage:**
```bicep
module keyVault 'modules/security/keyvault.bicep' = {
  scope: resourceGroup
  name: 'kv-deployment'
  params: {
    vaultName: 'kv-banking-prod'
    location: location
    resourceGroupName: resourceGroup.name
    tenantId: tenant().tenantId
    principalId: identity.outputs.principalId
    tags: tags
  }
}

// Create private endpoint for Key Vault
module keyVaultPE 'modules/shared/private-endpoint.bicep' = {
  scope: resourceGroup
  name: 'kv-pe-deployment'
  params: {
    privateEndpointName: 'pe-kv-banking-prod'
    location: location
    subnetId: privateEndpointSubnetId
    privateLinkServiceConnectionName: 'pls-kv-banking'
    resourceId: keyVault.outputs.vaultId
    groupIds: ['vault']
    tags: tags
  }
}

// Create private DNS zone
module keyVaultDns 'modules/shared/private-dns-zone.bicep' = {
  scope: resourceGroup
  name: 'kv-dns-deployment'
  params: {
    zoneName: 'privatelink.vaultcore.azure.net'
    vnetIds: [hubVnetId, spokeVnetId]
    tags: tags
  }
}
```

---

### nsg.bicep

Creates a Network Security Group with configurable security rules.

**Parameters:**
- `nsgName` (string): Name of the NSG
- `location` (string): Azure region
- `securityRules` (array): Array of security rule configurations
- `tags` (object): Resource tags

**Security Rule Configuration:**
```bicep
securityRules: [
  {
    name: 'Allow-Bastion'
    description: 'Allow traffic from Bastion subnet'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'  // SSH
    sourceAddressPrefix: '10.19.1.0/24'  // Bastion subnet
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
  }
  {
    name: 'Deny-Internet'
    description: 'Deny inbound from internet'
    protocol: '*'
    sourcePortRange: '*'
    destinationPortRange: '*'
    sourceAddressPrefix: 'Internet'
    destinationAddressPrefix: '*'
    access: 'Deny'
    priority: 4096
    direction: 'Inbound'
  }
]
```

**Outputs:**
- `nsgId`: Resource ID of the NSG
- `nsgResource`: Complete NSG resource object

---

## Storage Modules

### storage-account.bicep

Creates an Azure Storage Account with public access denied.

**Security Features:**
- Public network access: Disabled
- Network ACLs: Default Deny, Bypass AzureServices
- HTTPS only (supportsHttpsTrafficOnly)
- TLS 1.2 minimum
- Blob public access disabled
- GRS replication by default

**Parameters:**
- `storageAccountName` (string): Name (3-24 lowercase alphanumeric)
- `location` (string): Azure region
- `kind` (string): StorageV2 | BlobStorage | etc. (default: StorageV2)
- `replication` (string): LRS | GRS | RAGRS | etc. (default: GRS)
- `minimumTlsVersion` (string): TLS1_2 | TLS1_3 (default: TLS1_2)
- `tags` (object): Resource tags

**Outputs:**
- `storageAccountId`: Resource ID
- `storageAccountName`: Account name
- `primaryBlobEndpoint`: Blob endpoint URI
- `storageAccountKey`: Primary access key (sensitive)

**Example Usage:**
```bicep
module storage 'modules/storage/storage-account.bicep' = {
  scope: resourceGroup
  name: 'storage-deployment'
  params: {
    storageAccountName: 'stabankingprod${uniqueString(resourceGroup().id)}'
    location: location
    kind: 'StorageV2'
    replication: 'GRS'
    tags: tags
  }
}

// Create private endpoint for Blob storage
module storagePE 'modules/shared/private-endpoint.bicep' = {
  scope: resourceGroup
  name: 'storage-blob-pe'
  params: {
    privateEndpointName: 'pe-blob-banking'
    location: location
    subnetId: privateEndpointSubnetId
    privateLinkServiceConnectionName: 'pls-blob'
    resourceId: storage.outputs.storageAccountId
    groupIds: ['blob']  // Also: 'file', 'table', 'queue'
    tags: tags
  }
}
```

---

## Database Modules

### sql-database.bicep

Creates an Azure SQL Server and Database with public endpoint disabled.

**Security Features:**
- Public network access: Disabled
- Firewall: Only allows AzureServices (for private endpoints)
- SQL authentication required
- Firewall rule: AllowAllWindowsAzureIps (for private endpoints)

**Parameters:**
- `sqlServerName` (string): SQL Server name
- `databaseName` (string): Database name
- `location` (string): Azure region
- `adminLogin` (string): Admin username
- `adminPassword` (secure string): Admin password
- `databaseSku` (string): Basic | Standard | Premium (default: Standard)
- `tags` (object): Resource tags

**Outputs:**
- `sqlServerId`: SQL Server resource ID
- `sqlServerFqdn`: Fully qualified domain name
- `databaseId`: Database resource ID
- `databaseName`: Database name

**Example Usage:**
```bicep
module sqlDb 'modules/database/sql-database.bicep' = {
  scope: resourceGroup
  name: 'sqldb-deployment'
  params: {
    sqlServerName: 'sql-banking-prod-${location}'
    databaseName: 'bankingdb'
    location: location
    adminLogin: 'sqladmin'
    adminPassword: keyVault.outputs.sqlAdminPassword
    databaseSku: 'Standard'
    tags: tags
  }
}

// Create private endpoint for SQL Database
module sqlPE 'modules/shared/private-endpoint.bicep' = {
  scope: resourceGroup
  name: 'sql-pe-deployment'
  params: {
    privateEndpointName: 'pe-sql-banking'
    location: location
    subnetId: privateEndpointSubnetId
    privateLinkServiceConnectionName: 'pls-sqlserver'
    resourceId: sqlDb.outputs.sqlServerId
    groupIds: ['sqlServer']
    tags: tags
  }
}
```

---

## Monitoring Modules

### log-analytics.bicep

Creates a Log Analytics Workspace with public access disabled.

**Features:**
- Public ingestion: Disabled
- Public queries: Disabled
- Container Insights solution enabled
- 30-day retention by default
- Daily quota cap (optional)

**Parameters:**
- `workspaceName` (string): Workspace name
- `location` (string): Azure region
- `sku` (string): PerGB2018 | Free | Standalone | PerNode (default: PerGB2018)
- `dailyCapGb` (int): Daily cap in GB (0 = unlimited)
- `tags` (object): Resource tags

**Outputs:**
- `workspaceId`: Resource ID
- `workspaceName`: Workspace name
- `workspaceCustomerId`: Customer ID for agents
- `workspaceResourceId`: Resource ID (for App Insights linking)

---

### application-insights.bicep

Creates Application Insights with Log Analytics integration.

**Features:**
- Linked to Log Analytics Workspace
- Public access disabled
- 30-day retention
- Web application monitoring

**Parameters:**
- `appInsightsName` (string): Name
- `location` (string): Azure region
- `workspaceResourceId` (string): Log Analytics Workspace ID
- `applicationType` (string): web | other (default: web)
- `disablePublicAccess` (bool): Disable public access (default: true)
- `tags` (object): Resource tags

**Outputs:**
- `appInsightsId`: Resource ID
- `appInsightsName`: Instance name
- `appInsightsKey`: Instrumentation key
- `appInsightsConnectionString`: Connection string

**Example Usage:**
```bicep
module law 'modules/monitoring/log-analytics.bicep' = {
  scope: resourceGroup
  name: 'law-deployment'
  params: {
    workspaceName: 'law-banking-prod'
    location: location
    sku: 'PerGB2018'
    tags: tags
  }
}

module appInsights 'modules/monitoring/application-insights.bicep' = {
  scope: resourceGroup
  name: 'appi-deployment'
  params: {
    appInsightsName: 'appi-banking-prod'
    location: location
    workspaceResourceId: law.outputs.workspaceResourceId
    disablePublicAccess: true
    tags: tags
  }
}
```

---

## Shared Modules

### private-endpoint.bicep

Creates a Private Endpoint to connect to PaaS services.

**Parameters:**
- `privateEndpointName` (string): PE name
- `location` (string): Azure region
- `subnetId` (string): Subnet resource ID
- `privateLinkServiceConnectionName` (string): Connection name
- `resourceId` (string): Target service resource ID
- `groupIds` (array): Service sub-resources (e.g., ['vault'], ['blob'], ['sqlServer'])
- `tags` (object): Resource tags

**Common Group IDs:**
- Key Vault: `['vault']`
- Storage Blob: `['blob']`
- Storage File: `['file']`
- Storage Queue: `['queue']`
- SQL Database: `['sqlServer']`
- App Services: `['sites']`
- Cosmos DB: `['sql']`

**Outputs:**
- `privateEndpointId`: Resource ID
- `networkInterfaceIds`: Associated NIC IDs
- `privateEndpointResource`: Complete PE resource

**Example:**
```bicep
module privateEndpoint 'modules/shared/private-endpoint.bicep' = {
  scope: resourceGroup
  name: 'pe-deployment'
  params: {
    privateEndpointName: 'pe-kv-banking'
    location: location
    subnetId: '${hubVnetId}/subnets/snet-private-endpoints'
    privateLinkServiceConnectionName: 'pls-kv-banking'
    resourceId: keyVault.outputs.vaultId
    groupIds: ['vault']
    tags: tags
  }
}
```

---

### private-dns-zone.bicep

Creates a Private DNS Zone and links it to VNets.

**Parameters:**
- `zoneName` (string): DNS zone name (e.g., privatelink.vaultcore.azure.net)
- `vnetIds` (array): VNet resource IDs to link
- `tags` (object): Resource tags

**Common Zone Names:**
- Key Vault: `privatelink.vaultcore.azure.net`
- Storage Blob: `privatelink.blob.core.windows.net`
- SQL Database: `privatelink.database.windows.net`
- App Service: `privatelink.azurewebsites.net`
- Cosmos DB: `privatelink.mongo.cosmos.azure.com`

**Outputs:**
- `privateDnsZoneId`: Resource ID
- `nameServers`: DNS name servers

**Example:**
```bicep
module dnsZone 'modules/shared/private-dns-zone.bicep' = {
  scope: resourceGroup
  name: 'dns-zone-deployment'
  params: {
    zoneName: 'privatelink.vaultcore.azure.net'
    vnetIds: [
      hubVnetId
      spokeVnetId1
      spokeVnetId2
    ]
    tags: tags
  }
}
```

---

## Best Practices

1. **Always use Private Endpoints** for PaaS services
2. **Set public access to Disabled** in module parameters
3. **Create Private DNS Zones** for service discovery
4. **Link all VNets** to DNS zones
5. **Use consistent naming** conventions
6. **Tag all resources** for cost tracking
7. **Test connectivity** after deployment
8. **Monitor private endpoints** in Log Analytics
9. **Enable diagnostics** on modules
10. **Document custom modules** thoroughly

## Common Issues & Solutions

### Private Endpoint Not Resolving

**Issue**: DNS name doesn't resolve to private IP

**Solution**:
```bicep
// Ensure DNS zone is linked to all VNets
module dnsZone 'modules/shared/private-dns-zone.bicep' = {
  params: {
    zoneName: 'privatelink.vaultcore.azure.net'
    vnetIds: [hub.outputs.vnetId, spoke.outputs.vnetId]  // Include all VNets
  }
}

// Test from VM
nslookup kv-banking-prod.vault.azure.net
```

### Access Denied to Service

**Issue**: Can't access service from private endpoint

**Solution**:
```bicep
// Check Network ACLs
// Ensure service is set to 'Bypass: AzureServices'
// Verify private endpoint subnet has correct NSG rules
```

### Circular Dependencies

**Issue**: Module A depends on Module B, B depends on A

**Solution**: Use separate module calls or refactor shared properties

```bicep
// Instead of circular references:
var tags = {}
module a 'a.bicep' = { params: { sharedValue: tags } }
module b 'b.bicep' = { params: { sharedValue: tags, aRef: a.outputs.id } }
```

For more information, see the main [README.md](./README.md).
