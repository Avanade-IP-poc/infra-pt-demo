---
name: markdown-formatting
description: CommonMark formatting rules and Bolt Framework conventions for .md files including .agent.md and .prompt.md. ALWAYS use when creating or editing any Markdown file. Triggers: "format markdown", "markdown style", ".md file", "markdown conventions", "CommonMark", "markdown rules", "document formatting", "write readme", "edit markdown", "markdown syntax", "agent.md", "prompt.md". Applies to all Markdown in Bolt Framework projects.
---

# Markdown Formatting

## When to Use

- Creating/editing any Markdown file (.md, .agent.md, .prompt.md)
- Ensuring consistent formatting across documentation

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

\\\\markdown
\\\ ypescript
interface User {
id: string;
}
\\\

\\\ash
npm install
\\\
\\\\

Common languages: `typescript`, `javascript`, `python`, `bash`, `powershell`, `json`, `yaml`, `gherkin`, `mermaid`

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
_italic_ or _italic_ (prefer `*`)
**bold** or **bold** (prefer `**`)
**_bold italic_**
`inline code`
```

### Links

```markdown
[Link text](https://url.com)
[Relative link](../path/file.md)
[Heading link](#heading-id)
```

### Tables

```markdown
| Column 1 | Column 2 |
| -------- | -------- |
| Data     | Data     |
```

## Bolt Framework conventions

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

## References

- [CommonMark Spec](https://commonmark.org/)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
