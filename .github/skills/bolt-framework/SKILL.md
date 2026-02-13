---
name: bolt-framework
description: >
  AURORA-IA-DLC methodology - AI-Driven Development Lifecycle.
  Defines 6 lifecycle phases (Inception, Discovery, Construction, Transition,
  Production, Retirement), Bolt micro-iterations, quality gates, and
  constitution compliance. Use when orchestrating AURORA projects, routing
  between agents, implementing workflows, or enforcing methodology.
---

# Bolt Framework — AURORA-IA-DLC Methodology

## When to Use This Skill

- When orchestrating development through AURORA lifecycle phases
- When implementing features using Bolt micro-iterations
- When enforcing quality gates and constitution compliance
- When routing work between specialized agents
- When detecting project state and deciding next steps
- When initializing new workspaces or onboarding projects
- When performing legacy modernization (brownfield)

---

## 1. What is AURORA-IA-DLC?

AURORA-IA-DLC (**AI-Driven Development Lifecycle**) is an AI-powered software development methodology that guides projects through six phases using specialized agents, quality gates, and micro-iterations called **Bolts**.

### Core Principles

| Principle | Description |
|-----------|-------------|
| **Constitution is Law** | Every project has a constitution (`memory/constitution.md`) that governs all decisions |
| **Specs Before Code** | Features need specifications before implementation |
| **Micro-Iterations** | Work in small, shippable Bolts (2-3 days max) |
| **Quality Gates** | Every Bolt must pass quality gates before completion |
| **Agent Specialization** | Each agent has one responsibility; orchestrate via handoffs |
| **Continuous Validation** | Test, review, and analyze at every step |

### Project File Structure

```
project/
├── memory/
│   └── constitution.md          # Project DNA — tech stack, standards, constraints
├── specs/
│   └── XXX-feature-name/        # Feature specifications
│       ├── feature.md           # Feature spec with user stories
│       ├── requirements/        # Detailed requirements
│       │   └── requirements.md
│       ├── planning/            # Implementation plan & tasks
│       │   ├── plan.md
│       │   └── tasks.md         # Bolt task breakdown
│       └── contracts/           # API contracts (OpenAPI, AsyncAPI)
├── src/                         # Source code
├── legacy/                      # Legacy code analysis (brownfield only)
├── scripts/
│   ├── bash/                    # Bash automation scripts
│   └── powershell/              # PowerShell automation scripts
└── .github/
    ├── agents/                  # AURORA agents (30)
    ├── prompts/                 # Reusable prompts
    └── skills/                  # Skills (bolt-framework, skill-development)
```

---

## 2. Lifecycle Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        AURORA-IA-DLC LIFECYCLE                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   🌅 INCEPTION    →    🔍 DISCOVERY    →    🏗️ CONSTRUCTION                │
│   constitution         feature              implement                       │
│   clarify              specify              test                            │
│                        usecase              review                          │
│                        gherkin              analyze                         │
│                        plan                 adr                             │
│                        tasks                                                │
│                                                                             │
│   📦 TRANSITION   →    🚀 PRODUCTION   →    🌙 RETIREMENT                   │
│   release              ops                  retire                          │
│                        improve              postmortem                      │
│                        alignment                                            │
│                        status                                               │
│                        monitoring                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 🌅 INCEPTION — Project Definition

**Goal**: Define the project's DNA through its constitution.

| Agent | Purpose |
|-------|---------|
| `@Aurora Constitution` | Define tech stack, standards, architecture, and constraints |
| `@Aurora Clarify` | Resolve ambiguities in requirements through structured questioning |

**Key Artifacts**:
- `memory/constitution.md` — The project's governing document
- Project structure (memory/, specs/, src/, scripts/)

**Entry Criteria**: User wants to start a new project or define standards
**Exit Criteria**: Constitution ratified, project structure created

### 🔍 DISCOVERY — Requirements & Planning

**Goal**: Transform ideas into actionable specifications.

| Agent | Purpose |
|-------|---------|
| `@Aurora Feature` | Create feature specification with user stories and acceptance criteria |
| `@Aurora Specify` | Transform natural language into structured feature spec |
| `@Aurora Use Case` | Generate detailed use case specifications (UML/Cockburn style) |
| `@Aurora Gherkin` | Generate BDD scenarios in Gherkin syntax with step definitions |
| `@Aurora DDD` | Define domain model, aggregates, bounded contexts, ubiquitous language |
| `@Aurora Plan` | Create technical implementation plan from feature spec |
| `@Aurora Tasks` | Generate Bolt task breakdown from plan |

