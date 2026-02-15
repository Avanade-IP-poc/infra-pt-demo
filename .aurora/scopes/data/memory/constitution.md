# AURORA-IA Project Constitution — Scope: Data

> **Extracted from**: `.aurora/memory/constitution.md`
> **Scope**: `data` — Data storage, access patterns, migrations, caching strategy, and data governance.
> Articles marked with 🔄 are **common to all scopes** and always present.
> Sections marked with 🆕 are **proposed additions** not present in the original constitution.

---

## Preamble 🔄

This Constitution establishes the governing principles, technology decisions, and standards for the **[PROJECT_NAME]** project. All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

---

## Article V: Data Storage

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 5.1: Primary Database

Select ONE:

- [ ] **Azure SQL Database** - Managed SQL Server
- [ ] **SQL Server** - On-premises
- [ ] **PostgreSQL** - Azure Database for PostgreSQL / On-premises
- [ ] **Azure Cosmos DB** - NoSQL, globally distributed
- [ ] **MongoDB** - Document database

### Section 5.2: Data Access Pattern

#### For C#/.NET:

- [ ] **Entity Framework Core** - Full ORM
- [ ] **Dapper** - Micro-ORM, performance-focused
- [ ] **EF Core + Dapper** - EF for writes, Dapper for reads (CQRS)

#### For Node.js/TypeScript:

- [ ] **Prisma** - Type-safe ORM
- [ ] **TypeORM** - Active Record / Data Mapper
- [ ] **Drizzle** - Lightweight, SQL-like
- [ ] **Knex.js** - Query builder

Repository Pattern: [ ] Yes [ ] No
Unit of Work Pattern: [ ] Yes [ ] No

### Section 5.3: Database Migrations

#### For C#/.NET:

- [ ] **EF Core Migrations** - Code-first
- [ ] **DbUp** - SQL scripts
- [ ] **FluentMigrator** - Fluent API

#### For Node.js/TypeScript:

- [ ] **Prisma Migrate** - Integrated with Prisma
- [ ] **TypeORM Migrations** - Integrated with TypeORM
- [ ] **Knex Migrations** - SQL-based

---

## Article VI: Caching Strategy

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 6.1: Cache Levels

| Level                | Technology                                 | Enabled        | TTL Default    |
| -------------------- | ------------------------------------------ | -------------- | -------------- |
| **L1 - In-Memory**   | IMemoryCache (.NET) / node-cache (Node.js) | [ ] Yes [ ] No | \_\_\_ minutes |
| **L2 - Distributed** | (see below)                                | [ ] Yes [ ] No | \_\_\_ minutes |
| **L3 - CDN**         | (see below)                                | [ ] Yes [ ] No | \_\_\_ hours   |

### Section 6.2: Distributed Cache (L2)

Select ONE:

- [ ] **None**
- [ ] **Azure Cache for Redis** - Managed Redis
- [ ] **Redis** - On-premises / Self-hosted

### Section 6.3: CDN (L3)

Select ONE:

- [ ] **None**
- [ ] **Azure CDN** - Static content caching
- [ ] **Azure Front Door** - Global load balancing + CDN

### Section 6.4: Cache Patterns

- [ ] **Cache-Aside** - Application manages cache
- [ ] **Read-Through** - Cache loads on miss
- [ ] **Write-Through** - Cache writes to source
- [ ] **Write-Behind** - Async persistence

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

#### For Application Development:

| Stage                  | Enabled | Threshold                          |
| ---------------------- | ------- | ---------------------------------- |
| **Build**              | [ ] Yes | Warnings as errors: [ ] Yes [ ] No |
| **Lint/Format**        | [ ] Yes | -                                  |
| **Unit Tests**         | [ ] Yes | Coverage >= \_\_%                  |
| **Integration Tests**  | [ ] Yes | -                                  |
| **Architecture Tests** | [ ] Yes | -                                  |
| **Mutation Tests**     | [ ] Yes | Score >= \_\_%                     |
| **Security Scan**      | [ ] Yes | 0 Critical                         |
| **Container Build**    | [ ] Yes | -                                  |
| **Container Scan**     | [ ] Yes | 0 Critical                         |

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

## Proposed Additions — Data Gaps 🆕

> The original constitution does not cover the following data-specific concerns.
> These are recommended Microsoft/Azure alternatives based on current best practices.

- **Data Governance & Catalog**: Microsoft Purview for unified data governance, data catalog, classification, and sensitivity labeling across Azure and hybrid sources.
- **Data Lineage**: Microsoft Purview Data Map for automated lineage tracking across Azure Data Factory, Synapse, and SQL pipelines.
- **Data Quality**: Microsoft Purview Data Quality rules; Azure Data Factory data flows with validation transforms.
- **Data Platform / Analytics**: Microsoft Fabric for unified analytics (lakehouse, warehouse, real-time intelligence); Azure Synapse Analytics for large-scale analytics workloads.
- **ETL / Data Integration**: Azure Data Factory for orchestration; Microsoft Fabric Data pipelines for integrated ETL.
- **Data Encryption at Field Level**: Azure Always Encrypted (SQL) or client-side encryption for column-level protection of sensitive data.
- **Backup & Retention Policies**: Azure SQL automated backups with configurable retention; Cosmos DB continuous backup with point-in-time restore.

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
