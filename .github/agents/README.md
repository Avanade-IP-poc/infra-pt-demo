# AURORA-IA AI Agents

This directory contains GitHub Copilot Custom Agents that implement the AURORA-IA / AI-DLC methodology.

## What are Agents?

Agents are conversational AI assistants specialized for specific tasks. Each agent has:

- **Name**: Display name for invocation (e.g., `@Bolt Testing`)
- **Description**: Brief explanation of capabilities
- **Tools**: Available VS Code built-in tools (see TOOLSETS.md)
- **Model**: AI model used (Claude Sonnet 4.5)
- **Handoffs**: Ability to delegate to other agents

## Available Agents (31 Total)

### 🌌 Orchestrator

| Agent              | File                      | Purpose                                          |
| ------------------ | ------------------------- | ------------------------------------------------ |
| **Bolt Framework** | `bolt-framework.agent.md` | Main orchestrator - routes to specialized agents |

### 📋 Discovery & Requirements

| Agent           | File                      | Purpose                                        |
| --------------- | ------------------------- | ---------------------------------------------- |
| Bolt Feature  | `aurora-feature.agent.md` | Create comprehensive feature specifications    |
| Bolt Specify  | `aurora-specify.agent.md` | Transform natural language to structured specs |
| Bolt Clarify  | `aurora-clarify.agent.md` | Clarify ambiguous requirements                 |
| Bolt Use Case | `aurora-usecase.agent.md` | Generate UML/Cockburn style use cases          |
| Bolt Gherkin  | `aurora-gherkin.agent.md` | Generate BDD scenarios in Gherkin syntax       |

### 🏛️ Architecture & Design

| Agent               | File                           | Purpose                          |
| ------------------- | ------------------------------ | -------------------------------- |
| Bolt Architect    | `aurora-architect.agent.md`    | Solution architecture and ADRs   |
| Bolt DDD          | `aurora-ddd.agent.md`          | Domain-Driven Design modeling    |
| Bolt Constitution | `aurora-constitution.agent.md` | Project governance and standards |

### 🗺️ Planning

| Agent        | File                    | Purpose                               |
| ------------ | ----------------------- | ------------------------------------- |
| Bolt Plan  | `aurora-plan.agent.md`  | Create technical implementation plans |
| Bolt Tasks | `aurora-tasks.agent.md` | Generate Bolt task lists              |

### 🏗️ Implementation

| Agent                 | File                             | Purpose                                         |
| --------------------- | -------------------------------- | ----------------------------------------------- |
| Bolt Implement      | `aurora-implement.agent.md`      | Execute implementation with quality gates       |
| Bolt Micro Iterator | `aurora-micro-iterator.agent.md` | Micro-iteration discipline                      |
| Bolt Testing        | `aurora-testing.agent.md`        | Generate test suites (TDD/BDD)                  |
| Bolt Review         | `aurora-review.agent.md`         | Code review, SOLID, and architecture validation |

### 🔍 Analysis & Quality

| Agent            | File                        | Purpose                                                              |
| ---------------- | --------------------------- | -------------------------------------------------------------------- |
| Bolt Analyze   | `aurora-analyze.agent.md`   | Consistency analysis between artifacts                               |
| Bolt Alignment | `aurora-alignment.agent.md` | Business-technical alignment                                         |
| Bolt ADR         | `bolt-adr.agent.md`         | Architecture Decision Records                                        |
| Bolt Researcher  | `bolt-researcher.agent.md`  | Research and investigate using MCP servers and project documentation |

### 🔒 Security & Compliance

| Agent           | File                       | Purpose                                              |
| --------------- | -------------------------- | ---------------------------------------------------- |
| Bolt Security | `aurora-security.agent.md` | Comprehensive security analysis and OWASP compliance |

### 📦 Release & Operations

| Agent             | File                         | Purpose                          |
| ----------------- | ---------------------------- | -------------------------------- |
| Bolt Release    | `aurora-release.agent.md`    | Semantic versioning and releases |
| Bolt Ops        | `aurora-ops.agent.md`        | Deployments and monitoring       |
| Bolt Status     | `aurora-status.agent.md`     | Project status reports           |
| Bolt Postmortem | `aurora-postmortem.agent.md` | Incident postmortems             |

### 📈 Evolution & Improvement

| Agent          | File                      | Purpose                         |
| -------------- | ------------------------- | ------------------------------- |
| Bolt Improve | `aurora-improve.agent.md` | Continuous improvement analysis |
| Aurora Retire  | `aurora-retire.agent.md`  | System decommissioning          |

### 🛠️ Infrastructure & DevOps

| Agent                | File                          | Purpose                             |
| -------------------- | ----------------------------- | ----------------------------------- |
| Bolt Skill Creator   | `bolt-skill-creator.agent.md` | AI-powered skill creation & testing |
| Bolt Templates     | `aurora-templates.agent.md`   | Project templates and scaffolding   |
| Bolt CI/CD         | `aurora-cicd.agent.md`        | Pipeline configuration              |
| Aurora Dependencies  | `aurora-deps.agent.md`        | Dependency management               |
| Aurora Documentation | `aurora-docs.agent.md`        | Documentation generation            |
| Aurora Monitoring    | `aurora-monitoring.agent.md`  | Observability setup                 |

