# Bolt Framework Skills

Specialized skills for the Bolt Framework methodology (AURORA-IA-DLC).

## Overview

This folder contains skills specifically designed to support the Bolt Framework, an AI-Driven Development Lifecycle methodology that guides projects through 6 lifecycle phases with micro-iterations (Bolts).

## Skills

| Skill                                       | Description                                                  | Use When                                      |
| ------------------------------------------- | ------------------------------------------------------------ | --------------------------------------------- |
| [bolt-framework](bolt-framework/SKILL.md)   | Core AURORA-IA-DLC methodology with 6 lifecycle phases       | Orchestrating projects, managing Bolt cycles  |
| [bolt-adr](bolt-adr/SKILL.md)               | Architecture Decision Records using MADR format              | Documenting architectural decisions           |

## What is Bolt Framework?

Bolt Framework (AURORA-IA-DLC) is an AI-powered software development methodology that organizes work into:

- **6 Lifecycle Phases**: INCEPTION → DISCOVERY → CONSTRUCTION → TRANSITION → PRODUCTION → RETIREMENT
- **Micro-Iterations (Bolts)**: Small, deliverable increments (2-3 days max)
- **Quality Gates**: Every Bolt must pass linting, tests, and review
- **Agent Specialization**: 31+ specialized AI agents for different tasks

## Key Concepts

### Constitution (`memory/constitution.md`)

The project's DNA - defines tech stack, standards, constraints. **Must be read before any work.**

### Bolts

Micro-iterations that deliver working, tested, reviewed code. Each Bolt:

- Has clear acceptance criteria
- Passes quality gates
- Takes 2-3 days maximum
- Builds incrementally on previous Bolts

### Agents

Specialized AI agents handle specific tasks:

- `@Bolt Framework` - Main orchestrator
- `@Bolt ADR` - Architecture decisions
- `@Aurora Feature` - Feature specifications
- `@Aurora Implement` - Code implementation
- And 26+ more specialized agents

## Activation

These skills are activated in projects via `.aurora/scopes/` configuration when:

- Using Bolt Framework methodology
- Need architecture decision documentation
- Following AURORA-IA-DLC workflow

## Integration

Bolt Framework skills work with:

- **Constitution**: `memory/constitution.md` - Project constraints and standards
- **Feature Specs**: `specs/XXX-feature-name/` - Detailed feature specifications
- **Quality Gates**: Automated validation of code quality
- **Agents**: 31+ AURORA agents in `.github/agents/`

## Documentation

Each skill contains:

- `SKILL.md` - Complete skill methodology and usage
- `README.md` - Overview and quick reference
- `examples/` - Real-world usage examples
- `templates/` - Reusable document templates
- `scripts/` - Automation scripts (where applicable)

## References

- **Main Documentation**: [bolt-framework/SKILL.md](bolt-framework/SKILL.md)
- **Agents**: `.github/agents/` - All AURORA agents
- **Skills**: `.github/skills/` - Currently active skills
- **Scopes**: `.aurora/scopes/` - Skill activation rules

---

**Part of**: AURORA-IA-DLC (AI-Driven Development Lifecycle)
**Version**: 1.0.0
**Created**: 2026-02-23