**Key Artifacts**:
- `specs/XXX-feature-name/feature.md`
- `specs/XXX-feature-name/requirements/requirements.md`
- `specs/XXX-feature-name/planning/plan.md`
- `specs/XXX-feature-name/planning/tasks.md`

**Entry Criteria**: Constitution exists, user describes a feature
**Exit Criteria**: Feature spec, plan, and task breakdown approved

### 🏗️ CONSTRUCTION — Implementation

**Goal**: Build working, tested code through micro-iterations.

| Agent | Purpose |
|-------|---------|
| `@Aurora Implement` | Execute Bolt implementations following specs and constitution |
| `@Aurora Micro Iterator` | Manage micro-iteration (Bolt) lifecycle |
| `@Aurora Testing` | Generate comprehensive test suites (TDD/BDD, coverage-first) |
| `@Aurora Review` | Code review validating constitution compliance and quality |
| `@Aurora Analyze` | Consistency analysis across all artifacts |
| `@Aurora ADR` | Document Architecture Decision Records (MADR format) |
| `@Aurora Architect` | Solution architecture, C4 diagrams, technical decisions |

**Key Artifacts**:
- Source code in `src/`
- Test suites
- ADRs in `docs/adr/`

**Entry Criteria**: Task breakdown exists, feature branch created
**Exit Criteria**: All Bolts complete, quality gates passing, code reviewed

### 📦 TRANSITION — Release

**Goal**: Package and deploy the software.

| Agent | Purpose |
|-------|---------|
| `@Aurora Release` | Orchestrate release process (semantic versioning, changelogs) |
| `@Aurora CI/CD` | Pipeline automation and deployment configuration |

**Entry Criteria**: All tests passing, code reviewed
**Exit Criteria**: Release tagged, deployed, documented

### 🚀 PRODUCTION — Operations

**Goal**: Monitor, maintain, and improve.

| Agent | Purpose |
|-------|---------|
| `@Aurora Ops` | Operations, runbooks, incident response |
| `@Aurora Monitoring` | Observability, alerting, performance monitoring |
| `@Aurora Improve` | Continuous improvement opportunities |
| `@Aurora Alignment` | Business-technical alignment analysis |
| `@Aurora Status` | Project status reports and progress tracking |

**Entry Criteria**: Software deployed
**Exit Criteria**: Ongoing (continuous improvement)

### 🌙 RETIREMENT — Decommissioning

**Goal**: Gracefully retire systems.

| Agent | Purpose |
|-------|---------|
| `@Aurora Retire` | Plan controlled decommissioning |
| `@Aurora Postmortem` | Blameless postmortem for incidents or project failures |

**Entry Criteria**: Decision to retire a component/system
**Exit Criteria**: System decommissioned, data archived, stakeholders notified

---

## 3. Project State Detection

Use this algorithm to detect the current project phase and route appropriately:

```
function detectProjectPhase():
    if NOT exists("memory/constitution.md"):
        return PRE_INCEPTION
        → Action: Run init script or handoff to @Aurora Constitution

    if NOT exists("specs/") OR specs_directory_empty():
        return INCEPTION
        → Action: Handoff to @Aurora Feature or @Aurora Clarify

    if specs_exist() AND NOT exists("src/") OR src_empty():
        return DISCOVERY
        → Action: Handoff to @Aurora Plan or @Aurora Tasks

    if src_exists() AND (tests_failing() OR quality_gates_failing()):
        return CONSTRUCTION
        → Action: Handoff to @Aurora Implement or @Aurora Testing

    if tests_passing() AND NOT deployed():
        return TRANSITION
        → Action: Handoff to @Aurora Release

    if deployed():
        return PRODUCTION
        → Action: Handoff to @Aurora Ops or @Aurora Status

    return UNKNOWN
    → Action: Handoff to @Aurora Analyze for consistency check
```

### Structure Verification Checklist

Before proceeding, verify:
- [ ] `memory/` folder exists
- [ ] `specs/` folder exists
- [ ] `src/` folder exists
- [ ] `scripts/` folder exists
- [ ] `memory/constitution.md` exists and is ratified

---

## 4. Bolt Workflow — Micro-Iterations

A **Bolt** is the smallest shippable increment of work (2-3 days maximum).

### Bolt Properties

| Property | Description |
|----------|-------------|
| **Duration** | 2-3 days maximum |
| **Scope** | One user story or feature slice |
| **Output** | Working, tested code |
| **Deployable** | Can be shipped independently |
| **Reviewable** | Small enough for effective review |

### Bolt Lifecycle

