# Bicep Landing Zone Deployment

Comprehensive Infrastructure as Code (IaC) for Azure banking landing zone using Bicep modules with private endpoint enforcement.

## Directory Structure

```
bicep/
├── landing-zone/              # Main orchestration templates
│   ├── main.bicep            # Entry point - orchestrates all modules
│   ├── hub-vnet.bicep        # Hub VNet (Firewall, Bastion, Gateway subnets)
│   └── [shared templates]
├── modules/                  # Reusable Bicep modules
│   ├── networking/           # Network resources
│   │   ├── vnet.bicep        # Virtual Network with subnets
│   │   └── vnet-peering.bicep # VNet peering configuration
│   ├── security/             # Security and access resources
│   │   ├── keyvault.bicep    # Key Vault (private endpoint enforced)
│   │   └── nsg.bicep         # Network Security Groups
│   ├── storage/              # Storage resources
│   │   └── storage-account.bicep # Storage Account (public access denied)
│   ├── database/             # Database resources
│   │   └── sql-database.bicep # SQL Database (public endpoint disabled)
│   ├── monitoring/           # Monitoring and observability
│   │   ├── log-analytics.bicep # Log Analytics Workspace
│   │   └── application-insights.bicep # Application Insights
│   └── shared/               # Shared/utility modules
│       ├── private-endpoint.bicep  # Private Endpoint (reusable)
│       └── private-dns-zone.bicep  # Private DNS Zone
├── parameters/               # Environment-specific parameters
│   ├── dev.parameters.json
│   ├── staging.parameters.json
│   └── prod.parameters.json
└── scripts/                  # Deployment and management scripts
    ├── deploy.sh            # Deploy to Azure
    ├── cleanup.sh           # Remove all resources
    └── validate.sh          # Validate deployment
```

## Key Features

### Security & Access Control

- **Private Access Enforcement**: All PaaS services (Key Vault, Storage, SQL Database) deny public access
- **Private Endpoints**: Services are accessed via private endpoints from within the VNet
- **Network Isolation**: Hub-and-spoke architecture with centralized security
- **NSGs & UDRs**: Network security groups and user-defined routes for granular traffic control

### Network Architecture

- **Hub VNet** (10.19.0.0/16):
  - Azure Firewall Subnet (10.19.0.0/24)
  - Azure Bastion Subnet (10.19.1.0/24)
  - VPN/ER Gateway Subnet (10.19.2.0/24)
  - Private Endpoints Subnet (10.19.3.0/24)
  - Shared Services Subnet (10.19.4.0/24)
  - Management Subnet (10.19.5.0/24)

- **Spoke VNets**:
  - Dev: 10.19.16.0/20
  - Staging: 10.19.32.0/20
  - Production: 10.19.48.0/20

### Monitoring & Observability

- Log Analytics Workspace with disabled public access
- Application Insights integrated with Log Analytics
- Container Insights solution for monitoring
- Private DNS zones for service discovery

## Deployment

### Prerequisites

```bash
# Azure CLI (v2.45.0+)
az --version

# Bicep CLI (included with Azure CLI 2.45.0+)
az bicep version

# Permissions
# - Owner or Contributor role on the subscription
# - Ability to create resource groups
```

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/neetima27/AzureNamingTool.git
   cd AzureNamingTool
   ```

2. **Set environment variables**
   ```bash
   export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
   export AZURE_TENANT_ID="<your-tenant-id>"
   export AZURE_PRINCIPAL_ID="<your-principal-id>"  # For Key Vault access
   ```

3. **Deploy to Dev**
   ```bash
   chmod +x bicep/scripts/deploy.sh
   bicep/scripts/deploy.sh dev
   ```

4. **Deploy to Staging**
   ```bash
   bicep/scripts/deploy.sh staging
   ```

5. **Deploy to Production**
   ```bash
   bicep/scripts/deploy.sh prod
   ```

### Using GitHub Actions

The CI/CD pipeline automatically:

1. **Validates** Bicep syntax and linting
2. **Builds** Bicep templates to ARM JSON
3. **Plans** deployments with what-if
4. **Deploys** in stages: dev → staging → prod
5. **Requires** approval for production deployments

**Trigger deployment:**
- Push to `main` branch (auto-deploys dev → staging → prod)
- Create PR (runs validation and plan)
- Manual workflow dispatch

## Module Reference

### networking/vnet.bicep

Virtual Network with configurable subnets.

```bicep
module vnet 'modules/networking/vnet.bicep' = {
  scope: resourceGroup
  name: 'vnet-deployment'
  params: {
    vnetName: 'vnet-myapp-prod'
    location: 'southafricanorth'
    addressSpace: ['10.19.16.0/20']
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: '10.19.16.0/24'
      }
    ]
  }
}
```

### security/keyvault.bicep

Key Vault with private access enforcement.

```bicep
module keyVault 'modules/security/keyvault.bicep' = {
  scope: resourceGroup
  name: 'keyvault-deployment'
  params: {
    vaultName: 'kv-myapp-prod'
    location: 'southafricanorth'
    tenantId: tenant().tenantId
    principalId: identity.outputs.principalId
  }
}
```

### storage/storage-account.bicep

Storage Account with public access denied.

```bicep
module storage 'modules/storage/storage-account.bicep' = {
  scope: resourceGroup
  name: 'storage-deployment'
  params: {
    storageAccountName: 'stmyappprod'
    location: 'southafricanorth'
    kind: 'StorageV2'
    replication: 'GRS'
  }
}
```

### database/sql-database.bicep

SQL Database with public endpoint disabled.

```bicep
module sqlDb 'modules/database/sql-database.bicep' = {
  scope: resourceGroup
  name: 'sqldb-deployment'
  params: {
    sqlServerName: 'sql-myapp-prod'
    databaseName: 'myappdb'
    adminLogin: 'sqladmin'
    adminPassword: keyVault.outputs.sqlPassword
  }
}
```

## Private Endpoint Configuration

All PaaS services use private endpoints for access:

1. **Create Service** (e.g., Key Vault)
   - Disable public network access
   - Set network ACLs to Deny

2. **Create Private Endpoint**
   - Connect to private endpoint subnet
   - Link to Private DNS zone
   - Create DNS A record

3. **Access from App**
   - Application connects via private IP (e.g., 10.19.3.x)
   - DNS resolves service FQDN to private IP
   - Traffic stays within VNet

**Example - SQL Database via Private Endpoint:**
```
Application Server (10.19.16.x)
  ↓ (DNS query)
