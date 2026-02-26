---
name: bolt-framework
description: Bolt Framework methodology with 6 lifecycle phases and Bolt micro-iterations
---

# Bolt Framework

## When to Use

- Orchestrating Bolt Framework projects through lifecycle phases
- Implementing features with Bolt micro-iterations
- Routing work between specialized agents
- Understanding the AI-DLC (AI-Driven Development Lifecycle) methodology

## CRITICAL: Constitution-First Development

**MUST read `.aurora/memory/constitution.md` BEFORE any work.**

The Constitution defines:

- Technology stack (languages, frameworks, databases)
- Architecture patterns (Clean Architecture, DDD, CQRS)
- Quality standards (coverage thresholds, mutation scores)
- Development practices (TDD, BDD, code review rules)

**If missing:** Use `@Bolt Constitution` agent to create it.

## 6 Lifecycle Phases (AI-DLC)

```
🌅 INCEPTION → 🔍 DISCOVERY → 🏗️ CONSTRUCTION → 📦 TRANSITION → 🚀 PRODUCTION → 🌙 RETIREMENT
```

| Phase            | Goal               | Entry Criteria        | Exit Criteria          | Key Agents                                         |
| ---------------- | ------------------ | --------------------- | ---------------------- | -------------------------------------------------- |
| **INCEPTION**    | Define project DNA | Stakeholder approval  | Ratified constitution  | `@Bolt Constitution`, `@Bolt Clarify`              |
| **DISCOVERY**    | Create specs       | Constitution exists   | Approved feature specs | `@Bolt Feature`, `@Bolt Plan`, `@Bolt Tasks`       |
| **CONSTRUCTION** | Build & test       | Tasks generated       | All quality gates pass | `@Bolt Implement`, `@Bolt Testing`, `@Bolt Review` |
| **TRANSITION**   | Release            | Code merged           | Deployed to production | `@Bolt Release`, `@Bolt CI/CD`                     |
| **PRODUCTION**   | Operate            | Production deployment | Stable operation       | `@Bolt Ops`, `@Bolt Monitoring`, `@Bolt Improve`   |
| **RETIREMENT**   | Decommission       | Replacement ready     | System archived        | `@Bolt Retire`, `@Bolt Postmortem`                 |

---

## Phase 1: INCEPTION

**Goal:** Establish project foundation with constitution and constraints.

### Workflow

1. **Run Init Script**

```bash
# Windows (PowerShell)
.\Init.ps1 --output .\my-project --type green

# Linux/Mac/WSL (Bash)
./init.sh --output ./my-project --type green
```

**Generates:**

- Basic constitution template
- `.aurora/scopes.yaml` (active scopes configuration)
- Project directory structure

2. **Provision Constitution**

```bash
@Bolt Constitution
```

**Performs:**

- Merges scope-specific constitutions
- Provisions skills/agents based on scopes
- Generates provision report

3. **Ratify Constitution**

Review and approve:

- Tech stack choices
- Quality thresholds
- Architecture patterns
- Security policies

### Validation Checklist

- [ ] Constitution exists: `.aurora/memory/constitution.md`
- [ ] Scopes configured: `.aurora/scopes.yaml`
- [ ] Skills provisioned: `.github/skills/`
- [ ] Agents available: `.github/agents/`
- [ ] Provision report generated: `.aurora/memory/provision-report.md`
- [ ] Quality thresholds defined (coverage >= 80%, mutation >= 70%)
- [ ] Tech stack approved by stakeholders

### Quality Gates

- Constitution completeness: All required articles present
- Stakeholder approval: Sign-off on governance document
- Tool availability: Required dev tools installed

### References

- `skill-bolt-constitution-driven-development` skill (Constitution governance)
- `skill-bolt-setup-constitution` skill (Provisioning engine)
- `@Bolt Constitution` agent
- `Init.ps1` / `init.sh` scripts

---

## Phase 2: DISCOVERY

**Goal:** Create comprehensive feature specifications with clear acceptance criteria.

### Workflow

1. **Create Feature Spec**

```bash
@Bolt Feature "user authentication system with email/password login"
```

**Generates:** `specs/XXX-feature-name/`

- `feature.md` - User stories, acceptance criteria
- `requirements/requirements.md` - Detailed requirements

