# AURORA-IA AI Agents

This directory contains GitHub Copilot Custom Agents that implement the AURORA-IA / AI-DLC methodology.

## What are Agents?

Agents are conversational AI assistants specialized for specific tasks. Each agent has:
- **Name**: Display name for invocation (e.g., `@Aurora Testing`)
- **Description**: Brief explanation of capabilities
- **Tools**: Available actions (`read`, `edit`, `execute`, `search`, `web`)
- **Model**: AI model used (Claude Sonnet 4)
- **Handoffs**: Ability to delegate to other agents

## Available Agents (29 Total)

### 🌌 Orchestrator

| Agent | File | Purpose |
|-------|------|---------|
| **AURORA** | `aurora.agent.md` | Main orchestrator - routes to specialized agents |

### 📋 Discovery & Requirements

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Feature | `aurora-feature.agent.md` | Create comprehensive feature specifications |
| Aurora Specify | `aurora-specify.agent.md` | Transform natural language to structured specs |
| Aurora Clarify | `aurora-clarify.agent.md` | Clarify ambiguous requirements |
| Aurora Use Case | `aurora-usecase.agent.md` | Generate UML/Cockburn style use cases |
| Aurora Gherkin | `aurora-gherkin.agent.md` | Generate BDD scenarios in Gherkin syntax |

### 🏛️ Architecture & Design

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Architect | `aurora-architect.agent.md` | Solution architecture and ADRs |
| Aurora DDD | `aurora-ddd.agent.md` | Domain-Driven Design modeling |
| Aurora Constitution | `aurora-constitution.agent.md` | Project governance and standards |

### 🗺️ Planning

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Plan | `aurora-plan.agent.md` | Create technical implementation plans |
| Aurora Tasks | `aurora-tasks.agent.md` | Generate Bolt task lists |

### 🏗️ Implementation

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Implement | `aurora-implement.agent.md` | Execute implementation with quality gates |
| Aurora Micro Iterator | `aurora-micro-iterator.agent.md` | Micro-iteration discipline |
| Aurora Testing | `aurora-testing.agent.md` | Generate test suites (TDD/BDD) |
| Aurora Review | `aurora-review.agent.md` | Code review, SOLID, and architecture validation |

### 🔍 Analysis & Quality

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Analyze | `aurora-analyze.agent.md` | Consistency analysis between artifacts |
| Aurora Alignment | `aurora-alignment.agent.md` | Business-technical alignment |
| Aurora ADR | `aurora-adr.agent.md` | Architecture Decision Records |

### 🔒 Security & Compliance

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Security | `aurora-security.agent.md` | Comprehensive security analysis and OWASP compliance |

### 📦 Release & Operations

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Release | `aurora-release.agent.md` | Semantic versioning and releases |
| Aurora Ops | `aurora-ops.agent.md` | Deployments and monitoring |
| Aurora Status | `aurora-status.agent.md` | Project status reports |
| Aurora Postmortem | `aurora-postmortem.agent.md` | Incident postmortems |

### 📈 Evolution & Improvement

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Improve | `aurora-improve.agent.md` | Continuous improvement analysis |
| Aurora Retire | `aurora-retire.agent.md` | System decommissioning |

### 🛠️ Infrastructure & DevOps

| Agent | File | Purpose |
|-------|------|---------|
| Aurora Templates | `aurora-templates.agent.md` | Project templates and scaffolding |
| Aurora CI/CD | `aurora-cicd.agent.md` | Pipeline configuration |
| Aurora Dependencies | `aurora-deps.agent.md` | Dependency management |
| Aurora Documentation | `aurora-docs.agent.md` | Documentation generation |
| Aurora Monitoring | `aurora-monitoring.agent.md` | Observability setup |

## Usage

### Invoke an Agent

In VS Code Copilot Chat, use the `@` prefix:

```
@Aurora Testing generate unit tests for the UserService class

@Aurora Implement implement the authentication feature

@AURORA help me start a new feature for user registration
```

### Agent Handoffs

Agents can delegate to each other. When you see handoff buttons:
- Click to delegate the task to a specialized agent
- The context is passed automatically
- You can chain multiple agents for complex workflows

### Agent + Prompt Workflow

Agents can reference prompts for additional context:

```
@Aurora Testing #file:.github/prompts/aurora-test-generation.prompt.md
Generate comprehensive tests for the payment module
```

### Agent + Script Workflow

Agents can execute automation scripts when needed. Each agent documents its available scripts in the "Available Scripts" section.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION                                 │
│                    @Aurora, @Aurora Testing, etc.                        │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌────────────────────────────────────────────────────────────────┐    │
│   │                    🤖 AGENTS (29)                               │    │
│   │         Conversational interface with users                     │    │
│   │                                                                 │    │
│   │   Tools: read, edit, execute, search, web                      │    │
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
tools: ['read', 'edit', 'execute', 'search']
model: Claude Sonnet 4
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

| Tool | Alias | Purpose |
|------|-------|---------|
| `read` | filesystem | Read files and directories |
| `edit` | editFiles | Create and modify files |
| `execute` | runInTerminal | Run shell commands |
| `search` | codebase | Search code semantically |
| `web` | fetch | Fetch web content |
| `agent` | - | Delegate to other agents |

## Related Resources

- **Prompts**: `.github/prompts/` - Reusable instruction templates
- **Scripts**: `scripts/bash/` and `scripts/powershell/` - Automation scripts
- **Constitution**: `.aurora/memory/constitution.md` - Project governance
- **Workflows**: `.github/workflows/` - GitHub Actions CI/CD

## Migration from Commands

The previous `/aurora.*` slash commands have been replaced by agents:

| Old Command | New Agent |
|-------------|-----------|
| `/aurora.feature` | `@Aurora Feature` |
| `/aurora.implement` | `@Aurora Implement` |
| `/aurora.test` | `@Aurora Testing` |
| `/aurora.plan` | `@Aurora Plan` |
| `/aurora.constitution` | `@Aurora Constitution` |
| `/aurora.status` | `@Aurora Status` |
| `/aurora` | `@AURORA` |

## Best Practices

1. **Start with AURORA**: Use `@AURORA` to get guidance on which agent to use
2. **Read Constitution First**: Agents automatically reference `.aurora/memory/constitution.md`
3. **Use Handoffs**: Let agents delegate to specialists when appropriate
4. **Chain Workflows**: Feature → Plan → Tasks → Implement → Test → Review
5. **Execute Scripts**: Use the `execute` tool for automation tasks
6. **Run Quality Gates**: Execute `scripts/bash/quality-gates.sh` (multi-language support)
7. **Architecture Validation**: Use `npm run arch:check` and `arch:graph` for Mermaid diagrams
