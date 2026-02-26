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

## Article XIII: AI Architecture & Platform Strategy

> **📋 Applies to**: AI & Machine Learning projects, Generative AI applications, RAG systems
> **⏭️ Skip if**: Pure infrastructure-only project with no AI/ML components
> **Priority**: Must be decided BEFORE implementing AI features, model training, or RAG systems

### Section 13.1: AI Architecture Pattern

Select ONE primary pattern (or multiple for hybrid):

- [ ] **MLOps with Azure Machine Learning** - Full ML lifecycle management
  - **Best for**: Custom predictive models, traditional ML (classification, regression, forecasting)
  - **Includes**: Training pipelines, model registry, experiment tracking, managed endpoints
  - **Use cases**: Credit scoring, demand forecasting, recommendation engines, anomaly detection

- [ ] **RAG (Retrieval Augmented Generation)** - Grounded LLM responses with organizational knowledge
  - **Best for**: Knowledge base Q&A, document search, contextual chat applications
  - **Includes**: Azure OpenAI + Vector Store + Document Processing
  - **Use cases**: Internal knowledge assistant, document Q&A, customer support chatbot

- [ ] **Pre-built AI Services** - Cognitive Services for standard AI capabilities
  - **Best for**: Standard AI features without custom training (OCR, translation, speech)
  - **Includes**: Azure AI Vision, Speech, Language, Document Intelligence, Translator
  - **Use cases**: Document digitization, sentiment analysis, image classification, transcription

- [ ] **Custom ML Models** - Traditional machine learning with Python SDK
  - **Best for**: Unique business problems requiring custom feature engineering
  - **Includes**: Jupyter notebooks, AutoML, scikit-learn, PyTorch, TensorFlow
  - **Use cases**: Churn prediction, time series forecasting, image segmentation

- [ ] **Hybrid AI Architecture** - Multi-service orchestration
  - **Best for**: Complex workflows combining multiple AI capabilities
  - **Includes**: Azure OpenAI + Custom ML + Cognitive Services + Orchestration
  - **Use cases**: Intelligent document processing (OCR → Summarization → Classification)

- [ ] **Prompt Engineering & Orchestration** - LLM workflow management
  - **Best for**: Complex LLM chains, agent architectures, tool-calling patterns
  - **Includes**: Prompt Flow, LangChain, Semantic Kernel, multi-step reasoning
  - **Use cases**: Research assistant, data analysis agent, workflow automation

### Section 13.2: ML Training Strategy

> **📋 Applies to**: Projects requiring custom ML models (skip if using only pre-built services or OpenAI)

Select ONE:

- [ ] **AutoML** - Automated feature engineering, algorithm selection, hyperparameter tuning
  - **Best for**: Quick prototypes, teams without deep ML expertise
  - **Azure Service**: Azure Machine Learning AutoML
  - **Training time**: 15 min - 2 hours (depending on compute)

- [ ] **Custom Training (Python SDK)** - Full control over model architecture
  - **Best for**: Specific model requirements, advanced ML teams
  - **Azure Service**: Azure ML Workspaces + Compute Clusters
  - **Frameworks**: scikit-learn, PyTorch, TensorFlow, XGBoost

- [ ] **Transfer Learning** - Pre-trained models + fine-tuning on domain data
  - **Best for**: Computer vision, NLP with limited training data
  - **Azure Service**: Azure ML Model Catalog (Hugging Face, ONNX, PyTorch Hub)
  - **Examples**: Fine-tune BERT for custom NER, ResNet for specialized image classification

- [ ] **Fine-tuning Azure OpenAI** - Customize GPT models with proprietary data
  - **Best for**: Domain-specific language patterns, custom writing styles
  - **Azure Service**: Azure OpenAI Fine-tuning (GPT-3.5-Turbo, Babbage-002)
  - **Training data**: Minimum 50 examples (recommended 500+)

- [ ] **No Training** - Use only pre-built services or foundation models as-is
  - **Best for**: Standard AI capabilities, proof-of-concept projects
  - **Azure Services**: Azure OpenAI GPT-4o, Cognitive Services