2. **Create Implementation Plan**

```bash
@Bolt Plan "specs/001-user-authentication"
```

**Generates:** `specs/001-user-authentication/planning/plan.md`

- Architecture decisions
- Component breakdown
- BOLT strategy (4-6 Bolts per feature)
- Risk assessment

3. **Generate BOLT Tasks**

```bash
@Bolt Tasks "specs/001-user-authentication"
```

**Generates:** `specs/001-user-authentication/planning/tasks.md`

```markdown
## Bolt 1: Foundation (1-2 days)

- [ ] T001 Initialize project structure
- [ ] T002 Set up database schema
- [ ] T003-QG Run linting
- [ ] T004-QG Verify coverage >= 80%

## Bolt 2: Core Domain (2-3 days)

- [ ] T005 Create User aggregate
- [ ] T006 Implement authentication service
- [ ] T007-QG Run mutation tests
```

### Validation Checklist

- [ ] Feature spec exists with user stories
- [ ] Acceptance criteria defined (BDD scenarios)
- [ ] Implementation plan created
- [ ] BOLTs identified (each 1-3 days)
- [ ] Task breakdown complete (15-25 tasks per BOLT)
- [ ] Dependencies mapped
- [ ] Risk assessment documented

### Quality Gates

- User story completeness: All ACs defined in Gherkin
- Plan feasibility: Tech lead approval
- Task granularity: No task > 1 day

### References

- `@Bolt Feature` agent (Feature specification)
- `@Bolt Plan` agent (Implementation planning)
- `@Bolt Tasks` agent (Task breakdown)
- `@Bolt Specify` agent (Requirements documentation)

---

## Phase 3: CONSTRUCTION

**Goal:** Implement features incrementally with continuous validation.

### Workflow

**CRITICAL: Branch Management**

Use `skill-bolt-branch-management` skill:

1. **Verify feature branch**

```bash
git branch --show-current
# Expected: feature/user-authentication
```

2. **Create BOLT branch**

```bash
# Auto-created by @Bolt Implement
git checkout -b feature/user-authentication/bolt-1-domain
```

**Implementation Loop:**

1. **Implement BOLT**

```bash
@Bolt Implement "Bolt 1: Foundation"
```

- Reads tasks from `planning/tasks.md`
- Implements code following constitution
- Updates task checklist

2. **Generate Tests**

```bash
@Bolt Testing tdd      # For domain logic
@Bolt Gherkin          # For user stories
```

- Achieves >= 80% line coverage
- Achieves >= 75% branch coverage
- Generates mutation tests

3. **Run Quality Gates** (MANDATORY per BOLT)

```bash
# Linting
npm run lint          # or: dotnet format

# Unit tests
npm test              # or: dotnet test

# Coverage
npm run test:cov      # Verify >= 80%

# Mutation testing
npx stryker run       # Verify >= 70%
```

4. **Code Review**

```bash
@Bolt Review "src/domain/User.ts"
```

- Constitution compliance check
- SOLID principles validation
- Architecture tests

5. **Merge BOLT**

```bash
git checkout feature/user-authentication
git merge feature/user-authentication/bolt-1-domain
```

6. **Repeat for next BOLT**

### Validation Checklist (Per BOLT)

- [ ] All tasks completed and checked off
- [ ] Linting passes (0 errors)
- [ ] All tests pass (100%)
- [ ] Line coverage >= 80%
- [ ] Branch coverage >= 75%
- [ ] Mutation score >= 70%
- [ ] Code review approved
- [ ] Architecture tests pass
- [ ] Constitution compliance verified
- [ ] Branch merged to feature branch

### Quality Gates (Per BOLT - MANDATORY)

| Gate                    | Command                              | Threshold |
| ----------------------- | ------------------------------------ | --------- |
| Linting                 | `npm run lint` / `dotnet format`     | 0 errors  |
| Unit Tests              | `npm test` / `dotnet test`           | 100% pass |
| Line Coverage           | `npm run test:cov`                   | >= 80%    |
| Branch Coverage         | Check coverage report                | >= 75%    |
| Mutation Score          | `npx stryker run` / `dotnet stryker` | >= 70%    |
| Architecture Tests      | `npm run test:arch`                  | 100% pass |
| Code Review             | `@Bolt Review`                       | Approved  |
| Constitution Compliance | `@Bolt Review --check-constitution`  | Pass      |