```
┌─────────────────────────────────────────────────┐
│  BOLT Start                                      │
│  ├── AUTO-CREATE branch bolt-[N]-[desc]         │
│  ├── READ constitution & tasks                   │
│  ├── EXECUTE tasks sequentially                 │
│  │   ├── Write test (if TDD)                    │
│  │   ├── Implement code                         │
│  │   ├── Run tests                              │
│  │   ├── ✅ Mark task complete                  │
│  │   └── Commit incrementally                   │
│  ├── Run quality gates                          │
│  ├── Review (self or peer)                      │
│  └── Bolt complete → merge or next Bolt         │
└─────────────────────────────────────────────────┘
```

### 1. Planning Phase (30 min)

Define Bolt scope:
```markdown
## Bolt Planning

**Bolt ID**: B-[XX]
**User Story**: US-[XXX]
**Goal**: [What this Bolt delivers]
**Estimated**: [1-3 days]

### Tasks
- [ ] T1: [task description]
- [ ] T2: [task description]
- [ ] T3: [task description]

### Acceptance Criteria
- [ ] AC1: [criterion]
- [ ] AC2: [criterion]
```

### 2. Build Phase (Core Work)

For each task:
1. Write test first (if TDD)
2. Write implementation code
3. Run tests — ensure passing
4. Refactor if needed (green → refactor cycle)
5. Mark task `[x]` complete
6. Commit with descriptive message

### 3. Test Phase (Continuous)

```bash
# Run unit tests
npm test           # or: dotnet test

# Check coverage (must be >= 80%)
npm run test:cov   # or: dotnet test /p:CollectCoverage=true

# Run mutation testing (must be >= 70%)
npx stryker run    # or: dotnet stryker
```

### 4. Review Phase (End of Bolt)

```markdown
## Bolt Review Checklist

- [ ] All tasks completed
- [ ] Tests passing
- [ ] Coverage meets threshold (≥80%)
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] No linting errors
- [ ] No security vulnerabilities
```

### 5. Integration Phase

```bash
# Create PR or merge to feature branch
git checkout feature/[feature-name]
git merge bolt-[N]-[description]
git push origin feature/[feature-name]
```

### Branch Management

```bash
# Get current feature branch
FEATURE_BRANCH=$(git branch --show-current)

# Create Bolt branch
BOLT_BRANCH="${FEATURE_BRANCH}/bolt-${N}-${DESCRIPTION}"
git checkout -b "$BOLT_BRANCH"

# After Bolt complete, merge back
git checkout "$FEATURE_BRANCH"
git merge "$BOLT_BRANCH"
```

### Bolt States

| State | Symbol | Meaning |
|-------|--------|---------|
| Planned | ⬜ | Tasks defined, not started |
| In Progress | 🔄 | Work ongoing |
| Complete | ✅ | All tasks done, quality gates passed |
| Blocked | 🔴 | Cannot proceed, needs resolution |
| At Risk | ⚠️ | Behind schedule, may need scope reduction |

---

## 5. Quality Gates & Compliance

### Mandatory Quality Gate Thresholds

| Metric | Minimum | Recommended | Tool |
|--------|---------|-------------|------|
| Line Coverage | ≥ 80% | ≥ 90% | istanbul / coverlet |
| Branch Coverage | ≥ 75% | ≥ 85% | istanbul / coverlet |
| Mutation Score | ≥ 70% | ≥ 80% | Stryker |
| Linting | 0 errors | 0 warnings | ESLint / dotnet format |
| Security | 0 critical | 0 high | npm audit / dotnet list --vulnerable |
| Layer Violations | 0 | 0 | dependency-cruiser / depend |
| Circular Deps | 0 | 0 | madge / pydeps |

### Running Quality Gates

**Bash**:
```bash
./scripts/bash/quality-gates.sh
```

**PowerShell**:
```powershell
.\scripts\powershell\Quality-Gates.ps1
```

### Constitution Compliance

**ALWAYS verify before marking a Bolt complete**:

1. **Tech Stack**: Using only allowed languages/frameworks?
2. **Naming Conventions**: Following defined patterns?
3. **Architecture Patterns**: Respecting layer boundaries?
4. **Testing Requirements**: Meeting coverage thresholds?
5. **Security Standards**: No known vulnerabilities?
6. **Documentation**: Required docs updated?

Read the constitution: `memory/constitution.md`

---

## 6. Agent Coordination

### 30 Specialized Agents

The AURORA ecosystem includes 30 specialized agents organized by lifecycle phase.
See `HANDOFF-MATRIX.md` in this skill for the complete handoff validation matrix.

### Handoff Patterns

