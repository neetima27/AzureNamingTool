# Architecture Diagrams & Visual Designs

## 1. Overall Landing Zone Architecture

```mermaid
graph TB
    subgraph "Azure Organization"
        subgraph "Management Plane"
            MG["Management Group Hierarchy"]
            POLICY["Azure Policy<br/>Governance & Compliance"]
            RBAC["Identity & Access<br/>RBAC, MFA"]
            AUDIT["Audit & Logging<br/>Activity Log, Audit Logs"]
        end
        
        subgraph "Shared Services (Connectivity Subscription)"
            HUB["☁️ Hub VNet<br/>10.19.0.0/16"]
            FW["🛡️ Azure Firewall<br/>L3-L7 Filtering"]
            BASTION["🔐 Bastion Host<br/>Secure Access"]
            FW ---|Controls Traffic| HUB
            HUB --> BASTION
            
            subgraph "Shared Infrastructure"
                ACR["📦 Container Registry<br/>Private Endpoint"]
                KV["🔑 Key Vault<br/>Secret Management"]
                PE["🔒 Private Endpoints<br/>Subnet 10.19.3.0/24"]
            end
            classDef azure fill:#0078D4,stroke:#004E8C,color:#ffffff;
            class HUB,FW,BASTION,ACR,KV,PE azure;
            
            HUB --> ACR
            HUB --> KV
            HUB --> PE
        end
        
        subgraph "Monitoring Subscription"
            LAW["Log Analytics Workspace<br/>730-day retention"]
            AI["Application Insights<br/>Performance Monitoring"]
            ALERTS["Alert Rules & Actions<br/>Real-time Notifications"]
            DASH["Dashboards & Workbooks<br/>Visualization"]
            
            LAW --> ALERTS
            LAW --> DASH
            AI --> LAW
        end
        
        subgraph "Project A"
            subgraph "Prod (10.19.16.0/20)"
                APP1["App 1<br/>Private Endpoint"]
                APP2["App 2<br/>Private Endpoint"]
                DB1["SQL Database<br/>TDE Encryption"]
                VNET1["Spoke VNet - Prod"]
                APP1 --> VNET1
                APP2 --> VNET1
                DB1 --> VNET1
            end
            
            subgraph "Dev (10.19.32.0/20)"
                APP3["App 3<br/>Private Endpoint"]
                DB2["SQL Database<br/>TDE Encryption"]
                VNET2["Spoke VNet - Dev"]
                APP3 --> VNET2
                DB2 --> VNET2
            end
        end
        
        subgraph "Project B"
            subgraph "Prod (10.19.48.0/20)"
                APP4["App 4<br/>Private Endpoint"]
                APP5["App 5<br/>Private Endpoint"]
                DB3["Cosmos DB<br/>Customer Managed Keys"]
                VNET3["Spoke VNet - Prod"]
                APP4 --> VNET3
                APP5 --> VNET3
                DB3 --> VNET3
            end
        end
        
        VNET1 ---|Peer to Hub| HUB
        VNET2 ---|Peer to Hub| HUB
        VNET3 ---|Peer to Hub| HUB
    end
    
    GH["GitHub<br/>Infrastructure Repository"]
    RUNNER["Self-Hosted Runner<br/>In Hub VNet<br/>Private IP"]
    
    GH -->|Triggers| RUNNER
    RUNNER -->|Deploys via<br/>Managed Identity| HUB
```

## 2. Management Group & Subscription Hierarchy

```mermaid
graph TD
    ROOT["Root<br/>Banking Organization"]
    
    ROOT --> MGMT["Management MG<br/>(Governance)"]
    ROOT --> PROJECTS["Projects MG<br/>(Workloads)"]
    ROOT --> SHARED["Shared Services MG<br/>(Platform)"]
    
    MGMT --> MGMT_SUB["Management Subscription<br/>Policy, Identity, Audit"]
    
    PROJECTS --> PROJA_MG["Project A MG"]
    PROJECTS --> PROJB_MG["Project B MG"]
    PROJECTS --> PROJC_MG["Project C MG"]
    
    PROJA_MG --> PROJA_PROD["Project A Prod Sub"]
    PROJA_MG --> PROJA_DEV["Project A Dev Sub"]
    
    PROJB_MG --> PROJB_PROD["Project B Prod Sub"]
    PROJB_MG --> PROJB_DEV["Project B Dev Sub"]
    
    SHARED --> IDENTITY["Identity Subscription<br/>Azure AD Integration"]
    SHARED --> MONITORING["Monitoring Subscription<br/>LAW, Alerts, Dashboards"]
    SHARED --> CONNECTIVITY["Connectivity Subscription<br/>Hub VNet, Firewall, Bastion"]
```