### Section 13.3: AI Service Selection

> **📋 Applies to**: ALL AI projects

Select ALL applicable services:

- [ ] **Azure Machine Learning** - Full ML platform (training, deployment, monitoring)
  - **When**: Custom models, MLOps pipelines, batch/real-time inference
  - **Pricing**: Pay for compute (CPU/GPU hours), storage, endpoints

- [ ] **Azure OpenAI Service** - Managed GPT-4o, GPT-4, GPT-3.5-Turbo, Embeddings
  - **When**: Chat, completions, text generation, embeddings for RAG
  - **Pricing**: Pay per token (input + output), provisioned throughput available

- [ ] **Azure AI Search** - Vector and hybrid search engine
  - **When**: RAG architecture, semantic search, knowledge base indexing
  - **Pricing**: Per search unit, storage, queries per second

- [ ] **Azure Cognitive Services** - Pre-built AI APIs
  - **Services**: Vision (OCR, image analysis), Speech (STT/TTS), Language (sentiment, NER), Document Intelligence
  - **When**: Standard AI capabilities without custom training
  - **Pricing**: Pay per API call (tiered discounts available)

- [ ] **Azure AI Foundry** - Model catalog, prompt flow, evaluation tools
  - **When**: Rapid prototyping, model comparison, prompt engineering
  - **Included**: Access to 1,600+ models from Microsoft, Meta, Mistral, Cohere

### Section 13.4: Inference Deployment Pattern

> **📋 Applies to**: Projects deploying custom ML models (not applicable to API-only services)

Select ONE primary pattern:

- [ ] **Managed Online Endpoints** - Real-time inference with auto-scaling
  - **Latency**: <100ms typical
  - **Best for**: Real-time predictions, interactive applications
  - **Features**: Blue-green deployment, A/B testing, traffic splitting, auto-scale
  - **Cost**: Always-on compute (per VM hour)

- [ ] **Batch Endpoints** - Scheduled scoring on large datasets
  - **Latency**: Minutes to hours
  - **Best for**: Daily scoring jobs, data pipeline integration, cost optimization
  - **Features**: Parallel processing, scheduled triggers, Event Grid integration
  - **Cost**: Pay only for job execution time

- [ ] **Serverless Inference** - Pay-per-use, no infrastructure management
  - **Latency**: 100-500ms (includes cold start)
  - **Best for**: Unpredictable traffic, proof-of-concept, low-frequency inference
  - **Features**: Auto-scale to zero, pay per request
  - **Cost**: Per invocation (no minimum)

- [ ] **Container Instances (ACI)** - Custom runtime with full control
  - **Latency**: Configurable (depends on container specs)
  - **Best for**: Specialized runtimes, legacy models, custom dependencies
  - **Features**: Full Docker support, custom health checks
  - **Cost**: Per vCPU and memory allocation

- [ ] **Edge Deployment** - On-device inference (IoT, offline scenarios)
  - **Latency**: <10ms (local processing)
  - **Best for**: IoT devices, low-latency requirements, offline operation
  - **Features**: ONNX Runtime, model quantization, Azure IoT Edge integration
  - **Cost**: Device compute only (no cloud inference cost)

### Section 13.5: Vector Store & Embeddings (RAG Enablement)

> **📋 Applies to**: RAG (Retrieval Augmented Generation) architectures ONLY
> **⏭️ Skip if**: No RAG, no semantic search, no vector embeddings

Select ONE vector store:

- [ ] **Azure AI Search** - Hybrid search (vectors + keywords) with semantic ranking
  - **Best for**: Enterprise RAG, multi-modal search (text + vectors), rich filtering
  - **Features**: Integrated vectorization, semantic ranking, knowledge mining pipelines
  - **Max vectors**: 50M per index (single replica)
  - **Pricing**: Per search unit + storage

- [ ] **Azure Cosmos DB (NoSQL + Vector Extension)** - Transactional database + vectors
  - **Best for**: Operational RAG (user data + semantic search), global distribution
  - **Features**: Multi-region replication, consistency models, vector indexing
  - **Max vectors**: Unlimited (distributed partitions)
  - **Pricing**: Per RU + storage

