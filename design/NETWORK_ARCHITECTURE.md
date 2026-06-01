# Network Architecture Details

## VNet and Subnet Design

### Hub VNet Configuration (10.19.0.0/16)

```
10.19.0.0/16 - Hub VNet (South Africa North)
├── 10.19.0.0/24 - Azure Firewall Subnet (Required)
├── 10.19.1.0/24 - Azure Bastion Subnet (Required)
├── 10.19.2.0/24 - VPN/ExpressRoute Gateway Subnet
├── 10.19.3.0/24 - Private Endpoints Subnet
├── 10.19.4.0/24 - Shared Services Subnet (ACR, KV, etc.)
└── 10.19.5.0/24 - Management Tools Subnet (Self-hosted Runner)
```

### Spoke VNet Design

**Project A - Production (10.19.16.0/20)**
```
10.19.16.0/20 - Project A Production
├── 10.19.16.0/24 - Application Tier (App Service, AKS, etc.)
├── 10.19.17.0/24 - Data Tier (SQL, Cosmos DB with Private Endpoints)
├── 10.19.18.0/24 - Integration Tier (Service Bus, Event Hub)
└── 10.19.19.0/24 - Reserved for Expansion
```

**Project A - Development (10.19.32.0/20)**
```
10.19.32.0/20 - Project A Development
├── 10.19.32.0/24 - Application Tier
├── 10.19.33.0/24 - Data Tier
├── 10.19.34.0/24 - Integration Tier
└── 10.19.35.0/24 - Reserved for Expansion
```

**Project B - Production (10.19.48.0/20)**
```
10.19.48.0/20 - Project B Production
├── 10.19.48.0/24 - Application Tier
├── 10.19.49.0/24 - Data Tier
└── 10.19.50.0/24 - Reserved for Expansion
```

## Routing Architecture

### User-Defined Routes (UDRs)

All traffic from spoke VNets is routed through the Azure Firewall for:
- Egress filtering
- Threat protection
- Logging and monitoring
- Network isolation

**Route Table Configuration:**
```
Destination         Next Hop              Purpose
0.0.0.0/0          Azure Firewall        Default internet egress
10.0.0.0/8         VNet Peering          Inter-VNet communication
168.63.129.16/32   Internet              Metadata service
```

### Private DNS Zones

**DNS Zones in Private Link Subnet:**
```
- privatelink.database.windows.net       (SQL Database)
- privatelink.blob.core.windows.net      (Storage Blob)
- privatelink.file.core.windows.net      (Storage File Share)
- privatelink.queue.core.windows.net     (Storage Queue)
- privatelink.table.core.windows.net     (Storage Table)
- privatelink.vaultcore.azure.net        (Key Vault)
- privatelink.azurecr.io                 (Container Registry)
- privatelink.servicebus.windows.net     (Service Bus)
- privatelink.cognitiveservices.azure.com (Cognitive Services)
```

## Network Security Groups (NSGs)

### Hub NSG Rules

| Priority | Name | Source | Dest | Port | Action | Notes |
|----------|------|--------|------|------|--------|-------|
| 100 | AllowBastion | 10.19.1.0/24 | * | 22,3389 | Allow | SSH/RDP from Bastion |
| 110 | AllowVNetPeering | 10.19.16.0/20, 10.19.32.0/20, 10.19.48.0/20 | * | * | Allow | Internal VNet communication |
| 120 | AllowDiagnostics | * | 168.63.129.16/32 | 443 | Allow | Azure diagnostics |
| 200 | DenyAll | * | * | * | Deny | Default deny |

### Application Tier NSG Rules (Spoke)

| Priority | Name | Source | Dest Port | Action | Notes |
|----------|------|--------|-----------|--------|-------|
| 100 | AllowHTTPS | Internet | 443 | Allow | Public HTTPS (if applicable) |
| 110 | AllowFromBastion | 10.19.1.0/24 | 22,3389 | Allow | Bastion management |
| 120 | AllowFromFirewall | 10.19.0.0/24 | * | Allow | Traffic from FW |
| 130 | AllowToDatabase | * | 1433 | Allow | To data tier |
| 200 | DenyAll | * | * | Deny | Default deny |

### Data Tier NSG Rules (Spoke)

| Priority | Name | Source | Dest Port | Action | Notes |
|----------|------|--------|-----------|--------|-------|
| 100 | AllowFromAppTier | 10.x.1.0/24 | 1433 | Allow | Database access |
| 110 | AllowFromBastion | 10.19.1.0/24 | 1433,3306 | Allow | Management access |
| 120 | AllowPrivateEndpoints | 10.19.3.0/24 | * | Allow | Private endpoints |
| 200 | DenyAll | * | * | Deny | Default deny |

## Azure Firewall Configuration

