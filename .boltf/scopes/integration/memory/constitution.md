# AURORA-IA Project Constitution — Scope: Integration

> **Extracted from**: `.boltf/memory/constitution.md`
> **Scope**: `integration` — Communication patterns, API management, legacy migration, and external system integration.
> Articles marked with 🔄 are **common to all scopes** and always present.
> Sections marked with 🆕 are **proposed additions** not present in the original constitution.

---

## Preamble 🔄

This Constitution establishes the governing principles, technology decisions, and standards for the **[PROJECT_NAME]** project. All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

---

## Article IV: Communication

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 4.1: Communication Style

Select ONE:

- [ ] **Synchronous only** - REST, gRPC
- [ ] **Asynchronous only** - Messages, Events
- [ ] **Hybrid** - Both sync and async

### Section 4.2: Synchronous Communication

- [ ] **REST API** - Enabled
- [ ] **gRPC** - Enabled
- [ ] **GraphQL** - [ ] None [ ] HotChocolate (.NET) [ ] Apollo (Node.js)

### Section 4.3: Asynchronous Communication

Message Broker - Select ONE:

- [ ] **None**
- [ ] **Azure Service Bus** - Cloud-native, enterprise
- [ ] **Azure Event Hubs** - High-throughput streaming
- [ ] **RabbitMQ** - On-premises, flexible
- [ ] **Azure Storage Queues** - Simple, cost-effective

Background Processing - Select ONE or more:

- [ ] **None**
- [ ] **.NET BackgroundService** / **Node.js Worker Threads**
- [ ] **Azure Functions** - Serverless triggers
- [ ] **Hangfire** (.NET) / **BullMQ** (Node.js) - Persistent jobs

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

## Article XVII: Legacy & Migration

> **📋 Applies to**: Application Development, Full Stack (if migrating)
> **⏭️ Skip if**: Greenfield Infrastructure Only

### Section 17.1: Migration Context

Select ONE:

- [ ] **Greenfield** - New project, no legacy
- [ ] **Brownfield** - Existing codebase enhancement
- [ ] **Legacy Migration** - Full rewrite/refactor
- [ ] **Strangler Fig** - Incremental replacement

### Section 17.2: Migration Strategy (if applicable)

Select ONE:

- [ ] **Big Bang** - Full rewrite, cutover
- [ ] **Strangler Fig** - Incremental replacement
- [ ] **Branch by Abstraction** - Parallel implementations

---

## Article XVIII: API Management

> **📋 Applies to**: Application Development, Full Stack
> **⏭️ Skip if**: Infrastructure Only

### Section 18.1: API Gateway

Select ONE:

- [ ] **None** - Direct service access
- [ ] **Azure API Management (APIM)** - Full-featured
- [ ] **Azure Front Door** - Global routing + WAF
- [ ] **YARP** - .NET reverse proxy

### Section 18.2: API Features

| Feature        | Enabled        | Configuration                |
| -------------- | -------------- | ---------------------------- |
| Rate Limiting  | [ ] Yes [ ] No | \_\_\_ requests/minute       |
| API Versioning | [ ] Yes [ ] No | Strategy: [ ] URL [ ] Header |

### Section 18.3: API Documentation

| Type         | Tool              | Enabled        |
| ------------ | ----------------- | -------------- |
| REST API     | OpenAPI / Swagger | [ ] Yes        |
| Async Events | AsyncAPI          | [ ] Yes [ ] No |

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

## Proposed Additions — Integration Gaps 🆕

> The original constitution does not cover the following integration-specific concerns.
> These are recommended Microsoft/Azure alternatives based on current best practices.

- **Contract Testing**: Use Pact or Azure API Management policy validation to enforce consumer-driven contracts between services.
- **API Versioning Strategy**: Azure API Management supports URL path, query string, and header-based versioning with revision management built-in.
- **Event-Driven Integration**: Azure Event Grid for reactive event routing; Azure Service Bus Topics for pub/sub with dead-letter queues and sessions.
- **Workflow Orchestration**: Azure Logic Apps (Standard) for low-code integration workflows; Azure Durable Functions for code-first orchestration.
- **Hybrid Integration**: Azure Relay and Azure Arc for connecting on-premises systems; Azure API Management self-hosted gateway for hybrid API exposure.
- **Schema Registry**: Azure Schema Registry (Event Hubs) for Avro/JSON Schema validation of event payloads across producers and consumers.
- **Integration Observability**: Azure Application Insights distributed tracing with W3C Trace Context for end-to-end correlation across services and brokers.

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