- [ ] **Redis Enterprise (RediSearch + Vector Similarity)** - In-memory vectors
  - **Best for**: Ultra-low latency (<10ms), high-throughput search
  - **Features**: In-memory performance, real-time indexing
  - **Max vectors**: 100M+ (depends on memory)
  - **Pricing**: Per memory allocation

- [ ] **Pinecone** - Managed vector database (SaaS)
  - **Best for**: Quick RAG prototypes, no infrastructure management
  - **Features**: Managed service, metadata filtering, namespaces
  - **Max vectors**: Unlimited (managed service)
  - **Pricing**: Per pod (storage + compute combined)

- [ ] **None** - No RAG architecture

**Embedding Model**:

- [ ] **Azure OpenAI text-embedding-ada-002** - 1536 dimensions, optimized for English
- [ ] **Azure OpenAI text-embedding-3-small** - 512-1536 dimensions, multilingual
- [ ] **Azure OpenAI text-embedding-3-large** - 256-3072 dimensions, highest accuracy
- [ ] **Azure AI Search Integrated Vectorization** - Built-in chunking + embeddings
- [ ] **Custom embedding model** - E5, BGE, or domain-specific embeddings

### Section 13.6: Prompt Engineering & Orchestration

> **📋 Applies to**: Projects using Azure OpenAI, GPT models, or LLM chains

Select ONE orchestration framework:

- [ ] **Prompt Flow (Azure AI Foundry)** - Visual designer for LLM workflows
  - **Best for**: Low-code/no-code teams, visual debugging, Azure-native integration
  - **Features**: Flow tracing, evaluation metrics, A/B testing, deployment to Azure
  - **Languages**: Python, .NET (via SDK)

- [ ] **LangChain** - Python/JavaScript orchestration framework
  - **Best for**: Complex agent architectures, tool calling, memory management
  - **Features**: 100+ integrations, agent types (ReAct, Self-Ask, Plan-and-Execute)
  - **Community**: Large open-source ecosystem

- [ ] **Semantic Kernel (Microsoft)** - .NET/Python/Java SDK for AI orchestration
  - **Best for**: Enterprise .NET applications, plugin architecture, function calling
  - **Features**: Planners, memory connectors, native function integration
  - **Integration**: Deep Azure OpenAI integration

- [ ] **Manual (Direct API Calls)** - No orchestration framework
  - **Best for**: Simple chat applications, single-turn completions
  - **Approach**: Direct Azure OpenAI SDK calls, custom retry logic

**Prompt Management**:

- [ ] **Prompt Registry** - Versioned prompt templates in Git + Azure App Configuration
- [ ] **Inline Prompts** - Hardcoded in application code
- [ ] **Prompt Flow Studio** - Manage prompts in Azure AI Foundry UI

### Section 13.7: Model Governance & MLOps

> **📋 Applies to**: Projects with custom ML models or multiple model versions

Select ONE model registry:

- [ ] **Azure ML Model Registry** - Centralized, versioned, RBAC-enabled
  - **Best for**: Enterprise MLOps, model lineage tracking, compliance requirements
  - **Features**: Model versioning, tags/metadata, deployment history, audit logs
  - **Integration**: Azure ML Pipelines, endpoints

- [ ] **MLflow Tracking** - Open-source experiment logging + model tracking
  - **Best for**: ML research, experiment comparison, platform-agnostic
  - **Features**: Experiment runs, parameter logging, artifact storage
  - **Integration**: Can log to Azure ML backend

- [ ] **Git-based (NOT RECOMMENDED for production)** - Model files in repository
  - **Risk**: Large binary files, no versioning for artifacts, no audit trail
  - **Use only for**: Proof-of-concept, local development

- [ ] **None** - Manual model governance

**CI/CD for ML Pipelines**:

- [ ] **Azure DevOps + Azure ML Pipelines** - Integrated MLOps
- [ ] **GitHub Actions + Azure ML CLI v2** - Git-native automation
- [ ] **Manual** - No automated retraining/deployment

### Section 13.8: Responsible AI Practices

