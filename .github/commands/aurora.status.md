---
description: Analyze project status, progress, and continuity. Shows completion state of features, tasks, NFRs, and all AURORA-IA artifacts to help resume work after a pause.
handoffs: 
  - label: Continue Feature
    agent: aurora.feature
    prompt: Continue working on the selected in-progress feature
    send: true
  - label: Continue Tasks
    agent: aurora.tasks
    prompt: Continue with pending tasks from the selected Bolt
    send: true
  - label: Review Blockers
    agent: aurora.clarify
    prompt: Clarify blockers and pending decisions
    send: true
  - label: Run Quality Gates
    agent: aurora.review
    prompt: Run quality gates on completed items
    send: true
scripts:
  sh: scripts/bash/project-status.sh
  ps: scripts/powershell/Get-ProjectStatus.ps1
---

## User Input

```text
$ARGUMENTS
```

**Arguments supported:**
- `full` - Complete analysis (all artifacts)
- `features` - Feature status only
- `tasks` - Tasks and Bolts status only
- `infra` - Infrastructure status only
- `quality` - Quality metrics only
- `blockers` - Blockers and pending decisions
- (empty) - Executive summary with recommendations

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Provide a comprehensive project status report to help developers and AI agents understand the current state and resume work efficiently after any pause.

**AURORA Stage**: ALL (Meta-command for continuity)

**Responsible Agent**: Project Status Analyzer (Cross-functional)

## When to Use

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     USE /aurora.status WHEN...                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  🔄 CONTINUITY                                                          │
│  • Resuming work after days/weeks away                                  │
│  • Starting a new session with AI agent                                 │
│  • Onboarding new team member                                           │
│  • Handoff between team members                                         │
│                                                                         │
│  📊 PROGRESS TRACKING                                                   │
│  • Sprint review preparation                                            │
│  • Stakeholder status update                                            │
│  • Identifying blockers and risks                                       │
│  • Planning next steps                                                  │
│                                                                         │
│  🔍 HEALTH CHECK                                                        │
│  • Quality gates verification                                           │
│  • Constitution compliance check                                        │
│  • Test coverage status                                                 │
│  • Documentation completeness                                           │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Execution Flow

### Step 1: Read Project Constitution

**FIRST**: Load `memory/constitution.md` to determine:

```markdown
# Extract from constitution.md:

## Project Identity
- Project Name: [PROJECT_NAME]
- Project Scope: [ ] Infrastructure [ ] Application [ ] Full Stack
- Status: [ ] Greenfield [ ] Brownfield [ ] Migration

## Tech Stack (if App/Full Stack)
- Backend: [.NET 8 / Node.js 20]
- Frontend: [Vue/React/Angular/Blazor/None]
- Database: [SQL/PostgreSQL/CosmosDB]
- Architecture: [Modular Monolith / Microservices / Serverless]

## Infrastructure (if Infra/Full Stack)
- Scope: [Landing Zone / Workload / Both]
- IaC Tool: [Bicep / Terraform]
```

### Step 2: Scan Project Structure

