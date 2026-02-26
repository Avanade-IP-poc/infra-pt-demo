# 2review Cleanup Analysis

**Fecha**: 2026-02-26
**Estado**: `18 skills analizados` → `8 para borrar` + `9 para mover` + `1 vacío ya migrado`

---

## Resumen Ejecutivo

| Acción                     | Cantidad | Skills                                                                                                                                                                                           |
| -------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| ✅ **BORRAR** (duplicados) | 7        | architec-diagramer, skill-creator, azure-identity-dotnet, azure-role-selector, azure-usage, tdd-workflow, test-driven-development                                                                |
| ✅ **BORRAR** (vacíos)     | 1        | playwright-e2e (templates vacías en 2review Y functional-tests)                                                                                                                                  |
| ✅ **MOVER**               | 9        | git-branch-manager, issue-formatter, mermaid-creator, planning-with-files, frontend-design, tailwind-design-system, web-design-reviewer, integration-e2e-testing, senior-devops, senior-frontend |
| **TOTAL**                  | 18       | -                                                                                                                                                                                                |

---

## 1. SKILLS A BORRAR (Duplicados)

### 1.1 Duplicados Confirmados en Carpetas Organizadas

| Skill en 2review        | Ya existe en                    | Acción                      |
| ----------------------- | ------------------------------- | --------------------------- |
| `architec-diagramer`    | `azure/architect-diagramer/`    | **BORRAR** (typo en nombre) |
| `skill-creator`         | `.github/skills/skill-creator/` | **BORRAR**                  |
| `azure-identity-dotnet` | `azure/azure-identity-dotnet/`  | **BORRAR**                  |
| `azure-role-selector`   | `azure/azure-role-selector/`    | **BORRAR**                  |
| `azure-usage`           | `azure/azure-usage/`            | **BORRAR**                  |

### 1.2 Duplicados TDD (Consolidar en tdd-comprehensive)

| Skill en 2review          | Ya existe en               | Razón                                                               | Acción     |
| ------------------------- | -------------------------- | ------------------------------------------------------------------- | ---------- |
| `tdd-workflow`            | `common/tdd-comprehensive` | 567 líneas, "Iron Law", Red-Green-Refactor - prácticamente idéntico | **BORRAR** |
| `test-driven-development` | `common/tdd-comprehensive` | 478 líneas, "Iron Law" condensado - mismo contenido                 | **BORRAR** |

**Nota**: `tdd-comprehensive` en scope `common` YA cubre completamente TDD con 521 líneas.

### 1.3 Skills Vacíos (Sin contenido)

| Skill            | Estado                                                                    | Acción                                                                      |
| ---------------- | ------------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| `playwright-e2e` | Ambos (2review Y functional-tests) solo tienen carpeta `templates/` VACÍA | **BORRAR 2review** (functional-tests también está vacío - resolver después) |

---

## 2. SKILLS A MOVER

### 2.1 Destino: `github/` (Git/GitHub workflows)

| Skill                | Propósito                                                          | Scope sugerido |
| -------------------- | ------------------------------------------------------------------ | -------------- |
| `git-branch-manager` | Gestión branches/commits/PR, AURORA compliance, naming conventions | `common`       |
| `issue-formatter`    | Convierte logs/notas/screenshots en GitHub issues estructurados    | `common`       |

**Scope.yaml afectado**: `common/scope.yaml` (universal git workflows)

### 2.2 Destino: `document/` (Documentation/Diagramming)

| Skill                 | Propósito                                                                       | Scope sugerido |
| --------------------- | ------------------------------------------------------------------------------- | -------------- |
| `mermaid-creator`     | Creación de diagramas Mermaid (C4, flowcharts, sequence, ER, etc.) - 278 líneas | `common`       |
| `planning-with-files` | Workflow Manus-style: task_plan.md, notes.md, deliverable.md                    | `common`       |

**Scope.yaml afectado**: `common/scope.yaml` (universal documentation)

### 2.3 Destino: `ui-common/` (Frontend UI/UX)

| Skill                    | Propósito                                                         | Scope sugerido |
| ------------------------ | ----------------------------------------------------------------- | -------------- |
| `frontend-design`        | Diseño frontend distintivo (Angular, React, Vue) con Tailwind CSS | `frontend`     |
| `tailwind-design-system` | Design systems con Tailwind v4, OKLCH, design tokens - 397 líneas | `frontend`     |
| `web-design-reviewer`    | Revisión visual de diseño web con browser automation - 380 líneas | `frontend`     |

**Scope.yaml afectado**: `frontend/scope.yaml`

