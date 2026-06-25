# BOLT Framework Project Constitution

> **Version**: 1.0.0
> **Ratification Date**: 2026-06-19
> **Last Amended**: 2026-06-19
> **Status**: Ratified
> **Project**: SICA Modernization (Migración VB.NET WebForms → Azure .NET 6+ / React SPA)
> **Kind**: Brownfield migration
> **Interaction Language**: Español (España)

---

## Preamble

This Constitution establishes the governing principles, technology decisions, and standards for the **SICA Modernization** project — the modernization of the legacy SICA system (described in [demo/origen.md](../../demo/origen.md)) toward the target cloud-native architecture (described in [demo/destino.md](../../demo/destino.md)). All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

---

## Article I: Project Scope & Type

> **⚠️ IMPORTANT**: Define the active scopes FIRST. This determines which articles and scope constitutions apply. The project type (Infrastructure / Application / Full Stack) is automatically derived from the selected scopes.

### Section 1.1: Active Scopes

Select ONE or MORE scopes. Each active scope injects its own constitution sections and activates the corresponding articles. Scopes are **combinable** — a typical project activates 2-4 scopes.

|     | Scope              | Description                                                  | Activates                                                                                             |
| --- | ------------------ | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- |
| [x] | **backend**        | Server-side APIs, services, domain logic                     | Articles II §2.1, III §3.1/3.3/3.4, IV, V, VI, VII, VIII, XIII §13.1-13.3, XIV, XV (A-D), XVII, XVIII |
| [x] | **frontend**       | Web/mobile UI, SPA, design system                            | Articles II §2.2-2.3, III §3.2, VII §7.3-7.4, XIII (E2E), XIV, XV (frontend)                          |
| [x] | **cloud-platform** | Infrastructure, Landing Zones, IaC, platform engineering     | Articles VIII, IX, XII §12.3, XIII §13.4, XV (E-F)                                                    |
| [x] | **data**           | Databases, ETL/ELT, analytics, data governance               | Articles V, VI                                                                                        |
| [x] | **integration**    | API management, messaging, external system connectors        | Articles IV, XVII, XVIII                                                                              |
| [ ] | **ai**             | AI/ML models, agents, prompt engineering, responsible AI     | Article XIX §19.2 (emphasis) + AI-specific extensions                                                 |
| [ ] | **crm**            | Dynamics 365, Power Platform, Dataverse, business automation | Article VII                                                                                           |

> **Note**: The `work-management` scope (Azure DevOps, GitHub Projects, Jira synchronization) is **transversal** and managed separately. It does not appear here because it applies to all projects regardless of scope selection.

#### Common Scope Combinations

| Project Profile                     | Recommended Scopes                                                 |
| ----------------------------------- | ------------------------------------------------------------------ |
| REST API microservices              | `backend` + `cloud-platform` + `integration`                       |
| Full-stack web application          | `backend` + `frontend` + `data`                                    |
| AI-powered application              | `backend` + `ai` + `data`                                          |
| Enterprise CRM solution             | `crm` + `integration` + `data`                                     |
| Data platform / analytics           | `data` + `cloud-platform`                                          |
| Landing Zone / platform engineering | `cloud-platform`                                                   |
| Complete enterprise solution        | `backend` + `frontend` + `cloud-platform` + `data` + `integration` |

---

## Article X: Environments & Configuration

> **📋 Applies to**: ALL project types

### Section 10.1: Environment Strategy

| Environment | Purpose                      | Enabled | Auto-Deploy              |
| ----------- | ---------------------------- | ------- | ------------------------ |
| **dev**     | Development, rapid iteration | [x] Yes | [x] On commit to develop |
| **uat**     | User Acceptance Testing      | [x] Yes | [x] On PR merge          |
| **pre**     | Pre-production, staging      | [x] Yes | [x] Manual trigger       |
| **prod**    | Production                   | [x] Yes | [x] Manual approval      |

### Section 10.2: Configuration Management

Select strategy:

- [ ] **Azure App Configuration** - Centralized, feature flags (recommended)
- [ ] **Environment Variables** - Container/App Service config
- [ ] **appsettings.{Environment}.json** (.NET) / **.env files** (Node.js)
- [x] **Combination** - App Config + Key Vault (recommended)

### Section 10.3: Secrets Management

