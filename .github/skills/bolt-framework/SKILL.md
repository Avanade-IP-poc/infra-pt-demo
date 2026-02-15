---
name: bolt-framework
description: AURORA-IA-DLC methodology with 6 lifecycle phases and Bolt micro-iterations
---

# Bolt Framework

## When to Use

- Orchestrating AURORA projects through lifecycle phases
- Implementing features with Bolt micro-iterations
- Routing work between specialized agents

## CRITICAL: Load Constitution First

**MUST read `memory/constitution.md` before any work** - defines tech stack, standards, constraints.

If missing → use `@Aurora Constitution` agent to create it.

## 6 Lifecycle Phases

```
🌅 INCEPTION → 🔍 DISCOVERY → 🏗️ CONSTRUCTION → 📦 TRANSITION → 🚀 PRODUCTION → 🌙 RETIREMENT
```

| Phase | Goal | Key Agents |
|-------|------|------------|
| **INCEPTION** | Define project DNA | `@Aurora Constitution`, `@Aurora Clarify` |
| **DISCOVERY** | Create specs | `@Aurora Feature`, `@Aurora Plan`, `@Aurora Tasks` |
| **CONSTRUCTION** | Build & test | `@Aurora Implement`, `@Aurora Testing`, `@Aurora Review` |
| **TRANSITION** | Release | `@Aurora Release`, `@Aurora CI/CD` |
| **PRODUCTION** | Operate | `@Aurora Ops`, `@Aurora Monitoring`, `@Aurora Improve` |
| **RETIREMENT** | Decommission | `@Aurora Retire`, `@Aurora Postmortem` |

## File Structure

```
project/
├── memory/
│   └── constitution.md      # Project DNA
├── specs/
│   └── XXX-feature-name/    # Feature specs
│       ├── feature.md
│       ├── requirements/
│       │   └── requirements.md
│       ├── planning/
│       │   ├── plan.md
│       │   └── tasks.md     # Bolt tasks
│       └── contracts/
├── src/                     # Source code
└── .github/
    ├── agents/              # AURORA agents (30+)
    └── skills/              # Skills
```

## Core Principles

| Principle | Description |
|-----------|-------------|
| **Constitution is Law** | All decisions must comply with `memory/constitution.md` |
| **Specs Before Code** | Features need specifications first |
| **Micro-Iterations** | Work in small Bolts (2-3 days max) |
| **Quality Gates** | Every Bolt must pass linting, tests, review |
| **Agent Specialization** | One responsibility per agent |

## Workflow Example

```bash
# 1. INCEPTION - Create constitution
@Aurora Constitution

# 2. DISCOVERY - Create feature spec
@Aurora Feature "time tracking system"
@Aurora Plan "specs/001-time-tracking"
@Aurora Tasks "specs/001-time-tracking"

# 3. CONSTRUCTION - Implement
@Aurora Implement "specs/001-time-tracking/planning/tasks.md"
@Aurora Review "src/backend/Modules/TimeTracking"

# 4. TRANSITION - Release
@Aurora Release "v1.0.0"
```

## Bolt Micro-Iterations

Tasks in `planning/tasks.md`:

```markdown
- [ ] **001-time-tracking-001** Implement TimeEntry aggregate (4h)
- [ ] **001-time-tracking-002** Add validation rules (2h)
- [x] **001-time-tracking-003** Create REST endpoints (6h)
```

Each Bolt must pass:
- ✅ Linting
- ✅ Unit tests
- ✅ Architecture compliance
- ✅ Code review

## References

- Full agent list: [.github/agents/README.md](.github/agents/README.md)
- Constitution template: `@Aurora Constitution`
- Related skills: `skill-bolt-adr`, `azure-devops-sync`
