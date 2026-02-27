# AURORA-IA Project Constitution — Scope: Cloud Platform

> **Extracted from**: `.boltf/memory/constitution.md`
> **Scope**: `cloud-platform` — Infrastructure scope, containers, orchestration, IaC, infra monitoring, infra testing, and landing zone templates.
> Articles marked with 🔄 are **common to all scopes** and always present.
> Sections marked with 🆕 are **proposed additions** not present in the original constitution.

---

## Preamble 🔄

This Constitution establishes the governing principles, technology decisions, and standards for the **[PROJECT_NAME]** project. All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

---

## Article VIII: Containers & Orchestration

> **📋 Applies to**: Application Development, Full Stack (workload infra)
> **⏭️ Skip if**: Infrastructure Only (platform level)

### Section 8.1: Container Strategy

- [ ] **Docker** - Standard containers
- [ ] **None** - PaaS only (Azure App Service)

### Section 8.2: Orchestration Platform

Select ONE:

- [ ] **Azure Kubernetes Service (AKS)** - Managed K8s
- [ ] **Azure Container Apps** - Serverless containers
- [ ] **Azure App Service** - PaaS (Containers or Code)
- [ ] **On-premises Kubernetes** - Self-managed K8s
- [ ] **Docker Compose** - Development only

### Section 8.3: Kubernetes Configuration (if AKS/K8s selected)

Package Manager:

- [ ] **Helm** - Chart-based deployments
- [ ] **Kustomize** - Overlay-based configuration

Ingress Controller:

- [ ] **NGINX Ingress** - Community standard
- [ ] **Azure Application Gateway Ingress (AGIC)** - Azure-native
- [ ] **Traefik** - Cloud-native, auto-discovery

### Section 8.4: Cloud-Native Extensions

#### KEDA (Kubernetes Event-Driven Autoscaling)

KEDA Enabled: [ ] Yes [ ] No

If Yes, select scalers:

- [ ] Azure Service Bus
- [ ] Azure Event Hubs
- [ ] Azure Storage Queue
- [ ] HTTP Request count

#### Dapr (Distributed Application Runtime)

Dapr Enabled: [ ] Yes [ ] No

If Yes, select building blocks:

| Building Block     | Enabled        | Azure Component                      |
| ------------------ | -------------- | ------------------------------------ |
| Service Invocation | [ ] Yes [ ] No | -                                    |
| State Management   | [ ] Yes [ ] No | [ ] Azure Cosmos DB [ ] Redis        |
| Pub/Sub            | [ ] Yes [ ] No | [ ] Azure Service Bus [ ] Event Hubs |
| Secrets            | [ ] Yes [ ] No | [ ] Azure Key Vault                  |

---

## Article VIII-B: Infrastructure Scope & Landing Zone Strategy

> **📋 Applies to**: Infrastructure Only, Full Stack
> **⏭️ Skip if**: Application Development Only (assumes infra exists)
> **Priority**: Must be decided BEFORE IaC tool selection

### Section 8B.1: Infrastructure Scope

Select infrastructure provisioning scope:

- [ ] **Landing Zone** - Enterprise-scale foundation with Management Groups, Hub-Spoke networking, governance, and platform-level services
- [ ] **Workload Infrastructure** - App-specific resources only (databases, storage, compute) on existing platform
- [ ] **Both** - Landing Zone + Workload (greenfield deployment)

### Section 8B.2: Landing Zone Components (if Landing Zone selected)

**Core Components**:

- [ ] Management Groups hierarchy
- [ ] Subscription organization
- [ ] Hub-Spoke network topology
- [ ] Azure Policy governance
- [ ] RBAC baseline
- [ ] Log Analytics workspace (centralized)
- [ ] Azure Security Center / Defender
- [ ] Azure Firewall / Network Virtual Appliances

**Implementation Pattern**:

- [ ] **Azure Landing Zones (ALZ)** - Microsoft reference architecture with Bicep/Terraform modules
- [ ] **Cloud Adoption Framework (CAF) Enterprise Scale** - Full governance framework
- [ ] **Custom Landing Zone** - Organization-specific design