### 2.4 Destino: `functional-tests/` (Integration/E2E Testing)

| Skill                     | Propósito                                                           | Scope sugerido |
| ------------------------- | ------------------------------------------------------------------- | -------------- |
| `integration-e2e-testing` | Testing .NET con Testcontainers + Respawn (SQL Server) - 317 líneas | `backend`      |

**Scope.yaml afectado**: `backend/scope.yaml`

**Nota crítica**: Este skill es DIFERENTE de playwright-e2e (browser testing). Se enfoca en tests de integración con SQL Server real usando Podman.

### 2.5 Destino: `cloud-platform/` (DevOps Completo)

| Skill           | Propósito                                                               | Scope sugerido   |
| --------------- | ----------------------------------------------------------------------- | ---------------- |
| `senior-devops` | DevOps completo (CI/CD, IaC, containers, monitoring) con Python scripts | `cloud-platform` |

**Scope.yaml afectado**: `cloud-platform/scope.yaml`

### 2.6 Destino: `frontend/` (Frontend Architecture - crear carpeta)

| Skill             | Propósito                                                                | Scope sugerido |
| ----------------- | ------------------------------------------------------------------------ | -------------- |
| `senior-frontend` | Frontend completo (React, Next, TypeScript, Tailwind) con Python scripts | `frontend`     |

**Scope.yaml afectado**: `frontend/scope.yaml`

**Nota**: El scope `frontend/` YA existe, pero NO hay carpeta `frontend/` en available-skills. Opciones:

- Crear `available-skills/frontend/` para skills frontend genéricos
- O moverlo a `react/` (tecnología específica)

**Decisión propuesta**: Crear `available-skills/frontend/` para skills frontend agnósticos al framework.

---

## 3. SCOPE.YAML - Actualizaciones Necesarias

### 3.1 `common/scope.yaml`

**Agregar** (4 nuevos skills universales):

```yaml
skills:
  - markdown-formatting # (YA existe)
  - tdd-comprehensive # (YA existe)
  - gherkin-reqnroll # (YA existe)
  - git-branch-manager # NUEVO - Git workflows
  - issue-formatter # NUEVO - GitHub issue templates
  - mermaid-creator # NUEVO - Diagrams documentation
  - planning-with-files # NUEVO - Planning workflow
```

### 3.2 `frontend/scope.yaml`

**Agregar** (4 nuevos skills frontend):

```yaml
skills:
  - frontend-design # NUEVO - Frontend UI design
  - tailwind-design-system # NUEVO - Tailwind v4 design systems
  - web-design-reviewer # NUEVO - Visual design review
  - senior-frontend # NUEVO - Frontend architecture
```

### 3.3 `backend/scope.yaml`

**Agregar** (1 nuevo skill):

```yaml
skills:
  - integration-e2e-testing # NUEVO - Testcontainers + Respawn
```

### 3.4 `cloud-platform/scope.yaml`

**Agregar** (1 nuevo skill):

```yaml
skills:
  - senior-devops # NUEVO - DevOps complete toolkit
```

---

## 4. ESTRUCTURA DE COMANDOS

### 4.1 Borrar Duplicados (8 skills)

```powershell
# Borrar duplicados
Remove-Item -Recurse -Force "2review/architec-diagramer"
Remove-Item -Recurse -Force "2review/skill-creator"
Remove-Item -Recurse -Force "2review/azure-identity-dotnet"
Remove-Item -Recurse -Force "2review/azure-role-selector"
Remove-Item -Recurse -Force "2review/azure-usage"
Remove-Item -Recurse -Force "2review/tdd-workflow"
Remove-Item -Recurse -Force "2review/test-driven-development"
Remove-Item -Recurse -Force "2review/playwright-e2e"
```

### 4.2 Mover Skills (9 skills)

```powershell
# A github/
Move-Item "2review/git-branch-manager" "github/"
Move-Item "2review/issue-formatter" "github/"

# A document/
Move-Item "2review/mermaid-creator" "document/"
Move-Item "2review/planning-with-files" "document/"

# A ui-common/
Move-Item "2review/frontend-design" "ui-common/"
Move-Item "2review/tailwind-design-system" "ui-common/"
Move-Item "2review/web-design-reviewer" "ui-common/"

# A functional-tests/
Move-Item "2review/integration-e2e-testing" "functional-tests/"

# A cloud-platform/ (crear si no existe carpeta skills)
Move-Item "2review/senior-devops" "cloud-platform/"

# Crear frontend/ y mover
New-Item -ItemType Directory -Path "frontend" -Force
Move-Item "2review/senior-frontend" "frontend/"
```