## 3. Network Topology - Hub and Spoke

```mermaid
graph TB
    subgraph "South Africa North Region"
        subgraph "Hub VNet (10.19.0.0/16)"
            FW_SUBNET["Firewall Subnet<br/>10.19.0.0/24"]
    BASTION_SUBNET["Bastion Subnet<br/>10.19.1.0/24"]
    GATEWAY_SUBNET["Gateway Subnet<br/>10.19.2.0/24"]
    PE_SUBNET["Private Endpoints<br/>10.19.3.0/24"]
    SHARED_SUBNET["Shared Services<br/>10.19.4.0/24"]
    MGMT_SUBNET["Management<br/>10.19.5.0/24"]
            
            FW["Azure Firewall"]
            BASTION["Bastion Host"]
            VPN["VPN Gateway"]
            RUNNER["GitHub Runner VM"]
            
            FW_SUBNET --> FW
            BASTION_SUBNET --> BASTION
            GATEWAY_SUBNET --> VPN
            SHARED_SUBNET --> RUNNER
        end
        
        subgraph "Project A VNets"
            subgraph "Prod (10.19.16.0/20)"
                APP_SUBNET_A1["App Tier<br/>10.19.16.0/24"]
                DB_SUBNET_A1["Data Tier<br/>10.19.17.0/24"]
                INT_SUBNET_A1["Integration<br/>10.19.18.0/24"]
                VNET_A_PROD["Spoke VNet Prod"]
                APP_SUBNET_A1 --> VNET_A_PROD
                DB_SUBNET_A1 --> VNET_A_PROD
                INT_SUBNET_A1 --> VNET_A_PROD
            end
            
            subgraph "Dev (10.19.32.0/20)"
                APP_SUBNET_A2["App Tier<br/>10.19.32.0/24"]
                DB_SUBNET_A2["Data Tier<br/>10.19.33.0/24"]
                VNET_A_DEV["Spoke VNet Dev"]
                APP_SUBNET_A2 --> VNET_A_DEV
                DB_SUBNET_A2 --> VNET_A_DEV
            end
        end
        
        subgraph "Project B VNets"
            subgraph "Prod (10.19.48.0/20)"
                APP_SUBNET_B1["App Tier<br/>10.19.48.0/24"]
                DB_SUBNET_B1["Data Tier<br/>10.19.49.0/24"]
                VNET_B_PROD["Spoke VNet Prod"]
                APP_SUBNET_B1 --> VNET_B_PROD
                DB_SUBNET_B1 --> VNET_B_PROD
            end
        end
        
        VNET_A_PROD ---|Peered| FW
        VNET_A_DEV ---|Peered| FW
        VNET_B_PROD ---|Peered| FW
        
        FW -->|Egress NAT| INTERNET["Internet"]
    end
```

## 4. Security Layers

```mermaid
graph TB
    INTERNET["Internet/Users"]
    
    L1["Layer 1: Perimeter<br/>DDoS Protection<br/>Azure Firewall"]
    L2["Layer 2: Network<br/>NSGs<br/>UDRs"]
    L3["Layer 3: Application<br/>WAF<br/>HTTPS/TLS 1.2+"]
    L4["Layer 4: Data<br/>Encryption at Rest<br/>Encryption in Transit"]
    L5["Layer 5: Identity<br/>MFA<br/>RBAC<br/>Managed Identity"]
    L6["Layer 6: Monitoring<br/>Audit Logging<br/>Threat Detection<br/>Real-time Alerts"]
    
    INTERNET --> L1
    L1 --> L2
    L2 --> L3
    L3 --> L4
    L4 --> L5
    L5 --> L6
    
    L6 -->|Alert to SOC| INCIDENTS["Incident Management"]
```