| Secret Type        | Storage         |
| ------------------ | --------------- |
| Connection Strings | Azure Key Vault |
| API Keys           | Azure Key Vault |
| Certificates       | Azure Key Vault |

Local Development Secrets:

- [x] **User Secrets** (.NET) - `dotnet user-secrets`
- [x] **.env files** (Node.js) - gitignored
- [ ] **Local Key Vault** - Azure Key Vault dev instance

### Section 10.4: Feature Flags

Feature Flag Provider:

- [ ] **None**
- [x] **Azure App Configuration** - Native integration
- [ ] **LaunchDarkly** - Enterprise features
- [ ] **Unleash** - Open-source

---

## Article XI: CI/CD Pipeline

> **📋 Applies to**: ALL project types

### Section 11.1: CI/CD Platform

Select ONE:

- [x] **GitHub Actions** - GitHub-native
- [ ] **Azure DevOps Pipelines** - Azure-native

### Section 11.2: Pipeline Stages

#### For Application Development

| Stage                  | Enabled | Threshold                          |
| ---------------------- | ------- | ---------------------------------- |
| **Build**              | [x] Yes | Warnings as errors: [x] Yes [ ] No |
| **Lint/Format**        | [x] Yes | -                                  |
| **Unit Tests**         | [x] Yes | Coverage >= 80%                  |
| **Integration Tests**  | [x] Yes | -                                  |
| **Architecture Tests** | [x] Yes | -                                  |
| **Mutation Tests**     | [x] Yes | Score >= 70%                     |
| **Security Scan**      | [x] Yes | 0 Critical                         |
| **Container Build**    | [x] Yes | -                                  |
| **Container Scan**     | [x] Yes | 0 Critical                         |

#### For Infrastructure

| Stage                | Enabled | Threshold           |
| -------------------- | ------- | ------------------- |
| **IaC Lint**         | [x] Yes | Bicep lint / tflint |
| **IaC Validation**   | [x] Yes | what-if / plan      |
| **Security Scan**    | [x] Yes | Checkov / tfsec     |
| **Cost Estimation**  | [x] Yes | Infracost           |
| **Compliance Check** | [x] Yes | Azure Policy        |

#### Deployment Stages

| Stage           | Enabled | Trigger            |
| --------------- | ------- | ------------------ |
| **Deploy Dev**  | [x] Yes | Auto on develop    |
| **Deploy UAT**  | [x] Yes | Auto on release/\* |
| **Deploy Pre**  | [x] Yes | Manual trigger     |
| **Deploy Prod** | [x] Yes | Manual approval    |

### Section 11.3: Deployment Strategy

Select ONE:

- [ ] **Rolling Update** - Gradual replacement
- [x] **Blue-Green** - Azure Deployment Slots / K8s
- [ ] **Canary** - Gradual traffic shift
- [ ] **Feature Flags** - Deploy dark, enable via flags

### Section 11.4: Branch Strategy

Select ONE:

- [x] **GitFlow** - feature/, develop, release/, main
- [ ] **GitHub Flow** - feature/, main
- [ ] **Trunk-Based** - Short-lived branches, main

---

## Article XII: Observability

> **📋 Applies to**: ALL project types

### Section 12.1: Observability Strategy

Select ONE:

- [ ] **Azure-Native** - Azure Monitor + Application Insights
- [x] **OpenTelemetry → Azure** - OTel SDK → Azure Monitor Exporter
- [ ] **OpenTelemetry → Grafana Stack** - Self-hosted Grafana/Loki/Tempo

### Section 12.2: Health Checks

```text
/health       - Full health check
/health/ready - Readiness probe
/health/live  - Liveness probe
```

### Section 12.3: Infrastructure Monitoring (if Infrastructure scope)

| Component       | Tool                      | Enabled |
| --------------- | ------------------------- | ------- |
| Resource Health | Azure Resource Health     | [x] Yes |
| Activity Logs   | Azure Monitor             | [x] Yes |
| Diagnostics     | Log Analytics             | [x] Yes |
| Alerts          | Azure Monitor Alerts      | [x] Yes |
| Dashboards      | Azure Workbooks / Grafana | [x] Yes |

---

## Article XVI: Security Policies

> **📋 Applies to**: ALL project types

### Section 16.1: Network Security

