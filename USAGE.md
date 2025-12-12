# 🌅 AURORA-IA Usage Guide

> **AI-Unified Requirements, Orchestration, Reasoning & Automation**

Complete guide to using AURORA-IA with GitHub Copilot Chat.

---

## 🎯 What is AURORA-IA?

**AURORA-IA** is an AI-native development methodology that provides:

- **18 Specialized AI Agents** across 7 development phases
- **13 Slash Commands** (`/aurora.*`) for workflow automation
- **15 Context Prompts** for specific development tasks
- **1 Constitution** as the single source of truth

All components are unified under the **AURORA** namespace.

---

## ⚡ Quick Start

```text
Step 1: /aurora.constitution     → Define your project DNA
Step 2: /aurora.feature myapp    → Create feature specification
Step 3: /aurora.plan             → Generate implementation plan
Step 4: /aurora.implement        → Start coding with AI assistance
```

---

## 📋 Quick Reference

| Element          | Location                             | How to Use                 |
| ---------------- | ------------------------------------ | -------------------------- |
| **Commands**     | `.github/commands/aurora.*.md`       | Type `/aurora.xxx` in chat |
| **Prompts**      | `.github/prompts/aurora-*.prompt.md` | Attach with `#file:` or 📎 |
| **Agents**       | `.github/copilot/agents/aurora-*.md` | Auto-loaded by prompts     |
| **Constitution** | `memory/constitution.md`             | Auto-read by agents        |

---

## 🔧 AURORA Commands (Slash Commands)

Commands are invoked with `/aurora.` prefix in GitHub Copilot Chat.

### Available Commands

| Command                  | Purpose                                   | Phase        |
| ------------------------ | ----------------------------------------- | ------------ |
| `/aurora.constitution`   | Establish project governance & tech stack | Foundation   |
| `/aurora.feature [name]` | Create new feature specification          | Discovery    |
| `/aurora.specify`        | Define detailed requirements              | Discovery    |
| `/aurora.clarify`        | Resolve ambiguous requirements            | Discovery    |
| `/aurora.usecase`        | Generate use cases                        | Discovery    |
| `/aurora.gherkin`        | Generate BDD scenarios                    | Discovery    |
| `/aurora.plan`           | Create implementation plan                | Design       |
| `/aurora.adr [title]`    | Create Architecture Decision Record       | Design       |
| `/aurora.tasks`          | Generate Bolt task lists                  | Construction |
| `/aurora.implement`      | Execute implementation                    | Construction |
| `/aurora.test`           | Generate test suites                      | Construction |
| `/aurora.analyze`        | Validate consistency                      | Validation   |
| `/aurora.review`         | Perform code review                       | Validation   |

### Command Examples

**Start a new project:**

```text
/aurora.constitution
```

**Create a feature:**

```text
/aurora.feature user-authentication
```

**Document a technical decision:**

```text
/aurora.adr database-selection
```

### AURORA Workflow

