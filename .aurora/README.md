# AURORA-IA / AI-DLC Project Template

> **AI-Unified Requirements, Orchestration, Reasoning & Automation**  
> Combined with **AWS AI-Driven Development Lifecycle with Bolts**

[![License](https://img.shields.io/badge/license-CUSTOM-orange.svg)](LICENSE)
[![AURORA-IA](https://img.shields.io/badge/methodology-AURORA--IA-orange.svg)](.github/agents/)
[![AI-DLC](https://img.shields.io/badge/lifecycle-AI--DLC-orange.svg)](.github/agents/)

---

## Overview

This repository serves as a project template implementing the **AURORA-IA** + **AI-DLC** methodology - a comprehensive AI-native approach to software development that replaces traditional sprints with intelligent, micro-iteration "Bolts" orchestrated by specialized AI agents.

### What is AURORA-IA?

**AURORA** (AI-Unified Requirements, Orchestration, Reasoning & Automation) is an 8-stage cognitive framework that mirrors human problem-solving patterns while leveraging AI capabilities:

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AURORA-IA COGNITIVE STAGES                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   1. PERCEIVE ────→ Understand context and gather information       │
│   2. ANALYZE  ────→ Decompose problems into components              │
│   3. REASON   ────→ Apply logic and domain knowledge                │
│   4. PLAN     ────→ Create actionable strategies                    │
│   5. EXECUTE  ────→ Implement solutions                             │
│   6. VALIDATE ────→ Verify correctness and quality                  │
│   7. ADAPT    ────→ Learn and adjust from feedback                  │
│   8. REFLECT  ────→ Document and improve processes                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### What is AI-DLC?

**AI-DLC** (AI-Driven Development Lifecycle) is an AWS-inspired framework that organizes development into 7 blocks with **Bolts** (micro-iterations of 2-3 days):

| Block | Phase | Focus |
|-------|-------|-------|
| 🎯 Inception | Discovery | Vision, stakeholders, initial scope |
| 🔍 Discovery | Analysis | Requirements, domain modeling |
| 🎨 Design | Architecture | Technical design, API contracts |
| 🔨 Construction | Development | Implementation in Bolts |
| 🚀 Release | Delivery | Deployment, rollout |
| ⚙️ Operations | Maintenance | Monitoring, support |
| 📈 Evolution | Improvement | Refactoring, optimization |

---

## Getting Started

### Prerequisites

- **Node.js** 20+ or **Python** 3.11+
- **Git** 2.40+
- **Docker** (optional, for local development)
- **VS Code** with GitHub Copilot (recommended)

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/your-project.git
cd your-project

# Install dependencies
npm install

# Configure environment
cp .env.example .env

# Start development server
npm run dev
```

### Project Structure

```
.
├── .github/
│   ├── agents/          # AI Agents (29 specialized agents)
│   ├── prompts/         # Copilot prompt files (18 prompts)
│   └── workflows/       # GitHub Actions CI/CD
├── scripts/
│   ├── bash/            # Automation scripts (Linux/macOS/WSL)
│   └── powershell/      # Automation scripts (Windows)
├── memory/
│   └── constitution.md  # Project governance (single source of truth)
├── specs/               # Feature specifications (organized by feature)
│   ├── .template/       # Template for new features
│   │   ├── contracts/   # API contracts (OpenAPI, JSON Schema)
│   │   ├── requirements/# User stories, acceptance criteria
│   │   ├── tests/       # Gherkin feature files
│   │   └── planning/    # Plan, tasks, research
│   └── XXX-feature/     # Actual feature specs
├── src/
│   ├── domain/          # Domain layer (entities, value objects)
│   ├── application/     # Application layer (use cases)
│   ├── infrastructure/  # Infrastructure layer (adapters)
│   └── presentation/    # Presentation layer (API, UI)
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   ├── adr/             # Architecture Decision Records
│   ├── features/        # Feature specifications
│   └── api/             # API documentation
└── infrastructure/
    └── terraform/       # Infrastructure as Code
```

---

## AI Agents

This project is supported by **29 specialized AI agents** organized across the development lifecycle:

### How to Use Agents

Invoke agents in VS Code Copilot Chat using the `@` prefix:

```
# Main orchestrator - guides you to the right agent
@AURORA help me start a new feature

# Direct agent invocation
@Aurora Feature create a user authentication feature
@Aurora Testing generate tests for UserService
@Aurora Implement implement the login endpoint
```

### Agent Categories

| Category | Agents | Purpose |
|----------|--------|---------|
| **Orchestration** | AURORA | Main router to specialized agents |
| **Discovery** | Feature, Specify, Clarify, Use Case, Gherkin | Requirements & Analysis |
| **Architecture** | Architect, DDD, Constitution | Design & Modeling |
| **Planning** | Plan, Tasks | Implementation planning |
| **Construction** | Implement, Micro Iterator, Testing, Review | Development |
| **Quality** | Analyze, Alignment, ADR | Validation & Documentation |
| **Security** | Security | OWASP compliance & Security analysis |
| **Release** | Release, Ops, Status | Deployment & Monitoring |
| **Evolution** | Improve, Postmortem, Retire | Improvement & Lifecycle |
| **DevOps** | Templates, CI/CD, Deps, Docs, Monitoring | Infrastructure |

📚 **Full documentation**: [.github/agents/README.md](.github/agents/README.md)

---

## 🚀 Quick Start by Scenario

AURORA supports different starting points. Choose your scenario:

### Scenario A: Greenfield (New Project from Scratch)

**You have:** Nothing, just an idea or RFP  
**Goal:** Build a new system from zero

```
┌─────────────────────────────────────────────────────────────────────┐
│                    GREENFIELD WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. @AURORA              → Initialize and guide you                  │
│  2. @Aurora Constitution → Define project DNA (tech stack, rules)    │
│  3. @Aurora Feature      → Create first feature spec                 │
│  4. @Aurora Specify      → Detail requirements                       │
│  5. @Aurora Plan         → Create implementation plan (Bolts)        │
│  6. @Aurora Implement    → Execute each Bolt                         │
│  7. @Aurora Testing      → Generate and run tests                    │
│  8. @Aurora Release      → Prepare release                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Step by Step:**

```bash
# Step 1: Initialize project structure
./init.sh                                       # Linux/macOS/WSL
.\scripts\powershell\Init.ps1             # Windows

# Step 2: Define Constitution (in VS Code Copilot Chat)
@Aurora Constitution create project constitution for a REST API 
with TypeScript, NestJS, PostgreSQL, following Clean Architecture

# Step 3: Create your first feature
@Aurora Feature create user-authentication feature

# Or via script:
./.aurora/scripts/bash/create-new-feature.sh "user-authentication"
```

---

### Scenario B: Brownfield (Modernize Legacy System)

**You have:** Existing legacy code (COBOL, VB6, old Java, etc.)  
**Goal:** Understand, document, and modernize

```
┌─────────────────────────────────────────────────────────────────────┐
│                    BROWNFIELD WORKFLOW                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. @AURORA              → Initialize and guide you                  │
│  2. @Aurora Constitution → Define TARGET tech stack                  │
│  3. @Aurora Analyze      → Analyze legacy code (put in legacy/)      │
│  4. @Aurora Use Case     → Extract use cases from legacy             │
│  5. @Aurora Feature      → Create feature specs from use cases       │
│  6. @Aurora DDD          → Model the domain                          │
│  7. @Aurora Plan         → Plan migration in Bolts                   │
│  8. @Aurora Implement    → Implement modern version                  │
│  9. @Aurora Testing      → Create tests (use legacy as oracle)       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Step by Step:**

```bash
# Step 1: Initialize and place legacy code
./init.sh ../my-migration brown ./legacy-source --backend csharp --architecture microservices
# Legacy code copied to: legacy/source/

# Step 2: Define TARGET constitution
@Aurora Constitution create constitution for modernizing COBOL system
to TypeScript microservices with event-driven architecture

# Step 3: Analyze legacy code
@Aurora Analyze analyze the COBOL code in legacy/ and extract 
business rules and data structures

# Step 4: Extract use cases
@Aurora Use Case generate use cases from the legacy analysis

# Step 5: Create modern feature specs
@Aurora Feature create features based on extracted use cases
```

---

### Scenario C: From RFP (Request for Proposal)

**You have:** An RFP document or client requirements document  
**Goal:** Analyze, estimate, and plan the project

```
┌─────────────────────────────────────────────────────────────────────┐
│                    RFP ANALYSIS WORKFLOW                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. @AURORA              → Initialize and guide you                  │
│  2. @Aurora Analyze      → Analyze RFP document (put in demo/from_rfp/)│
│  3. @Aurora Use Case     → Extract use cases from RFP                │
│  4. @Aurora Specify      → Create detailed requirements              │
│  5. @Aurora Architect    → Propose architecture                      │
│  6. @Aurora Plan         → Create high-level plan & estimate         │
│  7. @Aurora Constitution → Define tech stack (if approved)           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Step by Step:**

```bash
# Step 1: Initialize and place RFP
./init.sh ../rfp-project green --scope app-only --backend csharp
# RFP copied from: demo/from_rfp/

# Step 2: Analyze RFP
@Aurora Analyze analyze the RFP in demo/from_rfp/ and identify 
functional requirements, non-functional requirements, and risks

# Step 3: Generate use cases
@Aurora Use Case create use cases from the RFP analysis

# Step 4: Estimate effort
@Aurora Plan create estimation and high-level plan for the RFP
```

---

### Scenario D: Discovery Only (Analysis Phase)

**You have:** Need to understand a domain or existing system  
**Goal:** Document, model, and create specifications only (no code)

```
┌─────────────────────────────────────────────────────────────────────┐
│                    DISCOVERY ONLY WORKFLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. @AURORA              → Initialize                                │
│  2. @Aurora Clarify      → Clarify requirements with stakeholders    │
│  3. @Aurora Use Case     → Document use cases                        │
│  4. @Aurora DDD          → Model domain (entities, aggregates)       │
│  5. @Aurora Gherkin      → Write acceptance criteria                 │
│  6. @Aurora Architect    → Propose architecture                      │
│  7. @Aurora ADR          → Document key decisions                    │
│  8. @Aurora Alignment    → Verify business-tech alignment            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Step by Step:**

```bash
# Step 1: Initialize
./init.sh ../clarify-project green --scope app-only --backend csharp

# Step 2: Start clarification session
@Aurora Clarify I need to understand the requirements for 
an e-commerce checkout system

# Step 3: Generate use cases
./.aurora/scripts/bash/generate-usecases.sh "checkout"

# Step 4: Model domain
@Aurora DDD create domain model for checkout bounded context

# Step 5: Write Gherkin scenarios
./.aurora/scripts/bash/generate-gherkin.sh "checkout"

# Step 6: Check alignment
./.aurora/scripts/bash/alignment-analysis.sh
```

---

### Scenario E: Single Feature (Add to Existing Project)

**You have:** An existing AURORA project with Constitution  
**Goal:** Add a new feature following the methodology

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SINGLE FEATURE WORKFLOW                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. @Aurora Feature      → Create feature specification              │
│  2. @Aurora Specify      → Detail requirements                       │
│  3. @Aurora Gherkin      → Write acceptance criteria                 │
│  4. @Aurora Plan         → Plan implementation (Bolts)               │
│  5. @Aurora Tasks        → Break down into tasks                     │
│  6. @Aurora Implement    → Execute Bolt by Bolt                      │
│  7. @Aurora Testing      → Test each Bolt                            │
│  8. @Aurora Review       → Code review                               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Step by Step:**

```bash
# Step 1: Create feature
./.aurora/scripts/bash/create-new-feature.sh "payment-processing"
# Or:
@Aurora Feature create payment-processing feature

# Step 2: Specify requirements
@Aurora Specify detail requirements for payment-processing

# Step 3: Generate Gherkin
./.aurora/scripts/bash/generate-gherkin.sh "payment-processing"

# Step 4: Plan implementation
@Aurora Plan create implementation plan for payment-processing

# Step 5: Execute Bolt 1
@Aurora Implement execute Bolt 1 for payment-processing

# Step 6: Test
./.aurora/scripts/bash/generate-tests.sh "payment-processing"

# Step 7: Validate
./.aurora/scripts/bash/quality-gates.sh
```

---

## 📋 Agent Execution Order Reference

### Full Development Cycle (Recommended Order)

| Phase | Agent | Script Alternative | Output |
|-------|-------|-------------------|--------|
| **INCEPTION** | | | |
| 1 | `@AURORA` | `init.sh` | Project initialized |
| 2 | `@Aurora Constitution` | - | `.aurora/memory/constitution.md` |
| **DISCOVERY** | | | |
| 3 | `@Aurora Clarify` | - | Requirements clarified |
| 4 | `@Aurora Feature` | `create-new-feature.sh` | `specs/XXX-feature/` |
| 5 | `@Aurora Specify` | - | `requirements/requirements.md` |
| 6 | `@Aurora Use Case` | `generate-usecases.sh` | `requirements/use-cases.md` |
| 7 | `@Aurora Gherkin` | `generate-gherkin.sh` | `tests/*.feature` |
| 8 | `@Aurora DDD` | - | Domain model |
| 9 | `@Aurora Architect` | - | Architecture design |
| **CONSTRUCTION** | | | |
| 10 | `@Aurora Plan` | - | `planning/plan.md` |
| 11 | `@Aurora Tasks` | - | `planning/tasks.md` |
| 12 | `@Aurora Implement` | - | Source code |
| 13 | `@Aurora Micro Iterator` | - | Bolt execution |
| 14 | `@Aurora Testing` | `generate-tests.sh` | Test files |
| 15 | `@Aurora Review` | - | Code reviewed |
| 16 | `@Aurora ADR` | `create-adr.sh` | `docs/adr/` |
| **TRANSITION** | | | |
| 17 | `@Aurora Release` | `create-release.sh` | Release prepared |
| 18 | `@Aurora Docs` | - | Documentation |
| **PRODUCTION** | | | |
| 19 | `@Aurora Ops` | `ops-status.sh` | Operations running |
| 20 | `@Aurora Monitoring` | - | Monitoring configured |
| 21 | `@Aurora Status` | `project-status.sh` | Status report |
| **EVOLUTION** | | | |
| 22 | `@Aurora Postmortem` | `generate-postmortem.sh` | Incident analysis |
| 23 | `@Aurora Improve` | `analyze-improvements.sh` | Improvements |
| 24 | `@Aurora Alignment` | `alignment-analysis.sh` | Alignment report |
| **RETIREMENT** | | | |
| 25 | `@Aurora Retire` | `plan-retirement.sh` | Decommission plan |

---

## 🔧 Development Workflow (Detailed)

### Phase 1: Constitution (Do Once)

The Constitution is the **DNA** of your project. It defines:
- Tech stack (languages, frameworks, databases)
- Coding standards
- Architecture patterns
- Quality gates
- Git workflow

```bash
# Create constitution
@Aurora Constitution create constitution for {project description}

# Verify constitution
cat .aurora/memory/constitution.md
```

⚠️ **Important:** All agents read the Constitution before generating code. Update it carefully.

---

### Phase 2: Feature Definition

⚠️ **MANDATORY: Every feature MUST have its own Git branch**

Before creating any feature specification, create the branch first:

```bash
# This is REQUIRED - DO NOT SKIP
./.aurora/scripts/bash/create-new-feature.sh "feature-name" "main"
# Or PowerShell:
.\scripts\powershell\Create-NewFeature.ps1 -FeatureName "feature-name"
```

The script automatically:
1. Creates branch `feature/feature-name` from base branch
2. Creates the `specs/feature-name/` directory structure
3. Initializes template files

Each feature gets its own directory under `specs/`:

```
specs/
└── 001-user-authentication/
    ├── feature.md           # Feature overview
    ├── requirements/
    │   ├── requirements.md  # Detailed requirements
    │   └── use-cases.md     # Use case diagrams
    ├── contracts/
    │   └── openapi.yaml     # API contract
    ├── tests/
    │   └── auth.feature     # Gherkin scenarios
    └── planning/
        ├── plan.md          # Implementation plan
        └── tasks.md         # Bolt tasks
```

```bash
# Create feature structure
@Aurora Feature create {feature-name} feature

# Or via script
./.aurora/scripts/bash/create-new-feature.sh "{feature-name}"
```

---

### Phase 3: Implementation Bolts

Bolts are **micro-iterations of 2-3 days**. Each Bolt:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         BOLT LIFECYCLE                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐     │
│   │  DESIGN  │───▶│ IMPLEMENT│───▶│   TEST   │───▶│  REVIEW  │     │
│   └──────────┘    └──────────┘    └──────────┘    └──────────┘     │
│        │               │               │               │            │
│        ▼               ▼               ▼               ▼            │
│   Domain model    Clean code      Unit tests     Code review        │
│   API contract    TDD approach    Integration    Quality gates      │
│                                   E2E tests      Merge ready        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

```bash
# Execute a Bolt
@Aurora Implement execute Bolt 1 for {feature-name}

# Generate tests for the implementation
@Aurora Testing generate tests for {component}

# Run quality gates
./.aurora/scripts/bash/quality-gates.sh

# Code review
@Aurora Review review the implementation of {feature-name}
```

---

### Phase 4: Validation & Release

```bash
# Check project status
./.aurora/scripts/bash/project-status.sh

# Verify alignment
./.aurora/scripts/bash/alignment-analysis.sh

# Create release
./.aurora/scripts/bash/create-release.sh "1.0.0"
# Or:
@Aurora Release prepare release 1.0.0
```

---

## 🤖 AI Agents (29 Total)

This project is supported by **29 specialized AI agents** organized across the development lifecycle.

### How to Invoke Agents

In VS Code with GitHub Copilot, use `@` in the Chat:

```
@AURORA help me start a new project          # Main orchestrator
@Aurora Feature create a login feature       # Direct agent
@Aurora Testing generate unit tests          # Direct agent
```

### Agents by Phase

| Phase | Agent | Purpose | When to Use |
|-------|-------|---------|-------------|
| **ORCHESTRATION** | | | |
| | `@AURORA` | Main orchestrator | Start here if unsure |
| **INCEPTION** | | | |
| | `@Aurora Constitution` | Project DNA | First step in any project |
| | `@Aurora Templates` | Project scaffolding | Initial setup |
| **DISCOVERY** | | | |
| | `@Aurora Feature` | Create feature specs | New feature needed |
| | `@Aurora Specify` | Detail requirements | Elaborate on feature |
| | `@Aurora Clarify` | Requirements Q&A | Unclear requirements |
| | `@Aurora Use Case` | Extract use cases | Document behaviors |
| | `@Aurora Gherkin` | BDD scenarios | Acceptance criteria |
| | `@Aurora Analyze` | Code/doc analysis | Legacy/RFP analysis |
| **ARCHITECTURE** | | | |
| | `@Aurora Architect` | System design | Architecture decisions |
| | `@Aurora DDD` | Domain modeling | Domain entities/aggregates |
| | `@Aurora ADR` | Decision records | Document decisions |
| **CONSTRUCTION** | | | |
| | `@Aurora Plan` | Implementation plan | Before coding |
| | `@Aurora Tasks` | Task breakdown | Bolt task lists |
| | `@Aurora Implement` | Write code | During Bolts |
| | `@Aurora Micro Iterator` | Bolt orchestration | Execute Bolts |
| | `@Aurora Testing` | Test generation | After implementation |
| | `@Aurora Review` | Code review | Before merge |
| **TRANSITION** | | | |
| | `@Aurora Release` | Release prep | Version release |
| | `@Aurora Docs` | Documentation | API docs, guides |
| | `@Aurora CI/CD` | Pipeline config | CI/CD setup |
| **PRODUCTION** | | | |
| | `@Aurora Ops` | Operations | Deployment, monitoring |
| | `@Aurora Monitoring` | Observability | Metrics, alerts |
| | `@Aurora Status` | Project status | Progress reports |
| **EVOLUTION** | | | |
| | `@Aurora Improve` | Improvements | Refactoring proposals |
| | `@Aurora Postmortem` | Incident analysis | After incidents |
| | `@Aurora Alignment` | Alignment check | Business-tech sync |
| | `@Aurora Deps` | Dependencies | Update deps |
| **RETIREMENT** | | | |
| | `@Aurora Retire` | Decommission | End of life |

📚 **Full documentation**: [.github/agents/README.md](.github/agents/README.md)

---

## 📜 Automation Scripts

Scripts are available in **Bash** (Linux/macOS/WSL) and **PowerShell** (Windows):

### Script Reference

| Task | Bash | PowerShell | Related Agent |
|------|------|------------|---------------|
| **INCEPTION** | | | |
| Initialize project | `init.sh` | `Init.ps1` | `@AURORA` |
| **DISCOVERY** | | | |
| Create feature | `create-new-feature.sh` | `Create-NewFeature.ps1` | `@Aurora Feature` |
| Generate use cases | `generate-usecases.sh` | `Generate-UseCases.ps1` | `@Aurora Use Case` |
| Generate Gherkin | `generate-gherkin.sh` | `Generate-Gherkin.ps1` | `@Aurora Gherkin` |
| Validate specs | `validate-specs.sh` | `Validate-Specs.ps1` | `@Aurora Specify` |
| **CONSTRUCTION** | | | |
| Generate tests | `generate-tests.sh` | `Generate-Tests.ps1` | `@Aurora Testing` |
| Quality gates | `quality-gates.sh` | `Quality-Gates.ps1` | `@Aurora Review` |
| Create ADR | `create-adr.sh` | `Create-ADR.ps1` | `@Aurora ADR` |
| **TRANSITION** | | | |
| Create release | `create-release.sh` | `Create-Release.ps1` | `@Aurora Release` |
| Deploy | `deploy.sh` | - | `@Aurora Ops` |
| **PRODUCTION** | | | |
| Project status | `project-status.sh` | `Get-ProjectStatus.ps1` | `@Aurora Status` |
| Ops status | `ops-status.sh` | `Get-OpsStatus.ps1` | `@Aurora Ops` |
| **EVOLUTION** | | | |
| Alignment analysis | `alignment-analysis.sh` | `Get-AlignmentAnalysis.ps1` | `@Aurora Alignment` |
| Analyze improvements | `analyze-improvements.sh` | `Get-Improvements.ps1` | `@Aurora Improve` |
| Generate postmortem | `generate-postmortem.sh` | `Generate-Postmortem.ps1` | `@Aurora Postmortem` |
| **RETIREMENT** | | | |
| Plan retirement | `plan-retirement.sh` | `Plan-Retirement.ps1` | `@Aurora Retire` |
| **UTILITIES** | | | |
| Update agent context | `update-agent-context.sh` | `Update-AgentContext.ps1` | - |
| Generate structure | `generate-project-structure.sh` | - | - |

### Usage Examples

```bash
# Linux/macOS/WSL
./init.sh ../my-project green --scope app-only --backend csharp
./.aurora/scripts/bash/create-new-feature.sh "payment"
./.aurora/scripts/bash/quality-gates.sh

# Windows PowerShell
.\scripts\powershell\Init.ps1
.\scripts\powershell\Create-NewFeature.ps1 -Name "payment"
.\scripts\powershell\Quality-Gates.ps1
```

📚 **Full documentation**: [scripts/README.md](scripts/README.md)

---

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | Push/PR | Build, test, lint |
| `cd.yml` | Main branch | Deploy to environments |
| `security-scan.yml` | Daily | Security scanning |
| `release.yml` | Tags | Version releases |

---

## Documentation

- **Agents**: `/.github/agents/` - AI agent definitions (29 agents)
- **Prompts**: `/.github/prompts/` - Reusable prompt templates (18 prompts)
- **Scripts**: `/scripts/` - Automation scripts (36 scripts)
- **Constitution**: `/.aurora/memory/constitution.md` - Project governance
- **API Documentation**: `/docs/api/`
- **Architecture Decisions**: `/docs/adr/`

---

## Contributing

1. Create a feature branch from `develop`
2. Follow the Bolt workflow (intent → spec → plan → implement)
3. Ensure all tests pass
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- **AURORA-IA Methodology** - AI-native development approach
- **AWS AI-DLC** - AI-Driven Development Lifecycle framework
- **Domain-Driven Design** - Strategic and tactical patterns
- **Clean Architecture** - Separation of concerns principles

---

## Contact

- **Project Lead**: [Name]
- **Repository**: [GitHub URL]
- **Documentation**: [Wiki URL]
