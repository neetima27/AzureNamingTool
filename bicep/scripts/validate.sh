#!/bin/bash

# Landing Zone Validation Script
# This script validates the deployed landing zone resources

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-dev}"
LOCATION="${2:-southafricanorth}"
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"

if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  echo -e "${RED}Error: Invalid environment. Must be dev, staging, or prod.${NC}"
  exit 1
fi

if [ -z "$SUBSCRIPTION_ID" ]; then
  echo -e "${RED}Error: AZURE_SUBSCRIPTION_ID environment variable not set${NC}"
  exit 1
fi

echo -e "${YELLOW}Landing Zone Validation Script${NC}"
echo -e "Environment: $ENVIRONMENT"
echo -e "Location: $LOCATION"
echo ""

# Validation results
CHECKS_PASSED=0
CHECKS_FAILED=0

check_resource() {
  local resource_type=$1
  local resource_group=$2
  local resource_name=$3

  echo -e "${YELLOW}Checking $resource_type: $resource_name${NC}"

  if az resource show \
    --resource-group "$resource_group" \
    --resource-type "$resource_type" \
    --name "$resource_name" \
    --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
    echo -e "  ${GREEN}✓ Found${NC}"
    ((CHECKS_PASSED++))
  else
    echo -e "  ${RED}✗ Not found${NC}"
    ((CHECKS_FAILED++))
  fi
}

# Check hub resources
HUB_RG="rg-hub-${ENVIRONMENT}-${LOCATION}"
echo -e "${YELLOW}Validating Hub Resources in $HUB_RG${NC}"
echo ""

check_resource "Microsoft.Network/virtualNetworks" "$HUB_RG" "vnet-hub-${ENVIRONMENT}"
check_resource "Microsoft.Network/azureFirewalls" "$HUB_RG" "fw-${ENVIRONMENT}"
check_resource "Microsoft.Network/bastionHosts" "$HUB_RG" "bastion-${ENVIRONMENT}"
check_resource "Microsoft.KeyVault/vaults" "$HUB_RG" "kvbanking${ENVIRONMENT:0:1}"
check_resource "Microsoft.OperationalInsights/workspaces" "$HUB_RG" "law-banking-platform-${ENVIRONMENT}"
check_resource "Microsoft.Network/privateDnsZones" "$HUB_RG" "privatelink.vaultcore.azure.net"

echo ""

# Check spoke resources
PROJECT_RG="rg-banking-platform-${ENVIRONMENT}-${LOCATION}"
echo -e "${YELLOW}Validating Spoke Resources in $PROJECT_RG${NC}"
echo ""

check_resource "Microsoft.Network/virtualNetworks" "$PROJECT_RG" "vnet-banking-platform-${ENVIRONMENT}"
check_resource "Microsoft.Insights/components" "$PROJECT_RG" "appi-banking-platform-${ENVIRONMENT}"

echo ""
echo -e "${YELLOW}Validation Summary${NC}"
echo -e "Checks Passed: ${GREEN}${CHECKS_PASSED}${NC}"
echo -e "Checks Failed: ${RED}${CHECKS_FAILED}${NC}"
echo ""

# Verify VNet peering
echo -e "${YELLOW}Verifying VNet Peering${NC}"

PEERINGS=$(az network vnet peering list \
  --resource-group "$HUB_RG" \
  --vnet-name "vnet-hub-${ENVIRONMENT}" \
  --subscription "$SUBSCRIPTION_ID" \
  --output json 2>/dev/null | jq '. | length')

if [ "$PEERINGS" -gt 0 ]; then
  echo -e "  ${GREEN}✓ Found $PEERINGS peering(s)${NC}"
else
  echo -e "  ${RED}✗ No peerings found${NC}"
  ((CHECKS_FAILED++))
fi

echo ""

# Check Key Vault access
echo -e "${YELLOW}Checking Key Vault Network Access${NC}"

KV_NAME="kvbanking${ENVIRONMENT:0:1}"
KV_ACCESS=$(az keyvault show \
  --resource-group "$HUB_RG" \
  --name "$KV_NAME" \
  --subscription "$SUBSCRIPTION_ID" \
  --query "properties.publicNetworkAccess" \
  --output tsv 2>/dev/null || echo "Error")

if [[ "$KV_ACCESS" == "Disabled" ]]; then
  echo -e "  ${GREEN}✓ Public network access is disabled${NC}"
  ((CHECKS_PASSED++))
else
  echo -e "  ${RED}✗ Public network access is not disabled${NC}"
  ((CHECKS_FAILED++))
fi

echo ""

# Check Storage Account access
echo -e "${YELLOW}Checking Storage Account Network Access${NC}"

STORAGE_ACCOUNTS=$(az storage account list \
  --resource-group "$PROJECT_RG" \
  --subscription "$SUBSCRIPTION_ID" \
  --output json 2>/dev/null || echo "[]")

STORAGE_COUNT=$(echo "$STORAGE_ACCOUNTS" | jq '. | length')

if [ "$STORAGE_COUNT" -gt 0 ]; then
  for SA in $(echo "$STORAGE_ACCOUNTS" | jq -r '.[].name'); do
    SA_ACCESS=$(az storage account show \
      --resource-group "$PROJECT_RG" \
      --name "$SA" \
      --subscription "$SUBSCRIPTION_ID" \
      --query "networkAcls.defaultAction" \
      --output tsv 2>/dev/null || echo "Error")
    
    if [[ "$SA_ACCESS" == "Deny" ]]; then
      echo -e "  ${GREEN}✓ Storage account $SA has public access denied${NC}"
      ((CHECKS_PASSED++))
    fi
  done
else
  echo -e "  ${YELLOW}No storage accounts found (may be expected)${NC}"
fi

echo ""
echo -e "${YELLOW}Final Result${NC}"

if [ $CHECKS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All validations passed!${NC}"
  exit 0
else
  echo -e "${RED}✗ $CHECKS_FAILED validation(s) failed${NC}"
  exit 1
fi
