---
name: new-skill
description: Guide for creating custom GitHub Copilot skills with YAML frontmatter, SKILL.md format, progressive disclosure, and auto-discovery. Use when creating domain-specific capabilities (testing patterns, API design, security workflows) or improving existing skills. Triggers: "create skill", "new skill", "skill template", "YAML frontmatter", "auto-discovery", "skill format", "make a skill", "build skill", "skill structure", "skill best practices", "progressive disclosure".
---

# Creating New Skills

## When to Use

- Creating domain-specific capabilities (testing, API design, security patterns)
- Documenting proven workflows for repeated tasks
- NOT for one-off tasks or constantly changing info

## Structure

```
.github/skills/
└── skill-name/
    ├── SKILL.md           # Required
    ├── examples/          # Optional
    └── templates/         # Optional
```

## SKILL.md Format

```markdown
---
name: skill-name
description: Brief one-line description
---

# Skill Title

## When to Use

- Specific use case 1
- Specific use case 2

## Quick Start

[Essential commands/steps only]

## Key Actions

[2-3 core workflows with examples]

## References

[Links to detailed docs if needed]
```

## Creating a Skill

```bash
# 1. Create directory
mkdir -p .github/skills/my-skill

# 2. Create SKILL.md (use template above)
code .github/skills/my-skill/SKILL.md

# 3. Register in copilot-instructions.md
```

Add to `.github/copilot-instructions.md`:

```markdown
<skill>
<name>my-skill</name>
<description>Brief description</description>
<file>f:\repos\registro-horas\.github\skills\my-skill\SKILL.md</file>
</skill>
```

## Best Practices

- ✅ Specific domain focus (not "general programming")
- ✅ Actionable steps with code examples
- ✅ 50-150 lines max
- ✅ Test with actual Copilot queries
- ❌ No verbose explanations
- ❌ No duplicate constitution content