```text
┌─────────────────────────────────────────────────────────────────────┐
│                    🌅 AURORA-IA WORKFLOW                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   /aurora.constitution  ──→ Define project DNA                      │
│           │                                                         │
│           ▼                                                         │
│   /aurora.feature       ──→ Specify what to build                   │
│           │                                                         │
│           ▼                                                         │
│   /aurora.plan          ──→ Plan how to build it                    │
│           │                                                         │
│           ▼                                                         │
│   /aurora.tasks         ──→ Break into Bolts (micro-iterations)     │
│           │                                                         │
│           ▼                                                         │
│   /aurora.implement     ──→ Build with AI assistance                │
│           │                                                         │
│           ▼                                                         │
│   /aurora.test          ──→ Generate tests                          │
│           │                                                         │
│           ▼                                                         │
│   /aurora.review        ──→ Quality assurance                       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 📄 AURORA Prompts

Prompts provide specialized context for development tasks. All prompts are prefixed with `aurora-`.

### Available Prompts

| Prompt                                 | Purpose                          | Phase        |
| -------------------------------------- | -------------------------------- | ------------ |
| `aurora-business-analysis.prompt.md`   | Business requirements extraction | Inception    |
| `aurora-technical-discovery.prompt.md` | Technical assessment             | Inception    |
| `aurora-legacy-analysis.prompt.md`     | Legacy system documentation      | Inception    |
| `aurora-planning.prompt.md`            | Sprint planning & Bolts          | Inception    |
| `aurora-architecture.prompt.md`        | Solution architecture            | Design       |
| `aurora-domain-modeling.prompt.md`     | DDD modeling                     | Design       |
| `aurora-code-generation.prompt.md`     | Clean code generation            | Construction |
| `aurora-test-generation.prompt.md`     | Test case creation               | Construction |
| `aurora-infrastructure.prompt.md`      | Terraform/IaC generation         | Construction |
| `aurora-security-review.prompt.md`     | Security analysis                | Construction |
| `aurora-release.prompt.md`             | CI/CD and deployment             | Delivery     |
| `aurora-operations.prompt.md`          | Monitoring & incidents           | Delivery     |
| `aurora-evolution.prompt.md`           | System evolution                 | Evolution    |
| `aurora-refactoring.prompt.md`         | Safe refactoring                 | Evolution    |
| `aurora-decommission.prompt.md`        | System decommissioning           | Sunset       |

### How to Use AURORA Prompts

#### Method 1: File Reference (Recommended)

```text
#file:.github/prompts/aurora-code-generation.prompt.md

Generate the UserService with CRUD operations
```

#### Method 2: Attach with 📎

1. Click 📎 in Copilot Chat
2. Select `.github/prompts/aurora-*.prompt.md`
3. Type your request

#### Method 3: Multiple AURORA Prompts

```text
#file:.github/prompts/aurora-domain-modeling.prompt.md
#file:.github/prompts/aurora-code-generation.prompt.md

Model and implement the Order aggregate with its entities
```

---

## 🤖 AURORA Agents (Internal)

AURORA-IA includes **18 specialized AI agents** that are automatically loaded by prompts. You don't invoke them directly.

### Agent Architecture

```text
┌─────────────────┐     references     ┌─────────────────┐     reads     ┌──────────────────┐
│  AURORA PROMPT  │ ─────────────────► │  AURORA AGENT   │ ────────────► │   CONSTITUTION   │
└─────────────────┘                    └─────────────────┘               └──────────────────┘
        │                                      │                                 │
        ▼                                      ▼                                 ▼
   Your Request              Role, Best Practices, Rules         Tech Stack, Standards, Rules
```

### Agent Catalog

| Agent                 | Role                   | Invoked By                             |
| --------------------- | ---------------------- | -------------------------------------- |
| Business Explorer     | Requirements discovery | `aurora-business-analysis.prompt.md`   |
| Technical Detective   | Technical assessment   | `aurora-technical-discovery.prompt.md` |
| Legacy Archaeologist  | Legacy analysis        | `aurora-legacy-analysis.prompt.md`     |
| Cosmic Planner        | Sprint planning        | `aurora-planning.prompt.md`            |
| Omega Architect       | Architecture design    | `aurora-architecture.prompt.md`        |
| DDD Master            | Domain modeling        | `aurora-domain-modeling.prompt.md`     |
| Domain Sage           | Business rules         | `aurora-domain-modeling.prompt.md`     |
| Coding Agent          | Code generation        | `aurora-code-generation.prompt.md`     |
| Micro Iterator        | Iterative development  | `aurora-code-generation.prompt.md`     |
| Test Inspector        | Test creation          | `aurora-test-generation.prompt.md`     |
| Infra Builder         | Infrastructure         | `aurora-infrastructure.prompt.md`      |
| Policy Guardian       | Security review        | `aurora-security-review.prompt.md`     |
| Release Orchestrator  | Deployment             | `aurora-release.prompt.md`             |
| Proactive Operator    | Operations             | `aurora-operations.prompt.md`          |
| Ops-Bugfix Autonomous | Auto-remediation       | `aurora-operations.prompt.md`          |
| Continuous Evolver    | Evolution              | `aurora-evolution.prompt.md`           |
| Surgical Refactorer   | Refactoring            | `aurora-refactoring.prompt.md`         |
| Final Archiver        | Decommissioning        | `aurora-decommission.prompt.md`        |

---

## 💡 AURORA Development Session

### Starting a New Feature with AURORA

```bash
# 1. Ensure constitution exists (first time only)
/aurora.constitution