---

## 5. VALIDACIÓN POST-MIGRACIÓN

### Checklist

- [ ] 2review/ debe quedar VACÍO (excepto README.md)
- [ ] github/ debe tener 7 skills (5 actuales + 2 nuevos)
- [ ] document/ debe tener 3 skills (1 actual + 2 nuevos)
- [ ] ui-common/ debe tener 3 skills (0 actuales + 3 nuevos)
- [ ] functional-tests/ debe tener 3 skills (2 actuales + 1 nuevo)
- [ ] cloud-platform/ debe tener 1 skill (0 actuales + 1 nuevo)
- [ ] frontend/ debe tener 1 skill (0 actuales + 1 nuevo)
- [ ] Todos los scope.yaml actualizados con nuevas referencias
- [ ] Validar con `npm run validate:scopes:ps`

---

## 6. README.md - Actualización

**Actualizar** `2review/README.md`:

```markdown
# ✅ CLEANUP COMPLETED (2026-02-26)

## Final Status

- **8 duplicados borrados**: architec-diagramer, skill-creator, azure-\*, tdd-workflow, test-driven-development, playwright-e2e (vacío)
- **9 skills migrados**: Distribuidos en github/, document/, ui-common/, functional-tests/, cloud-platform/, frontend/
- **Total procesado**: 18 skills (originalmente documentados 15 duplicados, pero se encontraron 3 TDD duplicados adicionales)

## Scope Updates

- `common/scope.yaml`: +4 skills (git-branch-manager, issue-formatter, mermaid-creator, planning-with-files)
- `frontend/scope.yaml`: +4 skills (frontend-design, tailwind-design-system, web-design-reviewer, senior-frontend)
- `backend/scope.yaml`: +1 skill (integration-e2e-testing)
- `cloud-platform/scope.yaml`: +1 skill (senior-devops)

**Carpeta 2review/ lista para archivo.**
```

---

## 7. DECISIONES CLAVE

### 7.0 Aspire Templates - Refactoring de Cohesión

**Problema**: Templates de Aspire separados en `.aurora/templates/aspire/` (baja cohesión con skill).

**Decisión**:

1. Mover templates DENTRO del skill: `.aurora/available-skills/aspire/skill-bolt-aspire-orchestration/templates/`
2. Provisioning unificado: 1 Copy-Item recursivo (no 2 separados)
3. Eliminar `.aurora/templates/aspire/` (redundante)

**Razón**:

- ✅ Alta cohesión: Skill + templates juntos
- ✅ Pattern consistency: Igual que otros skills con templates/ subdirectory
- ✅ Versionado: Skill y templates evolucionan juntos
- ✅ Portabilidad: Mover skill = todo incluido

**Implementación**:

- **Mover**: 4 templates (AppHost.csproj, ServiceDefaults.csproj, Extensions.cs, Program.cs.template)
- **Simplificar**: Copy-AspireResources function (1 Copy-Item recursivo)
- **Destino final**: `.github/skills/skill-bolt-aspire-orchestration/templates/` (después de provisioning)

### 7.1 Playwright-e2e

**Problema**: Ambos playwright-e2e (2review y functional-tests) están vacíos (solo `templates/` vacías).

**Decisión**:

1. Borrar `2review/playwright-e2e`
2. Mantener `functional-tests/playwright-e2e` como placeholder
3. **TODO separado**: Crear skill playwright-e2e completo en Phase 5.8

### 7.2 TDD Skills (3 → 1)

**Problema**: 3 skills TDD prácticamente idénticos:

- `tdd-comprehensive` (521 líneas) - común scope ✅
- `tdd-workflow` (567 líneas) - 2review ❌
- `test-driven-development` (478 líneas) - 2review ❌

**Decisión**: Mantener solo `tdd-comprehensive` (es el más completo y está en common scope).

### 7.3 Frontend Skills (crear carpeta frontend/)

**Problema**: `senior-frontend` necesita carpeta para skills frontend agnósticos.

**Decisión**: Crear `available-skills/frontend/` para skills NO específicos a React/Vue/Angular.

---

## 8. IMPACTO EN PLAN

**Actualizar plan**:

- **Fase 5.7**: 2review Cleanup (8 borrados, 9 migrados, 4 scope.yaml actualizados)
- **Progreso**: 93% → 95%
- **Siguiente**: Task 28 - Manual Testing de Init.ps1

---

**Autor**: Bolt Framework Analysis
**Fecha**: 2026-02-26