### References

- `skill-bolt-branch-management` skill (BOLT branching pattern)
- `skill-bolt-quality-gates` skill (Thresholds and tools)
- `skill-bolt-testing-discipline` skill (TDD/BDD guidance)
- `@Bolt Implement` agent
- `@Bolt Testing` agent
- `@Bolt Review` agent

---

## Phase 4: TRANSITION

**Goal:** Deploy to production with zero downtime.

### Workflow

1. **Create Release**

```bash
@Bolt Release "v1.0.0"
```

**Performs:**

- Semantic versioning
- CHANGELOG generation
- Tag creation
- Release notes

2. **Deploy**

```bash
@Bolt Ops deploy --environment prod
```

**Executes:**

- Pre-deployment checks
- Blue-green / canary deployment
- Health checks
- Rollback plan activation (if needed)

3. **Verify Deployment**

```bash
@Bolt Monitoring verify-deployment
```

- Smoke tests
- Performance baselines
- Error rate monitoring

### Validation Checklist

- [ ] All BOLTs merged to feature branch
- [ ] Feature branch merged to main
- [ ] CI/CD pipeline passes
- [ ] Release tag created
- [ ] CHANGELOG updated
- [ ] Deployment successful
- [ ] Smoke tests pass
- [ ] Monitoring alerts configured
- [ ] Rollback plan tested

### Quality Gates

- CI/CD: All pipeline stages green
- Smoke tests: 100% pass
- Performance: < 5% degradation from baseline
- Error rate: < 0.1% in first hour

### References

- `@Bolt Release` agent
- `@Bolt Ops` agent
- `@Bolt CI/CD` agent

---

## Phase 5: PRODUCTION

**Goal:** Monitor, improve, and maintain system health.

### Workflow

1. **Monitor System**

```bash
@Bolt Monitoring dashboard
```

- Performance metrics
- Error rates
- Resource utilization

2. **Continuous Improvement**

```bash
@Bolt Improve analyze
```

- Identify bottlenecks
- Suggest optimizations

3. **Incident Response**

```bash
@Bolt Ops incident --id INC-12345
```

- Diagnose issue
- Apply hotfix
- Post-incident review

### Validation Checklist

- [ ] Monitoring dashboards configured
- [ ] Alerts triggering correctly
- [ ] Performance within SLA
- [ ] Error budget not exceeded
- [ ] Incident response tested
- [ ] Improvement backlog maintained

### Quality Gates

- Uptime: >= 99.9%
- Response time: < 200ms p95
- Error rate: < 0.5%

### References

- `@Bolt Monitoring` agent
- `@Bolt Ops` agent
- `@Bolt Improve` agent

---

## Phase 6: RETIREMENT

**Goal:** Safely decommission systems with knowledge preservation.

### Workflow

1. **Plan Retirement**

```bash
@Bolt Retire plan --system legacy-api
```

- Data migration plan
- User communication
- Archive strategy

2. **Execute Retirement**

```bash
@Bolt Retire execute
```

- Redirect traffic
- Archive data
- Decommission resources

3. **Document Lessons**

```bash
@Bolt Postmortem
```

- What worked
- What to improve
- Knowledge transfer

### Validation Checklist

- [ ] Replacement system operational
- [ ] Data migrated successfully
- [ ] Users notified
- [ ] Resources decommissioned
- [ ] Documentation archived
- [ ] Postmortem conducted

### Quality Gates

- Data migration: 100% integrity check
- Zero data loss
- User migration: 100% transitioned

### References

- `@Bolt Retire` agent
- `@Bolt Postmortem` agent

---

## Bolt Micro-Iterations

**Each BOLT:**

- Duration: 1-3 days
- Deliverable: Working, tested code
- Branch: `feature/[name]/bolt-[N]-[description]`
- Quality gates: MANDATORY before merge

### BOLT Branching Pattern

```
feature/user-authentication                 # Feature branch
  ├── bolt-1-foundation                     # Setup, schema
  ├── bolt-2-domain                         # Aggregates, logic
  ├── bolt-3-api                            # Controllers, DTOs
  └── bolt-4-polish                         # UI, integration
```

