# AURORA-IA Slash Commands

This directory contains executable slash commands for AI agents implementing the AURORA-IA / AI-DLC methodology.

## Command Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                 🌅 AURORA-IA COMMAND WORKFLOW                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  /aurora.constitution  ──→ Define project principles & stack        │
│         │                                                           │
│         ▼                                                           │
│  /aurora.feature       ──→ Create feature specification             │
│         │                                                           │
│         ▼                                                           │
│  /aurora.specify       ──→ Define requirements & user stories       │
│         │                                                           │
│         ▼                                                           │
│  /aurora.clarify       ──→ Resolve ambiguities (optional)           │
│         │                                                           │
│         ▼                                                           │
│  /aurora.plan          ──→ Create technical implementation plan     │
│         │                                                           │
│         ▼                                                           │
│  /aurora.tasks         ──→ Generate Bolt task lists                 │
│         │                                                           │
│         ▼                                                           │
│  /aurora.implement     ──→ Execute tasks and generate code          │
│         │                                                           │
│         ▼                                                           │
│  /aurora.test          ──→ Generate test suites                     │
│         │                                                           │
│         ▼                                                           │
│  /aurora.analyze       ──→ Validate consistency & coverage          │
│         │                                                           │
│         ▼                                                           │
│  /aurora.review        ──→ Perform code review                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Available Commands

| Command | File | Description | Phase |
|---------|------|-------------|-------|
| `/aurora.constitution` | [aurora.constitution.md](aurora.constitution.md) | Establish project governing principles | Foundation |
| `/aurora.specify` | [aurora.specify.md](aurora.specify.md) | Define feature requirements | Discovery |
| `/aurora.clarify` | [aurora.clarify.md](aurora.clarify.md) | Clarify ambiguous requirements | Discovery |
| `/aurora.feature` | [aurora.feature.md](aurora.feature.md) | Create new feature specification | Discovery |
| `/aurora.usecase` | [aurora.usecase.md](aurora.usecase.md) | Generate detailed use cases | Discovery |
| `/aurora.gherkin` | [aurora.gherkin.md](aurora.gherkin.md) | Generate BDD scenarios | Discovery |
| `/aurora.plan` | [aurora.plan.md](aurora.plan.md) | Create implementation plan | Design |
| `/aurora.adr` | [aurora.adr.md](aurora.adr.md) | Create Architecture Decision Record | Design |
| `/aurora.tasks` | [aurora.tasks.md](aurora.tasks.md) | Generate Bolt task lists | Construction |
| `/aurora.implement` | [aurora.implement.md](aurora.implement.md) | Execute implementation tasks | Construction |
| `/aurora.test` | [aurora.test.md](aurora.test.md) | Generate test suites | Construction |
| `/aurora.analyze` | [aurora.analyze.md](aurora.analyze.md) | Cross-artifact consistency check | Validation |
| `/aurora.review` | [aurora.review.md](aurora.review.md) | Perform code review | Validation |

## Constitution Authority

The **Constitution** (`/memory/constitution.md`) is the **single source of truth** for:

- **Tech Stack**: Frontend, Backend, Database, Infrastructure technologies
- **Architecture Principles**: Patterns, styles, constraints
- **Code Standards**: Naming conventions, formatting, documentation
- **Quality Gates**: Testing requirements, coverage thresholds
- **Security Policies**: Authentication, authorization, data protection
- **CI/CD Pipeline**: Build, test, deploy configurations

**All agents MUST respect the Constitution.** Any deviation requires explicit constitution amendment.

## Command Structure

Each command file follows this structure:

```markdown
---
description: What this command does
handoffs:
  - label: Next Command Name
    agent: aurora.next-command
    prompt: Transition prompt
scripts:
  sh: scripts/bash/command-script.sh
  ps: scripts/powershell/command-script.ps1
---

## User Input
$ARGUMENTS

## Outline
[Command execution steps]

## Output
[Expected deliverables]
```

## Script Integration

Commands can execute scripts for automation:

- **Bash scripts**: `scripts/bash/`
- **PowerShell scripts**: `scripts/powershell/`

Scripts handle:
- File creation and management
- Git operations
- Template processing
- Environment setup

## Usage Examples

### Initialize a New Project
```
/aurora.constitution 
Stack: React + TypeScript frontend, Node.js + Express backend, 
PostgreSQL database, Terraform on AWS
```

### Define a Feature
```
/aurora.specify 
User authentication with OAuth2 social login (Google, GitHub)
and email/password registration
```

### Create Implementation Plan
```
/aurora.plan
Use JWT for sessions, bcrypt for passwords, Redis for session cache
```

### Generate Bolt Tasks
```
/aurora.tasks
Break into 2-day Bolts, prioritize core auth flow first
```

## AI Agent Compatibility

These commands work with:
- GitHub Copilot (VS Code)
- Claude Code
- Cursor
- Windsurf
- Amazon Q Developer
- Other AI coding assistants

## Related Resources

- **Agents**: `../.github/copilot/agents/`
- **Prompts**: `../.github/prompts/`
- **Workflows**: `../.github/workflows/`
- **Constitution**: `../../memory/constitution.md`
