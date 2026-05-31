# Project Instructions

## Methodology

This project uses the **Bolt Framework** (AI-Driven Development Lifecycle).
Read `.github/copilot-instructions.md` for the full methodology reference — it applies
equally to Claude Code and GitHub Copilot.

## Constitution

**ALWAYS** read `.boltf/memory/constitution.md` (and the active scope constitutions
under `.boltf/scopes/<scope>/memory/`) before generating code. They define the tech
stack, coding standards, architecture patterns, and constraints for this project.

## Unified AI Configuration

The framework is dual-client: GitHub Copilot (VS Code) and Claude Code share
the same artifacts.

| Artifact | Location | Autodescubierto por |
|---|---|---|
| Agents (Copilot shells) | `.github/agents/*.agent.md` | Copilot (`@Name`) |
| Agents (Claude shells) | `.claude/agents/*.md` | Claude Code (`Task subagent_type=<slug>`) |
| Skills (metodología, FUENTE ÚNICA) | `.claude/skills/*/SKILL.md` | Ambos (Agent Skills es estándar abierto) |
| Prompts | `.github/prompts/*.prompt.md` | Copilot (`/name`); Claude lee como markdown |
| Instructions | `.github/instructions/*.instructions.md` | Copilot (`applyTo` glob); Claude lee bajo demanda |
| Global instructions | `.github/copilot-instructions.md` | Copilot automático |
| Global instructions | `CLAUDE.md` (este fichero) | Claude automático |
| MCP servers | `.mcp.json` (source) → `.vscode/mcp.json` (generado) | Claude lee `.mcp.json`; Copilot lee `.vscode/mcp.json` |

**Agentes Bolt dual-client**: cada agente del Bolt Framework tiene una skill
metodológica en `.claude/skills/<slug>/SKILL.md` (fuente única) y dos shells
nativos: `.github/agents/<name>.agent.md` (Copilot) y `.claude/agents/<slug>.md`
(Claude). Para editar la metodología de un agente, edita su SKILL.md (no los shells).

## Interaction Language

- Interaction with agents: **(configurable — define el idioma del proyecto aquí)**.
- Generated documentation (code, plans, specs): **(mismo idioma que la interacción)**.

> El framework no impone idioma. Sustituye estos valores por el idioma del proyecto
> (p. ej. `English`, `Spanish (Spain)`).

## Commit Messages

Commit messages **MUST** reference the issue ID:

```text
feat(#128): descripción breve del cambio

Detalle de los cambios...

Closes #128
```

- Use `#<issue-number>` as the scope.
- Include `Closes #<id>` in the body.
- Conventional Commits types: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`.

## Key Directories

- `.boltf/` — Bolt Framework payload (manifest, scopes, available-skills, scripts)
- `.boltf/memory/constitution.md` — Project DNA and standards
- `.boltf/scopes/<scope>/memory/` — Per-scope constitutions
- `specs/` — Feature specifications
- `.github/agents/` — Bolt Framework agents (Copilot custom agents — shells)
- `.claude/agents/` — Bolt Framework agents (Claude Code subagents — shells)
- `.claude/skills/` — Specialized skills (Agent Skills standard, dual-client — FUENTE ÚNICA de metodología)
- `.github/prompts/` — Reusable prompt templates (Copilot slash commands)
- `.mcp.json` — MCP server definitions (source of truth for both clients)