### BOLT Examples

| BOLT        | Duration | Focus                          | Quality Gate        |
| ----------- | -------- | ------------------------------ | ------------------- |
| Foundation  | 1-2 days | Project setup, database schema | Schema migration OK |
| Core Domain | 2-3 days | Aggregates, business logic     | 80% coverage        |
| API Layer   | 2-3 days | Controllers, DTOs, validation  | Integration tests   |
| UI/Polish   | 2-3 days | Frontend, UX, E2E tests        | E2E tests pass      |

---

## File Structure

```
project/
├── .aurora/
│   ├── memory/
│   │   ├── constitution.md          # Project DNA
│   │   └── provision-report.md      # Provisioning log
│   ├── scopes.yaml                  # Active scopes config
│   └── scopes/                      # Scope definitions
│       ├── backend/
│       ├── frontend/
│       └── cloud-platform/
├── specs/
│   └── XXX-feature-name/
│       ├── feature.md
│       ├── requirements/
│       │   └── requirements.md
│       ├── planning/
│       │   ├── plan.md
│       │   └── tasks.md             # BOLT tasks
│       └── contracts/
├── src/                             # Source code
├── .github/
│   ├── agents/                      # Bolt agents (30+)
│   └── skills/                      # Provisioned skills
└── docs/
    └── adr/                         # Architecture Decision Records
```

---

## Core Principles

| Principle                 | Description                                                     | Enforcement                     |
| ------------------------- | --------------------------------------------------------------- | ------------------------------- |
| **Constitution is Law**   | All decisions must comply with `.aurora/memory/constitution.md` | Agent validation                |
| **Specs Before Code**     | Features need specifications first                              | @Bolt Feature required          |
| **Micro-Iterations**      | Work in small Bolts (1-3 days max)                              | Branch pattern enforced         |
| **Quality Gates**         | Every Bolt must pass thresholds                                 | Automated checks (80% coverage) |
| **Agent Specialization**  | One responsibility per agent                                    | YAML frontmatter contracts      |
| **Continuous Validation** | Test during development, not after                              | TDD/BDD practices               |

---

## Quick Start Workflow

### Greenfield Project

```bash
# 1. Initialize
./Init.ps1 --output ./my-app --type green

# 2. Setup constitution
@Bolt Constitution

# 3. Create feature
@Bolt Feature "user authentication"

# 4. Plan implementation
@Bolt Plan "specs/001-user-authentication"

# 5. Generate tasks
@Bolt Tasks "specs/001-user-authentication"

# 6. Implement
@Bolt Implement "Bolt 1: Foundation"

# 7. Quality gates
npm run lint && npm test -- --coverage && npx stryker run

# 8. Review & merge
@Bolt Review "src/domain"
```

### Brownfield Migration

```bash
# 1. Initialize with legacy code
./Init.ps1 --output ./my-app --type brown --source ./legacy

# 2. Analyze legacy
@Bolt Analyze "./legacy"

# 3. Create migration plan
@Bolt Plan "migration from COBOL to .NET"

# 4. Incremental BOLTs
@Bolt Implement "Bolt 1: Extract domain model from COBOL"
```

---

## References

### Skills

- `skill-bolt-branch-management` (BOLT branching pattern)
- `skill-bolt-quality-gates` (Thresholds and mutation testing)
- `skill-bolt-testing-discipline` (TDD/BDD decision matrix)
- `skill-bolt-constitution-driven-development` (Constitution governance)
- `skill-bolt-setup-constitution` (Provisioning engine)
- `skill-bolt-adr` (Architecture Decision Records)

### Agents

- Full agent list: `.github/agents/README.md`
- Agent handoff matrix: `.github/skills/bolt-framework/HANDOFF-MATRIX.md`

### Examples

- Greenfield workflow: `examples/greenfield-workflow.md`
- Brownfield workflow: `examples/brownfield-workflow.md`
- Hotfix workflow: `examples/hotfix-workflow.md`

### Templates

- BOLT template: `templates/bolt-template.md`
- Constitution template: `templates/constitution-template.md`
- Quality gate checklist: `templates/quality-gate-checklist.md`
