# AURORA-IA / AI-DLC Copilot Prompts Directory

This directory contains GitHub Copilot prompt files (`.prompt.md`) that provide context and instructions for AI-assisted development within the AURORA-IA methodology.

## Purpose

Copilot prompts help ensure consistent, high-quality AI assistance aligned with:
- **AURORA-IA**: 7-block AI-native development methodology
- **AI-DLC**: AWS AI-Driven Development Lifecycle with Bolts
- **Constitution**: Central governance through `memory/constitution.md`

## Available Prompts (15 Total)

### Block 1: Inception - Discovery & Analysis

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-business-analysis.prompt.md` | `aurora-business-explorer.md` | Business requirements extraction, stakeholder analysis |
| `aurora-technical-discovery.prompt.md` | `aurora-technical-detective.md` | Technical assessment, stack analysis, constraints |
| `aurora-legacy-analysis.prompt.md` | `aurora-legacy-archaeologist.md` | Legacy system documentation, migration planning |

### Block 2: Inception - Planning & Architecture

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-planning.prompt.md` | `aurora-cosmic-planner.md` | Sprint planning, Bolts definition, task breakdown |
| `aurora-architecture.prompt.md` | `aurora-omega-architect.md` | Solution architecture, design decisions |
| `aurora-domain-modeling.prompt.md` | `aurora-ddd-master.md`, `aurora-domain-sage.md` | Domain-Driven Design, bounded contexts |

### Block 3: Construction - Implementation

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-code-generation.prompt.md` | `aurora-coding-agent.md`, `aurora-micro-iterator.md` | Clean code generation following Constitution |
| `aurora-test-generation.prompt.md` | `aurora-test-inspector.md` | Test case creation (BDD/TDD/Unit) |
| `aurora-infrastructure.prompt.md` | `aurora-infra-builder.md` | Terraform/IaC generation |

### Block 4: Construction - Security & Quality

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-security-review.prompt.md` | `aurora-policy-guardian.md` | Security analysis, OWASP, policy compliance |

### Block 5: Delivery - Release & Operations

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-release.prompt.md` | `aurora-release-orchestrator.md` | CI/CD, versioning, deployment strategies |
| `aurora-operations.prompt.md` | `aurora-proactive-operator.md`, `aurora-ops-bugfix-autonomous.md` | Monitoring, alerting, incident response |

### Block 6: Evolution - Continuous Improvement

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-evolution.prompt.md` | `aurora-continuous-evolver.md` | System evolution, tech debt management |
| `aurora-refactoring.prompt.md` | `aurora-surgical-refactorer.md` | Safe refactoring patterns, code improvement |

### Block 7: Sunset - End of Life

| Prompt | Agent Reference | Purpose |
|--------|-----------------|---------|
| `aurora-decommission.prompt.md` | `aurora-final-archiver.md` | System decommissioning, archival, data migration |

## Usage

### In VS Code with Copilot Chat

Reference prompts using `#file` directive:

```
#file:.github/prompts/aurora-domain-modeling.prompt.md

Analyze the domain for our e-commerce system
```

### With GitHub Copilot Agent Mode

Agents automatically pick up relevant prompts. The prompt references which agent to use:

```markdown
## Agent Reference

> **Primary Agent**: [DDD Master](../copilot/agents/aurora-ddd-master.md)  
> **Phase**: Block 2 - Inception (Planning & Architecture)  
> **Constitution**: Read `memory/constitution.md` for tech stack and standards
```

### Prompt + Agent Workflow

1. **Select the prompt** for your task type
2. **Copilot loads the agent** referenced in the prompt
3. **Agent reads Constitution** for project-specific standards
4. **AI generates** context-aware output

## Prompt Structure

All prompts follow this consistent structure:

```markdown
# [Prompt Title]

## Context
[When this prompt applies and its purpose]

## Agent Reference
> **Primary Agent**: [Agent Name](../copilot/agents/agent-file.md)  
> **Phase**: Block X - Phase Name  
> **Constitution**: Read `memory/constitution.md` for tech stack and standards

## Instructions
[Detailed guidance for Copilot]

## Input Requirements
[What information is needed]

## Output Format
[Expected deliverables and format]

## Examples
[Input/Output examples when applicable]

## Quality Criteria
[Success criteria and validation points]
```

## Validation

Use the validation scripts to ensure prompt-agent-constitution consistency:

```bash
# Bash
./scripts/bash/update-agent-context.sh --check

# PowerShell
.\scripts\powershell\Update-AgentContext.ps1 -Mode Check
```

## Related Resources

- **Agents**: `.github/copilot/agents/` - AI agent definitions
- **Workflows**: `.github/workflows/` - GitHub Actions
- **Commands**: `.github/commands/` - PO/Developer commands
- **Constitution**: `memory/constitution.md` - Project governance

## Methodology Integration

Prompts map to AURORA-IA blocks and lifecycle phases:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     PROMPT → BLOCK MAPPING                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  BLOCK 1: INCEPTION (Discovery)                                         │
│    ├── aurora-business-analysis.prompt.md   → Aurora Business Explorer  │
│    ├── aurora-technical-discovery.prompt.md → Aurora Technical Detective│
│    └── aurora-legacy-analysis.prompt.md     → Aurora Legacy Archaeologist│
│                                                                         │
│  BLOCK 2: INCEPTION (Planning)                                          │
│    ├── aurora-planning.prompt.md            → Aurora Cosmic Planner     │
│    ├── aurora-architecture.prompt.md        → Aurora Omega Architect    │
│    └── aurora-domain-modeling.prompt.md     → Aurora DDD Master + Sage  │
│                                                                         │
│  BLOCK 3: CONSTRUCTION (Implementation)                                 │
│    ├── aurora-code-generation.prompt.md     → Aurora Coding Agent       │
│    ├── aurora-test-generation.prompt.md     → Aurora Test Inspector     │
│    └── aurora-infrastructure.prompt.md      → Aurora Infra Builder      │
│                                                                         │
│  BLOCK 4: CONSTRUCTION (Security)                                       │
│    └── aurora-security-review.prompt.md     → Aurora Policy Guardian    │
│                                                                         │
│  BLOCK 5: DELIVERY                                                      │
│    ├── aurora-release.prompt.md             → Aurora Release Orchestrator│
│    └── aurora-operations.prompt.md          → Aurora Proactive Operator │
│                                                                         │
│  BLOCK 6: EVOLUTION                                                     │
│    ├── aurora-evolution.prompt.md           → Aurora Continuous Evolver │
│    └── aurora-refactoring.prompt.md         → Aurora Surgical Refactorer│
│                                                                         │
│  BLOCK 7: SUNSET                                                        │
│    └── aurora-decommission.prompt.md        → Aurora Final Archiver     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```