## 5. Data Flow - Request to Database

```mermaid
graph LR
    USER["User<br/>Internet"]
    GW["Application Gateway<br/>WAF, SSL"]
    APP["App Service<br/>Managed Identity"]
    PE["Private Endpoint<br/>10.19.3.0/24"]
    DNS["Private DNS Zone<br/>privatelink.database.windows.net"]
    DB["SQL Database<br/>TDE Encryption"]
    
    USER -->|HTTPS| GW
    GW -->|Route via Firewall| APP
    APP -->|Query via MI| DNS
    DNS -->|Resolve to PE IP| PE
    PE -->|Direct connection<br/>No internet| DB
    DB -->|Encrypted response| PE
    PE -->|Back to App| APP
    APP -->|HTTPS Response| USER
    
    style DB fill:#ff9999
    style PE fill:#99ccff
    style DNS fill:#99ff99
```

## 6. Policy Enforcement Flow

```mermaid
graph TD
    CREATE["User Attempts<br/>Resource Creation"]
    
    AZURE["Azure Resource Manager<br/>Receives Request"]
    POLICY["Azure Policy Engine<br/>Evaluates Rules"]
    
    CHECK1{All Policies<br/>Satisfied?}
    
    CHECK1 -->|No| DENY["❌ DENY<br/>Resource Not Created<br/>Error Message to User"]
    CHECK1 -->|Yes| EVALUATE{Effect<br/>Type?}
    
    EVALUATE -->|Audit| AUDIT["Log Violation<br/>Allow Creation"]
    EVALUATE -->|Deny| DENY
    EVALUATE -->|Modify| MODIFY["Auto-Modify<br/>Add Tags/Settings"]
    
    MODIFY --> CREATE_COMPLIANT["✅ CREATE<br/>Compliant Resource<br/>Log Action"]
    AUDIT -->|Non-Compliant| LOG["Log Non-Compliance<br/>Allow Anyway"]
    
    LOG --> CREATE_AUDIT["✅ CREATE<br/>Non-Compliant Resource<br/>Flagged for Review"]
    
    CREATE_COMPLIANT --> MON["Monitor & Report"]
    CREATE_AUDIT --> MON
    
    CREATE --> AZURE
```

## 7. Monitoring Data Flow

```mermaid
graph TB
    subgraph "Data Sources"
        APP["Application Logs<br/>App Insights SDK"]
        VM["VM Metrics<br/>Azure Monitor Agent"]
        RESOURCE["Resource Diagnostics<br/>Auto Diagnostic Settings"]
        CONTROL["Control Plane<br/>Activity Log"]
        NETWORK["Network Events<br/>NSG Flow Logs"]
    end
    
    subgraph "Collection"
        LAW["Log Analytics Workspace<br/>Ingestion Pipeline"]
    end
    
    subgraph "Processing"
        KQL["KQL Queries<br/>Real-time Analysis"]
        ALERT["Alert Rules<br/>Threshold Detection"]
        ML["Machine Learning<br/>Anomaly Detection"]
    end
    
    subgraph "Output"
        DASH["Dashboards<br/>Visual Reports"]
        EMAIL["Email Alerts"]
        SLACK["Slack Notifications"]
        TICKETS["Incident Tickets"]
    end
    
    APP --> LAW
    VM --> LAW
    RESOURCE --> LAW
    CONTROL --> LAW
    NETWORK --> LAW
    
    LAW --> KQL
    LAW --> ALERT
    LAW --> ML
    
    KQL --> DASH
    ALERT --> EMAIL
    ALERT --> SLACK
    ALERT --> TICKETS
    ML --> DASH
```

## 8. CI/CD Pipeline Flow

