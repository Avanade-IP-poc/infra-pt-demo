# AURORA-IA Project Constitution — Scope: AI

> **Extracted from**: `.boltf/memory/constitution.md`
> **Scope**: `ai` — AI/ML models, AI agents, prompt engineering, responsible AI, and model lifecycle.
> Articles marked with 🔄 are **common to all scopes** and always present.
> Sections marked with 🆕 are **proposed additions** not present in the original constitution.

---

## Preamble 🔄

This Constitution establishes the governing principles, technology decisions, and standards for the **[PROJECT_NAME]** project. All AI agents, developers, and automated systems MUST adhere to this document.

**This document is the SINGLE SOURCE OF TRUTH.**

**Cloud Provider**: Microsoft Azure (mandatory for all deployments)

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

### Section 19.2: AI Agent Compliance ⭐

> **This section is especially critical for the AI scope.** All AI agents and models built within this project MUST comply with this governance framework.

All AI agents operating in this project MUST:

1. **Read** this constitution before any operation
2. **Validate** all decisions against constitution principles
3. **FAIL** operations that violate constitution
4. **Request** amendment for justified exceptions
5. **Log** all constitution checks for audit

---

## Proposed Additions — AI Gaps 🆕

> The original constitution has **minimal AI/ML-specific guidance** beyond agent compliance (§19.2).
> The following are recommended Microsoft/Azure technologies and governance practices.

### AI Platform & Infrastructure

- **Azure AI Foundry**: Unified platform for building, evaluating, and deploying AI models. Use as the central hub for model management, fine-tuning, and prompt flow orchestration.
- **Azure OpenAI Service**: Managed GPT-4o, GPT-4, GPT-3.5-Turbo, DALL-E, Whisper. Use for chat, completions, embeddings, and vision capabilities with enterprise SLA.
- **Azure AI Search**: Vector and hybrid search for RAG (Retrieval-Augmented Generation) patterns. Supports semantic ranking, integrated vectorization, and knowledge mining.
- **Azure Machine Learning**: For custom model training, MLOps pipelines, model registry, and managed endpoints.

### Responsible AI

- **Microsoft Responsible AI Toolkit**: Assess fairness, interpretability, error analysis, and causal inference for ML models.
- **Azure AI Content Safety**: Real-time content moderation for text and images. Mandatory for any user-facing generative AI feature.
- **Transparency Notes**: Document model capabilities, limitations, and intended use for every deployed AI feature.
- **Human-in-the-Loop**: Define escalation paths for AI decisions with material impact. AI should augment, not replace, human judgment for critical actions.

### Prompt Engineering & Governance

- **Prompt Governance**: Maintain a prompt registry with versioning, A/B testing, and rollback capabilities. Treat prompts as code (review, test, version).
- **Prompt Injection Protection**: Use Azure AI Content Safety + system prompt hardening + input/output validation to mitigate prompt injection attacks.
- **Grounding & Citations**: All RAG-based responses MUST include source citations. Implement grounding detection to measure hallucination rates.
- **Token & Cost Management**: Set per-deployment token quotas. Monitor token usage via Azure Monitor + Application Insights custom metrics.

### Model Lifecycle

- **Model Evaluation**: Use Azure AI Foundry evaluations (relevance, coherence, groundedness, fluency, similarity) before promoting any model or prompt to production.
- **A/B Testing & Experimentation**: Use feature flags (Azure App Configuration) to route traffic between model versions. Track business metrics per variant.
- **Model Monitoring**: Track drift, latency p50/p95/p99, error rates, safety incidents via Application Insights. Set alerts for quality degradation.
- **Model Deprecation**: Establish SLA for model version retirement (e.g., 90-day notice) aligned with Azure OpenAI model lifecycle policies.

### AI-Specific Security

- **Data Boundaries**: Ensure training/evaluation data stays within Azure data residency requirements. Use Azure Private Endpoints for all AI service communication.
- **PII in Prompts**: Implement PII detection and redaction (Azure AI Language PII entity recognition) before sending user data to AI models.
- **Audit Logging**: Log all AI interactions (prompt, completion, tokens, latency, safety flags) to Azure Monitor for compliance and debugging.

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