**Sequential Flow** (most common):
```
Feature → Plan → Tasks → Implement → Testing → Review → Release
```

**TDD Flow**:
```
Feature → Gherkin → Testing (red) → Implement (green) → Review
```

**Hotfix Flow**:
```
Implement (fix) → Testing → Review → Release
```

**Legacy Modernization**:
```
Constitution → Feature (map legacy) → Plan → Implement → Testing (parity)
```

### Handoff Rules

1. **Orchestrator delegates**: Bolt Framework can handoff to ANY agent
2. **Respect lifecycle order**: Don't skip phases without justification
3. **No self-handoffs**: An agent must NEVER hand off to itself
4. **No circular chains**: A → B → C → A is invalid
5. **No duplicate handoffs**: Don't have multiple handoffs to the same agent with similar prompts

### Agent Communication Pattern

When handing off to an agent, provide:
- **Context**: What has been done so far
- **Input artifacts**: Which files to read
- **Expected output**: What the agent should produce
- **Constraints**: Constitution rules to follow

---

## 7. Common Workflows

### New Project Setup (Greenfield)

```
1. Run init script:
   - Bash: ./init.sh my-project green --scope full-stack
   - PowerShell: .\Init.ps1 -ProjectName "my-project" -Type greenfield

2. @Aurora Constitution → Define tech stack and standards
3. @Aurora Feature → Create first feature specification
4. @Aurora Plan → Create implementation plan
5. @Aurora Tasks → Generate Bolt task breakdown
6. @Aurora Implement → Start Bolt 1
```

### Feature Development

```
1. @Aurora Feature → Write feature spec with stories
2. @Aurora Use Case → Detail use cases (optional)
3. @Aurora Gherkin → BDD scenarios (optional)
4. @Aurora Plan → Technical implementation plan
5. @Aurora Tasks → Generate Bolt tasks
6. For each Bolt:
   a. @Aurora Implement → Build code
   b. @Aurora Testing → Generate/run tests
   c. @Aurora Review → Code review
7. @Aurora Release → Package and deploy
```

### Legacy Modernization (Brownfield)

```
1. Run init with brownfield flag:
   - Bash: ./init.sh my-project brown --source ./legacy-code
   - PowerShell: .\Init.ps1 -ProjectName "my-project" -Type brownfield

2. @Aurora Constitution → Define modern stack
3. Analyze legacy code in legacy/ folder
4. @Aurora Feature → Map legacy functions to modern features
5. @Aurora Plan → Migration plan with parity testing
6. @Aurora Implement → Modern implementation
7. @Aurora Testing → Parity tests (legacy vs modern)
```

### Hotfix Process

```
1. Create hotfix branch from main/production
2. @Aurora Implement → Fix the issue (single Bolt)
3. @Aurora Testing → Regression + fix validation tests
4. @Aurora Review → Quick review
5. @Aurora Release → Emergency release
6. @Aurora Postmortem → Document incident (if applicable)
```

---

## 8. Scripts Reference

| Script | Bash | PowerShell |
|--------|------|------------|
| **Initialize Project** | `init.sh` | `Init.ps1` |
| **Project Status** | `scripts/bash/project-status.sh` | `scripts/powershell/Get-ProjectStatus.ps1` |
| **Quality Gates** | `scripts/bash/quality-gates.sh` | `scripts/powershell/Quality-Gates.ps1` |

---

## 9. Toolset Reference

See `TOOLSETS.md` in this skill folder for the complete toolset definitions
including VS Code built-in tools and MCP server tools.

Key MCP servers:
- **context7** — Up-to-date library documentation
- **awesome-copilot** — Templates, examples, and curated instructions
- **microsoftdocs** — Official Microsoft/Azure documentation

---

## 10. Quick Decision Guide

| User Request | Route To | Phase |
|-------------|----------|-------|
| "Start new project" | Init script → `@Aurora Constitution` | INCEPTION |
| "Add a feature" | `@Aurora Feature` | DISCOVERY |
| "Plan implementation" | `@Aurora Plan` → `@Aurora Tasks` | DISCOVERY |
| "Implement this" | `@Aurora Implement` | CONSTRUCTION |
| "Write tests" | `@Aurora Testing` | CONSTRUCTION |
| "Review code" | `@Aurora Review` | CONSTRUCTION |
| "Deploy / release" | `@Aurora Release` | TRANSITION |
| "Check status" | `@Aurora Status` | PRODUCTION |
| "Fix security issue" | `@Aurora Security` | Cross-Phase |
| "Document decision" | `@Aurora ADR` | Cross-Phase |
| "Retire system" | `@Aurora Retire` | RETIREMENT |