| Component                | Configuration                     |
| ------------------------ | --------------------------------- |
| Virtual Network          | [x] Azure VNet [ ] None           |
| Private Endpoints        | [x] Enabled [ ] Disabled          |
| Web Application Firewall | [x] Azure Front Door WAF [ ] None |

### Section 16.2: Data Protection

| Policy                | Value                                                 |
| --------------------- | ----------------------------------------------------- |
| Encryption at Rest    | [x] Azure-managed keys [ ] Customer-managed keys      |
| Encryption in Transit | TLS 1.2+ (mandatory)                                  |
| PII Handling          | [ ] Anonymization [ ] Pseudonymization [x] Encryption |

### Section 16.3: Compliance Requirements

| Standard | Required       |
| -------- | -------------- |
| GDPR     | [x] Yes [ ] No |
| HIPAA    | [ ] Yes [x] No |
| SOC 2    | [ ] Yes [x] No |
| PCI-DSS  | [ ] Yes [x] No |

---

## Article XIX: Governance

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

### Agent Checklist

Before generating code or making changes:

#### Base Constitution (always apply)

- [ ] Project scope and selected scopes match Article I / Section 1.1
- [ ] Environment config per Article X
- [ ] CI/CD per Article XI
- [ ] Observability per Article XII
- [ ] Security policies per Article XVI
- [ ] Governance compliance per Article XIX

#### Scope-Specific (apply per selected scopes)

> Load the relevant scope constitution(s) from `.boltf/scopes/<scope>/memory/constitution.md`

| Scope               | Key Checks                                                                                                                                                                                                                                                                                                                 |
| ------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **backend**         | Language/Runtime (Art. II), Architecture (Art. III), CQRS (§3.3), Communication (Art. IV), Data Storage (Art. V), Caching (Art. VI), Identity (Art. VII), Containers (Art. VIII), Testing (Art. XIII), Code Standards (Art. XIV), Project Structure (Art. XV), Legacy & Migration (Art. XVII), API Management (Art. XVIII) |
| **frontend**        | Framework (§2.2), Mobile (§2.3), Architecture (§3.2), Auth Flows (§7.3), Authorization (§7.4), Testing (Art. XIII), Code Standards (Art. XIV), Legacy & Migration (Art. XVII)                                                                                                                                              |
| **cloud-platform**  | Containers & Orchestration (Art. VIII), IaC (Art. IX), Infra Monitoring (§12.3), Infra Testing (§13.4), Project Structure Templates (Art. XV)                                                                                                                                                                              |
| **data**            | Data Storage (Art. V), Caching (Art. VI)                                                                                                                                                                                                                                                                                   |
| **integration**     | Communication (Art. IV), Containers/Dapr (Art. VIII), Legacy & Migration (Art. XVII), API Management (Art. XVIII)                                                                                                                                                                                                          |
| **ai**              | Scope-specific AI/ML decisions                                                                                                                                                                                                                                                                                             |
| **crm**             | Identity & Access (Art. VII), CRM-specific integrations                                                                                                                                                                                                                                                                    |
| **work-management** | Artefact mapping, sync strategy, traceability                                                                                                                                                                                                                                                                              |

---

## Signatories

| Role         | Name   | Date   | Signature |
| ------------ | ------ | ------ | --------- |
| Project Lead | [NAME] | [DATE] |           |
| Tech Lead    | [NAME] | [DATE] |           |
| Architect    | [NAME] | [DATE] |           |

---

## Revision History

| Version | Date       | Author           | Changes                                                                                                                          |
| ------- | ---------- | ---------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| 1.0.0   | 2026-06-19 | Bolt Constitution | Constitución inicial ratificada: 5 scopes, React 18+.NET 8+Azure SQL+Bicep+GitHub Actions, Strangler Fig, CQRS nativo, GDPR |

---

## Technology Stack (SICA — Ratified Decisions)

> Full details per scope in `refinement-states/merged-refinement.yaml` and per-scope constitutions.

