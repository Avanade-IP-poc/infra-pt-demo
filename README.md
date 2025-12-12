# AURORA-IA / AI-DLC Project Template

> **AI-Unified Requirements, Orchestration, Reasoning & Automation** Combined with **AWS AI-Driven
> Development Lifecycle with Bolts**

[![License](https://img.shields.io/badge/license-CUSTOM-orange.svg)](LICENSE)
[![AURORA-IA](https://img.shields.io/badge/methodology-AURORA--IA-orange.svg)](.github/copilot/agents/)
[![AI-DLC](https://img.shields.io/badge/lifecycle-AI--DLC-orange.svg)](.github/commands/)

---

## Overview

This repository serves as a project template implementing the **AURORA-IA** + **AI-DLC**
methodology - a comprehensive AI-native approach to software development that replaces traditional
sprints with intelligent, micro-iteration "Bolts" orchestrated by specialized AI agents.

### What is AURORA-IA?

**AURORA** (AI-Unified Requirements, Orchestration, Reasoning & Automation) is an 8-stage cognitive
framework that mirrors human problem-solving patterns while leveraging AI capabilities:

```text
┌─────────────────────────────────────────────────────────────────────┐
│                    AURORA-IA COGNITIVE STAGES                       │
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

**AI-DLC** (AI-Driven Development Lifecycle) is an AWS-inspired framework that organizes development
into 7 blocks with **Bolts** (micro-iterations of 2-3 days):

| Block           | Phase        | Focus                               |
| --------------- | ------------ | ----------------------------------- |
| 🎯 Inception    | Discovery    | Vision, stakeholders, initial scope |
| 🔍 Discovery    | Analysis     | Requirements, domain modeling       |
| 🎨 Design       | Architecture | Technical design, API contracts     |
| 🔨 Construction | Development  | Implementation in Bolts             |
| 🚀 Release      | Delivery     | Deployment, rollout                 |
| ⚙️ Operations   | Maintenance  | Monitoring, support                 |
| 📈 Evolution    | Improvement  | Refactoring, optimization           |

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

```text
.
├── .github/
│   ├── copilot/
│   │   └── agents/      # AI Agent documentation (18 agents)
│   ├── commands/        # Slash Commands with embedded templates
│   ├── prompts/         # Copilot prompt files (15 prompts)
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

This project is supported by **18 specialized AI agents** organized across the development
lifecycle:

### Agent Categories

| Category         | Agents                                                                       | Purpose                 |
| ---------------- | ---------------------------------------------------------------------------- | ----------------------- |
| **Discovery**    | Business Explorer, Domain Sage, Technical Detective, Legacy Archaeologist    | Requirements & Analysis |
| **Design**       | DDD Master, Omega Architect                                                  | Architecture & Modeling |
| **Construction** | Micro Iterator, Policy Guardian, Coding Agent, Test Inspector, Infra Builder | Development             |
| **Release**      | Release Orchestrator                                                         | Deployment              |
| **Operations**   | Proactive Operator, Ops Bugfix Autonomous                                    | Monitoring & Support    |
| **Evolution**    | Surgical Refactorer, Continuous Evolver, Final Archiver                      | Improvement             |

📚 **Full documentation**: [.github/copilot/agents/README.md](.github/copilot/agents/README.md)

---

## Development Workflow

### 1. Constitution Phase

```bash
# Establish project governance
/aurora.constitution
# Defines: tech stack, principles, quality gates
```

### 2. Feature Definition Phase

```bash
# Create new feature specification
/aurora.feature user-authentication
# Creates: specs/001-user-authentication/ with:
#   - requirements/requirements.md
#   - contracts/openapi.yaml
#   - tests/feature.feature
#   - planning/plan.md, tasks.md
```

### 3. Planning Phase

```bash
# Create implementation plan
/aurora.plan
# Creates: plan.md with Bolts breakdown
```

### 4. Implementation Bolts

Each Bolt follows:

1. **Design** → Domain model, API contract
2. **Implement** → Clean code with tests
3. **Review** → Code review, validation
4. **Integrate** → Merge and deploy

### 5. Validation

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run contract tests
npm run test:contracts
```

---

## Scripts

| Script                  | Description              |
| ----------------------- | ------------------------ |
| `npm run dev`           | Start development server |
| `npm run build`         | Build for production     |
| `npm test`              | Run test suite           |
| `npm run test:coverage` | Run tests with coverage  |
| `npm run lint`          | Run linter               |
| `npm run format`        | Format code              |
| `npm run typecheck`     | TypeScript type checking |

---

## CI/CD

This project uses GitHub Actions for continuous integration and deployment:

| Workflow            | Trigger     | Purpose                |
| ------------------- | ----------- | ---------------------- |
| `ci.yml`            | Push/PR     | Build, test, lint      |
| `cd.yml`            | Main branch | Deploy to environments |
| `security-scan.yml` | Daily       | Security scanning      |
| `release.yml`       | Tags        | Version releases       |

---

## Documentation

- **API Documentation**: `/docs/api/`
- **Architecture Decisions**: `/docs/adr/`
- **Agent Documentation**: `/.github/copilot/agents/`
- **Slash Commands**: `/.github/commands/`
- **Prompts**: `/.github/prompts/`
- **Constitution**: `/memory/constitution.md`

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
