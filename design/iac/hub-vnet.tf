# Hub VNet with Azure Firewall
# LEGACY: This Terraform template remains for reference only.
# The current landing zone implementation is Bicep-only and uses bicep/landing-zone/hub-vnet.bicep.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "organization_name" {
  type = string
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = "Platform"
    Owner       = "platform-team@banking.com"
    ManagedBy   = "Terraform-Legacy"
  }
}

# Resource Group
resource "azurerm_resource_group" "hub" {
  name     = "rg-hub-${var.environment}-${var.location}"
  location = var.location
  tags     = local.common_tags
}

# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-${var.environment}"
  address_space       = ["10.19.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags
}

# Firewall Subnet
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.19.0.0/24"]
}

# Bastion Subnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.19.1.0/24"]
}

# Gateway Subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.19.2.0/24"]
}

# Private Endpoints Subnet
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.19.3.0/24"]

  private_endpoint_network_policies_enabled = true
}

# Public IP for Firewall
resource "azurerm_public_ip" "firewall" {
  name                = "pip-firewall-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Azure Firewall
resource "azurerm_firewall" "main" {
  name                = "fw-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_tier            = "Premium"
  sku_name            = "AZFW_VNet"
  tags                = local.common_tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# Firewall Application Rule Collection
resource "azurerm_firewall_application_rule_collection" "main" {
  name                = "allow-microsoft"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = azurerm_resource_group.hub.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "AllowMicrosoft"
    source_addresses = [
      "10.0.0.0/8"
    ]
    target_fqdns = [
      "*.microsoft.com",
      "*.azure.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

# Firewall Network Rule Collection
resource "azurerm_firewall_network_rule_collection" "main" {
  name                = "allow-internal"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = azurerm_resource_group.hub.name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "AllowInternalVNet"
    source_addresses      = ["10.0.0.0/8"]
    destination_addresses = ["10.0.0.0/8"]
    destination_ports     = ["*"]
    protocols             = ["TCP", "UDP"]
  }
}

# Public IP for Bastion
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Azure Bastion
resource "azurerm_bastion_host" "main" {
  name                = "bastion-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}

# Network Security Group for Bastion
resource "azurerm_network_security_group" "bastion" {
  name                = "nsg-bastion-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags

  security_rule {
    name                       = "AllowHttpsInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 900
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.common_tags
}

# Link Private DNS Zone to Hub VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "link-hub-kv"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  tags                  = local.common_tags
}

# Outputs
output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "firewall_private_ip" {
  value = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "keyvault_dns_zone_id" {
  value = azurerm_private_dns_zone.keyvault.id
}
