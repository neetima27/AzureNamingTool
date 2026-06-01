#!/bin/bash

# Landing Zone Cleanup Script
# This script removes all resources deployed by the landing zone

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

echo -e "${RED}Landing Zone Cleanup Script${NC}"
echo -e "Environment: $ENVIRONMENT"
echo -e "Location: $LOCATION"
echo -e ""
echo -e "${RED}⚠️  WARNING: This will delete all resources in resource groups for this environment!${NC}"
echo -e "Resource groups to delete:"
echo -e "  - rg-hub-${ENVIRONMENT}-${LOCATION}"
echo -e "  - rg-banking-platform-${ENVIRONMENT}-${LOCATION}"
echo ""

read -p "Type 'DELETE' to confirm deletion: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
  echo -e "${YELLOW}Cleanup cancelled${NC}"
  exit 0
fi

echo -e "${YELLOW}Deleting resource groups...${NC}"

# Delete hub resource group
HUB_RG="rg-hub-${ENVIRONMENT}-${LOCATION}"
echo "Deleting $HUB_RG..."

if az group exists --name "$HUB_RG" --subscription "$SUBSCRIPTION_ID" | grep -q true; then
  az group delete \
    --name "$HUB_RG" \
    --subscription "$SUBSCRIPTION_ID" \
    --yes \
    --no-wait
  echo -e "${GREEN}✓ Deletion started for $HUB_RG${NC}"
fi

# Delete project resource group
PROJECT_RG="rg-banking-platform-${ENVIRONMENT}-${LOCATION}"
echo "Deleting $PROJECT_RG..."

if az group exists --name "$PROJECT_RG" --subscription "$SUBSCRIPTION_ID" | grep -q true; then
  az group delete \
    --name "$PROJECT_RG" \
    --subscription "$SUBSCRIPTION_ID" \
    --yes \
    --no-wait
  echo -e "${GREEN}✓ Deletion started for $PROJECT_RG${NC}"
fi

echo ""
echo -e "${YELLOW}Resource deletion is in progress. This may take several minutes.${NC}"
echo -e "You can monitor progress in the Azure Portal.${NC}"