**Networking Model**:

- [ ] Hub-Spoke (centralized connectivity)
- [ ] Virtual WAN (global transit architecture)
- [ ] Mesh (peer-to-peer connectivity)

### Section 8B.3: Workload Infrastructure Components (if Workload or Both selected)

**Compute Resources**:

- [ ] App Services / Container Apps
- [ ] AKS clusters
- [ ] Virtual Machines
- [ ] Serverless (Functions, Logic Apps)

**Data Resources**:

- [ ] Azure SQL / Cosmos DB / PostgreSQL
- [ ] Redis Cache
- [ ] Storage Accounts

**Integration Resources**:

- [ ] Service Bus / Event Hubs
- [ ] API Management
- [ ] Application Gateway

### Section 8B.4: Deployment Strategy

**Provisioning Order** (if Both selected):

1. Landing Zone foundation (management, networking, governance)
2. Workload-specific subscriptions
3. Application resources

**Separation of Concerns**:

- [ ] **Separate repositories** - Landing Zone repo + Workload repo
- [ ] **Monorepo** - Single repo with /landing-zone and /workload folders
- [ ] **Modular approach** - Shared modules with environment-specific configurations

### Section 8B.5: Trade-offs and Rationale

**Landing Zone Benefits**:

- ✅ Enterprise governance at scale
- ✅ Consistent security baseline
- ✅ Centralized networking (ExpressRoute, VPN)
- ✅ Multi-subscription architecture support

**Landing Zone Costs**:

- ⚠️ Increased complexity (Management Groups, policies)
- ⚠️ Longer initial setup time
- ⚠️ Requires platform engineering expertise

**Workload-Only Benefits**:

- ✅ Faster time-to-market (assumes platform exists)
- ✅ Focused scope (app-specific resources only)
- ✅ Simpler IaC (no cross-subscription dependencies)

**Workload-Only Assumptions**:

- ⚠️ Assumes existing landing zone or shared platform
- ⚠️ Limited control over networking/governance
- ⚠️ May require coordination with platform team

---

## Article VIII-C: Service Orchestration with .NET Aspire

> **📋 Applies to**: Multi-service .NET applications (2+ services)
> **⏭️ Skip if**: Single-service architecture, non-.NET stack, or manual orchestration preferred

### Section 8C.1: Aspire Adoption Decision

**Choose ONE**:

- [ ] **Yes** - Enable .NET Aspire for service orchestration
- [ ] **No** - Manual orchestration (Docker Compose / Kubernetes / Podman)

### Section 8C.2: Aspire Components (if Yes)

When Aspire is enabled, the following components are provisioned:

- **AppHost Project**: Orchestrator that defines service topology and dependencies
- **ServiceDefaults Library**: Shared OpenTelemetry, health checks, and resilience configuration
- **Service Discovery**: Automatic resolution via `WithReference()` API
- **Aspire Dashboard**: Local observability dashboard at `http://localhost:15888`

### Section 8C.3: Service Discovery Strategy

**Choose ONE**:

- [ ] **Aspire Automatic** - Use `WithReference()` for all inter-service communication (recommended)
- [ ] **Manual Configuration** - Environment variables and explicit URLs
- [ ] **Hybrid** - Aspire for local dev, manual for production

### Section 8C.4: Rationale and Trade-offs

**✅ When to Use Aspire**:

- Multi-service .NET architecture (backend + frontend + API gateway)
- Team wants unified local development experience (`dotnet run` launches all)
- Observability is a priority (OpenTelemetry out-of-the-box)
- Deploying to Azure with `azd` CLI

**❌ When NOT to Use**:

- Single-service application (no orchestration needed)
- Non-.NET services (Node.js, Python, Go) - Aspire is .NET-centric
- Team prefers explicit configuration over "magic" service discovery
- Docker Desktop unavailable (Aspire requires containers for local dev)

**Benefits**:

