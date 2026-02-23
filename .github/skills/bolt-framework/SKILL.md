---
name: bolt-framework
description: Bolt Framework methodology with 6 lifecycle phases and Bolt micro-iterations
---

# Bolt Framework

## When to Use

- Orchestrating Bolt Framework projects through lifecycle phases
- Implementing features with Bolt micro-iterations
- Routing work between specialized agents

## CRITICAL: Load Constitution First

**MUST read `memory/constitution.md` before any work** - defines tech stack, standards, constraints.

If missing → use `@Bolt Constitution` agent to create it.

## 6 Lifecycle Phases

```
🌅 INCEPTION → 🔍 DISCOVERY → 🏗️ CONSTRUCTION → 📦 TRANSITION → 🚀 PRODUCTION → 🌙 RETIREMENT
```

| Phase            | Goal               | Key Agents                                         |
| ---------------- | ------------------ | -------------------------------------------------- |
| **INCEPTION**    | Define project DNA | `@Bolt Constitution`, `@Bolt Clarify`              |
| **DISCOVERY**    | Create specs       | `@Bolt Feature`, `@Bolt Plan`, `@Bolt Tasks`       |
| **CONSTRUCTION** | Build & test       | `@Bolt Implement`, `@Bolt Testing`, `@Bolt Review` |
| **TRANSITION**   | Release            | `@Bolt Release`, `@Bolt CI/CD`                     |
| **PRODUCTION**   | Operate            | `@Bolt Ops`, `@Bolt Monitoring`, `@Bolt Improve`   |
| **RETIREMENT**   | Decommission       | `@Bolt Retire`, `@Bolt Postmortem`                 |

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

| Principle                | Description                                             |
| ------------------------ | ------------------------------------------------------- |
| **Constitution is Law**  | All decisions must comply with `memory/constitution.md` |
| **Specs Before Code**    | Features need specifications first                      |
| **Micro-Iterations**     | Work in small Bolts (2-3 days max)                      |
| **Quality Gates**        | Every Bolt must pass linting, tests, review             |
| **Agent Specialization** | One responsibility per agent                            |

## Workflow Example

```bash
# 1. INCEPTION - Create constitution
@Bolt Constitution

# 2. DISCOVERY - Create feature spec
@Bolt Feature "time tracking system"
@Bolt Plan "specs/001-time-tracking"
@Bolt Tasks "specs/001-time-tracking"

# 3. CONSTRUCTION - Implement
@Bolt Implement "specs/001-time-tracking/planning/tasks.md"
@Bolt Review "src/backend/Modules/TimeTracking"

# 4. TRANSITION - Release
@Bolt Release "v1.0.0"
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
- Constitution template: `@Bolt Constitution`
- Related skills: `bolt-adr`, `azdo-sync`