> **📋 Applies to**: ALL AI projects (mandatory for production deployments)

Select ALL applicable practices (minimum 3 required for production):

- [ ] **Fairness Dashboard** - Bias detection across demographic groups
  - **Tool**: Microsoft Fairness 360, Fairlearn
  - **Metrics**: Demographic parity, equalized odds, disparate impact
  - **When**: Any model making decisions impacting people (hiring, lending, healthcare)

- [ ] **Interpretability (SHAP/LIME)** - Model explainability
  - **Tool**: InterpretML, SHAP library
  - **Output**: Feature importance, local explanations for predictions
  - **When**: Regulated industries (finance, healthcare), high-stakes decisions

- [ ] **Model Monitoring** - Drift detection, performance degradation
  - **Tool**: Azure ML Model Monitor, Evidently AI
  - **Metrics**: Data drift, model drift, prediction distribution
  - **Alerts**: Trigger retraining when drift exceeds threshold

- [ ] **Model Cards** - Document model behavior, limitations, intended use
  - **Format**: Markdown document in model registry
  - **Content**: Training data, performance metrics, known limitations, ethical considerations
  - **Audience**: Data scientists, compliance teams, end users

- [ ] **Datasheets for Datasets** - Document training data provenance
  - **Content**: Data sources, collection methodology, known biases, privacy considerations
  - **Purpose**: Reproducibility, transparency, compliance

- [ ] **Azure AI Content Safety** - Real-time content moderation (text + images)
  - **Protections**: Hate speech, violence, self-harm, sexual content
  - **Severity levels**: Safe, Low, Medium, High (configurable thresholds)
  - **When**: **MANDATORY** for any user-facing generative AI feature

- [ ] **Human-in-the-Loop (HITL)** - Human review for high-stakes predictions
  - **Pattern**: AI suggests → Human reviews → Human approves/rejects
  - **When**: Medical diagnosis, legal decisions, financial approvals

- [ ] **Prompt Injection Protection** - Mitigate adversarial prompts
  - **Techniques**: System prompt hardening, input/output validation, Azure AI Content Safety
  - **When**: User-provided prompts in production applications

### Section 13.9: Trade-offs and Rationale

> This section provides comparative analysis to guide architecture decisions.

#### 13.9.1: MLOps (Azure ML) vs Pre-built Services (Cognitive Services)

| Factor               | MLOps (Azure ML)                                                 | Pre-built Services (Cognitive Services)           |
| -------------------- | ---------------------------------------------------------------- | ------------------------------------------------- |
| **Time to Value**    | ⚠️ Weeks to months (data prep, training, evaluation)             | ✅ Hours to days (API integration)                |
| **Accuracy**         | ✅ Optimized for your data (90%+ achievable)                     | ⚠️ General-purpose (70-85% typical)               |
| **Customization**    | ✅ Full control (features, algorithms, hyperparameters)          | ⚠️ Limited (API parameters only)                  |
| **Cost (training)**  | ⚠️ $200-$5,000/month (compute clusters, storage)                 | ✅ $0 (no training cost)                          |
| **Cost (inference)** | ⚠️ $100-$2,000/month (always-on endpoints or batch jobs)         | ✅ Pay-per-call ($1-$3 per 1,000 transactions)    |
| **Expertise**        | ⚠️ Requires data scientists, ML engineers                        | ✅ Requires only developers (API integration)     |
| **Best for**         | Unique business problems, high-value predictions, data available | Standard AI capabilities (OCR, translation, etc.) |

**Recommendation**: Start with pre-built services for POCs. Invest in MLOps when accuracy gains justify the cost (high-value use cases like fraud detection, personalized recommendations).

#### 13.9.2: RAG (Azure OpenAI) vs Fine-tuning Custom Model