# 2. Create feature specification
/aurora.feature payment-processing

# 3. Generate use cases
/aurora.usecase

# 4. Plan implementation
/aurora.plan

# 5. Generate task breakdown
/aurora.tasks
```

### Implementing Code with AURORA

```text
#file:.github/prompts/aurora-code-generation.prompt.md

Implement task T001: Create PaymentService in src/application/services/
```

### Writing Tests with AURORA

```text
#file:.github/prompts/aurora-test-generation.prompt.md

Generate unit tests for PaymentService covering all edge cases
```

### Security Review with AURORA

```text
#file:.github/prompts/aurora-security-review.prompt.md

Review the PaymentService for security vulnerabilities
```

### Creating an ADR with AURORA

```text
/aurora.adr payment-gateway-selection
```

---

## 🎯 AURORA Best Practices

### 1. Always Start with Constitution

The AURORA constitution is the DNA of your project:

```text
/aurora.constitution
```

### 2. Use AURORA Commands for Workflows

Commands guide you through multi-step processes with intelligent handoffs:

```text
/aurora.feature → /aurora.plan → /aurora.implement → /aurora.test
```

### 3. Use AURORA Prompts for Specific Tasks

Prompts provide focused context. Combine them for complex work:

```text
#file:.github/prompts/aurora-architecture.prompt.md
#file:.github/prompts/aurora-infrastructure.prompt.md

Design and implement the caching layer
```

### 4. Reference Context in Your Questions

Always provide context about what you're working on:

```text
#file:.github/prompts/aurora-code-generation.prompt.md
#file:specs/user-authentication/spec.md

Implement the login use case from the spec
```

### 5. Let AURORA Agents Work Together

The agents are designed to collaborate. Use handoffs in commands to flow between phases.

---

## 🔍 Troubleshooting

| Issue                        | Solution                                                                      |
| ---------------------------- | ----------------------------------------------------------------------------- |
| `/aurora.xxx` not recognized | Ensure `aurora.xxx.md` exists in `.github/commands/` with correct frontmatter |
| Prompt not loading           | Use full path: `#file:.github/prompts/aurora-xxx.prompt.md`                   |
| Constitution not found       | Run `/aurora.constitution` to create `memory/constitution.md`                 |
| Agent behavior unexpected    | Check that prompt references correct agent in `.github/copilot/agents/`       |

---

## 📚 Related Documentation

- **Commands**: [.github/commands/README.md](.github/commands/README.md)
- **Prompts**: [.github/prompts/README.md](.github/prompts/README.md)
- **Agents**: [.github/copilot/agents/README.md](.github/copilot/agents/README.md)
- **Scripts**: [scripts/README.md](scripts/README.md)

---

## 🌅 AURORA-IA Philosophy

> _"AURORA brings the dawn of AI-native development - where human creativity meets artificial intelligence in perfect harmony."_

AURORA-IA follows these core principles:

1. **Constitution First**: Every project has a single source of truth
2. **Agent Specialization**: 18 agents, each expert in their domain
3. **Bolt Methodology**: Micro-iterations for rapid, quality delivery
4. **Clean Architecture**: Domain-driven design at the core
5. **AI Collaboration**: Human intent + AI execution = Excellence

---

**Welcome to AURORA-IA** 🌅
