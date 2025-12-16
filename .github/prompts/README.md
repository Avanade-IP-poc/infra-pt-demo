# AURORA-IA / AI-DLC Copilot Prompts Directory

This directory contains GitHub Copilot prompt files (`.prompt.md`) that provide context and instructions for AI-assisted development within the AURORA-IA methodology.

## Purpose

Copilot prompts help ensure consistent, high-quality AI assistance aligned with:
- **AURORA-IA**: 7-block AI-native development methodology
- **AI-DLC**: AWS AI-Driven Development Lifecycle with Bolts
- **Constitution**: Central governance through `memory/constitution.md`

## How Prompts Relate to Agents

Prompts are **reusable instruction templates** that agents can reference for additional context:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AGENTS → PROMPTS RELATIONSHIP                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   🤖 AGENT                         📝 PROMPT                             │
│   (Conversational)                 (Instructions)                        │
│                                                                          │
│   @Aurora Testing       ──uses──>  aurora-test-generation.prompt.md     │
│   @Aurora Implement     ──uses──>  aurora-code-generation.prompt.md     │
│   @Aurora Architect     ──uses──>  aurora-architecture.prompt.md        │
│   @Aurora DDD           ──uses──>  aurora-domain-modeling.prompt.md     │
│   @Aurora Release       ──uses──>  aurora-release.prompt.md             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Available Prompts (18 Total)

### Block 1: Inception - Discovery & Analysis

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-business-analysis.prompt.md` | Aurora Feature | Business requirements extraction |
| `aurora-technical-discovery.prompt.md` | Aurora Analyze | Technical assessment |
| `aurora-legacy-analysis.prompt.md` | Aurora Analyze | Legacy system documentation |

### Block 2: Inception - Planning & Architecture

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-planning.prompt.md` | Aurora Plan | Sprint planning, Bolts definition |
| `aurora-architecture.prompt.md` | Aurora Architect | Solution architecture |
| `aurora-domain-modeling.prompt.md` | Aurora DDD | Domain-Driven Design |

### Block 3: Construction - Implementation

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-code-generation.prompt.md` | Aurora Implement | Clean code generation |
| `aurora-test-generation.prompt.md` | Aurora Testing | Test case creation (BDD/TDD) |
| `aurora-infrastructure.prompt.md` | Aurora CI/CD | Terraform/IaC generation |

### Block 4: Construction - Security & Quality

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-security-review.prompt.md` | Aurora Review | Security analysis, OWASP |
| `aurora-guardrails.prompt.md` | Aurora Review | Policy compliance |

### Block 5: Delivery - Release & Operations

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-release.prompt.md` | Aurora Release | CI/CD, versioning |
| `aurora-operations.prompt.md` | Aurora Ops | Monitoring, alerting |

### Block 6: Evolution - Continuous Improvement

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-evolution.prompt.md` | Aurora Improve | System evolution, tech debt |
| `aurora-refactoring.prompt.md` | Aurora Implement | Safe refactoring patterns |

### Block 7: Sunset - End of Life

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora-decommission.prompt.md` | Aurora Retire | System decommissioning |

### Cross-Phase

| Prompt | Related Agent | Purpose |
|--------|---------------|---------|
| `aurora.prompt.md` | AURORA | Main orchestrator instructions |
| `aurora-structure-generator.prompt.md` | Aurora Templates | Project scaffolding |

## Usage

### Method 1: Reference in Chat

Use the `#file` directive to add prompt context to any chat:

```
#file:.github/prompts/aurora-test-generation.prompt.md
Generate comprehensive tests for the UserService class
```

### Method 2: Use with Agent

Combine agent invocation with prompt context:

```
@Aurora Testing #file:.github/prompts/aurora-test-generation.prompt.md
Generate BDD tests for the payment module
```

### Method 3: Agent Auto-Discovery

Agents automatically pick up relevant prompts based on the task. The agent will reference the appropriate prompt internally.

## Prompt + Agent + Script Workflow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    COMPLETE WORKFLOW EXAMPLE                             │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   1. USER: @Aurora Testing generate tests for auth module                │
│                                                                          │
│   2. AGENT: Aurora Testing                                               │
│      ├── Reads: aurora-test-generation.prompt.md (instructions)         │
│      ├── Reads: memory/constitution.md (standards)                      │
│      └── Generates: Test code following BDD/TDD patterns                │
│                                                                          │
│   3. AGENT: Executes script (if needed)                                  │
│      └── scripts/bash/generate-tests.sh                                  │
│                                                                          │
│   4. OUTPUT: Comprehensive test suite                                    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Related Resources

- **Agents**: `.github/agents/` - AI agent definitions (29 agents)
- **Scripts**: `scripts/bash/` and `scripts/powershell/` - Automation
- **Constitution**: `memory/constitution.md` - Project governance
- **Workflows**: `.github/workflows/` - GitHub Actions

## Validation

Use validation scripts to ensure prompt-agent consistency:

```bash
# Bash
./scripts/bash/update-agent-context.sh --check

# PowerShell
.\scripts\powershell\Update-AgentContext.ps1 -Mode Check
```