| Factor               | RAG (Retrieval Augmented Generation)                         | Fine-tuning Azure OpenAI                            |
| -------------------- | ------------------------------------------------------------ | --------------------------------------------------- |
| **Use Case**         | ✅ Knowledge base Q&A, document search, contextual answers   | ⚠️ Domain-specific language patterns, custom styles |
| **Training Data**    | ✅ No training (uses documents as-is)                        | ⚠️ Minimum 50 examples (500+ recommended)           |
| **Cost (setup)**     | ⚠️ Vector store + embeddings ($50-$500/month)                | ✅ One-time training cost ($5-$50 per job)          |
| **Cost (inference)** | ⚠️ Higher (prompt + embeddings + completion = 3x token cost) | ✅ Lower (no retrieval overhead)                    |
| **Accuracy**         | ✅ Grounded in source documents (citable, auditable)         | ⚠️ Depends on training data quality                 |
| **Hallucination**    | ✅ Lower (grounded in retrieved facts)                       | ⚠️ Higher (model generates from learned patterns)   |
| **Update Frequency** | ✅ Real-time (add documents to index immediately)            | ⚠️ Requires retraining (weeks to update model)      |
| **Transparency**     | ✅ Can show source citations                                 | ⚠️ Black-box model behavior                         |
| **Best for**         | Dynamic knowledge bases, compliance-driven industries        | Static domain language (medical terminology, etc.)  |

**Recommendation**: Default to RAG for knowledge-based applications. Use fine-tuning ONLY if you need specific writing styles or terminology that RAG cannot capture.

#### 13.9.3: Real-time Endpoints vs Batch Endpoints

| Factor               | Managed Online Endpoints (Real-time)          | Batch Endpoints                                   |
| -------------------- | --------------------------------------------- | ------------------------------------------------- |
| **Latency**          | ✅ <100ms                                     | ⚠️ Minutes to hours                               |
| **Throughput**       | ⚠️ 100-1,000 requests/sec (depends on VM)     | ✅ Millions of rows per job (parallel processing) |
| **Cost**             | ⚠️ Always-on ($200-$2,000/month per endpoint) | ✅ Pay only for job execution ($10-$100 per job)  |
| **Auto-scaling**     | ✅ Scale based on traffic                     | ❌ Fixed parallelism per job                      |
| **Best for**         | Interactive apps, chatbots, real-time scoring | Daily scoring pipelines, bulk processing          |
| **Example use case** | Credit card fraud detection (instant)         | Customer churn scoring (daily batch)              |

**Recommendation**: Use real-time endpoints for user-facing applications (<500ms requirement). Use batch endpoints for backoffice analytics, daily reports, data pipeline integration.

#### 13.9.4: Prompt Flow vs LangChain

| Factor                | Prompt Flow (Azure AI Foundry)                 | LangChain                                         |
| --------------------- | ---------------------------------------------- | ------------------------------------------------- |
| **Learning Curve**    | ✅ Low (visual designer, no-code/low-code)     | ⚠️ Medium-High (Python/JS code, abstractions)     |
| **Debugging**         | ✅ Built-in tracing, visual flow execution     | ⚠️ Manual instrumentation (LangSmith recommended) |
| **Azure Integration** | ✅ Native (Azure OpenAI, AI Search, Key Vault) | ⚠️ Requires custom connectors                     |
| **Flexibility**       | ⚠️ Limited to supported node types             | ✅ Highly extensible (100+ integrations)          |
| **Community**         | ⚠️ Smaller (Microsoft ecosystem)               | ✅ Large open-source community                    |
| **Agent Support**     | ⚠️ Basic (custom Python nodes required)        | ✅ Built-in (ReAct, Self-Ask, Plan-and-Execute)   |
| **Best for**          | Azure-native teams, visual debugging           | Complex agents, multi-framework integration       |

**Recommendation**: Use Prompt Flow for Azure-centric projects with low-code requirements. Use LangChain if you need advanced agent patterns or multi-cloud portability.

#### 13.9.5: Azure AI Search vs Cosmos DB (Vector Store)