| Layer             | Technology                                       |
| ----------------- | ------------------------------------------------ |
| Backend Runtime   | **C# / .NET 8 LTS**                              |
| Backend API       | **ASP.NET Core Controllers + Azure Functions**   |
| Backend Arch      | **Modular Monolith** (Strangler Fig → extract)   |
| CQRS              | **Simple CQRS — native .NET, NO MediatR**        |
| Frontend          | **React 18 + TypeScript + Vite**                 |
| Component Library | **shadcn/ui + Tailwind CSS v4**                  |
| State (server)    | **TanStack Query**                               |
| State (client)    | **Zustand**                                      |
| Auth (SPA)        | **MSAL.js v3 / @azure/msal-react**               |
| Auth (API)        | **Microsoft.Identity.Web + Azure AD B2C**        |
| Database          | **Azure SQL Database + EF Core 8**               |
| Cache             | **Azure Cache for Redis**                        |
| Messaging         | **Azure Service Bus (Standard)**                 |
| IaC               | **Bicep**                                        |
| CI/CD             | **GitHub Actions** (GitFlow, Blue-Green)         |
| Observability     | **OpenTelemetry → Azure Monitor / App Insights** |
| API Management    | **Azure API Management**                         |
| Secrets           | **Azure Key Vault**                              |
| Identity          | **Azure AD B2C / Entra ID**                      |
| Network Security  | **Azure VNet + Private Endpoints + WAF v2**      |
| Compliance        | **GDPR** ✅                                      |

---

## Scope Constitution Files

| Scope            | Constitution File                                                |
| ---------------- | ---------------------------------------------------------------- |
| Backend          | [backend-constitution.md](backend-constitution.md)               |
| Frontend         | [frontend-constitution.md](frontend-constitution.md)             |
| Cloud Platform   | [cloud-platform-constitution.md](cloud-platform-constitution.md) |
| Data             | [data-constitution.md](data-constitution.md)                     |
| Integration      | [integration-constitution.md](integration-constitution.md)       |

**Refinement states**: `refinement-states/` (per-scope YAMLs + `merged-refinement.yaml`)

---

## Provisioned Skills

| Skill                       | Scope(s)                  | Purpose                                        |
| --------------------------- | ------------------------- | ---------------------------------------------- |
| `dotnet-backend-patterns`   | backend                   | Clean Architecture, CQRS, EF Core, Result<T>   |
| `backend-testing-dotnet`    | backend                   | xUnit, Coverlet, NetArchTest, Stryker.NET       |
| `tdd-comprehensive`         | backend, frontend         | Red-Green-Refactor, mutation testing discipline |
| `integration-e2e-testing`   | backend, data             | Testcontainers SQL Server, Respawn              |
| `gherkin-reqnroll`          | backend                   | BDD acceptance tests .NET (Reqnroll)            |
| `azure-identity-dotnet`     | backend, integration      | Microsoft.Identity.Web, Azure AD B2C           |
| `senior-frontend`           | frontend                  | React 18, TanStack Query, MSAL.js              |
| `playwright-e2e`            | frontend                  | E2E testing SPA, Page Object Model             |
| `skill-senior-devops`       | cloud-platform            | Bicep IaC, GitHub Actions, Azure deployments   |
| `github-actions-templates`  | cloud-platform, integration | CI/CD pipelines reutilizables                |
| `skill-characterization-testing` | backend (legacy)     | Golden-master tests antes de reescribir        |
| `skill-bolt-quality-gates`  | all                       | Quality gates per Bolt iteration               |
| `skill-bolt-branch-management` | all                    | Branch discipline (feature/bolt)               |

---

## Architecture Decision Records (Pending)

| ADR     | Decisión                                                        | Estado   |
| ------- | --------------------------------------------------------------- | -------- |
| [ADR-001](../../../docs/adr/ADR-001-backend-stack-dotnet8-modular-monolith-cqrs.md) | Backend stack: C#/.NET 8, Modular Monolith, CQRS nativo, EF Core | Accepted |
| [ADR-002](../../../docs/adr/ADR-002-frontend-react18-typescript-vite.md) | Frontend: React 18 + TypeScript + Vite + shadcn/ui | Accepted |
| [ADR-003](../../../docs/adr/ADR-003-infra-azure-appservice-bicep-ghactions.md) | Infra: Azure App Service + Bicep + GitHub Actions + Blue-Green | Accepted |
| [ADR-004](../../../docs/adr/ADR-004-migracion-strangler-fig-characterization-tests.md) | Migración: Strangler Fig + Characterization Tests + ACL | Accepted |
| [ADR-005](../../../docs/adr/ADR-005-seguridad-identity-keyvault-waf-gdpr.md) | Seguridad: Azure AD B2C + Key Vault + WAF + GDPR | Accepted |