### Firewall Rules

**Application Rules:**
```
Priority | Name | Action | Source IPs | Destination FQDNs | Ports
1        | Allow-Microsoft | Allow | 10.0.0.0/8 | *.microsoft.com, *.azure.com | 443
2        | Allow-NTP | Allow | 10.0.0.0/8 | time.nist.gov | 123 UDP
3        | Allow-DNS | Allow | 10.0.0.0/8 | *.windows.net | 53 UDP
4        | Block-Malware | Deny | 10.0.0.0/8 | blocklist.* | *
```

**NAT Rules:**
```
For outbound internet traffic from private IPs
Source Port Range: All
Dest Port Range: All
Protocol: TCP/UDP
Translated Address: Firewall public IP
Translated Port: Dynamic
```

**Network Rules:**
```
Priority | Name | Action | Source | Dest IP | Dest Port | Protocol
1        | Allow-VNet-to-VNet | Allow | 10.0.0.0/8 | 10.0.0.0/8 | * | TCP/UDP
2        | Allow-DNS | Allow | 10.0.0.0/8 | 168.63.129.16 | 53 | UDP
```

## VNet Peering Configuration

### Peering Setup (Hub-and-Spoke)

**From Hub to Spoke:**
```
Peering Name: hub-to-project-a-prod
Allow Virtual Network Access: Yes
Allow Forwarded Traffic: Yes
Allow Gateway Transit: Yes
Use Remote Gateways: No
```

**From Spoke to Hub:**
```
Peering Name: project-a-prod-to-hub
Allow Virtual Network Access: Yes
Allow Forwarded Traffic: Yes
Allow Gateway Transit: No
Use Remote Gateways: Yes (if hub has gateway)
```

### Traffic Flow Example

```
Developer VM in 10.19.16.0/24 (Project A Prod App Tier)
↓
NSG check → Allow from Firewall
↓
UDR: 0.0.0.0/0 → Azure Firewall (10.19.0.1)
↓
Firewall Application Rules check
↓
If allowed: Route via VNet Peering to Hub
↓
From Hub to Spoke or Internet based on rules
```

## Service Endpoints vs Private Endpoints

### When to Use Each

| Scenario | Service Endpoint | Private Endpoint |
|----------|-----------------|-----------------|
| **VNet within same region** | ✓ Suitable | ✓ Recommended |
| **Cross-region VNet** | ✓ Works | ✓ Recommended |
| **On-premises access** | ✗ No | ✓ Yes (via ExpressRoute) |
| **Compliance requirement** | May be insufficient | ✓ Recommended |
| **Multi-region redundancy** | Limited | ✓ Better |

### Private Endpoint Implementation

**For each PaaS service requiring private access:**

1. Create Private Endpoint in private endpoint subnet (10.19.3.0/24)
2. Disable public access on the PaaS service
3. Create DNS A record in Private DNS Zone pointing to Private Endpoint IP
4. NSGs allow traffic only from authorized subnets

**Example: SQL Database Private Endpoint**
```
Private Endpoint Name: pe-sqldb-projecta
Subnet: 10.19.3.0/24 (Private Endpoints)
Service: Microsoft.Sql/servers
Resource: projecta-sql-db-001
Subresource: sqlServer
Private IP: 10.19.3.5
DNS Zone: privatelink.database.windows.net
DNS Record: projecta-sql-db-001.database.windows.net → 10.19.3.5
```

## ExpressRoute / VPN Gateway (Optional)

If on-premises connectivity is needed:

```
On-Premises Network (192.168.0.0/16)
↓ (ExpressRoute or Site-to-Site VPN)
↓
VPN Gateway in Hub (10.19.2.0/24)
↓
Firewall (10.19.0.0/24)
↓
Spoke VNets (10.19.16.0/20, 10.19.32.0/20, 10.19.48.0/20)
```

---

## Network Troubleshooting Guide

### Common Issues

1. **Cannot reach database from application**
   - Check NSG rules on data tier subnet
   - Verify Private Endpoint DNS resolution
   - Check Firewall Application Rules

2. **Intermittent connectivity**
   - Check Firewall health
   - Verify UDR routes
   - Check VNet peering status

3. **High latency**
   - Review Firewall processing load
   - Check for VNet peering constraints
   - Verify region selection (South Africa North)

### Network Testing Commands

```bash
# From Bastion or management VM
# Test DNS resolution
nslookup projecta-sql-db-001.database.windows.net

# Test connectivity
Test-NetConnection -ComputerName 10.19.17.10 -Port 1433

# Check route table
route print

# View NSG effective rules
Get-AzEffectiveNetworkSecurityGroup -ResourceGroupName rg-projecta
```

---

**Document Version**: 1.0  
**Last Updated**: June 2026