- ✅ **Automatic Service Discovery**: Eliminates hardcoded URLs between services
- ✅ **Built-in Observability**: OpenTelemetry dashboard for traces, metrics, logs
- ✅ **Simplified Local Development**: Single `dotnet run` launches all services
- ✅ **Unified Deployment**: `azd up` deploys entire solution to Azure with Bicep generation

**Costs & Constraints**:

- ⚠️ **Docker Desktop Required**: Aspire runs services in containers locally
- ⚠️ **Learning Curve**: AppHost model and `WithReference()` API
- ⚠️ **.NET 8+ Required**: Aspire is not available for older frameworks
- ⚠️ **Additional Project**: AppHost adds complexity to solution structure

### Section 8C.5: Implementation References

**Provisioning**:

- Article VIII-C decisions are processed by `@Bolt Constitution` agent
- Templates downloaded from [dotnet/aspire GitHub](https://github.com/dotnet/aspire/tree/main/templates)
- AppHost project created at `src/AppHost/`
- ServiceDefaults library created at `src/ServiceDefaults/`

**Learn More**:

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [AppHost Patterns](https://learn.microsoft.com/dotnet/aspire/fundamentals/app-host-overview)
- [Service Discovery Overview](https://learn.microsoft.com/dotnet/aspire/service-discovery/overview)
- Skill: `skill-bolt-aspire-orchestration` (provisioned if enabled)

---

## Article IX: Infrastructure as Code

> **📋 Applies to**: Infrastructure Only, Full Stack
> **⏭️ Skip if**: Application Development Only (assumes infra exists)

### Section 9.1: IaC Tool

Select ONE:

- [ ] **Bicep** - Azure-native, recommended
- [ ] **Terraform** - Multi-cloud, HCL
- [ ] **Pulumi** - Programmatic (.NET/TypeScript)
- [ ] **ARM Templates** - Azure legacy JSON

### Section 9.2: IaC Structure

```
infra/
├── bicep/                      # or terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── compute/
│   │   ├── data/
│   │   └── security/
│   ├── environments/
│   │   ├── dev.bicepparam
│   │   ├── uat.bicepparam
│   │   ├── pre.bicepparam
│   │   └── prod.bicepparam
│   └── main.bicep
├── k8s/                        # If using Kubernetes
│   ├── helm/
│   └── kustomize/
└── scripts/
    └── deploy.ps1
```

### Section 9.3: Landing Zone Configuration

> **📋 Applies to**: Infrastructure Only (Landing Zone scope), Full Stack (if deploying platform)

Landing Zone Pattern: [ ] CAF Enterprise-Scale [ ] Start-Small (single subscription)

#### If CAF Enterprise-Scale:

| Component                  | Enabled                       | Notes                                                |
| -------------------------- | ----------------------------- | ---------------------------------------------------- |
| Management Group Hierarchy | [ ] Yes                       | Platform, Landing Zones, Decommissioned, Sandboxes   |
| Connectivity               | [ ] Hub-Spoke [ ] Virtual WAN | Central networking                                   |
| Identity                   | [ ] Yes                       | Entra ID integration, Privileged Identity Management |
| Management                 | [ ] Yes                       | Azure Monitor, Log Analytics, Automation             |
| Security                   | [ ] Yes                       | Microsoft Defender for Cloud, Sentinel (optional)    |

#### Governance Components:

| Policy                   | Enabled        | Scope                             |
| ------------------------ | -------------- | --------------------------------- |
| Azure Policy Initiatives | [ ] Yes        | [ ] Built-in ALZ [ ] Custom       |
| Azure RBAC Custom Roles  | [ ] Yes        | -                                 |
| Azure Blueprints         | [ ] Yes [ ] No | Deprecated, use Deployment Stacks |
| Cost Management Budgets  | [ ] Yes        | Per subscription/resource group   |
| Resource Tags            | [ ] Yes        | Required tags: \_\_\_             |

#### Landing Zone Structure (Bicep):

```
infra/
├── platform/
│   ├── management-groups/
│   │   └── main.bicep
│   ├── policies/
│   │   ├── initiatives/
│   │   └── assignments/
│   ├── connectivity/
│   │   ├── hub-network.bicep
│   │   ├── dns-zones.bicep
│   │   └── firewall.bicep
│   ├── identity/
│   │   └── main.bicep
│   └── management/
│       ├── log-analytics.bicep
│       └── automation.bicep
├── landing-zones/
│   ├── templates/
│   │   ├── corp/           # Internal workloads
│   │   └── online/         # Public-facing workloads
│   └── subscriptions/
│       └── {workload-name}/
└── scripts/
    ├── deploy-platform.ps1
    └── deploy-landing-zone.ps1
```

---

## Article X: Environments & Configuration 🔄

> **📋 Applies to**: ALL project types

### Section 10.1: Environment Strategy

| Environment | Purpose                      | Enabled | Auto-Deploy              |
| ----------- | ---------------------------- | ------- | ------------------------ |
| **dev**     | Development, rapid iteration | [ ] Yes | [ ] On commit to develop |
| **uat**     | User Acceptance Testing      | [ ] Yes | [ ] On PR merge          |
| **pre**     | Pre-production, staging      | [ ] Yes | [ ] Manual trigger       |
| **prod**    | Production                   | [ ] Yes | [ ] Manual approval      |

### Section 10.2: Configuration Management

Select strategy:

- [ ] **Azure App Configuration** - Centralized, feature flags (recommended)
- [ ] **Environment Variables** - Container/App Service config
- [ ] **appsettings.{Environment}.json** (.NET) / **.env files** (Node.js)
- [ ] **Combination** - App Config + Key Vault (recommended)

### Section 10.3: Secrets Management

| Secret Type        | Storage         |
| ------------------ | --------------- |
| Connection Strings | Azure Key Vault |
| API Keys           | Azure Key Vault |
| Certificates       | Azure Key Vault |

Local Development Secrets:

- [ ] **User Secrets** (.NET) - `dotnet user-secrets`
- [ ] **.env files** (Node.js) - gitignored
- [ ] **Local Key Vault** - Azure Key Vault dev instance

### Section 10.4: Feature Flags

Feature Flag Provider:

- [ ] **None**
- [ ] **Azure App Configuration** - Native integration
- [ ] **LaunchDarkly** - Enterprise features
- [ ] **Unleash** - Open-source

---

## Article XI: CI/CD Pipeline 🔄

> **📋 Applies to**: ALL project types

### Section 11.1: CI/CD Platform

Select ONE:

- [ ] **GitHub Actions** - GitHub-native
- [ ] **Azure DevOps Pipelines** - Azure-native

### Section 11.2: Pipeline Stages

#### For Infrastructure:

| Stage                | Enabled | Threshold           |
| -------------------- | ------- | ------------------- |
| **IaC Lint**         | [ ] Yes | Bicep lint / tflint |
| **IaC Validation**   | [ ] Yes | what-if / plan      |
| **Security Scan**    | [ ] Yes | Checkov / tfsec     |
| **Cost Estimation**  | [ ] Yes | Infracost           |
| **Compliance Check** | [ ] Yes | Azure Policy        |

#### Deployment Stages:

| Stage           | Enabled | Trigger            |
| --------------- | ------- | ------------------ |
| **Deploy Dev**  | [ ] Yes | Auto on develop    |
| **Deploy UAT**  | [ ] Yes | Auto on release/\* |
| **Deploy Pre**  | [ ] Yes | Manual trigger     |
| **Deploy Prod** | [ ] Yes | Manual approval    |

### Section 11.3: Deployment Strategy

Select ONE:

- [ ] **Rolling Update** - Gradual replacement
- [ ] **Blue-Green** - Azure Deployment Slots / K8s
- [ ] **Canary** - Gradual traffic shift
- [ ] **Feature Flags** - Deploy dark, enable via flags

### Section 11.4: Branch Strategy

Select ONE:

- [ ] **GitFlow** - feature/, develop, release/, main
- [ ] **GitHub Flow** - feature/, main
- [ ] **Trunk-Based** - Short-lived branches, main

---

## Article XII: Observability 🔄

> **📋 Applies to**: ALL project types

### Section 12.1: Observability Strategy

Select ONE:

- [ ] **Azure-Native** - Azure Monitor + Application Insights
- [ ] **OpenTelemetry → Azure** - OTel SDK → Azure Monitor Exporter
- [ ] **OpenTelemetry → Grafana Stack** - Self-hosted Grafana/Loki/Tempo

### Section 12.2: Health Checks

```
/health       - Full health check
/health/ready - Readiness probe
/health/live  - Liveness probe
```

### Section 12.3: Infrastructure Monitoring (if Infrastructure scope)

| Component       | Tool                      | Enabled |
| --------------- | ------------------------- | ------- |
| Resource Health | Azure Resource Health     | [ ] Yes |
| Activity Logs   | Azure Monitor             | [ ] Yes |
| Diagnostics     | Log Analytics             | [ ] Yes |
| Alerts          | Azure Monitor Alerts      | [ ] Yes |
| Dashboards      | Azure Workbooks / Grafana | [ ] Yes |

---

## Article XIII: Testing Standards (Infrastructure)

### Section 13.4: Infrastructure Testing (if Infrastructure scope)

| Test Type         | Tool                   | Purpose                    |
| ----------------- | ---------------------- | -------------------------- |
| IaC Lint          | Bicep linter / tflint  | Syntax and best practices  |
| Security Scan     | Checkov / tfsec        | Security misconfigurations |
| Policy Compliance | Azure Policy (what-if) | Governance validation      |
| Integration Test  | Pester / Terratest     | Post-deployment validation |
| Cost Estimation   | Infracost              | Budget validation          |

---

## Article XV: Project Structure Templates (Infrastructure)

### Template E: Infrastructure Only - Landing Zone

```
project-root/
├── platform/
│   ├── management-groups/
│   │   ├── main.bicep
│   │   └── modules/
│   ├── policies/
│   │   ├── initiatives/
│   │   │   ├── security.bicep
│   │   │   └── tagging.bicep
│   │   ├── definitions/
│   │   └── assignments/
│   ├── connectivity/
│   │   ├── hub-network/
│   │   │   ├── main.bicep
│   │   │   ├── firewall.bicep
│   │   │   └── bastion.bicep
│   │   ├── dns/
│   │   │   └── private-dns-zones.bicep
│   │   └── vwan/                 # If Virtual WAN
│   ├── identity/
│   │   ├── main.bicep
│   │   └── rbac-assignments.bicep
│   └── management/
│       ├── log-analytics.bicep
│       ├── automation.bicep
│       └── defender.bicep
├── landing-zones/
│   ├── templates/
│   │   ├── corp-workload/
│   │   │   ├── main.bicep
│   │   │   └── parameters/
│   │   └── online-workload/
│   │       ├── main.bicep
│   │       └── parameters/
│   └── subscriptions/
│       └── README.md             # Instructions for new workloads
├── modules/
│   ├── networking/
│   ├── security/
│   ├── compute/
│   └── data/
├── tests/
│   ├── policy-compliance/
│   ├── integration/
│   └── security-scan/
├── pipelines/
│   ├── platform-deploy.yml
│   └── landing-zone-deploy.yml
├── docs/
│   ├── architecture/
│   └── runbooks/
└── README.md
```

### Template F: Infrastructure Only - Workload

```
project-root/
├── infra/
│   ├── bicep/                    # or terraform/
│   │   ├── main.bicep
│   │   ├── modules/
│   │   │   ├── networking/
│   │   │   │   ├── vnet.bicep
│   │   │   │   └── nsg.bicep
│   │   │   ├── compute/
│   │   │   │   ├── aks.bicep
│   │   │   │   └── container-apps.bicep
│   │   │   ├── data/
│   │   │   │   ├── sql.bicep
│   │   │   │   └── cosmos.bicep
│   │   │   └── security/
│   │   │       ├── keyvault.bicep
│   │   │       └── managed-identity.bicep
│   │   └── environments/
│   │       ├── dev.bicepparam
│   │       ├── uat.bicepparam
│   │       ├── pre.bicepparam
│   │       └── prod.bicepparam
│   └── k8s/                      # If AKS
│       ├── helm/
│       └── kustomize/
├── tests/
│   ├── bicep-lint/
│   ├── security/
│   └── post-deploy/
├── pipelines/
│   └── infra-deploy.yml
├── docs/
│   └── architecture.md
└── README.md
```

---

## Article XVI: Security Policies 🔄

> **📋 Applies to**: ALL project types

### Section 16.1: Network Security

| Component                | Configuration                     |
| ------------------------ | --------------------------------- |
| Virtual Network          | [ ] Azure VNet [ ] None           |
| Private Endpoints        | [ ] Enabled [ ] Disabled          |
| Web Application Firewall | [ ] Azure Front Door WAF [ ] None |

### Section 16.2: Data Protection

| Policy                | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Encryption at Rest    | [ ] Azure-managed keys [ ] Customer-managed keys      |
| Encryption in Transit | TLS 1.2+ (mandatory)                                  |
| PII Handling          | [ ] Anonymization [ ] Pseudonymization [ ] Encryption |

### Section 16.3: Compliance Requirements

| Standard | Required       |
| -------- | -------------- |
| GDPR     | [ ] Yes [ ] No |
| HIPAA    | [ ] Yes [ ] No |
| SOC 2    | [ ] Yes [ ] No |
| PCI-DSS  | [ ] Yes [ ] No |

---

## Article XIX: Governance 🔄

> **📋 Applies to**: ALL project types

### Section 19.1: Constitution Amendments

1. **Proposal**: Any team member may propose amendments
2. **Review**: Tech Lead + Architect review required
3. **Approval**: Majority approval from signatories
4. **Implementation**: Update constitution + notify AI agents
5. **Versioning**: Semantic versioning (MAJOR.MINOR.PATCH)

### Section 19.2: AI Agent Compliance

All AI agents operating in this project MUST:

1. **Read** this constitution before any operation
2. **Validate** all decisions against constitution principles
3. **FAIL** operations that violate constitution
4. **Request** amendment for justified exceptions
5. **Log** all constitution checks for audit

---

## Proposed Additions — Cloud Platform Gaps 🆕

> The original constitution does not cover the following cloud platform concerns.
> These are recommended Microsoft/Azure alternatives based on current best practices.

- **Cost Management / FinOps**: Azure Cost Management + Budgets; Infracost in CI; Azure Advisor cost recommendations.
- **SLO / SLA Targets**: Define per-environment SLOs using Azure Monitor SLI dashboards and Azure Service Health alerts.
- **Disaster Recovery**: Azure Site Recovery for VMs; Geo-redundant storage (GRS); Azure Cosmos DB multi-region writes.
- **Azure Deployment Stacks**: Preferred over deprecated Blueprints for managed resource group deployments.
- **Azure Verified Modules (AVM)**: Use AVM Bicep/Terraform modules for standardized, Microsoft-maintained infrastructure components.
- **Azure Landing Zone Accelerators**: Use ALZ Bicep/Terraform accelerators from Microsoft CAF for rapid enterprise-scale bootstrapping.

---

## Signatories

| Role         | Name   | Date   | Signature |
| ------------ | ------ | ------ | --------- |
| Project Lead | [NAME] | [DATE] |           |
| Tech Lead    | [NAME] | [DATE] |           |
| Architect    | [NAME] | [DATE] |           |

---

## Revision History

| Version | Date   | Author   | Changes                                                                                    |
| ------- | ------ | -------- | ------------------------------------------------------------------------------------------ |
| 2.1.0   | [DATE] | [AUTHOR] | Added Project Scope (App/Infra/Full Stack), Landing Zone templates, Infrastructure testing |
| 2.0.0   | [DATE] | [AUTHOR] | Complete rewrite with C#/Node.js options                                                   |
| 1.0.0   | [DATE] | [AUTHOR] | Initial constitution                                                                       |
