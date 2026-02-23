# Bolt Framework - GitHub Copilot Instructions

> This file provides context to GitHub Copilot about the Bolt Framework methodology used in this workspace.

## What is Bolt Framework?

Bolt Framework (AI-Driven Development Lifecycle) is an AI-powered software development methodology. It guides development through six phases:

1. **INCEPTION** - Project definition and constitution
2. **DISCOVERY** - Requirements, features, and planning
3. **CONSTRUCTION** - Implementation with quality gates
4. **TRANSITION** - Release and documentation
5. **PRODUCTION** - Operations and continuous improvement
6. **RETIREMENT** - Decommissioning and archival

## Key Concepts

### Constitution (`memory/constitution.md`)

The project's DNA - defines tech stack, standards, and constraints. **ALWAYS read this first** before generating code.

### Features (`specs/XXX-feature-name/`)

Each feature has its own directory with:

- `feature.md` - Feature specification
- `requirements/` - Detailed requirements
- `planning/` - Tasks and implementation plan
- `contracts/` - API contracts

### Agents (`@Bolt*`)

Invoke Bolt Framework workflows via agents:

- `@Bolt Framework` - Main orchestrator
- `@Bolt Feature` - Create feature
- `@Bolt Implement` - Implement code
- `@Bolt Testing` - Generate tests
- `@Bolt Status` - Project status

## Code Generation Rules

When generating code in a Bolt Framework project:

1. **Check Constitution First** - Read `memory/constitution.md` for:
   - Allowed languages/frameworks
   - Coding standards
   - Architecture patterns
   - Testing requirements

2. **Follow Specs** - Implementation must match specifications in `specs/`

3. **Quality Gates** - Code must pass:
   - Linting
   - Unit tests
   - Architecture compliance

4. **Documentation** - Include:
   - Code comments
   - API documentation
   - README updates

## File Structure

```
project/
├── memory/
│   └── constitution.md      # Project DNA
├── specs/
│   └── XXX-feature-name/    # Feature specs
├── src/                     # Source code
├── legacy/                  # Legacy code analysis (brownfield)
└── .github/
    ├── agents/              # Bolt Framework agents (30)
    ├── prompts/             # Reusable prompts
    ├── skills/              # Auto-discovered skills
    └── workflows/           # GitHub Actions
```

## Specialized Agents

Bolt Framework includes 30 specialized AI agents. Invoke them with `@AgentName`:

| Topic           | Agent                 |
| --------------- | --------------------- |
| Orchestration   | `@Bolt Framework`     |
| Architecture    | `@Bolt Architect`     |
| Domain modeling | `@Bolt DDD`           |
| Testing         | `@Bolt Testing`       |
| Implementation  | `@Bolt Implement`     |
| Documentation   | `@Bolt Documentation` |
| Operations      | `@Bolt Ops`           |
| Releases        | `@Bolt Release`       |

📚 **Full list**: [.github/agents/README.md](.github/agents/README.md)

## Skills - Specialized Capabilities

Bolt Framework includes specialized **skills** that are auto-discovered from `.github/skills/<name>/SKILL.md`. When working on specific tasks, Copilot automatically loads relevant skills.

### Available Skills

| Skill                                                      | Domain                        | Use When                                                                                         |
| ---------------------------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------ |
| [bolt-framework](.github/skills/bolt-framework/)           | Bolt Framework Methodology    | Working on Bolt Framework projects, managing lifecycle                                           |
| [bolt-adr](.github/skills/bolt-adr/)                       | Architecture Decision Records | Documenting architectural decisions, technology selections, or design patterns using MADR format |
| [new-skill](.github/skills/new-skill/)                     | Skill Creation                | Creating or improving Copilot skills                                                             |
| [markdown-formatting](.github/skills/markdown-formatting/) | Markdown Best Practices       | Writing or editing any Markdown document (.md, .agent.md, .prompt.md)                            |

### Creating Custom Skills

Want to add a new skill? Ask Copilot:

```
"Help me create a skill for [domain]"
```

Copilot will guide you through the process using the new-skill guidelines.

## Remember

- 🔒 **Constitution is law** - Never violate its constraints
- 📋 **Specs before code** - Features need specifications first
- 🧪 **Test everything** - TDD/BDD approach
- 📝 **Document decisions** - ADRs for architecture
- 🔄 **Iterate small** - Micro-iterations, frequent validation
- 🎯 **Use skills** - Load relevant skills for specialized tasks

---

_Bolt Framework v2.0.0_