| Factor                  | Azure AI Search                                   | Azure Cosmos DB (NoSQL + Vectors)              |
| ----------------------- | ------------------------------------------------- | ---------------------------------------------- |
| **Primary Purpose**     | ✅ Search engine with vector capabilities         | ⚠️ Transactional database with vector indexing |
| **Hybrid Search**       | ✅ Native (vectors + keywords + semantic ranking) | ⚠️ Manual implementation                       |
| **Max Vectors**         | ⚠️ 50M per index (single replica)                 | ✅ Unlimited (distributed partitions)          |
| **Latency**             | ⚠️ 50-200ms (typical)                             | ✅ <10ms (transactional queries)               |
| **Global Distribution** | ❌ Regional deployments only                      | ✅ Multi-region replication (5-way writes)     |
| **Cost**                | ⚠️ $250-$2,500/month (depends on search units)    | ⚠️ $200-$5,000/month (depends on RU + storage) |
| **Best for**            | Pure search/RAG workloads, document indexing      | Operational apps (user data + semantic search) |

**Recommendation**: Use Azure AI Search for RAG applications focused on search/retrieval. Use Cosmos DB if you need operational database + semantic search in one service (e.g., user profiles with vector similarity).

### Section 13.10: References & Resources

> Official Microsoft Learn documentation for Azure AI architecture patterns

#### Azure Machine Learning & MLOps

- [MLOps v2 Architecture with Azure Machine Learning](https://learn.microsoft.com/azure/architecture/ai-ml/guide/machine-learning-operations-v2)
- [Train models in Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/concept-train-machine-learning-model)
- [Deploy models with managed online endpoints](https://learn.microsoft.com/azure/machine-learning/concept-endpoints-online)
- [Batch inference with Azure ML](https://learn.microsoft.com/azure/machine-learning/concept-endpoints-batch)

#### Azure OpenAI & RAG

- [Retrieval Augmented Generation (RAG) in Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/concepts/use-your-data)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [Prompt engineering techniques](https://learn.microsoft.com/azure/ai-services/openai/concepts/advanced-prompt-engineering)
- [Fine-tune Azure OpenAI models](https://learn.microsoft.com/azure/ai-services/openai/how-to/fine-tuning)

#### Azure AI Search

- [Vector search in Azure AI Search](https://learn.microsoft.com/azure/search/vector-search-overview)
- [Hybrid search (vectors + keywords)](https://learn.microsoft.com/azure/search/hybrid-search-overview)
- [Semantic ranking](https://learn.microsoft.com/azure/search/semantic-search-overview)

#### Responsible AI

- [Microsoft Responsible AI Standard v2](https://www.microsoft.com/ai/responsible-ai)
- [Azure AI Content Safety](https://learn.microsoft.com/azure/ai-services/content-safety/overview)
- [Fairness assessment with Fairlearn](https://learn.microsoft.com/azure/machine-learning/how-to-machine-learning-fairness-aml)
- [Model interpretability in Azure ML](https://learn.microsoft.com/azure/machine-learning/how-to-machine-learning-interpretability)

#### Prompt Flow & Orchestration

- [Prompt Flow in Azure AI Foundry](https://learn.microsoft.com/azure/ai-studio/how-to/prompt-flow)
- [LangChain with Azure OpenAI](https://python.langchain.com/docs/integrations/platforms/microsoft)
- [Semantic Kernel (Microsoft)](https://learn.microsoft.com/semantic-kernel/overview/)

#### Azure AI Foundry

- [Azure AI Foundry documentation](https://learn.microsoft.com/azure/ai-studio/)
- [Model catalog (1,600+ models)](https://learn.microsoft.com/azure/ai-studio/how-to/model-catalog)
- [Evaluation of generative AI applications](https://learn.microsoft.com/azure/ai-studio/concepts/evaluation-metrics-built-in)

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

| Version | Date       | Author         | Changes                                                                                              |
| ------- | ---------- | -------------- | ---------------------------------------------------------------------------------------------------- |
| 2.2.0   | 2026-02-26 | GitHub Copilot | Added Article XIII: AI Architecture & Platform Strategy (396 lines) with Azure AI decision framework |
| 2.1.0   | [DATE]     | [AUTHOR]       | Added Project Scope (App/Infra/Full Stack), Landing Zone templates, Infrastructure testing           |
| 2.0.0   | [DATE]     | [AUTHOR]       | Complete rewrite with C#/Node.js options                                                             |
| 1.0.0   | [DATE]     | [AUTHOR]       | Initial constitution                                                                                 |