## Usage

### Invoke an Agent

In VS Code Copilot Chat, use the `@` prefix:

```
@Bolt Testing generate unit tests for the UserService class

@Bolt Implement implement the authentication feature

@Bolt Framework help me start a new feature for user registration
```

### Agent Handoffs

Agents can delegate to each other. When you see handoff buttons:

- Click to delegate the task to a specialized agent
- The context is passed automatically
- You can chain multiple agents for complex workflows

### Agent + Prompt Workflow

Agents can reference prompts for additional context:

```
@Bolt Testing #file:.github/prompts/bolt-test-generation.prompt.md
Generate comprehensive tests for the payment module
```

### Agent + Script Workflow

Agents can execute automation scripts when needed. Each agent documents its available scripts in the "Available Scripts" section.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION                                 │
│                    @Bolt Framework, @Bolt Testing, etc.                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌────────────────────────────────────────────────────────────┐    │
│   │                    🤖 AGENTS (31)                               │    │
│   │         Conversational interface with users                     │    │
│   │                                                                 │    │
│   │   Tools: codebase, search, edit, runInTerminal, etc.            │    │
│   │   Handoffs: Delegate to other agents                           │    │
│   └────────────────────────┬───────────────────────────────────────┘    │
│                            │                                             │
│              ┌─────────────┼─────────────┐                              │
│              ▼             ▼             ▼                              │
│   ┌──────────────┐ ┌──────────────┐ ┌──────────────┐                   │
│   │  📝 Prompts  │ │  ⚙️ Scripts  │ │ 📜 Constitution│                  │
│   │  (18 files)  │ │  (36 files)  │ │    (1 file)   │                   │
│   │              │ │              │ │               │                   │
│   │ Reusable     │ │ Automation   │ │ Project DNA   │                   │
│   │ instructions │ │ tasks        │ │ & standards   │                   │
│   └──────────────┘ └──────────────┘ └──────────────┘                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Agent File Structure

Each agent follows this YAML frontmatter structure:

```yaml
---
name: Aurora Agent Name
description: 📝 Brief description of capabilities
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - runSubagent
  - VSCodeAPI
  - context7/*
  - awesome-copilot/*
  - microsoftdocs/*
model: Claude Sonnet 4.5
handoffs:
  - label: 🔗 Handoff Label
    agent: Aurora Other Agent
    prompt: Context for the delegation
    send: false
---

# Agent Title

## Available Scripts

When you need automation, execute these scripts:
- **Bash**: `scripts/bash/script-name.sh`
- **PowerShell**: `scripts/powershell/Script-Name.ps1`

[Agent instructions and documentation...]
```

## Supported Tools

Agents use VS Code built-in tools organized in 9 toolset categories.
See `.github/skills/bolt-framework/examples/TOOLSETS.md` for the complete reference.

**Namespace shortcuts** (recommended):
`search`, `execute`, `read`, `edit`, `web`, `vscode`, `agent`, `todo`, `memory`

**Specialized tools**:
`problems`, `terminalLastCommand`, `selection`, `extensions`, `installExtension`,
`getProjectSetupInfo`, `editNotebook`, `readNotebookCellOutput`, `getNotebookSummary`

**MCP servers**:
`'context7/*'`, `'awesome-copilot/*'`, `'microsoftdocs/mcp/*'`, `'github/*'`,
`'azure-mcp/*'`, `'bicep/*'`, `'angular-cli/*'`, `'azure-devops/*'`

## Related Resources

- **Prompts**: `.github/prompts/` - Reusable instruction templates
- **Scripts**: `scripts/bash/` and `scripts/powershell/` - Automation scripts
- **Constitution**: `.boltf/memory/constitution.md` - Project governance
- **Workflows**: `.github/workflows/` - GitHub Actions CI/CD

## Migration from Commands

The previous `/aurora.*` slash commands have been replaced by agents:

| Old Command            | New Agent              |
| ---------------------- | ---------------------- |
| `/aurora.feature`      | `@Bolt Feature`      |
| `/aurora.implement`    | `@Bolt Implement`    |
| `/aurora.test`         | `@Bolt Testing`      |
| `/aurora.plan`         | `@Bolt Plan`         |
| `/aurora.constitution` | `@Bolt Constitution` |
| `/aurora.status`       | `@Bolt Status`       |
| `/aurora`              | `@Bolt Framework`      |

## Best Practices

1. **Start with Bolt Framework**: Use `@Bolt Framework` to get guidance on which agent to use
2. **Read Constitution First**: Agents automatically reference `.boltf/memory/constitution.md`
3. **Use Handoffs**: Let agents delegate to specialists when appropriate
4. **Chain Workflows**: Feature → Plan → Tasks → Implement → Test → Review
5. **Execute Scripts**: Use the `execute` tool for automation tasks
6. **Run Quality Gates**: Execute `scripts/bash/quality-gates.sh` (multi-language support)
7. **Architecture Validation**: Use `npm run arch:check` and `arch:graph` for Mermaid diagrams