```mermaid
graph LR
    DEV["Developer<br/>Local Machine"]
    REPO["GitHub Repo<br/>Main Branch"]
    PR["Pull Request<br/>Code Review"]
    PLAN["Bicep Build & What-If<br/>Self-Hosted Runner"]
    REVIEW["Approve<br/>& Merge"]
    CONNECT["Connectivity Stage<br/>Deploy Hub, Firewall, Bastion"]
    PROJECT["Project Stage<br/>Deploy Spoke Subscriptions"]
    AZURE["Azure Deployment<br/>via Managed Identity"]
    DEV -->|Feature Branch| REPO
    REPO -->|Create PR| PR
    PR -->|Trigger| PLAN
    PLAN -->|Generate Artifacts| PR
    PR -->|Review & Approve| REVIEW
    REVIEW -->|Merge to Main| CONNECT
    CONNECT -->|Deploy connectivity landing zone| PROJECT
    PROJECT -->|Provision project subscriptions| AZURE
    AZURE -->|Log Output| REPO
    style PLAN fill:#ffcc99
    style CONNECT fill:#99ccff
    style PROJECT fill:#99ff99
    
    DEV -->|Feature Branch| REPO
    REPO -->|Create PR| PR
    PR -->|Trigger| PLAN
    PLAN -->|Generate Plan Artifact| PR
    PR -->|Review & Approve| REVIEW
    REVIEW -->|Merge to Main| DEPLOY
    DEPLOY -->|Uses MI for Auth| AZURE
    AZURE -->|Log Output| REPO
    
    style PLAN fill:#ffcc99
    style DEPLOY fill:#99ff99
```

## 9. Cost Allocation Model

```mermaid
graph TB
    TOTAL["Total Monthly Cost<br/>$X"]
    
    TOTAL --> COMPUTE["Compute<br/>40%"]
    TOTAL --> STORAGE["Storage<br/>20%"]
    TOTAL --> DATABASE["Database<br/>25%"]
    TOTAL --> NETWORK["Networking<br/>10%"]
    TOTAL --> SHARED["Shared Services<br/>5%"]
    
    COMPUTE --> CVM["VMs"]
    COMPUTE --> CAPP["App Services"]
    COMPUTE --> CAKS["AKS Clusters"]
    
    STORAGE --> SBLOB["Blob Storage"]
    STORAGE --> SDISK["Managed Disks"]
    
    DATABASE --> DSQL["SQL Databases"]
    DATABASE --> DCOSMOS["Cosmos DB"]
    
    SHARED --> SLAB["Lab Costs"]
    SHARED --> SMON["Monitoring"]
    
    subgraph "Chargeback"
        PROJA["Project A: $Y1"]
        PROJB["Project B: $Y2"]
        PLATFORM["Platform: $Y3"]
    end
    
    COMPUTE -.->|Allocated by| PROJA
    COMPUTE -.->|Allocated by| PROJB
    COMPUTE -.->|Allocated by| PLATFORM
```

## 10. Deployment Topology

```mermaid
graph TB
    subgraph "GitHub"
        IaC["Infrastructure Code<br/>Bicep"]
        WORKFLOW["GitHub Actions<br/>Workflows"]
    end
    
    subgraph "Private Network<br/>Azure"
        RUNNER["Self-Hosted Runner<br/>Hub VNet VM"]
        BICEP_EXEC["Bicep Executor<br/>Build/Deploy"]
        AZURE_API["Azure Resource Manager<br/>API"]
    end
    
    subgraph "Azure Subscriptions"
        MGMT_SUB["Management Sub<br/>Policies & RBAC"]
        CONN_SUB["Connectivity Sub<br/>Network & Firewall"]
        MON_SUB["Monitoring Sub<br/>LAW & Alerts"]
        PROJECT_SUBS["Project Subscriptions<br/>Apps & Databases"]
    end
    
    IaC -->|Committed Code| WORKFLOW
    WORKFLOW -->|Triggers Execution| RUNNER
    RUNNER -->|Runs| TF
    TF -->|Authenticates with MI| AZURE_API
    AZURE_API -->|Creates/Updates| MGMT_SUB
    AZURE_API -->|Creates/Updates| CONN_SUB
    AZURE_API -->|Creates/Updates| MON_SUB
    AZURE_API -->|Creates/Updates| PROJECT_SUBS
    
    style RUNNER fill:#99ff99
    style TF fill:#99ff99
```

---

**Document Version**: 1.0  
**Last Updated**: June 2026
