# Skill Generation Master Plan

## Executive Summary

- **Total articles analyzed**: 65+ specific articles across 9 scopes
- **Transversal articles**: 6 (common to all scopes)
- **Existing skills**: 3 (markdown-formatting, tdd-comprehensive, gherkin-reqnroll in common scope)
- **Total skills to create**: **52 new skills**
  - P0 Critical: **18 skills** (architectural foundation)
  - P1 High: **16 skills** (production readiness)
  - P2 Medium: **12 skills** (best practices)
  - P3 Low: **6 skills** (refinement)

---

## ✅ Skill Creation Best Practices (Learned from skill-creator)

### Core Principles

1. **Explain the "Why"**: Instead of rigid MUSTs, explain the reasoning behind decisions. Models are smart and understand context.
2. **Theory of Mind**: Treat the model as intelligent, not as a command follower. Provide frameworks, not prescriptions.
3. **Keep Skills Lean**: SKILL.md should be <300 lines ideal, <500 lines max. Externalize code and references.
4. **Progressive Disclosure**:
   - Metadata (name + description) - Always loaded (~100 words)
   - SKILL.md body - Loaded when skill triggers (<500 lines)
   - Bundled resources (references/, scripts/) - Loaded on demand

### Skill Structure

```
skill-name/
├── SKILL.md (concise, explanatory)
│   ├── Why use this skill
│   ├── Decision frameworks (not rigid rules)
│   ├── Pattern overviews (link to examples)
│   └── References to bundled resources
└── references/
    ├── code-examples.md (all code samples)
    └── microsoft-learn.md (curated documentation)
```

### Writing Style

- ❌ **Avoid**: "ALWAYS do this", "MUST follow", "NEVER use", rigid step-by-step
- ✅ **Prefer**: "This helps because...", "Consider when...", "Different patterns excel in different contexts"
- Use scoring models and decision trees, but frame them as conversation starters
- Acknowledge hybrid approaches and real-world complexity

### Status Tracker

- ✅ **skill-architecture-patterns** - Complete (paradigm established)
- 🔄 **skill-cqrs-event-sourcing** - In progress
- ⏳ **Remaining 50 skills** - Pending

---

## P0: Critical Architectural Skills

### ✅ skill-architecture-patterns (COMPLETE)

- **Scope**: backend
- **Status**: ✅ Complete and validated
- **Location**: `.boltf/scopes/backend/skills/skill-architecture-patterns/`
- **Structure**:
  - SKILL.md: 254 lines (decision frameworks, pattern overviews, explanatory)
  - references/code-examples.md: 452 lines (7 complete implementations)
  - references/microsoft-learn.md: 79 lines (curated docs)
- **Key Learnings Applied**:
  - Removed rigid MUSTs, added contextual "why" explanations
  - Removed Trade-offs Analysis table (duplicated scoring model)
  - Scoring model framed as "conversation starter", not rigid calculation
  - "How to Proceed" emphasizes understanding constraints over following steps
- **Articles**:
  - Article III (Section 3.1): Backend Architecture Style 🔴 CRITICAL
  - Article III (Section 3.2): Frontend Architecture Style 🔴 CRITICAL (frontend scope)
- **Trigger Description**: "ALWAYS use when choosing backend architecture (microservices, modular monolith, serverless, event-driven) OR frontend architecture (micro-frontends, SPA, SSR, SSG). Triggers: architecture style, microservices vs monolith, modular monolith, serverless architecture, architecture patterns, service boundaries, deployment strategy, team organization, event-driven architecture, CQRS architecture, architecture decision, choose architecture, architecture comparison, micro-frontends, SPA vs SSR, architecture trade-offs, when to use microservices, monolith to microservices. This skill is MANDATORY for Article III (Backend/Frontend Architecture) decisions."

---

### skill-cqrs-event-sourcing

- **Scope**: backend
- **Description**: Implement CQRS (Command Query Responsibility Segregation) and Event Sourcing patterns without MediatR library. ALWAYS use when implementing CQRS, event sourcing, domain events, or event stores. Triggers: "CQRS", "event sourcing", "command query", "event store", "domain events", "EventStoreDB", "Cosmos DB event store", "native CQRS", "no MediatR", "projections", "read models", "event versioning". Essential for event-driven architectures.
- **Articles**:
  - Article III (Section 3.3): CQRS Configuration 🟡 IMPORTANT
  - Article III (Section 3.4): Event Sourcing Configuration 🔴 CRITICAL
- **Justification**: CQRS + Event Sourcing is a complex architectural pattern that's very difficult to migrate away from once committed
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "CQRS pattern azure", "event sourcing azure", "azure cosmos db event store", "eventstoredb"
  - context7: "MediatR" (note: constitution prohibits it), "EventStoreDB"