Analyze the following locations:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PROJECT SCAN LOCATIONS                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  📋 SPECIFICATIONS                                                      │
│  └── specs/                                                             │
│      └── [XXX-feature-name]/                                            │
│          ├── requirements/requirements.md    # Feature spec             │
│          ├── requirements/data-model.md      # Domain model             │
│          ├── contracts/*.yaml                # API contracts            │
│          ├── tests/*.feature                 # Gherkin scenarios        │
│          ├── planning/plan.md                # Implementation plan      │
│          └── planning/tasks.md               # Task breakdown           │
│                                                                         │
│  🏛️ ARCHITECTURE                                                        │
│  └── docs/                                                              │
│      ├── architecture/                       # Architecture docs        │
│      │   ├── decisions/                      # ADRs                     │
│      │   └── diagrams/                       # Architecture diagrams    │
│      └── nfrs/                               # Non-functional reqs      │
│                                                                         │
│  💻 SOURCE CODE                                                         │
│  └── src/                                                               │
│      ├── domain/                             # Domain layer             │
│      ├── application/                        # Application layer        │
│      ├── infrastructure/                     # Infrastructure layer     │
│      └── presentation/                       # API/UI layer             │
│                                                                         │
│  🧪 TESTS                                                               │
│  └── tests/                                                             │
│      ├── unit/                               # Unit tests               │
│      ├── integration/                        # Integration tests        │
│      └── e2e/                                # End-to-end tests         │
│                                                                         │
│  🏗️ INFRASTRUCTURE                                                      │
│  └── infra/                                                             │
│      ├── bicep/ or terraform/                # IaC templates            │
│      ├── k8s/                                # Kubernetes manifests     │
│      └── pipelines/                          # CI/CD definitions        │
│                                                                         │
│  📝 MEMORY                                                              │
│  └── memory/                                                            │
│      ├── constitution.md                     # Project constitution     │
│      ├── decisions/                          # Decision log             │
│      └── context/                            # Preserved context        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Step 3: Analyze Feature Status

For each feature in `specs/`:

```markdown
## Feature Analysis: [XXX-feature-name]

### Completion Matrix

| Artifact | Status | Completion | Last Updated |
|----------|--------|------------|--------------|
| requirements.md | ✅/⚠️/❌ | X% | YYYY-MM-DD |
| data-model.md | ✅/⚠️/❌ | X% | YYYY-MM-DD |
| API contracts | ✅/⚠️/❌ | X% | YYYY-MM-DD |
| Gherkin scenarios | ✅/⚠️/❌ | X% | YYYY-MM-DD |
| plan.md | ✅/⚠️/❌ | X% | YYYY-MM-DD |
| tasks.md | ✅/⚠️/❌ | X% | YYYY-MM-DD |

### User Stories Status

| US ID | Title | Priority | Status | Completion |
|-------|-------|----------|--------|------------|
| US-001 | [Title] | P1 | 🔄 In Progress | 60% |
| US-002 | [Title] | P2 | ⏳ Pending | 0% |
| US-003 | [Title] | P3 | ✅ Done | 100% |

### Bolts Progress

| Bolt | Goal | Tasks | Done | In Progress | Pending |
|------|------|-------|------|-------------|---------|
| Bolt 1 | Setup | 8 | 8 | 0 | 0 | ✅ 100%
| Bolt 2 | Core | 12 | 7 | 2 | 3 | 🔄 58%
| Bolt 3 | API | 10 | 0 | 0 | 10 | ⏳ 0%
```

### Step 4: Analyze Task Status

Parse `tasks.md` files and calculate:

```markdown
## Task Analysis

### Overall Progress

```
Total Tasks: [X]
├── ✅ Completed: [X] (X%)
├── 🔄 In Progress: [X] (X%)
├── ⏳ Pending: [X] (X%)
└── ❌ Blocked: [X] (X%)
```

### Task Breakdown by Category

| Category | Total | Done | In Progress | Pending | Blocked |
|----------|-------|------|-------------|---------|---------|
| Setup | X | X | X | X | X |
| Domain | X | X | X | X | X |
| Application | X | X | X | X | X |
| Infrastructure | X | X | X | X | X |
| API | X | X | X | X | X |
| Tests | X | X | X | X | X |

### Current Bolt Details

**Active Bolt**: Bolt [N] - [Goal]

| Task ID | Description | Status | Assignee | Notes |
|---------|-------------|--------|----------|-------|
| T015 | Create UserRepository | 🔄 | - | WIP |
| T016 | Database migration | ⏳ | - | Depends on T015 |
```

### Step 5: Analyze Quality Metrics

```markdown
## Quality Status

### Test Coverage (from constitution Article XIII)

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Line Coverage | ≥80% | X% | ✅/⚠️/❌ |
| Branch Coverage | ≥75% | X% | ✅/⚠️/❌ |
| Mutation Score | ≥70% | X% | ✅/⚠️/❌ |

### Code Quality

| Check | Status | Details |
|-------|--------|---------|
| Linting | ✅/❌ | X errors, X warnings |
| Formatting | ✅/❌ | X files need formatting |
| Architecture Tests | ✅/❌ | X violations |
| Security Scan | ✅/❌ | X critical, X high |

### Documentation Completeness

| Document | Required | Present | Complete |
|----------|----------|---------|----------|
| constitution.md | ✅ | ✅/❌ | X% |
| README.md | ✅ | ✅/❌ | X% |
| API docs | ✅/❌ | ✅/❌ | X% |
| ADRs | ✅/❌ | ✅/❌ | X% |
```

### Step 6: Identify Blockers & Decisions

```markdown
## Blockers & Pending Decisions

### 🚫 Blockers

| ID | Description | Blocked Items | Owner | Since |
|----|-------------|---------------|-------|-------|
| B001 | [Description] | T015, T016 | [Who] | X days |
| B002 | [Description] | US-002 | [Who] | X days |

### ❓ Pending Decisions

| ID | Question | Options | Impact | Urgency |
|----|----------|---------|--------|---------|
| D001 | [Decision needed] | A, B, C | High | 🔴 |
| D002 | [Decision needed] | X, Y | Medium | 🟡 |

### ⚠️ Risks

| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R001 | [Risk description] | Medium | High | [Action] |
```

### Step 7: Generate Continuity Report

```markdown
## 📋 Executive Summary

### Project Identity

| Property | Value |
|----------|-------|
| Project | [PROJECT_NAME] |
| Type | 🚀 Greenfield / 🔄 Brownfield / 🔀 Migration |
| Scope | 💻 App / 🏗️ Infra / 🚀 Full Stack |
| Phase | INCEPTION / DISCOVERY / PLAN / EXECUTE / OPERATE |

### Overall Progress

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PROJECT PROGRESS                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Features    [████████░░░░░░░░░░░░] 40% (2/5 complete)                 │
│  User Stories [██████░░░░░░░░░░░░░░] 30% (6/20 complete)               │
│  Tasks       [████████████░░░░░░░░] 60% (42/70 complete)               │
│  Tests       [██████████░░░░░░░░░░] 50% (coverage)                     │
│  Docs        [████████████████░░░░] 80% complete                       │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 🎯 Recommended Next Actions

Based on current state, here's what to focus on:

| Priority | Action | Command | Why |
|----------|--------|---------|-----|
| 🔴 HIGH | Resolve blocker B001 | `/aurora.clarify` | Blocking 2 tasks |
| 🔴 HIGH | Complete T015 (in progress) | `/aurora.implement T015` | Current WIP |
| 🟡 MEDIUM | Finish Bolt 2 tasks | `/aurora.tasks` | 42% remaining |
| 🟢 LOW | Start US-002 planning | `/aurora.plan US-002` | Next priority |

### 🕐 Timeline Status

| Milestone | Target | Status | Days |
|-----------|--------|--------|------|
| Bolt 1 Complete | 2024-01-15 | ✅ Done | - |
| Bolt 2 Complete | 2024-01-22 | 🔄 In Progress | +3 days |
| MVP Release | 2024-02-01 | ⏳ At Risk | - |

### 📝 Session Notes

Last session ended with:
- Working on: [Task/Feature]
- Last commit: [commit message]
- Open questions: [if any]

To continue from where you left off:
```
/aurora.implement [continue with T015]
```
```

## Output Format

### Full Report (default)

Generate comprehensive markdown report covering all sections above.

### Summary Mode (`/aurora.status`)

```markdown
# 🚀 [PROJECT_NAME] Status

**Last Updated**: [timestamp]
**Project Phase**: [PHASE]

## Quick Stats

| Metric | Value |
|--------|-------|
| Features | 2/5 (40%) |
| Active Bolt | Bolt 2 |
| Tasks Today | T015, T016 |
| Blockers | 1 critical |
| Quality | ⚠️ 72% coverage |

## 🎯 Resume Work

**Continue with**: T015 - Create UserRepository
**Command**: `/aurora.implement T015`

## ⚠️ Needs Attention

1. Blocker B001 pending 3 days
2. Coverage below target (72% < 80%)
3. Decision D001 needed for API design
```

### Specific Views

- `/aurora.status features` → Feature-only view
- `/aurora.status tasks` → Task/Bolt-only view
- `/aurora.status quality` → Quality metrics only
- `/aurora.status blockers` → Blockers and decisions only

## Integration with Scripts

### Bash Script Usage

```bash
# Generate full status report
./scripts/bash/project-status.sh

# Generate JSON for CI/CD
./scripts/bash/project-status.sh --json

# Check specific feature
./scripts/bash/project-status.sh --feature 001-user-auth
```

### PowerShell Script Usage

```powershell
# Generate full status report
.\scripts\powershell\Get-ProjectStatus.ps1

# Generate JSON for CI/CD
.\scripts\powershell\Get-ProjectStatus.ps1 -Format Json

# Check specific feature
.\scripts\powershell\Get-ProjectStatus.ps1 -Feature "001-user-auth"
```

## AI Agent Collaboration

### For AI Agents

When starting a new session, ALWAYS run `/aurora.status` first to:

1. Understand project context
2. Identify current work in progress
3. Know blockers and constraints
4. Follow constitution guidelines
5. Continue from the correct point

### Memory Persistence

The status report can be saved to `memory/context/` for session continuity:

```
memory/
└── context/
    ├── last-session.md      # Auto-generated session summary
    ├── work-in-progress.md  # Current WIP tracking
    └── decisions-pending.md # Pending decisions queue
```

## Constitution Reference

This command reads and validates against:

| Article | Section | Information |
|---------|---------|-------------|
| Article I | 1.0 | Project Scope (App/Infra/Full Stack) |
| Article I | 1.0.1 | Infrastructure Scope |
| Article XIII | 13.1 | Testing thresholds |
| Article XVII | 17.1 | Migration Context (Greenfield/Brownfield) |
| Article XIX | 19.2 | AI Agent Compliance checklist |
