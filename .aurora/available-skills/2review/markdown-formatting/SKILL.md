---
name: markdown-formatting
description: CommonMark formatting rules and AURORA conventions for .md files
---

# Markdown Formatting

## When to Use

- Creating/editing any Markdown file (.md, .agent.md, .prompt.md)
- Ensuring consistent formatting across documentation
- The user requests markdown formatting guidance or validation

## Essential Rules

### Headings

```markdown
# H1 - One per document only

## H2 - Main sections

### H3 - Subsections

Don't skip levels (H2 → H4 is wrong)
```

### Code Blocks

Always use fenced blocks with language:

```typescript
interface User {
  id: string;
}
```

```bash
npm install
```

'''text This is a generic code block without language '''

Common languages: `typescript`, `javascript`, `python`, `bash`, `powershell`, `json`, `yaml`,
`gherkin`, `mermaid`

When a fenced block is not related to any particular language, use `text`:

### Lists

```markdown
- Use `-` for unordered lists
- Indent with 2 spaces
  - Nested item

1. Ordered lists
2. Auto-number with `1.`
3. Will render correctly

- [ ] Task not done
- [x] Task completed
```

### Emphasis

```markdown
_italic_ or _italic_ (prefer `*`) **bold** or **bold** (prefer `**`) **_bold italic_** `inline code`
```

### Links

```markdown
[Link text](https://url.com) [Relative link](../examples/adr-example.md) [Heading link](#heading-id)
```

### Tables

```markdown
| Column 1 | Column 2 |
| -------- | -------- |
| Data     | Data     |
```

## AURORA Conventions

- YAML frontmatter for agents/prompts:
  ```yaml
  ---
  name: document-name
  description: Brief description
  ---
  ```
- Use Mermaid for diagrams, not ASCII art
- Prefer `*` over `_` for consistency
- One blank line between sections
- No trailing whitespace

## Validation

```bash
# Install markdownlint
npm install -g markdownlint-cli

# Check file
markdownlint README.md

# Fix auto-fixable issues
markdownlint --fix README.md
```

## Graphics and Diagrams

- ALWAYS prioritize Mermaid diagrams for architecture, flowcharts, sequence diagrams
- Use ASCII art only when Mermaid is not a good fit

## References

- [CommonMark Spec](https://commonmark.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
