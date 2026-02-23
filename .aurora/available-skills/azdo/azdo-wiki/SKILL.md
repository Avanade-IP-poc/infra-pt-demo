---
name: azdo-wiki
description: Synchronize project documentation from docs/ folder to Azure DevOps wiki with mermaid diagram conversion to SVG
---

# Azure DevOps Wiki Sync

## When to Use

- Publishing docs/ folder to Azure DevOps wiki
- Converting Mermaid diagrams to SVG (wiki doesn't support mermaid natively)
- Maintaining wiki navigation order with `.order` files

## Prerequisites

```powershell
# Install Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Configure Azure DevOps
$env:AZURE_DEVOPS_EXT_PAT = "your-pat"
az devops configure -d project="Registro Horario"
```

## Quick Start

**Sync single document:**

```powershell
.\.aurora\available-skills\azdo-wiki\scripts\Sync-DocsToWiki.ps1 -SourcePath "docs/architecture.md"
```

**Sync docs/ folder:**

```powershell
.\.aurora\available-skills\azdo-wiki\scripts\Sync-DocsToWiki.ps1 -SourcePath "docs/" -Recursive
```

**Preview (dry run):**

```powershell
.\.aurora\available-skills\azdo-wiki\scripts\Sync-DocsToWiki.ps1 -SourcePath "docs/" -DryRun
```

## Core Workflows

### 1. List Wikis

```javascript
// Using MCP tools
mcp_azure_devops_wiki_list_wikis({ project: 'Registro Horario' });
```

### 2. Publish Page with MCP

```javascript
mcp_azure_devops_wiki_create_or_update_page({
  wikiIdentifier: 'Registro-Horario.wiki',
  project: 'Registro Horario',
  path: '/Documentation/My-Page',
  content: markdownContent,
});
```

### 3. Convert Mermaid Manually

```powershell
# Use conversion script
$result = .\.aurora\available-skills\azdo-wiki\scripts\Convert-MermaidToSvg.ps1 `
  -Content $markdown `
  -BaseName "doc" `
  -OutputPath "."

# Upload SVGs
.\.aurora\available-skills\azdo-wiki\scripts\Upload-WikiAttachments.ps1 `
  -SvgFiles ($result.SvgFiles | % { $_.Path })
```

## Best Practices

**Mermaid conversion settings:**

```powershell
mmdc -i input.mmd -o output.svg -t dark -b transparent -s 2
```

**Wiki path mapping:**

- `docs/architecture.md` → `/Documentation/Architecture`
- `docs/adr/ADR-001.md` → `/Documentation/ADR/ADR-001`

**Order files** (control navigation):

```
# docs/adr/.order
ADR-0001-Adopt-DotNet-Aspire
ADR-0002-Azure-Architecture
ADR-0003-OpenTelemetry
```

## Scripts

| Script                       | Purpose                    |
| ---------------------------- | -------------------------- |
| `Sync-DocsToWiki.ps1`        | Main sync tool             |
| `Convert-MermaidToSvg.ps1`   | Extract & convert diagrams |
| `Upload-WikiAttachments.ps1` | Upload SVGs to wiki repo   |

See: `.aurora/available-skills/azdo-wiki/scripts/`

## Troubleshooting

**mmdc not found:** `npm install -g @mermaid-js/mermaid-cli`
**PAT issues:** Verify `$env:AZURE_DEVOPS_EXT_PAT` is set
**ETag mismatch:** Get page first with `mcp_azure_devops_wiki_get_page`

## References

- [Azure DevOps Wiki Docs](https://learn.microsoft.com/azure/devops/project/wiki/)
- [Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)
- Scripts: `.aurora/available-skills/azdo-wiki/scripts/`
- Examples: `.aurora/available-skills/azdo-wiki/examples/`
