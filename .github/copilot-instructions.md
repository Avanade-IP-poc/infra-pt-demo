# AURORA-IA-DLC - GitHub Copilot Instructions

> This file provides context to GitHub Copilot about the AURORA methodology used in this workspace.

## What is AURORA?

AURORA-IA-DLC (AI-Driven Development Lifecycle) is an AI-powered software development methodology. It guides development through six phases:

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

### Agents (`@Aurora*`)

Invoke AURORA workflows via agents:

- `@Bolt Framework` - Main orchestrator
- `@Aurora Feature` - Create feature
- `@Aurora Implement` - Implement code
- `@Aurora Testing` - Generate tests
- `@Aurora Status` - Project status

## Code Generation Rules

When generating code in an AURORA project:

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
    ├── agents/              # AURORA agents (30)
    ├── prompts/             # Reusable prompts
    ├── skills/              # Auto-discovered skills
    └── workflows/           # GitHub Actions
```

## Specialized Agents

AURORA includes 30 specialized AI agents. Invoke them with `@AgentName`:

| Topic           | Agent                   |
| --------------- | ----------------------- |
| Orchestration   | `@Bolt Framework`       |
| Architecture    | `@Aurora Architect`     |
| Domain modeling | `@Aurora DDD`           |
| Testing         | `@Aurora Testing`       |
| Implementation  | `@Aurora Implement`     |
| Documentation   | `@Aurora Documentation` |
| Operations      | `@Aurora Ops`           |
| Releases        | `@Aurora Release`       |

📚 **Full list**: [.github/agents/README.md](.github/agents/README.md)

## Skills - Specialized Capabilities

AURORA includes specialized **skills** that are auto-discovered from `.github/skills/<name>/SKILL.md`. When working on specific tasks, Copilot automatically loads relevant skills.

### Available Skills

| Skill                                                      | Domain                        | Use When                                                                                         |
| ---------------------------------------------------------- | ----------------------------- | ------------------------------------------------------------------------------------------------ |
| [bolt-framework](.github/skills/bolt-framework/)           | AURORA Methodology            | Working on AURORA projects, managing lifecycle                                                   |
| [skill-bolt-adr](.github/skills/skill-bolt-adr/)           | Architecture Decision Records | Documenting architectural decisions, technology selections, or design patterns using MADR format |
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

_AURORA-IA-DLC v1.0.0_
