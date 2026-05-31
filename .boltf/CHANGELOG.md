# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- N/A

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- N/A

### Security
- N/A

---

## [0.1.0] - 2026-05-31

### Added
- Initial project structure with Bolt Framework / AI-DLC methodology
- Dual-client AI agents (GitHub Copilot `.github/agents/` + Claude `.claude/agents/`)
- GitHub Copilot prompt files with Agent References
- CI/CD workflows for GitHub Actions
- Slash Commands with embedded templates
- Automation scripts (Bash + PowerShell)
- Project documentation (README, CONTRIBUTING, LICENSE)
- Modelo de gobierno: git subtree + PowerShell CLI (`BoltFramework.psm1`)
- `bolt-manifest.yaml` — metadata de versión del framework y scopes
- `CODEOWNERS` — governance por scope y categoría de skills
- Documentación completa de contribución (`CONTRIBUTING.md`)
- Workflow `bolt-update-check.yml` — aviso semanal de nuevas versiones upstream
- Skills como **fuente única** en `.claude/skills/` (modelo shell+skill dual-client)
- `Init.ps1` / `init.sh`: selección de agente (Copilot/Claude), copia selectiva e
  inicialización de la gobernanza git (subtree + remote `bolt-upstream`)

---

## Template

Use this template for new versions:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- New features

### Changed
- Changes in existing functionality

### Deprecated
- Soon-to-be removed features

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Vulnerability fixes
```

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 0.1.0 | 2026-05-31 | Initial release |

---

## Links

- [Releases](https://github.com/ava-group-iberiademos/bolt-framework/releases)
- [Milestones](https://github.com/ava-group-iberiademos/bolt-framework/milestones)
- [Compare Versions](https://github.com/ava-group-iberiademos/bolt-framework/compare)
