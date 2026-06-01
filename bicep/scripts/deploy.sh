#!/bin/bash

# Landing Zone Deployment Script
# This script deploys the Bicep-based landing zone infrastructure

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENVIRONMENT="${1:-dev}"
LOCATION="${2:-southafricanorth}"
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"

# Validate inputs
if [[ ! "$ENVIRONMENT" =~ ^(dev|staging|prod)$ ]]; then
  echo -e "${RED}Error: Invalid environment. Must be dev, staging, or prod.${NC}"
  exit 1
fi

if [ -z "$SUBSCRIPTION_ID" ]; then
  echo -e "${RED}Error: AZURE_SUBSCRIPTION_ID environment variable not set${NC}"
  exit 1
fi

echo -e "${YELLOW}Landing Zone Deployment Script${NC}"
echo -e "Environment: $ENVIRONMENT"
echo -e "Location: $LOCATION"
echo -e "Subscription: $SUBSCRIPTION_ID"
echo ""

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v az &> /dev/null; then
  echo -e "${RED}Azure CLI is not installed${NC}"
  exit 1
fi

if ! az account show --subscription "$SUBSCRIPTION_ID" &> /dev/null; then
  echo -e "${RED}Cannot access subscription $SUBSCRIPTION_ID${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Azure CLI and subscription access verified${NC}"
echo ""

# Validate Bicep templates
echo -e "${YELLOW}Validating Bicep templates...${NC}"

for file in "$SCRIPT_DIR"/bicep/landing-zone/*.bicep "$SCRIPT_DIR"/bicep/modules/**/*.bicep; do
  if [ -f "$file" ]; then
    echo -e "  Validating: $(basename $file)"
    if ! az bicep build --file "$file" --output-format json --no-restore > /dev/null 2>&1; then
      echo -e "${RED}✗ Validation failed for $file${NC}"
      exit 1
    fi
  fi
done

echo -e "${GREEN}✓ All Bicep templates validated${NC}"
echo ""

# Build Bicep template
echo -e "${YELLOW}Building Bicep template...${NC}"

BUILD_DIR="$SCRIPT_DIR/build"
mkdir -p "$BUILD_DIR"

az bicep build \
  --file "$SCRIPT_DIR/bicep/landing-zone/main.bicep" \
  --outdir "$BUILD_DIR"

echo -e "${GREEN}✓ Bicep template built successfully${NC}"
echo ""

# What-If Deployment
echo -e "${YELLOW}Planning deployment (what-if)...${NC}"

az deployment sub what-if \
  --location "$LOCATION" \
  --template-file "$BUILD_DIR/main.json" \
  --parameters "$SCRIPT_DIR/bicep/parameters/${ENVIRONMENT}.parameters.json" \
  --subscription "$SUBSCRIPTION_ID"

echo -e "${YELLOW}Review the changes above. Continue with deployment? (yes/no)${NC}"
read -r CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo -e "${YELLOW}Deployment cancelled${NC}"
  exit 0
fi

echo ""
echo -e "${YELLOW}Deploying landing zone...${NC}"

az deployment sub create \
  --location "$LOCATION" \
  --template-file "$BUILD_DIR/main.json" \
  --parameters "$SCRIPT_DIR/bicep/parameters/${ENVIRONMENT}.parameters.json" \
  --subscription "$SUBSCRIPTION_ID" \
  --name "bicep-landing-zone-${ENVIRONMENT}-$(date +%s)" \
  --output json | tee "$BUILD_DIR/deployment-${ENVIRONMENT}.json"

echo ""
echo -e "${GREEN}✓ Landing zone deployed successfully${NC}"
echo ""

# Display deployment outputs
echo -e "${YELLOW}Deployment Outputs:${NC}"
az deployment sub show \
  --name "bicep-landing-zone-${ENVIRONMENT}-$(date +%s)" \
  --subscription "$SUBSCRIPTION_ID" \
  --query properties.outputs \
  --output table 2>/dev/null || echo "Outputs will be available after deployment completes"

echo ""
echo -e "${GREEN}Deployment completed at $(date)${NC}"
