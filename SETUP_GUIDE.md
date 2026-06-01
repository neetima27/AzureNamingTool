# Setup & Prerequisites Guide

Complete setup instructions for deploying the Azure Banking Landing Zone infrastructure.

## Table of Contents

1. [Environment Prerequisites](#environment-prerequisites)
2. [Azure Setup](#azure-setup)
3. [Local Development Setup](#local-development-setup)
4. [GitHub Repository Setup](#github-repository-setup)
5. [Self-Hosted Runner Setup](#self-hosted-runner-setup)
6. [Deployment Validation](#deployment-validation)
7. [Troubleshooting](#troubleshooting)

---

## Environment Prerequisites

### Operating System
- **Windows** (PowerShell 7.0+) ✅
- **macOS** (Zsh/Bash) ✅
- **Linux** (Bash/Zsh) ✅

### Required Software

#### 1. Azure CLI
```bash
# Windows (Chocolatey)
choco install azure-cli

# macOS (Homebrew)
brew install azure-cli

# Linux (apt, yum, zypper)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify
az --version
# Output: azure-cli 2.45.0+
```

#### 2. Bicep CLI
```bash
# Included with Azure CLI 2.45.0+
az bicep version

# Manual update (if needed)
az bicep upgrade
```

#### 3. Git
```bash
# Windows (Chocolatey)
choco install git

# macOS (Homebrew)
brew install git

# Linux (apt/yum)
sudo apt-get install git

# Verify
git --version
```

#### 4. GitHub CLI (Optional but Recommended)
```bash
# Windows (Chocolatey)
choco install gh

# macOS (Homebrew)
brew install gh

# Linux (See: https://github.com/cli/cli/releases)
curl -fsSLo - https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

#### 5. Text Editor
- **VS Code** (Recommended): https://code.visualstudio.com/
- **Extensions**:
  ```bash
  code --install-extension ms-azuretools.vscode-bicep
  code --install-extension ms-azuretools.vscode-azureextensionpack
  code --install-extension ms-dotnettools.csharp
  ```

---

## Azure Setup

### 1. Create Azure Subscription

```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set default subscription
az account set --subscription "<subscription-id>"

# Verify
az account show --output table
```

### 2. Create Service Principal (for CI/CD)

```bash
# Create service principal
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/<subscription-id>" \
  --output json

# Output:
{
  "appId": "...",
  "displayName": "github-actions-sp",
  "password": "...",
  "tenant": "..."
}

# Save the output - you'll need it for GitHub secrets
```

### 3. Get Required IDs

```bash
# Subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "SUBSCRIPTION_ID=$SUBSCRIPTION_ID"

# Tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
echo "TENANT_ID=$TENANT_ID"

# Principal ID (your user or service principal)
PRINCIPAL_ID=$(az ad signed-in-user show --query id -o tsv)
echo "PRINCIPAL_ID=$PRINCIPAL_ID"

# Save to .env file
cat > .env << EOF
export AZURE_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export AZURE_TENANT_ID="$TENANT_ID"
export AZURE_PRINCIPAL_ID="$PRINCIPAL_ID"
EOF

source .env
```

### 4. Verify Permissions

```bash
# Check your role on subscription
az role assignment list \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
  --output table

# Should show: Owner or Contributor role
```

---

## Local Development Setup

### 1. Clone Repository

```bash
git clone https://github.com/neetima27/AzureNamingTool.git
cd AzureNamingTool
```

### 2. Setup Environment Variables

```bash
# Create .env file
cat > .env << 'EOF'
# Azure Credentials
export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
export AZURE_TENANT_ID="<your-tenant-id>"
export AZURE_PRINCIPAL_ID="<your-principal-id>"

# Deployment Settings
export AZURE_LOCATION="southafricanorth"
export ENVIRONMENT="dev"

# (Optional) Bicep Parameters
export PROJECT_NAME="banking-platform"
EOF

# Make it executable and source it
chmod 600 .env
source .env
```

### 3. Validate Setup

```bash
# Test Azure CLI
az account show --output table

# Test Bicep
az bicep version

# Test Git
git status

# Verify environment variables
echo "Subscription: $AZURE_SUBSCRIPTION_ID"
echo "Tenant: $AZURE_TENANT_ID"
echo "Principal: $AZURE_PRINCIPAL_ID"
```

### 4. Initialize Local Bicep Build

```bash
# Create build directory
mkdir -p bicep/build

# Build main template
az bicep build \
  --file bicep/landing-zone/main.bicep \
  --outdir bicep/build/ \
  --output-format json

# Verify build output
ls -la bicep/build/
# Should see: main.json
```

---

## GitHub Repository Setup

### 1. Fork Repository (if contributing)

```bash
gh repo fork neetima27/AzureNamingTool --clone
```

### 2. Add Repository Secrets

GitHub Actions needs access to Azure credentials:

**Via GitHub CLI:**
```bash
# Set variables
gh secret set AZURE_CREDENTIALS \
  --body '{
    "clientId": "<appId>",
    "clientSecret": "<password>",
    "subscriptionId": "<subscription-id>",
    "tenantId": "<tenant-id>"
  }' \
  --repo <your-org>/<your-repo>

gh secret set AZURE_SUBSCRIPTION_ID \
  --body "<subscription-id>" \
  --repo <your-org>/<your-repo>
```

**Via GitHub Web UI:**
1. Go to Repository → Settings → Secrets and variables → Actions
2. Create new secret: `AZURE_CREDENTIALS`
   ```json
   {
     "clientId": "<appId>",
     "clientSecret": "<password>",
     "subscriptionId": "<subscription-id>",
     "tenantId": "<tenant-id>"
   }
   ```
3. Create new secret: `AZURE_SUBSCRIPTION_ID` = `<subscription-id>`

### 3. Configure Branch Protection

1. Go to Repository → Settings → Branches
2. Add rule for `main` branch:
   - ✅ Require a pull request before merging
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Require approval reviews
   - ✅ Dismiss stale pull request approvals

---

## Self-Hosted Runner Setup

**Required for private network deployments**

### 1. Create Virtual Machine

```bash
# Create VM on private network
az vm create \
  --resource-group rg-hub-prod-southafricanorth \
  --name vm-actions-runner \
  --image UbuntuLTS \
  --vnet-name vnet-hub-prod \
  --subnet snet-management \
  --private-ip-address 10.19.5.10 \
  --no-public-ip \
  --admin-username azureuser \
  --generate-ssh-keys
```

### 2. Install GitHub Actions Runner

On the VM:
```bash
# Download runner
mkdir ~/actions-runner && cd ~/actions-runner
curl -o actions-runner-linux-x64-2.310.0.tar.gz \
  -L https://github.com/actions/runner/releases/download/v2.310.0/actions-runner-linux-x64-2.310.0.tar.gz

tar xzf ./actions-runner-linux-x64-2.310.0.tar.gz

# Configure runner
./config.sh \
  --url https://github.com/neetima27/AzureNamingTool \
  --token <PAT-from-github> \
  --name vm-actions-runner \
  --runnergroup private-network \
  --labels Linux,private-network

# Install as service
sudo ./svc.sh install
sudo ./svc.sh start
```

### 3. Verify Runner

In GitHub:
1. Go to Repository → Settings → Actions → Runners
2. Should see: `vm-actions-runner` with status `Idle`

---

## Deployment Validation

### 1. Pre-Deployment Checks

```bash
# Validate Bicep templates
for file in bicep/landing-zone/*.bicep bicep/modules/**/*.bicep; do
  echo "Validating: $file"
  az bicep lint --file "$file"
done

# Check parameter files
az bicep build --file bicep/landing-zone/main.bicep --output-format json
```

### 2. Dry-Run Deployment (What-If)

```bash
# Test dev deployment
az deployment sub what-if \
  --location southafricanorth \
  --template-file bicep/build/main.json \
  --parameters bicep/parameters/dev.parameters.json \
  --subscription $AZURE_SUBSCRIPTION_ID

# Review changes before committing
```

### 3. Deploy to Dev

```bash
# Run deployment script
chmod +x bicep/scripts/deploy.sh
bicep/scripts/deploy.sh dev

# Confirm when prompted
```

### 4. Verify Deployment

```bash
# Run validation script
chmod +x bicep/scripts/validate.sh
bicep/scripts/validate.sh dev

# Should see all checks passing ✓
```

### 5. Test Private Endpoints

**From Bastion or Management VM:**

```bash
# Connect to VM via Bastion
# In Azure Portal: VM → Bastion

# Test Key Vault
az keyvault secret list \
  --vault-name kv-banking-platform-dev \
  --output table

# Test Storage Account
az storage blob list \
  --account-name stabankingdev001 \
  --container-name test

# Test SQL Database
Test-NetConnection \
  -ComputerName sql-banking-dev.database.windows.net \
  -Port 1433
```

---

## Troubleshooting

### Issue: `az bicep` command not found

**Solution:**
```bash
# Update Azure CLI
az upgrade

# Verify Bicep CLI
az bicep version
```

### Issue: Insufficient permissions

**Solution:**
```bash
# Check current role
az role assignment list \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID" \
  --output table

# Assign role (as Owner)
az role assignment create \
  --role "Contributor" \
  --assignee "<principal-id>" \
  --scope "/subscriptions/$AZURE_SUBSCRIPTION_ID"
```

### Issue: Deployment fails with missing parameters

**Solution:**
```bash
# Verify parameter file
cat bicep/parameters/dev.parameters.json

# Check environment variables
echo "AZURE_TENANT_ID=$AZURE_TENANT_ID"
echo "AZURE_PRINCIPAL_ID=$AZURE_PRINCIPAL_ID"

# Update parameters if needed
```

### Issue: Private Endpoint not resolving DNS

**Solution:**
```bash
# From VM in VNet
nslookup kv-banking-platform-dev.vault.azure.net

# Should resolve to 10.19.x.x (private IP)

# Check Private DNS Zone
az network private-dns zone list \
  --resource-group rg-hub-dev-southafricanorth \
  --output table
```

### Issue: Bicep build fails

**Solution:**
```bash
# Get detailed error
az bicep lint --file bicep/landing-zone/main.bicep

# Check for missing modules
ls -la bicep/modules/**/*.bicep

# Validate individual modules
az bicep build --file bicep/modules/security/keyvault.bicep
```

### Issue: GitHub Actions workflow fails

**Solution:**
1. Check workflow logs: Repository → Actions → Failed workflow
2. Look for:
   - Missing secrets (AZURE_CREDENTIALS, AZURE_SUBSCRIPTION_ID)
   - Runner availability (Settings → Runners)
   - Bicep compilation errors
   - Parameter file issues

```bash
# Test locally first
./bicep/scripts/deploy.sh dev
```

---

## Security Best Practices

### 1. Protect Secrets

```bash
# ✅ Store in GitHub Secrets
AZURE_CREDENTIALS: (JSON)
AZURE_SUBSCRIPTION_ID: xxxx-xxxx

# ❌ Never commit to repository
# Remove .env from git
echo ".env" >> .gitignore
git rm --cached .env
```

### 2. Credential Rotation

```bash
# Create new service principal every 90 days
az ad sp create-for-rbac \
  --name "github-actions-sp-$(date +%Y%m%d)" \
  --role "Contributor" \
  --scopes "/subscriptions/$AZURE_SUBSCRIPTION_ID"

# Update GitHub secrets with new credentials
```

### 3. Audit Logs

```bash
# Monitor Azure Activity Log
az monitor activity-log list \
  --subscription $AZURE_SUBSCRIPTION_ID \
  --output table
```

---

## Next Steps

1. ✅ Complete all prerequisites
2. ✅ Setup Azure subscription and credentials
3. ✅ Configure GitHub repository
4. ✅ Setup self-hosted runner (optional)
5. ✅ Run local deployment validation
6. ✅ Deploy to dev environment
7. ✅ Verify infrastructure
8. ✅ Deploy to staging and production

For detailed deployment instructions, see: [bicep/README.md](./bicep/README.md)

---

**Last Updated**: June 2026  
**Supported Platforms**: Windows, macOS, Linux  
**Required Tools**: Azure CLI 2.45.0+, Git, Bicep CLI  
**Estimated Setup Time**: 30-45 minutes