- **Code Examples**:
  1. Native CQRS interfaces (C#/.NET without MediatR)
  2. Native CQRS pattern (Node.js/TypeScript)
  3. Event sourcing with Cosmos DB
  4. Event sourcing with EventStoreDB
  5. Domain events pattern
- **Skill Sections**:
  - CQRS patterns (Full CQRS, Simple CQRS, CQRS+ES)
  - Native implementation (no MediatR - per constitution)
  - Event store selection (EventStoreDB, Cosmos DB, SQL)
  - Projections and read models
  - Snapshots for performance
  - Event versioning strategies
- **Dependencies**: skill-architecture-patterns
- **Priority**: P0

---

### skill-communication-patterns

- **Scope**: integration
- **Description**: Design synchronous (REST, gRPC, GraphQL) and asynchronous (Service Bus, Event Hubs, queues) communication between services. ALWAYS use when implementing APIs, message brokers, service integration, or background jobs. Triggers: "REST API", "gRPC", "GraphQL", "Service Bus", "Event Hubs", "message broker", "async communication", "API design", "service integration", "background processing", "Hangfire", "BullMQ", "queue", "pub/sub". Critical for distributed systems.
- **Articles**:
  - Article IV (Section 4.1): Communication Style 🔴 CRITICAL
  - Article IV (Section 4.2): Synchronous Communication 🟡 IMPORTANT
  - Article IV (Section 4.3): Asynchronous Communication 🔴 CRITICAL
- **Justification**: Sync vs Async communication defines entire integration approach and affects all service interactions
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "REST API azure", "gRPC azure", "GraphQL azure", "azure service bus", "azure event hubs", "azure storage queues", "rabbitmq azure"
  - context7: "gRPC", "GraphQL HotChocolate", "Apollo GraphQL"
- **Code Examples**:
  1. REST API with OpenAPI/Swagger
  2. gRPC service definition (proto) and implementation
  3. GraphQL schema and resolvers (HotChocolate for .NET, Apollo for Node.js)
  4. Service Bus queue producer/consumer
  5. Event Hubs streaming (partition-based)
  6. Background job processing (Hangfire, BullMQ)
- **Skill Sections**:
  - Sync vs Async decision framework
  - REST API best practices (versioning, pagination, HATEOAS)
  - gRPC for inter-service communication
  - GraphQL for flexible client queries
  - Message broker selection (Service Bus, Event Hubs, RabbitMQ)
  - Background processing patterns
  - Hybrid communication strategies
- **Dependencies**: skill-architecture-patterns
- **Priority**: P0

---

### skill-database-selection

- **Scope**: backend
- **Description**: Choose database technology (SQL vs NoSQL) and ORM/data access patterns for .NET and Node.js. ALWAYS use when selecting databases, implementing data access, choosing ORMs, or designing repository patterns. Triggers: "database selection", "SQL vs NoSQL", "Azure SQL", "PostgreSQL", "Cosmos DB", "MongoDB", "Entity Framework", "EF Core", "Dapper", "Prisma", "TypeORM", "repository pattern", "Unit of Work", "ORM", "data access". Critical decision affecting entire data layer.
- **Articles**:
  - Article V (Section 5.1): Primary Database 🔴 CRITICAL
  - Article V (Section 5.2): Data Access Pattern 🟡 IMPORTANT
- **Justification**: Database choice (SQL vs NoSQL) is extremely expensive to migrate later
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure sql database", "postgresql azure", "cosmos db", "mongodb azure", "entity framework core", "dapper", "prisma", "typeorm"
  - context7: "Prisma", "TypeORM", "Drizzle", "Knex.js"
- **Code Examples**:
  1. EF Core with repository pattern (C#)
  2. Dapper micro-ORM for read queries (C#)
  3. Prisma schema and queries (Node.js/TypeScript)
  4. TypeORM entities and migrations (Node.js/TypeScript)
  5. Cosmos DB SDK usage (NoSQL)
- **Skill Sections**:
  - SQL vs NoSQL decision matrix
  - Azure database services comparison (Azure SQL, PostgreSQL, Cosmos DB, MongoDB)
  - ORM selection per stack (EF Core, Dapper, Prisma, TypeORM)
  - Repository and Unit of Work patterns
  - Database migration strategies (EF Core Migrations, Prisma Migrate, DbUp)
  - Performance considerations
- **Dependencies**: skill-architecture-patterns
- **Priority**: P0

---

### skill-identity-provider-selection

- **Scope**: backend, frontend, crm
- **Description**: Implement authentication and authorization with Entra ID, Azure AD B2C, Auth0, or Keycloak. ALWAYS use when implementing auth, OAuth2 flows, JWT validation, or authorization models. Triggers: "authentication", "authorization", "Entra ID", "Azure AD", "B2C", "Auth0", "Keycloak", "OAuth2", "JWT", "RBAC", "claims-based", "identity provider", "login", "user management", "access control", "PKCE", "token validation". Foundational for all user-facing applications.
- **Articles**:
  - Article VII (Section 7.1): Identity Provider 🔴 CRITICAL
  - Article VII (Section 7.3): Authentication Flows 🟡 IMPORTANT
  - Article VII (Section 7.4): Authorization Model 🟡 IMPORTANT
- **Justification**: Identity provider choice (Entra ID vs B2C vs Auth0 vs Keycloak) affects entire auth stack and user management
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "microsoft entra id", "azure ad b2c", "oauth 2.0 azure", "authorization code flow pkce", "client credentials flow"
  - context7: "Auth0", "Keycloak", "Duende IdentityServer"
- **Code Examples**:
  1. Entra ID authentication (.NET Minimal API + React SPA)
  2. Azure AD B2C authentication (customer-facing)
  3. Auth0 integration (multi-provider)
  4. JWT validation in API
  5. RBAC implementation with policies (.NET)
  6. Claims-based authorization
- **Skill Sections**:
  - Identity provider comparison (Entra ID, B2C, Auth0, Keycloak, IdentityServer)
  - OAuth 2.0 flows (Authorization Code + PKCE, Client Credentials, Device Code)
  - JWT validation and token refresh
  - Authorization models (RBAC, Claims-based, Policy-based, ABAC)
  - SPA authentication best practices
  - Service-to-service authentication
- **Dependencies**: None (foundational)
- **Priority**: P0

---

### skill-container-orchestration

- **Scope**: cloud-platform
- **Description**: Deploy containerized applications on AKS, Azure Container Apps, or App Service with Helm, Kustomize, KEDA, and Dapr. ALWAYS use when deploying containers, setting up Kubernetes, configuring orchestration, or implementing cloud-native patterns. Triggers: "AKS", "Kubernetes", "Container Apps", "container deployment", "Helm", "Kustomize", "KEDA", "Dapr", "K8s", "ingress", "autoscaling", "container orchestration". Critical for containerized workloads.
- **Articles**:
  - Article VIII (Section 8.1): Container Strategy 🔴 CRITICAL
  - Article VIII (Section 8.2): Orchestration Platform 🔴 CRITICAL
  - Article VIII (Section 8.3): Kubernetes Configuration 🟡 IMPORTANT
- **Justification**: AKS vs Container Apps vs App Service = fundamentally different operational models
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure kubernetes service", "azure container apps", "azure app service containers", "helm azure", "kustomize", "dapr", "keda"
  - context7: "Helm", "Kustomize", "Dapr", "KEDA"
- **Code Examples**:
  1. AKS cluster deployment (Bicep)
  2. Helm chart structure for application
  3. Kustomize overlays for environments
  4. Container Apps deployment with Dapr
  5. KEDA autoscaling configuration
  6. NGINX Ingress setup
- **Skill Sections**:
  - Container platform comparison (AKS, Container Apps, App Service)
  - When to use Kubernetes vs serverless containers
  - Helm vs Kustomize decision
  - Cloud-native extensions (KEDA, Dapr)
  - Ingress controller selection
  - Cost optimization strategies
- **Dependencies**: skill-architecture-patterns
- **Priority**: P0

---

### skill-aspire-orchestration

- **Scope**: cloud-platform
- **Description**: Orchestrate multi-service .NET applications with .NET Aspire for local development and Azure deployment. ALWAYS use when working with .NET Aspire, multi-service .NET apps, service discovery, or AppHost projects. Triggers: ".NET Aspire", "Aspire", "AppHost", "service discovery", "multi-service .NET", "Aspire dashboard", "azd deploy", "ServiceDefaults", "WithReference", ".NET 8 orchestration", "distributed .NET apps". Essential for modern .NET distributed applications.
- **Articles**:
  - Article VIII-C: Service Orchestration with .NET Aspire 🟡 IMPORTANT
- **Justification**: .NET Aspire is Microsoft's recommended multi-service orchestration for .NET, affects local dev experience and Azure deployment
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: ".net aspire", "aspire app host", "aspire service discovery", "aspire deployment azure", "aspire dashboard"
  - context7: N/A (Microsoft-specific)
- **Code Examples**:
  1. AppHost project setup
  2. Service discovery with WithReference()
  3. ServiceDefaults configuration (OpenTelemetry)
  4. Multi-service deployment with azd
  5. Aspire Dashboard usage
- **Skill Sections**:
  - When to use Aspire (multi-service .NET apps)
  - AppHost patterns
  - Service discovery and dependencies
  - OpenTelemetry integration
  - Local development workflow
  - Azure deployment with azd
  - Trade-offs (Docker Desktop required, .NET 8+ only)
- **Dependencies**: skill-container-orchestration
- **Priority**: P0

---

### skill-iac-tool-selection

- **Scope**: cloud-platform
- **Description**: Choose and implement Infrastructure as Code with Bicep, Terraform, or Pulumi for Azure deployments. ALWAYS use when writing infrastructure code, choosing IaC tool, creating Azure resources, or implementing infrastructure pipelines. Triggers: "Bicep", "Terraform", "Pulumi", "Infrastructure as Code", "IaC", "ARM templates", "infrastructure deployment", "Azure resources", "infrastructure pipeline", "IaC modules", "state management". Critical architectural decision for all Azure projects.
- **Articles**:
  - Article IX (Section 9.1): IaC Tool 🔴 CRITICAL
- **Justification**: Bicep vs Terraform vs Pulumi = fundamentally different IaC approaches and ecosystems
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure bicep", "terraform azure", "pulumi azure", "arm templates"
  - context7: "Terraform", "Pulumi"
- **Code Examples**:
  1. Bicep module structure (modular architecture)
  2. Terraform module structure (Azure provider)
  3. Pulumi C# infrastructure code
  4. Parameter files per environment
  5. CI/CD integration (validation, what-if, deployment)
- **Skill Sections**:
  - IaC tool comparison (Bicep, Terraform, Pulumi, ARM)
  - When to use Bicep (Azure-native, recommended)
  - When to use Terraform (multi-cloud)
  - When to use Pulumi (programmatic IaC)
  - Module patterns and reusability
  - Environment parameterization
  - State management (Terraform state, Bicep none)
- **Dependencies**: None (foundational)
- **Priority**: P0

---

### skill-landing-zone-architecture

- **Scope**: cloud-platform
- **Description**: Design and implement Azure Landing Zones with CAF Enterprise Scale, hub-spoke networking, and governance policies. ALWAYS use when implementing landing zones, enterprise architecture, cloud adoption framework, or Azure governance. Triggers: "landing zone", "Azure Landing Zone", "CAF", "Cloud Adoption Framework", "Enterprise Scale", "hub-spoke", "management groups", "Azure Policy", "governance", "subscription design", "network topology", "enterprise Azure". Essential for enterprise-scale deployments.
- **Articles**:
  - Article VIII-B: Infrastructure Scope & Landing Zone Strategy 🔴 CRITICAL
  - Article IX (Section 9.3): Landing Zone Configuration 🟡 IMPORTANT
- **Justification**: Landing Zone vs Workload infra = different project scope and complexity, enterprise governance requirements
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure landing zones", "cloud adoption framework", "enterprise scale architecture", "hub spoke network", "azure virtual wan", "management groups azure"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. Management Groups hierarchy
  2. Hub-Spoke network topology (Bicep)
  3. Azure Policy initiatives and assignments
  4. Centralized Log Analytics workspace
  5. Landing Zone subscription scaffold
- **Skill Sections**:
  - Landing Zone vs Workload decision matrix
  - Azure Landing Zones (ALZ) reference architecture
  - CAF Enterprise Scale pattern
  - Management Groups and subscription organization
  - Hub-Spoke vs Virtual WAN networking
  - Governance (Azure Policy, RBAC baseline, Security Center)
  - Deployment strategy (foundation first, then workloads)
- **Dependencies**: skill-iac-tool-selection
- **Priority**: P0

---

### skill-ai-architecture-patterns

- **Scope**: ai
- **Description**: Design AI solutions with MLOps, RAG (Retrieval Augmented Generation), or pre-built Azure AI services. ALWAYS use when building AI applications, choosing AI architecture, implementing RAG, or selecting Azure AI services. Triggers: "AI architecture", "RAG", "retrieval augmented generation", "MLOps", "Azure OpenAI", "Azure Machine Learning", "AI Search", "Cognitive Services", "AI pattern", "machine learning", "LLM application", "AI service selection", "prompt engineering". Foundational for all AI projects.
- **Articles**:
  - Article XIII (Section 13.1): AI Architecture Pattern 🔴 CRITICAL
  - Article XIII (Section 13.3): AI Service Selection 🔴 CRITICAL
- **Justification**: AI architecture (MLOps vs RAG vs Pre-built Services) fundamentally determines project scope and complexity
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure machine learning", "azure openai service", "rag retrieval augmented generation", "azure ai search", "azure cognitive services", "azure ai foundry"
  - context7: "LangChain", "Semantic Kernel"
- **Code Examples**:
  1. Azure ML training pipeline
  2. Azure OpenAI RAG architecture
  3. Azure AI Search vector search setup
  4. Cognitive Services API integration
  5. Prompt Flow workflow
- **Skill Sections**:
  - AI architecture pattern comparison (MLOps, RAG, Pre-built, Custom ML, Hybrid, Prompt Engineering)
  - Azure AI service selection (Azure ML, Azure OpenAI, AI Search, Cognitive Services, AI Foundry)
  - When to use RAG vs fine-tuning
  - Decision matrix (use case, data availability, expertise, cost)
  - Trade-offs analysis (time to value, accuracy, customization)
- **Dependencies**: None (AI-specific foundational)
- **Priority**: P0

---

### skill-vector-store-selection

- **Scope**: ai
- **Description**: Implement vector stores and embeddings for RAG with Azure AI Search, Cosmos DB, Redis, or Pinecone. ALWAYS use when implementing RAG, vector search, semantic search, or embeddings. Triggers: "vector store", "vector search", "embeddings", "Azure AI Search", "Cosmos DB vector", "Redis vector", "Pinecone", "semantic search", "hybrid search", "text-embedding", "ada-002", "vector database", "similarity search". Critical for RAG architectures.
- **Articles**:
  - Article XIII (Section 13.5): Vector Store & Embeddings 🔴 CRITICAL
- **Justification**: Vector store choice (AI Search vs Cosmos DB vs Redis vs Pinecone) is hard to migrate later, tightly coupled to RAG architecture
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure ai search vector search", "cosmos db vector search", "redis vector similarity", "text-embedding-ada-002", "text-embedding-3"
  - context7: "Pinecone"
- **Code Examples**:
  1. Azure AI Search index with vector fields
  2. Cosmos DB NoSQL with vector extension
  3. Redis Enterprise vector similarity search
  4. Pinecone index creation and queries
  5. Embedding generation (Azure OpenAI)
  6. Hybrid search (vectors + keywords)
- **Skill Sections**:
  - Vector store comparison (AI Search, Cosmos DB, Redis, Pinecone)
  - Embedding model selection (ada-002, text-embedding-3-small/large)
  - Vector search patterns (similarity search, hybrid search, semantic ranking)
  - Performance and scale considerations
  - Cost analysis per vector store
- **Dependencies**: skill-ai-architecture-patterns
- **Priority**: P0

---

### skill-data-platform-selection

- **Scope**: data
- **Description**: Choose analytics platform (Microsoft Fabric, Azure Databricks, Synapse) and implement lakehouse or medallion architecture. ALWAYS use when building data platforms, choosing analytics services, implementing lakehouses, or designing data architectures. Triggers: "Microsoft Fabric", "Databricks", "Synapse", "data platform", "lakehouse", "data warehouse", "medallion architecture", "Delta Lake", "analytics platform", "data lake", "bronze silver gold", "data architecture". Foundational for all data & analytics projects.
- **Articles**:
  - Article V (Section 5.1): Primary Analytics Platform 🔴 CRITICAL
  - Article V (Section 5.2): Data Storage Architecture Pattern 🔴 CRITICAL
- **Justification**: Analytics platform (Fabric vs Databricks vs Synapse) = fundamentally different ecosystems and costs
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "microsoft fabric", "azure databricks", "azure synapse analytics", "delta lake", "lakehouse architecture", "medallion architecture"
  - context7: "Apache Spark", "Delta Lake"
- **Code Examples**:
  1. Fabric workspace setup
  2. Databricks Unity Catalog configuration
  3. Synapse dedicated SQL pool
  4. Delta Lake table creation
  5. Medallion architecture (Bronze → Silver → Gold)
- **Skill Sections**:
  - Analytics platform comparison (Fabric, Databricks, Synapse)
  - Lakehouse vs Data Warehouse vs Data Lake patterns
  - Medallion architecture layers (Bronze, Silver, Gold)
  - Storage format selection (Delta Lake, Iceberg, Hudi, Parquet)
  - When to use each platform
- **Dependencies**: None (data-specific foundational)
- **Priority**: P0

---

### skill-event-driven-architecture

- **Scope**: integration
- **Description**: Implement event-driven patterns with Azure Service Bus, Event Hubs, Event Grid, and queues. ALWAYS use when implementing messaging, pub/sub, event streaming, DLQ, or idempotent processing. Triggers: "event-driven", "Service Bus", "Event Hubs", "Event Grid", "messaging", "pub/sub", "event streaming", "dead letter queue", "DLQ", "idempotency", "message delivery", "event pattern", "queue", "topic", "subscription". Fundamental for distributed systems.
- **Articles**:
  - Article XVIII-A: Event-Driven Architecture & Messaging Patterns (complex, multiple sections)
- **Justification**: EDA patterns (Queue, Pub/Sub, Streaming, Request-Reply) are fundamental to distributed system design
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure service bus", "azure event hubs", "azure event grid", "azure storage queues", "message delivery guarantees", "dead letter queue"
  - context7: "RabbitMQ", "Apache Kafka"
- **Code Examples**:
  1. Service Bus queue (point-to-point)
  2. Service Bus topic/subscriptions (pub/sub)
  3. Event Hubs streaming (partition-based)
  4. Event Grid routing
  5. Dead-letter queue handling
  6. Idempotent message processing
- **Skill Sections**:
  - Messaging service selection (Service Bus, Event Hubs, Event Grid, Storage Queues)
  - Messaging patterns (Point-to-Point, Pub/Sub, Event Streaming, Request-Reply)
  - Message delivery guarantees (at-most-once, at-least-once, exactly-once)
  - Dead-letter queue strategies
  - Idempotency implementation
  - Event Grid routing patterns
- **Dependencies**: skill-communication-patterns
- **Priority**: P0

---

### skill-saga-workflow-orchestration

- **Scope**: integration
- **Description**: Implement saga patterns and distributed transactions with Azure Durable Functions, Logic Apps, or choreography. ALWAYS use when implementing sagas, distributed transactions, compensation logic, or long-running workflows. Triggers: "saga pattern", "distributed transaction", "Durable Functions", "Logic Apps", "compensation", "orchestration", "choreography", "workflow", "long-running process", "fan-out fan-in", "function chaining". Critical for multi-step business processes.
- **Articles**:
  - Article XVIII-B: Workflow Orchestration & Saga Patterns (complex, multiple sections)
- **Justification**: Saga pattern manages distributed transactions, critical for multi-step business processes
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure durable functions", "azure logic apps", "saga pattern", "compensation logic"
  - context7: "MassTransit", "NServiceBus"
- **Code Examples**:
  1. Durable Functions orchestration saga
  2. Orchestration-based saga with compensation
  3. Choreography-based saga (event-driven)
  4. Logic Apps Standard workflow
  5. Function chaining pattern
  6. Fan-out/fan-in pattern
- **Skill Sections**:
  - Orchestration tool selection (Durable Functions, Logic Apps, Service Bus choreography)
  - Saga patterns (Orchestration-based, Choreography-based)
  - Durable Functions patterns (Function Chaining, Fan-Out/Fan-In, Async HTTP, Monitor)
  - Compensation logic for rollbacks
  - Long-running workflows
  - Trade-offs (Orchestration vs Choreography)
- **Dependencies**: skill-event-driven-architecture
- **Priority**: P0

---

### skill-frontend-framework-selection

- **Scope**: frontend
- **Description**: Choose frontend framework (React, Angular, Vue, Blazor) and mobile framework (.NET MAUI, React Native, Flutter). ALWAYS use when selecting frontend tech, building SPAs, or implementing mobile apps. Triggers: "frontend framework", "React", "Angular", "Vue", "Blazor", ".NET MAUI", "React Native", "Flutter", "SPA", "mobile app", "cross-platform", "frontend architecture", "UI framework". Critical decision affecting entire frontend stack.
- **Articles**:
  - Article II (Section 2.2): Frontend Framework 🔴 CRITICAL
  - Article II (Section 2.3): Mobile Application 🔴 CRITICAL
- **Justification**: Frontend framework choice (React vs Angular vs Vue vs Blazor) = complete rewrite if changed
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "react azure", "angular azure", "vue.js azure", "blazor webassembly", "blazor server", ".net maui", "react native azure"
  - context7: "React", "Angular", "Vue.js", "React Native", "Flutter"
- **Code Examples**:
  1. React SPA with TypeScript setup
  2. Angular application structure
  3. Vue.js 3 composition API
  4. Blazor WebAssembly authentication
  5. .NET MAUI cross-platform app
  6. React Native app structure
- **Skill Sections**:
  - Frontend framework comparison (React, Angular, Vue, Blazor)
  - Mobile framework comparison (.NET MAUI, React Native, Flutter, Blazor Hybrid)
  - Decision matrix (team expertise, ecosystem, performance, TypeScript support)
  - Azure hosting (Static Web Apps, App Service)
  - Authentication integration per framework
- **Dependencies**: skill-identity-provider-selection
- **Priority**: P0

---

### skill-environment-configuration-strategy

- **Scope**: common (transversal)
- **Description**: Manage environment configuration, secrets, and feature flags across dev/uat/pre/prod with Azure App Configuration and Key Vault. ALWAYS use when implementing configuration management, environment strategy, secrets handling, or feature flags. Triggers: "environment config", "App Configuration", "Key Vault", "secrets management", "feature flags", "environment variables", "configuration", "dev uat prod", "appsettings", ".env files", "User Secrets", "LaunchDarkly". Transversal - applies to ALL projects.
- **Articles**:
  - Article X: Environments & Configuration 🔄 🟡 IMPORTANT (transversal - all scopes)
- **Justification**: Transversal article affecting all scopes - environment strategy and configuration management
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure app configuration", "azure key vault", "environment variables azure", "feature flags azure"
  - context7: "LaunchDarkly", "Unleash"
- **Code Examples**:
  1. Azure App Configuration setup
  2. Key Vault secret retrieval (.NET, Node.js)
  3. User Secrets for local dev (.NET)
  4. .env files for Node.js
  5. Feature flag implementation (Azure App Configuration, LaunchDarkly)
- **Skill Sections**:
  - Environment strategy (dev, uat, pre, prod)
  - Configuration management (App Configuration, Environment Variables, appsettings/env files)
  - Secrets management (Key Vault, User Secrets, env files)
  - Feature flags (Azure App Configuration, LaunchDarkly, Unleash)
  - Environment-specific configuration patterns
- **Dependencies**: None (transversal foundational)
- **Priority**: P0

---

### skill-cicd-pipeline-azure

- **Scope**: common (transversal)
- **Description**: Build CI/CD pipelines with GitHub Actions or Azure DevOps for build, test, and deployment automation. ALWAYS use when implementing CI/CD, deployment pipelines, GitHub Actions, or Azure DevOps workflows. Triggers: "CI/CD", "pipeline", "GitHub Actions", "Azure DevOps", "deployment", "blue-green", "canary deployment", "infrastructure pipeline", "build automation", "continuous integration", "continuous deployment", "GitFlow", "trunk-based". Transversal - required for ALL projects.
- **Articles**:
  - Article XI: CI/CD Pipeline 🔄 🟡 IMPORTANT (transversal - all scopes)
- **Justification**: Transversal article affecting all scopes - CI/CD platform and pipeline configuration
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "github actions azure", "azure devops pipelines", "deployment slots azure", "blue green deployment", "canary deployment"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. GitHub Actions workflow (build, test, deploy)
  2. Azure DevOps Pipeline YAML
  3. Multi-stage pipeline (CI + CD)
  4. Blue-Green deployment with slots
  5. Canary deployment pattern
  6. Infrastructure pipeline (IaC validation, deployment)
- **Skill Sections**:
  - CI/CD platform selection (GitHub Actions, Azure DevOps)
  - Pipeline stages (build, lint, test, security scan, container scan)
  - Deployment strategies (Rolling Update, Blue-Green, Canary, Feature Flags)
  - Branch strategy (GitFlow, GitHub Flow, Trunk-Based)
  - Environment promotion (dev → uat → pre → prod)
  - Infrastructure pipelines (IaC lint, validation, what-if, deployment)
- **Dependencies**: skill-environment-configuration-strategy, skill-iac-tool-selection
- **Priority**: P0

---

### skill-observability-azure

- **Scope**: common (transversal)
- **Description**: Implement observability with Application Insights, Azure Monitor, OpenTelemetry, and health checks. ALWAYS use when implementing monitoring, logging, tracing, health checks, or observability. Triggers: "observability", "Application Insights", "Azure Monitor", "OpenTelemetry", "health checks", "monitoring", "logging", "tracing", "metrics", "KQL", "Log Analytics", "telemetry", "APM", "distributed tracing". Transversal - critical for ALL production systems.
- **Articles**:
  - Article XII: Observability 🔄 🟡 IMPORTANT (transversal - all scopes)
- **Justification**: Transversal article affecting all scopes - observability strategy and health checks
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure monitor", "application insights", "log analytics", "opentelemetry azure", "kusto query language"
  - context7: "OpenTelemetry", "Grafana", "Prometheus"
- **Code Examples**:
  1. Application Insights instrumentation (.NET, Node.js)
  2. OpenTelemetry SDK setup with Azure Monitor exporter
  3. Custom metrics and traces
  4. Health check endpoints (ASP.NET Core, Express.js)
  5. KQL queries for log analysis
  6. Grafana + Loki + Tempo setup (self-hosted alternative)
- **Skill Sections**:
  - Observability strategy (Azure-Native, OpenTelemetry → Azure, OpenTelemetry → Grafana)
  - Application Insights best practices
  - OpenTelemetry instrumentation
  - Health checks (/health, /health/ready, /health/live)
  - Log Analytics and KQL queries
  - Alerting and dashboards
- **Dependencies**: skill-environment-configuration-strategy
- **Priority**: P0

---

### skill-security-policies-azure

- **Scope**: common (transversal)
- **Description**: Implement network security, data protection, and compliance (GDPR, HIPAA) with VNets, Private Endpoints, WAF, and encryption. ALWAYS use when implementing security, compliance, network isolation, or data protection. Triggers: "security", "compliance", "GDPR", "HIPAA", "VNet", "Private Endpoint", "WAF", "encryption", "TLS", "network security", "data protection", "PII", "Azure Policy", "security baseline". Transversal - mandatory for ALL production systems.
- **Articles**:
  - Article XVI: Security Policies 🔄 🟡 IMPORTANT (transversal - all scopes)
- **Justification**: Transversal article affecting all scopes - network security, data protection, compliance
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure virtual network", "azure private endpoints", "azure front door waf", "encryption at rest azure", "tls azure", "gdpr azure", "hipaa azure"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. VNet setup with subnets
  2. Private Endpoints for PaaS services
  3. Azure Front Door with WAF rules
  4. Customer-managed keys (Key Vault)
  5. TLS 1.2+ enforcement
  6. PII masking and anonymization
- **Skill Sections**:
  - Network security (VNet, Private Endpoints, WAF)
  - Data protection (encryption at rest, in transit, PII handling)
  - Compliance requirements (GDPR, HIPAA, SOC 2, PCI-DSS)
  - Security baselines per compliance standard
  - Azure Policy for compliance enforcement
- **Dependencies**: None (transversal foundational)
- **Priority**: P0

---

## P1: High-Priority Skills

### skill-caching-strategy

- **Scope**: backend
- **Description**: Implement L1 (in-memory), L2 (distributed Redis), and L3 (CDN) caching with cache-aside and other patterns. ALWAYS use when implementing caching, Redis, CDN, or cache patterns. Triggers: "caching", "cache", "Redis", "IMemoryCache", "distributed cache", "CDN", "cache-aside", "read-through", "write-through", "cache invalidation", "Azure Cache", "cache pattern", "performance optimization". Important for performance.
- **Articles**: Article VI: Caching Strategy 🟡 IMPORTANT
- **Justification**: Caching affects performance but patterns can be added incrementally
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure cache for redis", "in-memory caching dotnet", "azure cdn", "azure front door cdn", "cache patterns"
  - context7: "Redis", "node-cache"
- **Code Examples**:
  1. IMemoryCache usage (.NET)
  2. node-cache usage (Node.js)
  3. Azure Cache for Redis (distributed cache)
  4. CDN configuration
  5. Cache-aside pattern
  6. Read-through/write-through patterns
- **Skill Sections**:
  - Cache levels (L1 in-memory, L2 distributed, L3 CDN)
  - Distributed cache selection (Azure Redis, Redis self-hosted)
  - Cache patterns (Cache-Aside, Read-Through, Write-Through, Write-Behind)
  - TTL strategies
  - Cache invalidation patterns
- **Dependencies**: skill-database-selection
- **Priority**: P1

---

### skill-gitops-declarative-deployment

- **Scope**: cloud-platform
- **Description**: Implement GitOps with Flux or ArgoCD for declarative Kubernetes deployments, image automation, and Sealed Secrets. ALWAYS use when implementing GitOps, Flux, ArgoCD, or declarative K8s deployments. Triggers: "GitOps", "Flux", "ArgoCD", "declarative deployment", "git workflow", "Sealed Secrets", "GitRepository", "Kustomization", "Image Automation", "continuous reconciliation", "git as source of truth". Production best practice for Kubernetes.
- **Articles**: Article XIV: GitOps & Declarative Deployment (complex, many sections)
- **Justification**: GitOps is production best practice for Kubernetes/Container deployments but adds complexity
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "gitops flux azure", "gitops argocd", "aks gitops", "flux extension aks"
  - context7: "Flux", "ArgoCD"
- **Code Examples**:
  1. Flux bootstrap on AKS
  2. GitRepository source configuration
  3. Kustomization for app deployment
  4. Flux Image Automation (ACR scanning)
  5. ArgoCD Application manifest
  6. Sealed Secrets for secret management
- **Skill Sections**:
  - GitOps tool selection (Flux, ArgoCD)
  - GitOps repository structure (mono-repo, multi-repo)
  - Git workflow (PR promotion, branch-based)
  - Flux configuration (Source, Kustomize, Helm, Notification, Image controllers)
  - Secrets management (Sealed Secrets, External Secrets Operator, SOPS)
  - Monitoring and alerting
  - Rollback strategies (Git revert, Time Travel)
- **Dependencies**: skill-container-orchestration, skill-iac-tool-selection
- **Priority**: P1

---

### skill-ml-training-deployment

- **Scope**: ai
- **Description**: Train and deploy ML models with Azure Machine Learning, AutoML, and managed endpoints (online, batch, serverless). ALWAYS use when training models, deploying ML inference, or implementing MLOps. Triggers: "Azure ML", "AutoML", "model training", "managed endpoint", "batch endpoint", "serverless inference", "ML deployment", "model inference", "PyTorch", "TensorFlow", "scikit-learn", "online endpoint". High priority for production ML.
- **Articles**:
  - Article XIII (Section 13.2): ML Training Strategy 🟡 IMPORTANT
  - Article XIII (Section 13.4): Inference Deployment Pattern 🟡 IMPORTANT
- **Justification**: ML training and deployment patterns are important for production ML but have reasonable defaults
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure machine learning", "automl azure", "managed online endpoints", "batch endpoints", "serverless inference azure"
  - context7: "scikit-learn", "PyTorch", "TensorFlow"
- **Code Examples**:
  1. AutoML training job
  2. Custom training with Python SDK (scikit-learn, PyTorch)
  3. Managed online endpoint deployment
  4. Batch endpoint for bulk scoring
  5. Serverless inference configuration
- **Skill Sections**:
  - ML training strategies (AutoML, Custom Training, Transfer Learning, Fine-tuning)
  - Inference deployment patterns (Managed Online, Batch, Serverless, Container Instances, Edge)
  - Real-time vs batch trade-offs
  - Model deployment best practices
  - A/B testing and blue-green for models
- **Dependencies**: skill-ai-architecture-patterns
- **Priority**: P1

---

### skill-prompt-engineering-orchestration

- **Scope**: ai
- **Description**: Orchestrate LLM applications with Prompt Flow, LangChain, or Semantic Kernel for prompt management and agent patterns. ALWAYS use when implementing LLM orchestration, prompt engineering, AI agents, or tool calling. Triggers: "Prompt Flow", "LangChain", "Semantic Kernel", "prompt engineering", "LLM orchestration", "AI agent", "tool calling", "prompt template", "ReAct", "agent pattern", "LLM application". Important for LLM-based applications.
- **Articles**: Article XIII (Section 13.6): Prompt Engineering & Orchestration 🟡 IMPORTANT
- **Justification**: Orchestration framework affects development patterns but not core architecture
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "prompt flow azure", "langchain azure openai", "semantic kernel", "prompt engineering azure openai"
  - context7: "LangChain", "Semantic Kernel"
- **Code Examples**:
  1. Prompt Flow workflow (visual designer)
  2. LangChain agent with tools (Python)
  3. Semantic Kernel planner (.NET)
  4. Manual prompt templates
  5. Prompt registry with versioning
- **Skill Sections**:
  - Orchestration framework selection (Prompt Flow, LangChain, Semantic Kernel, Manual)
  - Prompt engineering best practices
  - Tool calling and function integration
  - Prompt management (registry, versioning)
  - Agent patterns (ReAct, Self-Ask, Plan-and-Execute)
  - Trade-offs (Prompt Flow vs LangChain)
- **Dependencies**: skill-ai-architecture-patterns
- **Priority**: P1

---

### skill-mlops-model-governance

- **Scope**: ai
- **Description**: Implement MLOps with Azure ML model registry, MLflow tracking, versioning, and CI/CD for ML pipelines. ALWAYS use when implementing model governance, experiment tracking, model versioning, or MLOps workflows. Triggers: "MLOps", "model registry", "MLflow", "experiment tracking", "model versioning", "ML pipeline", "model lineage", "model promotion", "ML CI/CD", "model governance". Critical for production ML systems.
- **Articles**: Article XIII (Section 13.7): Model Governance & MLOps 🟡 IMPORTANT
- **Justification**: Model governance is critical for production but tooling can evolve
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "azure ml model registry", "mlflow tracking", "mlops azure", "azure ml pipelines"
  - context7: "MLflow"
- **Code Examples**:
  1. Azure ML model registration
  2. MLflow experiment tracking
  3. Model versioning and tagging
  4. CI/CD for ML pipelines (Azure DevOps, GitHub Actions)
  5. Model deployment history
- **Skill Sections**:
  - Model registry selection (Azure ML, MLflow, Git-based)
  - Model versioning and lineage
  - CI/CD for ML pipelines
  - Experiment tracking
  - Model promotion (dev → prod)
  - Audit trail and compliance
- **Dependencies**: skill-ml-training-deployment
- **Priority**: P1

---

### skill-responsible-ai-practices

- **Scope**: ai
- **Description**: Implement Responsible AI with fairness testing (Fairlearn), interpretability (SHAP, LIME), content safety, and model monitoring. ALWAYS use when implementing AI ethics, fairness, interpretability, content moderation, or model monitoring. Triggers: "Responsible AI", "fairness", "Fairlearn", "interpretability", "SHAP", "LIME", "Azure AI Content Safety", "model monitoring", "drift detection", "Model Cards", "AI ethics", "bias detection". Important for compliance and ethics.
- **Articles**: Article XIII (Section 13.8): Responsible AI Practices 🟡 IMPORTANT
- **Justification**: Responsible AI is critical for compliance but practices can be added incrementally
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "responsible ai azure", "azure ai content safety", "fairness fairlearn", "model interpretability azure ml"
  - context7: "SHAP", "LIME", "Fairlearn"
- **Code Examples**:
  1. Fairness dashboard with Fairlearn
  2. SHAP explainability integration
  3. Azure AI Content Safety API
  4. Model monitoring (drift detection)
  5. Model Cards template
  6. Prompt injection protection
- **Skill Sections**:
  - Fairness assessment (Fairlearn, Fairness 360)
  - Interpretability (SHAP, LIME, InterpretML)
  - Model monitoring (drift detection, performance degradation)
  - Model Cards and Datasheets
  - Azure AI Content Safety integration
  - Human-in-the-loop patterns
  - Prompt injection mitigation
- **Dependencies**: skill-ml-training-deployment
- **Priority**: P1

---

### skill-multi-agent-architectures

- **Scope**: ai
- **Description**: Design multi-agent systems with Microsoft Agent Framework, Semantic Kernel, or LangGraph for complex AI workflows. ALWAYS use when implementing multi-agent systems, agent orchestration, or collaborative AI. Triggers: "multi-agent", "agent orchestration", "Microsoft Agent Framework", "Semantic Kernel agents", "LangGraph", "AutoGen", "agent collaboration", "handoff pattern", "group chat", "magentic", "agent coordination". High complexity - use when single agent insufficient.
- **Articles**: Article XIV: Multi-Agent Architectures & Orchestration 🟡 IMPORTANT (complex)
- **Justification**: Multi-agent decision affects complexity but can start simple and evolve
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "microsoft agent framework", "semantic kernel agents", "multi agent patterns azure"
  - context7: "LangChain", "LangGraph", "AutoGen"
- **Code Examples**:
  1. Microsoft Agent Framework sequential orchestration
  2. Concurrent orchestration (fan-out/fan-in)
  3. Group Chat (collaborative)
  4. Handoff pattern (escalation)
  5. Magentic pattern (dynamic planning)
  6. Semantic Kernel agents
- **Skill Sections**:
  - When to use multi-agent (decision tree)
  - Multi-agent orchestration patterns (Sequential, Concurrent, Group Chat, Handoff, Magentic)
  - Agent framework selection (Microsoft Agent Framework, Semantic Kernel, LangChain/LangGraph, Foundry Agent Service)
  - State management across agents
  - Human-in-the-loop integration
  - Multi-agent testing and validation
  - Cost optimization
  - Observability and tracing
- **Dependencies**: skill-prompt-engineering-orchestration
- **Priority**: P1

---

### skill-medallion-architecture

- **Scope**: data
- **Description**: Implement medallion architecture (Bronze→Silver→Gold) with Delta Lake for data lakehouse patterns. ALWAYS use when implementing data lake layers, Delta Lake, or medallion architecture. Triggers: "medallion architecture", "bronze silver gold", "Delta Lake", "data lakehouse", "bronze layer", "silver layer", "gold layer", "data quality", "DLT", "data transformation", "ACID transactions", "time travel". Standard pattern for modern data platforms.
- **Articles**: Article VI: Medallion Architecture Implementation 🟡 IMPORTANT
- **Justification**: Medallion (Bronze/Silver/Gold) is a complex pattern but well-documented for modern data platforms
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "medallion architecture", "delta lake bronze silver gold", "databricks medallion", "fabric medallion"
  - context7: "Delta Lake", "Apache Spark"
- **Code Examples**:
  1. Bronze layer ingestion (raw data preservation)
  2. Silver layer transformation (validation, deduplication, enrichment)
  3. Gold layer curation (dimensional modeling, aggregations)
  4. Delta Lake ACID operations
  5. Data quality checks (DLT Expectations)
- **Skill Sections**:
  - Medallion architecture overview (Bronze → Silver → Gold)
  - Bronze layer patterns (append-only, schema-on-read, metadata enrichment)
  - Silver layer transformations (quality checks, deduplication, SCD, joins)
  - Gold layer design (dimensional modeling, aggregations, optimization)
  - Delta Lake features (ACID, time travel, schema enforcement)
  - Data retention policies per layer
- **Dependencies**: skill-data-platform-selection
- **Priority**: P1

---

### skill-data-governance-quality

- **Scope**: data
- **Description**: Implement data governance with Microsoft Purview, Unity Catalog, data lineage, quality checks, and compliance. ALWAYS use when implementing data governance, data quality, lineage, or compliance controls. Triggers: "data governance", "Purview", "Unity Catalog", "data lineage", "data quality", "data classification", "RLS", "column-level security", "data catalog", "compliance", "GDPR data", "data masking". Mandatory for production data platforms.
- **Articles**: Article VIII: Data Governance & Quality (complex)
- **Justification**: Governance is mandatory for production but can be implemented incrementally
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "microsoft purview", "unity catalog databricks", "data lineage azure", "data quality azure"
  - context7: "Great Expectations", "Unity Catalog"
- **Code Examples**:
  1. Purview data map and lineage
  2. Unity Catalog fine-grained ACLs
  3. Data quality checks (DLT Expectations, Great Expectations)
  4. Data classification and sensitivity labels
  5. Dynamic data masking
  6. Audit logging (Unity Catalog, Purview)
- **Skill Sections**:
  - Data governance platform selection (Purview, Unity Catalog, Hybrid)
  - Data quality framework (ISO 8000 dimensions)
  - Data lineage and impact analysis
  - Data classification and sensitivity
  - Access control and auditing (RBAC, ABAC, RLS, column-level security)
  - Compliance reporting (GDPR, HIPAA)
- **Dependencies**: skill-medallion-architecture
- **Priority**: P1

---

### skill-dataops-cicd

- **Scope**: data
- **Description**: Implement DataOps CI/CD with Fabric Git, Databricks Repos, pipeline testing, and automated deployments. ALWAYS use when implementing data pipeline CI/CD, testing data workflows, or deploying data platforms. Triggers: "DataOps", "data pipeline CI/CD", "Fabric Git", "Databricks Repos", "data pipeline testing", "pytest PySpark", "Great Expectations", "Databricks Asset Bundles", "data deployment", "pipeline automation". Production best practice for data engineering.
- **Articles**: Article X: DataOps & CI/CD for Data Platforms (complex)
- **Justification**: DataOps is production best practice but adds significant complexity
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "fabric git integration", "databricks repos", "data pipeline testing", "deployment pipelines fabric"
  - context7: "pytest", "Great Expectations"
- **Code Examples**:
  1. Fabric Git integration and deployment pipelines
  2. Databricks Repos setup
  3. Unit tests for transformations (pytest, PySpark)
  4. Integration tests (full pipeline on sample data)
  5. CI pipeline for data pipelines (lint, test, validate)
  6. CD deployment (Fabric REST APIs, Databricks Asset Bundles)
- **Skill Sections**:
  - Source control strategy (Fabric Git, Databricks Repos, Azure DevOps, GitHub)
  - Branching strategy (GitFlow, GitHub Flow, Trunk-Based)
  - Continuous Integration for data pipelines (linting, unit tests, data quality tests)
  - Continuous Deployment (Fabric Deployment Pipelines, Databricks Asset Bundles, Terraform)
  - Environment configuration (dev, test, prod)
  - Data pipeline testing (unit, integration, data quality)
  - Monitoring and observability
  - Rollback and disaster recovery
- **Dependencies**: skill-medallion-architecture, skill-cicd-pipeline-azure
- **Priority**: P1

---

### skill-api-management-azure

- **Scope**: integration
- **Description**: Implement API Management with Azure APIM for API gateway, rate limiting, versioning, and documentation. ALWAYS use when implementing API gateway, APIM policies, rate limiting, or API versioning. Triggers: "API Management", "APIM", "API gateway", "rate limiting", "API versioning", "OpenAPI", "Swagger", "API policies", "API security", "API documentation", "API portal". Important for API governance and production APIs.
- **Articles**: Article XVIII: API Management (sections 18.1, 18.2, 18.3)
- **Justification**: API Management is production best practice for API governance and security
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure api management", "apim policies", "api versioning", "rate limiting apim", "openapi azure"
  - context7: "OpenAPI", "Swagger"
- **Code Examples**:
  1. APIM deployment (Bicep)
  2. API import from OpenAPI spec
  3. Rate limiting policies
  4. API versioning (URL path, header, query string)
  5. OAuth2 authentication in APIM
  6. APIM diagnostic logging
- **Skill Sections**:
  - API Gateway selection (APIM, Azure Front Door, YARP)
  - APIM policies (rate limiting, caching, transformation, authentication)
  - API versioning strategies
  - API documentation (OpenAPI/Swagger, AsyncAPI)
  - API security (OAuth2, API keys, IP filtering)
  - API monitoring and analytics
- **Dependencies**: skill-communication-patterns, skill-identity-provider-selection
- **Priority**: P1

---

### skill-schema-validation-contract-testing

- **Scope**: integration
- **Description**: Implement schema validation with Azure Schema Registry and consumer-driven contract testing with Pact. ALWAYS use when implementing schema validation, contract testing, Avro schemas, or API contracts. Triggers: "schema validation", "contract testing", "Schema Registry", "Avro", "Pact", "consumer-driven", "schema evolution", "breaking changes", "API contract", "Protobuf", "JSON Schema". Important for microservices integration.
- **Articles**: Article XVIII-C: Schema Validation & Contract Testing (complex)
- **Justification**: Contract testing prevents breaking changes in microservices but requires discipline
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure schema registry", "avro schema", "json schema", "consumer driven contract testing"
  - context7: "Pact", "OpenLineage"
- **Code Examples**:
  1. Azure Schema Registry (Event Hubs)
  2. Avro schema registration and validation
  3. Pact consumer test (defining contract)
  4. Pact provider test (verifying contract)
  5. API versioning with APIM
- **Skill Sections**:
  - Azure Schema Registry setup (supported formats: Avro, JSON Schema, Protobuf)
  - Schema evolution rules (forward compatible, backward compatible, breaking changes)
  - Consumer-Driven Contract Testing (Pact)
  - Pact workflow (consumer test → Pact Broker → provider verification)
  - API versioning strategies (URL path, header, query string, content negotiation)
  - Schema Registry integration with Event Hubs
- **Dependencies**: skill-event-driven-architecture, skill-api-management-azure
- **Priority**: P1

---

### skill-dynamics-power-platform

- **Scope**: crm
- **Description**: Build solutions with Dynamics 365, Power Apps, Power Automate, Power Pages, Dataverse, and Copilot Studio. ALWAYS use when implementing Dynamics 365, Power Platform, Dataverse, or low-code solutions. Triggers: "Dynamics 365", "Power Apps", "Power Automate", "Power Pages", "Dataverse", "Copilot Studio", "model-driven app", "canvas app", "cloud flow", "PCF", "Power Platform", "low-code", "CRM". Specialized for Microsoft business applications.
- **Articles**: Proposed Additions 🆕 - Dynamics 365, Power Platform, Dataverse, Power Apps, Power Automate, Power Pages, Copilot Studio
- **Justification**: CRM scope needs dedicated skill for Microsoft Dynamics 365 and Power Platform ecosystem
- **Complexity**: High
- **MCP Sources**:
  - microsoftdocs: "dynamics 365", "power platform", "dataverse", "power apps", "power automate", "power pages", "copilot studio", "power platform alm"
  - context7: N/A (Microsoft-specific)
- **Code Examples**:
  1. Dataverse custom entity creation
  2. Model-driven app configuration
  3. Canvas app with Power Apps Component Framework (PCF)
  4. Cloud Flow (approval workflow)
  5. Power Pages external portal
  6. Copilot Studio chatbot with Dataverse integration
- **Skill Sections**:
  - Dynamics 365 modules (Sales, Customer Service, Field Service)
  - Dataverse data model (entities, relationships, choice columns, business rules)
  - Power Apps (Canvas Apps, Model-Driven Apps, PCF controls)
  - Power Automate (Cloud Flows, Desktop Flows RPA)
  - Power Pages (external portals, web roles, table permissions)
  - Copilot Studio (conversational AI)
  - Power Platform ALM (environments, solutions, environment variables, CI/CD)
  - Security (Business Units, Security Roles, Field-Level Security, Row-Level Security)
- **Dependencies**: skill-identity-provider-selection, skill-cicd-pipeline-azure
- **Priority**: P1

---

### skill-work-item-synchronization

- **Scope**: work-management
- **Description**: Synchronize Bolt Framework artifacts with Azure DevOps, GitHub Projects, or Jira for traceability and reporting. ALWAYS use when implementing work item sync, Bolt traceability, or integrating with Azure DevOps/GitHub/Jira. Triggers: "work item sync", "Azure DevOps", "GitHub Projects", "Jira", "Bolt traceability", "feature to epic", "spec to work item", "traceability chain", "work management", "project tracking". Critical for Bolt Framework governance.
- **Articles**: Proposed Additions 🆕 - BOLT Framework Artefact-to-Work-Item Mapping, Synchronization Strategy, Azure DevOps/GitHub/Jira Configuration
- **Justification**: Work management sync is critical for BOLT Framework traceability and audit
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure devops boards", "github projects", "azure devops rest api", "github projects api"
  - context7: "Jira REST API"
- **Code Examples**:
  1. Azure DevOps work item creation (REST API)
  2. GitHub Projects v2 item creation (GraphQL)
  3. Jira issue creation (REST API)
  4. Spec → Work Item sync (push)
  5. Work Item → Spec sync (pull)
  6. Dependency link creation
- **Skill Sections**:
  - BOLT artefact to work item mapping (Feature → Epic, Use Case → Story, Bolt → Sprint, Task → Task)
  - Work management platform selection (Azure DevOps, GitHub Projects, Jira, Hybrid)
  - Synchronization strategy (push, pull, bidirectional)
  - Azure DevOps configuration (custom fields, area paths, iteration paths, queries, dashboards)
  - GitHub Projects v2 configuration (custom fields, views, automations, labels)
  - Traceability chain (Spec → Work Item → Branch → Commit → PR → CI/CD → Release)
  - Dependency management (intra-feature, cross-feature, cross-scope)
  - Reporting and metrics (velocity, lead time, cycle time, WIP limit, traceability coverage)
- **Dependencies**: skill-cicd-pipeline-azure
- **Priority**: P1

---

### skill-testing-frameworks-backend

- **Scope**: backend
- **Description**: Implement testing with xUnit, Jest, Testcontainers, NetArchTest, Reqnroll, and Playwright for comprehensive test coverage. ALWAYS use when implementing unit tests, integration tests, E2E tests, or architecture tests. Triggers: "testing", "xUnit", "Jest", "Vitest", "Testcontainers", "integration testing", "NetArchTest", "Reqnroll", "Playwright", "E2E testing", "architecture testing", "test framework". Important for test strategy and quality.
- **Articles**: Article XIII (Section 13.2, 13.3): Testing Frameworks 🟡 IMPORTANT
- **Justification**: Framework choice affects project structure and test patterns
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "xunit dotnet", "testcontainers dotnet", "netarchtest", "specflow reqnroll", "playwright", "nbomber"
  - context7: "xUnit", "NUnit", "Jest", "Vitest", "Testcontainers", "Playwright", "Cypress"
- **Code Examples**:
  1. xUnit unit test (.NET)
  2. Integration test with Testcontainers (.NET)
  3. NetArchTest architecture test
  4. Reqnroll BDD scenario (.NET)
  5. Playwright E2E test
  6. Jest unit test (Node.js/TypeScript)
- **Skill Sections**:
  - Testing framework selection per stack (xUnit, Jest, Vitest)
  - Integration testing with Testcontainers
  - Architecture testing (NetArchTest, dependency-cruiser)
  - BDD/Gherkin (SpecFlow/Reqnroll, Cucumber.js)
  - E2E testing (Playwright, Cypress)
  - Performance testing (NBomber, k6, Artillery)
  - Test project structure
- **Dependencies**: None (foundational)
- **Priority**: P1

---

## P2: Medium-Priority Skills

### skill-database-migrations

- **Scope**: backend
- **Description**: Implement database migrations with EF Core Migrations, Prisma Migrate, TypeORM, DbUp, or FluentMigrator. Use when implementing database migrations, schema versioning, or zero-downtime deployments. Triggers: "database migrations", "EF Core Migrations", "Prisma Migrate", "TypeORM migrations", "DbUp", "FluentMigrator", "schema changes", "migration rollback", "zero-downtime", "database versioning". Medium priority - has reasonable defaults.
- **Articles**: Article V (Section 5.3): Database Migrations 🟢 LOW-PRIO
- **Justification**: Migration tool choice is low-priority with reasonable defaults
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "entity framework core migrations", "dbup", "fluentmigrator", "prisma migrate", "typeorm migrations"
  - context7: "Prisma", "TypeORM", "Knex.js"
- **Code Examples**:
  1. EF Core migration creation and application
  2. DbUp SQL script execution
  3. FluentMigrator fluent API
  4. Prisma Migrate declarative migrations
  5. TypeORM migration files
- **Skill Sections**:
  - Migration tool selection per stack
  - Code-first vs database-first migrations
  - Migration versioning and rollback
  - Zero-downtime migrations
  - Migration testing
- **Dependencies**: skill-database-selection
- **Priority**: P2

---

### skill-code-standards-formatting

- **Scope**: backend, frontend, common
- **Description**: Configure code standards, naming conventions, and automated formatting with ESLint, Prettier, EditorConfig, and dotnet format. Use when setting up linting, code formatting, pre-commit hooks, or code standards. Triggers: "code standards", "formatting", "linting", "ESLint", "Prettier", "EditorConfig", "dotnet format", "naming conventions", "code style", "pre-commit hooks", "husky", "lint-staged". Medium priority - enforced by tooling.
- **Articles**:
  - Article XIV: Code Standards 🟢 LOW-PRIO (backend, frontend)
  - Article XXI: Documentation Standards (common - EXISTING SKILL: markdown-formatting)
- **Justification**: Code formatting is enforced by linters, easy to change
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "editorconfig", "dotnet format", "eslint", "prettier"
  - context7: "ESLint", "Prettier", "Black", "Flake8"
- **Code Examples**:
  1. .editorconfig file
  2. .eslintrc.json configuration
  3. .prettierrc configuration
  4. dotnet format command
  5. Pre-commit hooks (husky, lint-staged)
- **Skill Sections**:
  - Naming conventions per stack (C#, TypeScript, Python)
  - Code formatting settings (indentation, line length, quotes)
  - Linter configuration (ESLint, dotnet format, Flake8)
  - Formatter configuration (Prettier, Black)
  - Pre-commit hooks for automated formatting
- **Dependencies**: None (foundational)
- **Priority**: P2

---

### skill-legacy-migration-patterns

- **Scope**: backend, frontend, integration
- **Description**: Implement legacy modernization with Strangler Fig, Branch by Abstraction, and incremental migration patterns. Use when migrating legacy systems, modernizing applications, or implementing gradual cutover. Triggers: "legacy migration", "Strangler Fig", "strangler pattern", "Branch by Abstraction", "modernization", "incremental migration", "gradual cutover", "YARP proxy", "migration strategy", "brownfield". Important for modernization projects.
- **Articles**: Article XVII: Legacy & Migration 🟡 IMPORTANT
- **Justification**: Migration strategy affects implementation approach and timeline
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "strangler fig pattern", "branch by abstraction", "legacy modernization azure"
  - context7: N/A (architectural patterns)
- **Code Examples**:
  1. Strangler Fig proxy setup (YARP, Envoy)
  2. Branch by Abstraction interface
  3. Feature flag for gradual cutover
  4. Migration dashboard (progress tracking)
- **Skill Sections**:
  - Migration context (Greenfield, Brownfield, Legacy Migration, Strangler Fig)
  - Migration strategies (Big Bang, Strangler Fig, Branch by Abstraction)
  - Incremental migration patterns
  - Feature flags for gradual cutover
  - Legacy system integration patterns
  - Risk mitigation strategies
- **Dependencies**: skill-architecture-patterns, skill-communication-patterns
- **Priority**: P2

---

### skill-feature-flags-progressive-delivery

- **Scope**: common (transversal)
- **Description**: Implement feature flags and progressive delivery with Azure App Configuration, LaunchDarkly, or Unleash. Use when implementing feature toggles, progressive delivery, or A/B testing. Triggers: "feature flags", "feature toggles", "LaunchDarkly", "Unleash", "progressive delivery", "canary release", "percentage rollout", "kill switch", "A/B testing", "feature management". Valuable for progressive delivery.
- **Articles**: Article X (Section 10.4): Feature Flags 🟢 LOW-PRIO (transversal)
- **Justification**: Feature flags are low-priority initially but valuable for progressive delivery
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "azure app configuration feature flags", "launchdarkly", "unleash"
  - context7: "LaunchDarkly", "Unleash"
- **Code Examples**:
  1. Azure App Configuration feature flag creation
  2. Feature flag evaluation (.NET, Node.js)
  3. LaunchDarkly SDK integration
  4. Unleash SDK integration
  5. Targeting rules (user segments, percentage rollout)
- **Skill Sections**:
  - Feature flag provider selection (Azure App Configuration, LaunchDarkly, Unleash)
  - Feature flag patterns (kill switch, release toggle, experiment toggle, ops toggle)
  - Targeting and percentage rollout
  - Feature flag management lifecycle
  - Integration with deployment pipelines
  - Feature flag debt management
- **Dependencies**: skill-environment-configuration-strategy
- **Priority**: P2

---

### skill-api-versioning-openapi

- **Scope**: integration
- **Description**: Implement API versioning strategies and OpenAPI/AsyncAPI documentation for REST and event APIs. Use when implementing API versioning, OpenAPI docs, Swagger, or AsyncAPI. Triggers: "API versioning", "OpenAPI", "Swagger", "AsyncAPI", "API documentation", "Swashbuckle", "API deprecation", "version strategy", "header versioning", "URL versioning". Medium priority - has conventions.
- **Articles**: Article XVIII (Section 18.2, 18.3): API Features & Documentation
- **Justification**: API versioning and documentation are important but have reasonable conventions
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "api versioning aspnet core", "openapi swagger", "asyncapi"
  - context7: "Swagger", "OpenAPI", "AsyncAPI"
- **Code Examples**:
  1. ASP.NET Core API versioning (URL path, header)
  2. OpenAPI/Swagger configuration
  3. Swashbuckle annotations
  4. AsyncAPI specification for events
  5. API documentation portal
- **Skill Sections**:
  - API versioning strategies (URL path, header, query string, content negotiation)
  - OpenAPI/Swagger documentation generation
  - AsyncAPI for asynchronous events
  - API documentation portals
  - Deprecation strategies
- **Dependencies**: skill-api-management-azure
- **Priority**: P2

---

### skill-hybrid-integration-connectivity

- **Scope**: integration
- **Description**: Connect on-premises systems with Azure Arc, VPN Gateway, ExpressRoute, and Self-hosted Integration Runtime. Use when implementing hybrid connectivity, on-premises integration, or Azure Arc. Triggers: "hybrid integration", "Azure Arc", "VPN Gateway", "ExpressRoute", "on-premises", "hybrid connectivity", "Self-hosted Integration Runtime", "hybrid connections", "on-prem". Medium priority - only for hybrid scenarios.
- **Articles**: Article XVIII-D: Hybrid Integration & Connectivity (truncated in read, likely complex)
- **Justification**: Hybrid connectivity is important for on-premises integration but not needed for cloud-only
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure arc", "azure vpn gateway", "expressroute", "azure hybrid connections", "self-hosted integration runtime"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. Azure VPN Gateway setup
  2. ExpressRoute configuration
  3. Azure Arc-enabled Kubernetes
  4. Self-hosted Integration Runtime (Data Factory)
  5. Hybrid Connections (App Service, Logic Apps)
- **Skill Sections**:
  - Hybrid connectivity options (VPN Gateway, ExpressRoute, Azure Arc)
  - Self-hosted Integration Runtime for on-premises data sources
  - Hybrid Connections for App Service and Logic Apps
  - Azure Arc for hybrid Kubernetes management
  - Security and compliance for hybrid scenarios
- **Dependencies**: skill-event-driven-architecture, skill-api-management-azure
- **Priority**: P2

---

### skill-data-integration-orchestration

- **Scope**: data
- **Description**: Build data pipelines with Azure Data Factory, Fabric Pipelines, or Databricks Workflows for ETL/ELT and CDC. Use when implementing data pipelines, ETL, ELT, or data orchestration. Triggers: "data pipeline", "ETL", "ELT", "Azure Data Factory", "Fabric Pipelines", "Databricks Workflows", "data integration", "CDC", "change data capture", "data orchestration". Medium priority - standard patterns.
- **Articles**: Article VII: Data Integration & Orchestration (complex, multiple sections)
- **Justification**: Integration patterns are important but have reasonable conventions
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure data factory", "fabric data pipelines", "databricks workflows", "etl elt patterns", "change data capture"
  - context7: "Apache Airflow", "dbt"
- **Code Examples**:
  1. Azure Data Factory pipeline (copy activity, data flow)
  2. Fabric Data Pipeline
  3. Databricks Workflow job
  4. ETL vs ELT pattern comparison
  5. Change Data Capture (CDC) setup
  6. Incremental load with watermark
- **Skill Sections**:
  - Integration platform selection (Azure Data Factory, Fabric Pipelines, Databricks Workflows, Synapse Pipelines)
  - ETL vs ELT patterns
  - Batch ingestion (full load, incremental load, CDC)
  - Streaming ingestion (Event Hubs, Kafka, Structured Streaming)
  - Transformation engine selection (Data Flows, Spark notebooks, SQL, Dataflows Gen2, DLT)
  - Orchestration and scheduling (triggers, dependencies, error handling)
- **Dependencies**: skill-medallion-architecture
- **Priority**: P2

---

### skill-data-performance-optimization

- **Scope**: data
- **Description**: Optimize Delta Lake queries with Z-Ordering, partitioning, OPTIMIZE, VACUUM, and cost management. Use when optimizing data performance, query tuning, or cost optimization. Triggers: "data optimization", "Z-Ordering", "OPTIMIZE", "VACUUM", "Delta Lake performance", "query tuning", "partitioning strategy", "Photon", "data compression", "storage tiering". Medium priority - incremental improvements.
- **Articles**: Article IX: Performance & Cost Optimization (complex)
- **Justification**: Performance optimization is important but can be applied incrementally
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "delta lake optimize", "delta lake z-ordering", "delta lake vacuum", "databricks photon", "fabric capacity monitoring"
  - context7: "Delta Lake", "Apache Spark"
- **Code Examples**:
  1. OPTIMIZE command (file compaction, Z-Ordering)
  2. VACUUM command (old file cleanup)
  3. ANALYZE TABLE statistics collection
  4. Partitioning strategy (date-based, tenant-based, hash-based)
  5. Compression (Zstandard, Snappy)
  6. Storage tiering (Hot, Cool, Archive)
- **Skill Sections**:
  - Query performance optimization (partitioning, Z-Ordering, Bloom filters, data skipping)
  - Compute optimization (Photon, Adaptive Query Execution, autoscaling, Spot VMs)
  - Storage optimization (file size management, compression, tiering)
  - Cost monitoring and optimization
  - Right-sizing clusters
  - Query profiling and tuning
- **Dependencies**: skill-medallion-architecture
- **Priority**: P2

---

### skill-frontend-testing

- **Scope**: frontend
- **Description**: Implement frontend testing with Jest, Vitest, Testing Library, Playwright, and Cypress for unit, component, and E2E tests. Use when implementing frontend tests, component tests, or E2E tests. Triggers: "frontend testing", "Jest", "Vitest", "Testing Library", "Playwright", "Cypress", "component tests", "E2E testing", "visual regression", "React testing", "Vue testing". Medium priority - standard frameworks.
- **Articles**: Article XIII: Testing Standards (Frontend)
- **Justification**: Frontend testing frameworks have reasonable conventions
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "playwright testing", "testing library", "cypress", "jest", "vitest"
  - context7: "Playwright", "Cypress", "Jest", "Vitest", "React Testing Library", "Vue Testing Library"
- **Code Examples**:
  1. Jest unit test for React component
  2. Vitest unit test for Vue component
  3. React Testing Library component test
  4. Playwright E2E test
  5. Cypress E2E test
  6. Lighthouse CI performance test
- **Skill Sections**:
  - Component testing (Testing Library for React/Vue/Angular)
  - Unit testing (Jest, Vitest)
  - E2E testing (Playwright, Cypress)
  - Visual regression testing (Playwright, Chromatic)
  - Performance testing (Lighthouse CI, Web Vitals)
  - Test project structure
- **Dependencies**: skill-frontend-framework-selection
- **Priority**: P2

---

### skill-frontend-performance-accessibility

- **Scope**: frontend
- **Description**: Implement WCAG 2.2 accessibility testing and Core Web Vitals monitoring with Lighthouse CI and axe-core. Use when implementing accessibility, performance budgets, or Core Web Vitals monitoring. Triggers: "accessibility", "WCAG", "a11y", "Lighthouse", "Core Web Vitals", "performance budget", "axe-core", "LCP", "FID", "CLS", "web performance". Medium priority - incremental improvements.
- **Articles**: Proposed Additions 🆕 - Accessibility (WCAG 2.2), Performance Budgets, Core Web Vitals
- **Justification**: Accessibility and performance are important but can be added incrementally
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "web accessibility azure", "wcag 2.2", "lighthouse ci", "core web vitals", "application insights rum"
  - context7: "axe-core", "Lighthouse"
- **Code Examples**:
  1. axe-core accessibility audit
  2. Playwright accessibility testing
  3. Lighthouse CI pipeline
  4. Core Web Vitals monitoring (Application Insights RUM)
  5. Performance budget configuration
- **Skill Sections**:
  - Accessibility testing (WCAG 2.2, axe-core, Playwright a11y audits)
  - Performance budgets (Lighthouse CI thresholds)
  - Core Web Vitals monitoring (LCP, FID, CLS)
  - Application Insights Real User Monitoring
  - Performance optimization (code splitting, lazy loading, image optimization)
- **Dependencies**: skill-frontend-testing, skill-observability-azure
- **Priority**: P2

---

### skill-infrastructure-testing

- **Scope**: cloud-platform
- **Description**: Test infrastructure code with Bicep linter, tflint, Checkov, Pester, and Terratest for security and compliance. Use when implementing IaC testing, security scanning, or policy validation. Triggers: "infrastructure testing", "Bicep linter", "tflint", "Checkov", "tfsec", "Pester", "Terratest", "IaC testing", "policy validation", "security scan", "Infracost". Medium priority - standard testing.
- **Articles**: Article XIII (Section 13.4): Infrastructure Testing
- **Justification**: IaC testing is important but has reasonable conventions
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "bicep linter", "terraform tflint", "checkov", "tfsec", "azure policy", "pester", "terratest"
  - context7: "Checkov", "tfsec", "Terratest"
- **Code Examples**:
  1. Bicep linter rules
  2. tflint configuration (Terraform)
  3. Checkov security scan
  4. Azure Policy what-if validation
  5. Pester integration test (.NET)
  6. Terratest integration test (Go)
- **Skill Sections**:
  - IaC linting (Bicep linter, tflint)
  - Security scanning (Checkov, tfsec)
  - Policy compliance (Azure Policy what-if)
  - Integration testing (Pester, Terratest)
  - Cost estimation (Infracost)
- **Dependencies**: skill-iac-tool-selection
- **Priority**: P2

---

### skill-finops-cost-management

- **Scope**: cloud-platform
- **Description**: Implement FinOps with Azure Cost Management, budgets, cost allocation, and optimization recommendations. Use when implementing cost management, budgets, or cost optimization. Triggers: "FinOps", "cost management", "Azure Cost Management", "budgets", "cost optimization", "cost allocation", "tagging", "chargeback", "showback", "Azure Advisor", "Infracost". Medium priority - incremental optimization.
- **Articles**: Mentioned in multiple contexts but not dedicated article
- **Justification**: FinOps is important for production but can be added incrementally
- **Complexity**: Medium
- **MCP Sources**:
  - microsoftdocs: "azure cost management", "azure advisor", "azure budgets", "cost optimization azure"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. Azure Cost Management API queries
  2. Budget alert configuration
  3. Azure Advisor cost recommendations
  4. Resource tagging for cost allocation
  5. Infracost in CI/CD pipeline
- **Skill Sections**:
  - Azure Cost Management and Billing
  - Cost allocation (tagging, subscriptions, resource groups)
  - Budgets and alerts
  - Azure Advisor cost recommendations
  - Infracost for IaC cost estimation
  - Chargeback/showback strategies
  - Cost optimization patterns
- **Dependencies**: skill-iac-tool-selection, skill-observability-azure
- **Priority**: P2

---

## P3: Low-Priority Skills

### skill-project-structure-templates

- **Scope**: backend, frontend, cloud-platform
- **Description**: Generate project structure templates based on constitution decisions for consistent folder organization. Use when generating project scaffolding, folder structure, or templates. Triggers: "project structure", "folder structure", "project template", "scaffolding", "boilerplate", "project organization". Low priority - auto-generated from constitution.
- **Articles**: Article XV: Project Structure Templates (auto-generated)
- **Justification**: Templates are generated based on decisions, serve as reference
- **Complexity**: Low
- **MCP Sources**: N/A (templates are generated, not searched)
- **Code Examples**:
  1. C# Modular Monolith template
  2. C# Microservices template
  3. Node.js Modular Monolith template
  4. Node.js Microservices template
  5. Infrastructure Only - Landing Zone template
  6. Infrastructure Only - Workload template
- **Skill Sections**:
  - Template selection logic based on constitution decisions
  - Folder structure conventions
  - Naming conventions
  - Template customization
- **Dependencies**: skill-architecture-patterns, skill-iac-tool-selection
- **Priority**: P3

---

### skill-secrets-management-local-dev

- **Scope**: common (transversal)
- **Description**: Manage local development secrets with dotnet user-secrets, .env files, and local Key Vault. Use when configuring local dev secrets, dotnet user-secrets, or .env files. Triggers: "local secrets", "user secrets", "dotnet user-secrets", ".env file", "local development", "dev secrets", "gitignore secrets". Low priority - simple conventions.
- **Articles**: Article X (Section 10.3): Secrets Management (local dev only)
- **Justification**: Local dev secrets have simple conventions (User Secrets, .env files)
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "dotnet user-secrets", "environment variables"
  - context7: "dotenv"
- **Code Examples**:
  1. dotnet user-secrets command
  2. .env file with dotenv (Node.js)
  3. .gitignore for secrets
  4. Local Key Vault for dev environment
- **Skill Sections**:
  - User Secrets (.NET) - `dotnet user-secrets`
  - .env files (Node.js) - gitignored
  - Local Key Vault instance for development
  - Best practices for local secrets
- **Dependencies**: skill-environment-configuration-strategy
- **Priority**: P3

---

### skill-frontend-design-system

- **Scope**: frontend
- **Description**: Implement design systems with Fluent UI 2, component libraries, design tokens, and Storybook. Use when implementing design systems, component libraries, or design tokens. Triggers: "design system", "Fluent UI", "component library", "design tokens", "Storybook", "theming", "UI components", "style guide". Low priority - not blocking development.
- **Articles**: Proposed Additions 🆕 - Design System / Component Library
- **Justification**: Design system is valuable but not blocking for initial development
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "fluent ui 2", "fluent ui blazor"
  - context7: "Fluent UI", "Material-UI", "Ant Design"
- **Code Examples**:
  1. Fluent UI 2 (React) setup
  2. Fluent UI Blazor setup
  3. Design token configuration
  4. Component library structure
  5. Storybook for component documentation
- **Skill Sections**:
  - Design system selection (Fluent UI 2, Fluent UI Blazor, Material-UI, custom)
  - Component library patterns
  - Design tokens and theming
  - Component documentation (Storybook)
  - Accessibility in design system
- **Dependencies**: skill-frontend-framework-selection
- **Priority**: P3

---

### skill-frontend-static-hosting

- **Scope**: frontend
- **Description**: Deploy SPAs with Azure Static Web Apps, CDN, and PWA support for offline capabilities. Use when deploying static sites, implementing PWA, or configuring Azure Static Web Apps. Triggers: "Static Web Apps", "SPA hosting", "PWA", "progressive web app", "static hosting", "Azure CDN", "service worker", "offline-first". Low priority - straightforward deployment.
- **Articles**: Proposed Additions 🆕 - Static Hosting, PWA Support
- **Justification**: Static hosting is straightforward with Azure Static Web Apps
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "azure static web apps", "azure cdn", "azure front door", "pwa progressive web app"
  - context7: N/A (Azure-specific)
- **Code Examples**:
  1. Azure Static Web Apps deployment (GitHub Actions)
  2. staticwebapp.config.json configuration
  3. Azure CDN setup
  4. PWA manifest and service worker
  5. Offline-first caching strategy
- **Skill Sections**:
  - Azure Static Web Apps for SPA/SSG
  - Azure CDN for global distribution
  - Azure Front Door for advanced routing
  - PWA support (manifest, service worker, caching)
  - Client-side error tracking (Application Insights JavaScript SDK)
- **Dependencies**: skill-frontend-framework-selection, skill-observability-azure
- **Priority**: P3

---

### skill-governance-constitution-amendments

- **Scope**: common (transversal)
- **Description**: Manage constitution amendment process, versioning, and governance workflows for Bolt Framework projects. Use when modifying constitution, governance process, or amendment workflow. Triggers: "constitution amendment", "governance process", "constitution versioning", "amendment workflow", "governance rules", "constitution change". Low priority - process documentation.
- **Articles**: Article XIX: Governance 🔄 (transversal - process, not technical)
- **Justification**: Governance process is organizational, not technical implementation
- **Complexity**: Low
- **MCP Sources**: N/A (process documentation)
- **Code Examples**: N/A (process workflow)
- **Skill Sections**:
  - Constitution amendment process
  - Review and approval workflow
  - Semantic versioning for constitution
  - AI agent compliance checks
  - Audit trail and logging
- **Dependencies**: None (process-level)
- **Priority**: P3

---

### skill-crm-testing

- **Scope**: crm
- **Description**: Test Dynamics 365 and Power Platform with EasyRepro, Playwright, FakeXrmEasy, and Solution Checker. Use when testing Dynamics 365, Power Apps, or Dataverse customizations. Triggers: "Dynamics testing", "Power Apps testing", "EasyRepro", "FakeXrmEasy", "Solution Checker", "Dataverse testing", "plugin testing", "model-driven app testing". Low priority - specialized CRM testing.
- **Articles**: Proposed Additions 🆕 - CRM Testing (EasyRepro, FakeXrmEasy, Solution Checker)
- **Justification**: CRM testing tools are specialized but have clear conventions
- **Complexity**: Low
- **MCP Sources**:
  - microsoftdocs: "easyrepro", "fakexrmeasy", "power apps solution checker", "playwright dataverse"
  - context7: "FakeXrmEasy", "EasyRepro"
- **Code Examples**:
  1. EasyRepro UI test for model-driven app
  2. Playwright test for canvas app
  3. FakeXrmEasy unit test for plugin
  4. Solution Checker in CI pipeline
- **Skill Sections**:
  - EasyRepro/Playwright for UI testing (model-driven and canvas apps)
  - FakeXrmEasy for plugin/workflow unit testing
  - Solution Checker for static analysis
  - Integration testing with Dataverse
  - Test data management
- **Dependencies**: skill-dynamics-power-platform, skill-testing-frameworks-backend
- **Priority**: P3

---

## Implementation Strategy

### Phase 1: Critical Architecture (P0) - Weeks 1-6

Create 18 P0 skills that establish architectural foundation. These are complex, require deep Microsoft documentation research, and affect irreversible decisions. Focus on:

- Architecture patterns
- Database selection
- Identity provider
- IaC tool selection
- Container orchestration
- AI architecture patterns
- Landing zone design
- Transversal services (environment config, CI/CD, observability, security)

**Estimated effort**: 120-160 hours (18 skills × 7-9 hours avg per complex skill)

### Phase 2: Production Readiness (P1) - Weeks 7-12

Create 16 P1 skills for production-grade implementations. These are complex specialized articles that enable production deployment:

- GitOps, MLOps, DataOps
- Multi-agent architectures
- Medallion architecture
- Saga patterns
- API management
- Dynamics/Power Platform
- Work item synchronization

**Estimated effort**: 96-128 hours (16 skills × 6-8 hours avg per skill)

### Phase 3: Best Practices (P2) - Weeks 13-16

Create 12 P2 skills for standard patterns, performance optimization, and testing:

- Database migrations
- Legacy migration patterns
- Feature flags
- Hybrid connectivity
- Data integration/performance
- Frontend testing/performance

**Estimated effort**: 48-72 hours (12 skills × 4-6 hours avg per skill)

### Phase 4: Refinement (P3) - Weeks 17-18

Create 6 P3 skills for refinement and optional patterns:

- Project templates
- Local secrets
- Design systems
- Static hosting
- Governance process
- CRM testing

**Estimated effort**: 18-30 hours (6 skills × 3-5 hours avg per skill)

---

## Skill Distribution by Scope

- **common**: 6 skills (5 transversal P0, 1 P2, 1 P3) - _foundational for all projects_
- **backend**: 7 skills (4 P0, 1 P1, 2 P2)
- **frontend**: 5 skills (1 P0, 1 P1, 2 P2, 2 P3)
- **cloud-platform**: 10 skills (5 P0, 1 P1, 3 P2, 1 P3) - _complex infrastructure_
- **ai**: 7 skills (3 P0, 4 P1) - _high complexity, specialized_
- **crm**: 2 skills (1 P1, 1 P3)
- **data**: 7 skills (1 P0, 3 P1, 3 P2) - _complex analytics_
- **integration**: 7 skills (2 P0, 3 P1, 2 P2) - _distributed systems_
- **work-management**: 1 skill (1 P1)

---

## Total Estimated Effort

- **P0 (Critical)**: 120-160 hours (18 skills, avg 7-9 hrs/skill)
- **P1 (High)**: 96-128 hours (16 skills, avg 6-8 hrs/skill)
- **P2 (Medium)**: 48-72 hours (12 skills, avg 4-6 hrs/skill)
- **P3 (Low)**: 18-30 hours (6 skills, avg 3-5 hrs/skill)
- **Total**: **282-390 hours** (52 skills)

**Assumptions per skill**:

- Research phase (Microsoft Docs MCP, context7 library docs): 1-3 hours
- Skill structure design: 1-2 hours
- Code examples generation (5-7 examples per skill): 2-3 hours
- Skill documentation writing: 2-4 hours
- Review and refinement: 1-2 hours

**Team capacity**:

- Single developer: 18-20 weeks (full focus)
- Two developers: 9-10 weeks (parallel work)
- Three developers: 6-7 weeks (parallel work with coordination overhead)

---

## Notes

1. **Existing skills preserved**: `markdown-formatting`, `tdd-comprehensive`, `gherkin-reqnroll` (common scope)
2. **Transversal skills critical**: Environment config, CI/CD, Observability, Security affect all scopes
3. **Complex multi-section articles** (GitOps, DataOps, Multi-Agent, Saga patterns) may benefit from sub-skills if too large
4. **MCP documentation sources** specified for each skill - use `microsoftdocs/microsoft_docs_search` and `microsoftdocs/microsoft_code_sample_search` extensively
5. **Code examples** must cover both C#/.NET and Node.js/TypeScript where applicable (per constitution polyglot nature)
6. **Skill dependencies** tracked to ensure logical creation order
7. **Priority based on criticality markers** in constitution (🔴 CRITICAL = P0, 🟡 IMPORTANT = P1, 🟢 LOW-PRIO = P2/P3)
8. **Complexity assessment** based on article length, sections, decision impact, and reversibility

---

## Next Steps (Implementation Phase)

1. **Review and approve plan** with project stakeholders
2. **Prioritize P0 skills** for immediate creation (foundational)
3. **Create skill templates** based on existing skills (markdown-formatting, tdd-comprehensive)
4. **Set up MCP documentation access** (ensure `microsoftdocs` and `context7` MCPs are configured)
5. **Assign skills to developers** based on expertise (backend, frontend, cloud, AI, data)
6. **Track progress** in work management system (Azure DevOps, GitHub Projects, Jira)
7. **Iterative review** after each phase to refine estimates and approach

---

**End of Skill Generation Master Plan**