Private DNS Zone (privatelink.database.windows.net)
  ↓ (returns 10.19.3.x)
Private Endpoint (10.19.3.x)
  ↓ (secured connection)
SQL Database
```

## Validation & Testing

### Validate Deployment

```bash
chmod +x bicep/scripts/validate.sh
bicep/scripts/validate.sh dev
```

Checks:
- ✓ All resource groups created
- ✓ VNets and subnets deployed
- ✓ Key Vault public access disabled
- ✓ Storage Account public access denied
- ✓ VNet peering established
- ✓ Monitoring resources active

### Test Private Endpoint Access

```bash
# From Bastion or management VM
# Test Key Vault access
az keyvault secret list \
  --vault-name kv-banking-platform-prod \
  --output table

# Test SQL Database connectivity
Test-NetConnection -ComputerName <sql-server-fqdn> -Port 1433

# Test Storage Account access
az storage blob list \
  --account-name <storage-account-name> \
  --container-name mycontainer
```

## Environment Variables

Create a `.env` file:

```bash
# Azure Credentials
export AZURE_SUBSCRIPTION_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AZURE_TENANT_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export AZURE_PRINCIPAL_ID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Deployment Settings
export AZURE_LOCATION="southafricanorth"
export ENVIRONMENT="dev"
```

Load: `source .env`

## Troubleshooting

### Bicep Validation Fails

```bash
# Lint individual file
az bicep lint --file bicep/landing-zone/main.bicep

# Build with detailed output
az bicep build --file bicep/landing-zone/main.bicep --output-format json
```

### Deployment Fails

```bash
# Check deployment status
az deployment sub list --subscription $AZURE_SUBSCRIPTION_ID --output table

# Get error details
az deployment sub show \
  --name "bicep-landing-zone-dev-<timestamp>" \
  --query properties.error
```

### Private Endpoint Not Resolving

```bash
# Check DNS resolution from VM
nslookup kv-banking-platform-prod.vault.azure.net

# Check Private DNS zone
az network private-dns record-set list \
  --zone-name privatelink.vaultcore.azure.net \
  --resource-group rg-hub-prod-southafricanorth
```

## Best Practices

1. **Always use Private Endpoints** for PaaS services
2. **Disable Public Access** by default
3. **Use Network ACLs** to restrict access
4. **Enable Monitoring** for all resources
5. **Tag Resources** for cost allocation
6. **Review What-If** before deploying
7. **Use Parameter Files** for environment-specific configs
8. **Lock Production** resource groups
9. **Enable Diagnostic Logs** for troubleshooting
10. **Test Connectivity** after deployment

## Cleanup

Remove all resources:

```bash
chmod +x bicep/scripts/cleanup.sh
bicep/scripts/cleanup.sh dev
```

⚠️ **Warning**: This will delete all resource groups and resources for the specified environment.

## Support & Documentation

- [Bicep Language Reference](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/file)
- [Azure Private Endpoints](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Landing Zones Design](../../design/README.md)
- [Network Architecture](../../design/NETWORK_ARCHITECTURE.md)

## Contributing

1. Create feature branch
2. Update/create Bicep modules
3. Validate: `az bicep lint`
4. Test: `bicep/scripts/validate.sh`
5. Submit PR with description

## License

See [LICENSE](../../LICENSE) file.
