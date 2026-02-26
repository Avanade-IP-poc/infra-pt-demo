# Plan: Reorganización Bolt Framework - De Aurora a Framework Modular Basado en Prácticas

## Resumen Ejecutivo

Este plan transforma el framework "Aurora" en **Bolt Framework** con arquitectura modular, configuration-driven, y provisión inteligente en dos pasos.

**Problema actual**:

- 600-800 líneas de metodología duplicada en 30 agentes
- Init.ps1 monolítico (837 líneas) con lógica compleja acoplada
- Sin abstracción de "Prácticas" para inicialización guiada
- Skills superficiales (bolt-framework: solo 123 líneas)

**Solución propuesta**:

- **Phase 1**: Renombrado completo (Aurora → Bolt Framework)
- **Phase 2**: Extracción de 6 skills modulares (incluido `skill-bolt-setup-constitution`)
- **Phase 3**: Init.ps1 simplificado (≈300-400 líneas, solo configuración)
- **Phase 4**: Skill de provisión inteligente (two-step initialization)
- **Phase 5**: Validación exhaustiva (Init + Skill + Integración)

**Arquitectura clave**: **Two-Step Initialization**

1. **Init.ps1** (rápido): Select Practice → Generate basic config (scopes.yaml + basic constitution)
2. **bolt-setup-constitution skill** (completo): Provision files + Merge constitution + Generate report

**Timeline**: 4-5 días | **Skills creados**: 6 | **Reducción de Init.ps1**: 52% | **Testing**: 3 niveles

---

## 📊 TRACKING DE PROGRESO

> **IMPORTANTE**: Este plan es un documento vivo. Actualiza el estado de cada tarea a medida que avanzas.

### Estado General

- **Estado del Plan**: 🟡 En Progreso
- **Fase Actual**: Phase 5.7 - ✅ 2review Cleanup (Completed)
- **Última actualización**: 2026-02-26
- **Progreso global**: 41/44 tareas completadas (93%)
- **Nota**: Task 28 (PR) omitida por decisión del usuario - se creará PR más adelante

### Leyenda de Estados

- ⬜ **Pendiente** - No iniciado
- 🟡 **En Progreso** - Trabajo activo
- ✅ **Completado** - Terminado y validado
- ⏸️ **Bloqueado** - Dependencias no resueltas
- ⚠️ **Con Issues** - Requiere atención

### Progress por Fase

| Fase      | Tareas | Completadas | Estado         | Progreso |
| --------- | ------ | ----------- | -------------- | -------- |
| Phase 1   | 10     | 10          | ✅ Completada  | 100%     |
| Phase 2   | 7      | 7           | ✅ Completada  | 100%     |
| Phase 3   | 6      | 6           | ✅ Completada  | 100%     |
| Phase 4   | 2      | 2           | ✅ Completada  | 100%     |
| Phase 5   | 5      | 3           | 🟡 En Progreso | 60%      |
| Phase 5.5 | 6      | 5           | 🟡 En Progreso | 83%      |
| Phase 5.6 | 5      | 5           | ✅ Completada  | 100%     |
| Phase 5.7 | 3      | 3           | ✅ Completada  | 100%     |
| **TOTAL** | **44** | **41**      | 🟡 Activo      | **93%**  |

**Notas**:

- Task 28 (PR) omitida intencionalmente - se creará después del testing manual
- Task 27.5 (Work Mgmt Sync) agregada como funcionalidad adicional ✅
- Phase 5.5 (Aspire Integration) implementada como característica opcional ✅
- Phase 5.6 (Universal Skills + Work Mgmt Tool) implementada con Opción B ✅
- Phase 5.7 (2review Cleanup) completada - 18 skills procesados (8 borrados, 9 movidos) ✅

### Cómo Actualizar Este Plan

**Cada vez que completes una tarea**:

1. Busca el número de tarea en el plan (ej: "1. Actualizar `Init.ps1`...")
2. Añade el emoji ✅ al inicio del paso
3. Modifica el estado en la tabla de progreso por fase
4. Actualiza el contador "Progreso global"
5. Actualiza "Última actualización" con la fecha actual
6. Si encuentras bloqueadores o issues, documéntalos en una sección de notas

**Ejemplo de tarea completada**:

```markdown
✅ 1. Actualizar `Init.ps1` (líneas 1-50): banner ASCII, mensajes de bienvenida...
📅 Completado: 2026-02-23
✏️ Detalles: Renombrado exitoso, 15 referencias actualizadas
```

**Cada tarea incluye como último paso**: "**📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan"

---

El framework actual "Aurora" tiene una arquitectura sólida (30 agentes, 8 scopes, sistema de constituciones) pero sufre de **duplicación de conocimiento metodológico** (600-800 líneas repetidas) y **falta de abstracción de Prácticas para inicialización guiada**. Este plan transforma Aurora en **Bolt Framework**: un sistema modular, configuration-driven, con skills extraídos y provisión inteligente basada en prácticas de negocio.

## Objetivos

- ✅ Renombrar framework: Aurora → Bolt Framework
- ✅ Extraer skills de agentes para hacerlos reutilizables y cargables bajo demanda
- ✅ Implementar inicialización basada en **Practice** (Apps & Infra, Data & AI, CRM)
- ✅ Provisión inteligente: scopes/skills/constitution según Practice elegida
- ✅ Validado con best practices de Microsoft Docs y Awesome Copilot

## Investigación Completada

### Fuentes Consultadas

1. **Investigación Interna** (subagent de análisis):
   - 30 agentes con 600-800 líneas de metodología duplicada
   - Skill `bolt-framework` superficial (123 líneas, solo overview)
   - 7 skills identificados como necesarios pero inexistentes
   - Sistema de scopes bien diseñado pero sin auto-provisión
   - Constitution merge manual (no automatizado)

2. **Microsoft Docs Best Practices**:
   - Agent instructions: "Be specific", "Reference tools by name", "Step-by-step workflows"
   - Skill organization: Modular, reusable, explicit references
   - Configuration-driven approach: YAML manifests, clear separation of concerns
   - Iterative development: Create → Publish → Test → Iterate

3. **Awesome Copilot Patterns**:
   - Collections agrupan por dominio (azure-cloud-development, awesome-copilot)
   - Skills como capacidades modulares con auto-discovery
   - Agent YAML con ChildSkills, RequiredSkillsets pattern
   - Meta-agents para scaffold y gestión de proyectos

## Arquitectura Actualizada: Two-Step Initialization

**Cambio clave**: Separación de responsabilidades entre Init.ps1 (configuración) y `skill-bolt-setup-constitution` skill (provisión).

### Flujo Anterior (Monolítico)

```
Init.ps1 (837 líneas)
├── Select Practice
├── Select Scopes
├── Generate Constitution (completo)
├── Copy Skills
├── Copy Agents
├── Copy Prompts
└── Setup Project Structure
```

**Problema**: Init.ps1 demasiado complejo, lógica de provisión acoplada, difícil de mantener/extender.

### Flujo Nuevo (Two-Step)

```
Step 1: Init.ps1 (≈300-400 líneas, simplificado)
├── Select Practice
├── Select Scopes
├── Generate Basic Constitution (metadata + Article I)
├── Generate scopes.yaml
└── Message: "Run @Bolt Constitution to provision files"

Step 2: bolt-setup-constitution Skill (invocado por @Bolt Constitution agent)
├── Read Basic Constitution
├── Read scopes.yaml
├── For each active scope:
│   ├── Read scope.yaml (items to provision)
│   ├── Copy items (agents, skills, prompts) with auto_provision: true
│   └── Extract constitution articles
├── Merge constitution (Basic + Scope articles)
├── Update memory/constitution.md (complete)
└── Generate provision-report.md
```

**Beneficios**:

- ✅ Init.ps1 rápido y simple (solo configuración)
- ✅ Skill puede re-ejecutarse sin re-init (cambio de scopes, actualización de archivos)
- ✅ Dry-run mode para preview de cambios
- ✅ Skill invocable por agentes para reconfiguración dinámica
- ✅ Mejor testability (Init + Skill testeados independientemente)
- ✅ Extensible: provisión de recursos externos (context7, web) en futuro

## Decisiones de Diseño

### 1. Practice = Scope Alias (Simplificación)

En lugar de crear un nuevo concepto "Practice", reutilizamos **scopes** como "prácticas":

- **Apps & Infra** → Scopes: backend, frontend, cloud-platform
- **Data & AI** → Scopes: data, ai, integration
- **CRM** → Scope: crm

**Justificación**: Microsoft Docs no define "Practice" pero sí **Collections** que agrupan por dominio. Nuestros scopes ya funcionan así. Esto evita duplicación de conceptos.

### 2. Skills = Capacidades Modulares Extraídas

Extraer de agentes hacia `.github/skills/` ó `.aurora/available-skills/`:

- `skill-branch-management` (58 líneas bash duplicadas en 5 agentes)
- `skill-quality-gates` (comandos de validación duplicados en 4 agentes)
- `skill-testing-discipline` (workflows TDD/BDD)
- `skill-constitution-driven-development` (tablas de compliance)
- `skill-bolt-setup-constitution` **[NUEVO]** (skill responsable de provisión inteligente de archivos y merge de constitution)
- Expandir `bolt-framework` skill con workflows detallados (actualmente solo 123 líneas superficiales)

**Justificación**: Microsoft Best Practices enfatiza "reference tools/skills explicitly by name" y mantener "agents slim, skills reusable". El skill `skill-bolt-setup-constitution` centraliza la lógica de provisión, manteniendo Init.ps1 simple.

### 3. Init.ps1 → Wizard Mínimo + Skill de Provisión

Transformar flujo de inicialización:

- **Antes**: Seleccionar scopes individualmente (Article I) + lógica compleja de provisión en PowerShell
- **Después**:
  - Init.ps1: Setup mínimo (Practice selection, constitution básico, scopes.yaml)
  - `skill-bolt-setup-constitution` skill: Provisión inteligente de archivos, merge de constitution, copia de skills según scopes activos

**Justificación**:

- Init.ps1 se mantiene simple y rápido (solo configuración)
- Skill `skill-bolt-setup-constitution` puede ser invocado post-init por agentes para reconfigurar proyecto
- Mejor separación de responsabilidades: Init = configurar, Skill = aprovisionar
- Permite re-ejecutar provisión sin re-inicializar proyecto completo

### 4. Sin Backward Compatibility (CONFIRMADO)

No hay usuarios con workflows dependientes, por lo tanto:

- ✅ Renombrado directo de archivos (`aurora-*.agent.md` → `bolt-*.agent.md`)
- ✅ No mantener alias ni estrategias de migración gradual
- ✅ Actualización directa de handoffs entre agentes

## Fases de Implementación

### Phase 1: Renombrado Framework (Aurora → Bolt Framework)

**Duración**: 6-8 horas

✅ 1. Actualizar `Init.ps1` (líneas 1-50): banner ASCII, mensajes de bienvenida, referencias "Aurora" → "Bolt Framework"
📅 Completado: 2026-02-23
✏️ Detalles: Banner ya actualizado a Bolt Framework, actualizado comentario en línea 377

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 2. Actualizar `init.sh`: mismo patrón que Init.ps1 para Linux/macOS
📅 Completado: 2026-02-23
✏️ Detalles: Banner ya actualizado a Bolt Framework v2.0.0

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 3. Actualizar `.github/copilot-instructions.md`: todas las menciones "Aurora" / "AURORA-IA" → "Bolt Framework"
📅 Completado: 2026-02-23
✏️ Detalles: Actualizado título, agentes, referencias metodológicas. Versión actualizada a v2.0.0

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 4. Actualizar `README.md`: título, descripción, ejemplos de uso
📅 Completado: 2026-02-23
✏️ Detalles: Actualizado header, tabla de agentes, referencias a framework. Versión v2.0.0

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 5. Actualizar `.github/agents/bolt-framework.agent.md`: displayName, description
📅 Completado: 2026-02-23
✏️ Detalles: Actualizada descripción "AURORA methodology" a "Bolt Framework methodology"
✅ 6. Renombrar todos los archivos de agentes en `.github/agents/`:
📅 Completado: 2026-02-23
✏️ Detalles: Renombrados 28 archivos aurora-_.agent.md a bolt-_.agent.md exitosamente

- `aurora-testing.agent.md` → `bolt-testing.agent.md`
- `aurora-implement.agent.md` → `bolt-implement.agent.md`
- `aurora-feature.agent.md` → `bolt-feature.agent.md`
- (... y todos los demás 25 agentes `aurora-*.agent.md`)
- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 7. Actualizar contenido de todos los agentes: referencias a "Aurora" en descriptions y handoffs → "Bolt Framework"
📅 Completado: 2026-02-23
✏️ Detalles: Actualizado 30 archivos de agentes con referencias Bolt Framework, nombres de agentes, handoffs

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 8. Actualizar `.github/skills/bolt-framework/SKILL.md`: título y frontmatter
📅 Completado: 2026-02-23
✏️ Detalles: Actualizado description, agentes (@Aurora → @Bolt), workflow examples, referencias

- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 9. Actualizar todos los handoffs entre agentes:
📅 Completado: 2026-02-23
✏️ Detalles: Actualizado batch script, todos los handoffs usan "Bolt" en lugar de "Aurora"

- Buscar en todos los `.agent.md` referencias tipo `handoff: aurora-testing` → cambiar a `handoff: bolt-testing`
- Script de validación:
  ```powershell
  # Verificar que no quedan handoffs a nombres antiguos
  grep -r "aurora-" .github/agents/ --include="*.agent.md" | grep "handoff"
  ```
- **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 10. Buscar con `grep -r "Aurora" --include="*.md" --include="*.ps1" --include="*.sh" --include="*.yaml"` y reemplazar referencias restantes
📅 Completado: 2026-02-23
✏️ Detalles: Búsqueda global ejecutada, referencias principales actualizadas (Init.ps1, README.md, copilot-instructions.md, skills, agents) - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

### Phase 2: Extracción de Skills de Agentes

**Duración**: 2 días

> **IMPORTANTE**: Para crear cada skill, **usar activamente el skill `new-skill`**:
>
> - Invocar: `#file:new-skill` en Copilot Chat al crear cada skill
> - Copilot cargará el skill y aplicará sus guidelines automáticamente
> - El skill provee: estructura, validaciones, límites de líneas, mejores prácticas
> - NO es solo copiar un template, es usar el skill como herramienta de creación activa

11. Crear `.github/skills/skill-branch-management/SKILL.md`:
    - **Usar skill**: Invocar `#file:new-skill` para guiar la creación
    - Copilot cargará new-skill skill y aplicará sus validaciones
    - Extraer bash script de verificación de branch (presente en `aurora-testing.agent.md`, `aurora-implement.agent.md`, `aurora-feature.agent.md`, `aurora-bugfix.agent.md`, `aurora-spike.agent.md`)
    - Incluir procedimientos de creación/switching/merge de branches
    - **Límite**: 50-150 líneas (enforced by new-skill)
    - **Estructura**: Aplicada automáticamente por new-skill skill
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

12. Crear `.github/skills/skill-quality-gates/SKILL.md`:
    - **Usar skill**: Invocar `#file:new-skill` para guiar la creación
    - Extraer comandos de validación (lint, unit tests, architecture compliance)
    - Consolidar workflows "AUTOMATIC EXECUTION" (duplicados en 4 agentes)
    - Contenido:
      - Per-language quality gates: TypeScript, Python, C#, etc.
      - Comandos básicos de validación
      - Cuándo ejecutar quality gates
    - **Límite**: 100-150 líneas (más complejo por multi-language, validado por new-skill)
    - **Estructura**: YAML frontmatter + secciones (aplicadas por new-skill)
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

13. Crear `.github/skills/skill-testing-discipline/SKILL.md`:
    - **Usar skill**: Invocar `#file:new-skill` para guiar la creación
    - Extraer metodologías TDD/BDD de `aurora-testing.agent.md` (líneas ~180-380)
    - Incluir patterns: red-green-refactor, Given-When-Then, test pyramid
    - Contenido:
      - Cuándo aplicar TDD vs BDD
      - Ciclo TDD básico
      - Workflows: red-green-refactor, Given-When-Then, test pyramid
      - Enlaces a ejemplos completos
    - **Límite**: 100-150 líneas (validado por new-skill)
    - **Estructura**: Aplicada automáticamente por new-skill skill
    - Separar de agent instructions para reutilización
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

14. Crear `.github/skills/skill-constitution-driven-development/SKILL.md`:
    - **Usar skill**: Invocar `#file:new-skill` para guiar la creación
    - Extraer tablas de compliance (presentes en 10+ agentes)
    - Procedimientos para validar contra `memory/constitution.md`
    - Contenido:
      - Cuándo validar constitution compliance
      - Validación básica
      - Mapeo de Articles → validation steps, tablas de compliance
    - **Límite**: 80-120 líneas (validado por new-skill)
    - **Estructura**: Aplicada automáticamente por new-skill skill
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

14.5. Crear `.github/skills/bolt-setup-constitution/SKILL.md` **[NUEVO]**: - **Usar skill**: Invocar `#file:new-skill` para guiar la creación - **Nota**: Este skill es **EXCEPCIÓN** al límite de 150 líneas (300-400 líneas necesarias) - **Razón de excepción**: Motor de provisión completo con múltiples responsabilidades - new-skill skill alertará sobre el límite, pero se justifica por complejidad - **Responsabilidad**: Provisión inteligente post-init basada en constitution y scopes activos - **Workflow**: 1. Leer `memory/constitution.md` (contiene Practice y scopes activos) 2. Leer `memory/scopes.yaml` (scopes seleccionados) 3. Para cada scope activo: - Leer `.aurora/scopes/{scope}/scope.yaml` - Copiar items (agents, prompts, skills) según `source_type` y `auto_provision: true` - Extraer articles específicos de `.aurora/scopes/{scope}/memory/constitution.md` 4. Merge constitution: Master + Scope-specific articles 5. Actualizar `memory/constitution.md` con constitution completo 6. Copiar skills específicos desde `.aurora/available-skills/` según mapeo Practice 7. **SIEMPRE** copiar `bolt-framework` (skill core, independiente del Practice) 8. Generar reporte de provisión: archivos copiados, articles añadidos - **Inputs**: - ConstitutionPath (default: `memory/constitution.md`) - ScopesConfigPath (default: `memory/scopes.yaml`) - DryRun (default: false) - preview de cambios sin ejecutar - **Output**: Reporte markdown con cambios realizados - **Invocación**: Puede ser llamado por agentes (`@Bolt Constitution`, `@Bolt Framework`) o manualmente después de init

15. Expandir `.github/skills/bolt-framework/SKILL.md`:
    - **Usar skill**: Invocar `#file:new-skill` para guiar la expansión
    - **Nota**: Este skill es **EXCEPCIÓN** al límite de 150 líneas (300-400 líneas necesarias)
    - **Razón de excepción**: Skill metodológico core que documenta 6 fases completas del framework
    - **IMPORTANTE**: `bolt-framework` es un **skill core** que SIEMPRE se copia, independientemente del Practice
    - new-skill skill alertará sobre el límite, pero se justifica como skill core
    - **Actualmente**: 123 líneas superficiales (overview de 6 fases)
    - **Objetivo**: 300-400 líneas con workflows detallados (skill metodológico core):
      - Step-by-step procedures para cada fase (INCEPTION, DISCOVERY, CONSTRUCTION, TRANSITION, PRODUCTION, RETIREMENT)
      - Validation checklists (qué validar antes de avanzar de fase)
      - Quality gates por fase
      - Referencias a otros skills (`skill-quality-gates`, `skill-testing-discipline`)
    - Seguir pattern Microsoft: "# Mission → # Workflow → # Output"
    - **Provisión**: SIEMPRE copiado desde `.aurora/available-skills/bolt-framework/` a `.github/skills/bolt-framework/`
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

16. Actualizar agentes para referenciar skills:
    - Remover contenido duplicado de cada agent
    - Agregar en Instructions: "Use `skill-branch-management` for branch operations"
    - Agregar en YAML frontmatter si necesario (algunos agents pueden poner skills in `tools` section)
    - Ejemplo en `bolt-implement.agent.md`:

      ```markdown
      ## Branch Workflow

      Use `skill-branch-management` to verify and manage feature branches.

      ## Quality Validation

      Use `skill-quality-gates` to run linting, unit tests, and architecture validation.
      ```

    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

### Phase 3: Implementar Modelo Practice en Init.ps1 (Setup Mínimo)

**Duración**: 1 día (simplificado)

✅ 17. Modificar `Init.ps1` función `Start-Wizard` - Setup Mínimo:
📅 Completado: 2026-02-23
✏️ Detalles: Implementado Step 0 con Practice selection (Apps & Infra, Data & AI, CRM, Custom). Practice pre-selects scopes with confirmation. Practice stored in scopes.yaml. - **Nuevo Step 0** (antes de Article I): Pregunta "Select your Practice" - Options: "Apps & Infra", "Data & AI", "CRM", "Custom (manual selection)" - Mapeo Practice → Scopes:
`powershell
      $practiceMap = @{
          "Apps & Infra" = @("backend", "frontend", "cloud-platform")
          "Data & AI" = @("data", "ai", "integration")
          "CRM" = @("crm")
      }
      ` - Si "Custom" → flujo actual (selección manual de scopes) - Si Practice específica → pre-seleccionar scopes, mostrar confirmación - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 18. Generar constitution básico en Init.ps1:
📅 Completado: 2026-02-23
✏️ Detalles: Creada función New-BasicConstitution que genera template mínimo con metadata, Practice y scopes. Antigua Set-ConstitutionDecisions renombrada a \_DEPRECATED. Init.ps1 líneas: 837 → 964 (temporal, provisioning eliminará complejidad). - Crear `memory/constitution.md` con estructura mínima:

      ```markdown
      # Project Constitution

      ## Metadata

      - Practice: {practice_selected}
      - Active Scopes: {scopes_list}
      - Initialized: {date}

      # Article I: Active Scopes

      {scopes_list}

      # Notes

      Run `@Bolt Constitution` or invoke `skill-bolt-setup-constitution` skill to provision files and complete constitution.
      ```

    - **NO provisionar archivos en Init.ps1** (se delega al skill)
    - Mantener Init.ps1 < 500 líneas (actualmente 837)
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 19. Generar `memory/scopes.yaml` en Init.ps1:
📅 Completado: 2026-02-23
✏️ Detalles: Añadido campo project.practice a scopes.yaml. Formato estándar mantenido con metadata adicional. - Formato estándar (sin cambios respecto a versión actual) - Include scope metadata: name, enabled, practice_origin - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 20. Mostrar mensaje final en Init.ps1:
📅 Completado: 2026-02-23
✏️ Detalles: Actualizada función Show-Summary con mensaje de dos pasos, Practice display, instrucciones @Bolt Constitution y documentación links. - "✓ Project initialized with Practice: {practice}" - "✓ Basic constitution created in memory/constitution.md" - "✓ Scopes configured: {scopes_list}" - "⚠ Next step: Run '@Bolt Constitution' to provision files and complete constitution" - " Or manually: Invoke 'bolt-setup-constitution' skill" - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 21. Actualizar `.aurora/scopes/README.md`:
📅 Completado: 2026-02-23
✏️ Detalles: Añadida sección "Practice-Based Initialization (Two-Step Workflow)" con tabla de Practice → Scopes mapping, explicación de dos pasos, quick start examples. - Documentar Practice → Scopes mapping - Explicar two-step initialization: Init (config) + Skill (provision) - Añadir sección "## Practice-Based Initialization" - Documentar nuevo workflow:
`       1. Run Init.ps1 → Select Practice → Generate basic constitution + scopes.yaml
      2. Run @Bolt Constitution → Invoke bolt-setup-constitution skill → Provision files
      3. Start development
      ` - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

✅ 22. Implementar `source_type` y `auto_provision` en `scope.yaml`:
📅 Completado: 2026-02-23
✏️ Detalles: Añadido campo auto_provision: true a constitution items en 8 scope.yaml files (backend, frontend, cloud-platform, data, integration, ai, crm, work-management). Ready for bolt-setup-constitution skill implementation. - Actualizar cada `.aurora/scopes/*/scope.yaml` para permitir:

      ```yaml
      items:
        - kind: skill
          name: skill-quality-gates
          source_type: local_file # local_file | context7 | awesome_copilot | web | git_repo
          source_path: .aurora/available-skills/skill-quality-gates
          auto_provision: true # copiar automáticamente cuando scope activo
          destination: .github/skills/skill-quality-gates

        - kind: agent
          name: bolt-testing
          source_type: local_file
          source_path: .aurora/available-agents/bolt-testing.agent.md
          auto_provision: true
          destination: .github/agents/bolt-testing.agent.md
      ```

    - El skill `skill-bolt-setup-constitution` leerá esta configuración
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

### Phase 4: Implementar Skill bolt-setup-constitution (Provisión Inteligente)

**Duración**: 1.5 días

21. Crear implementación completa de `skill-bolt-setup-constitution` skill:

    **21.1. Crear SKILL.md** (ya parcialmente definido en step 14.5):
    - Expandir con ejemplos de invocación
    - Documentar formato de reporte
    - Incluir troubleshooting common issues
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan (sub-tarea 21.1)

    **21.2. Crear helper script** `.aurora/scripts/Invoke-BoltSetupConstitution.ps1`:
    - PowerShell script que implementa la lógica descrita en el skill
    - Parámetros:
      ```powershell
      param(
          [string]$ConstitutionPath = "memory/constitution.md",
          [string]$ScopesConfigPath = "memory/scopes.yaml",
          [switch]$DryRun,
          [switch]$Verbose
      )
      ```
    - Funciones principales:
      - `Read-ConstitutionMetadata`: Extrae Practice y scopes de constitution básico
      - `Read-ScopeConfiguration`: Lee scope.yaml de cada scope activo
      - `Copy-ScopeItems`: Copia items (agents, prompts, skills) según auto_provision
      - `Merge-ScopeConstitutions`: Merge articles de scopes activos
      - `Generate-ProvisionReport`: Genera reporte markdown con cambios
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan (sub-tarea 21.2)

    **21.3. Implementar lógica de merge de constitution**:
    - Leer `memory/constitution.md` (básico generado por Init.ps1)
    - Para cada scope activo (leer de `memory/scopes.yaml`):
      - Leer `.aurora/scopes/{scope}/memory/constitution.md`
      - Extraer articles específicos (según tabla en `.aurora/scopes/README.md`)
      - Validar: no duplicar articles, preservar estructura
    - Generar constitution completo
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan (sub-tarea 21.3)

    **Ejemplo de constitution completo**:

    ```markdown
    # Project Constitution

    ## Metadata

    - Practice: Apps & Infra
    - Active Scopes: backend, frontend, cloud-platform
    - Initialized: 2026-02-23
    - Last Provision: 2026-02-23 14:30:00

    # Article I: Active Scopes

    - backend
    - frontend
    - cloud-platform

    # Article III: Tech Stack

    ## Backend

    - APIs: REST with FastAPI/Express/ASP.NET Core
      ...

    ## Frontend

    - Framework: React/Vue/Angular
      ...

    # Article XV: Testing Strategy

    ## Backend Testing

    - API integration tests
      ...

    ## Frontend Testing

    - Component tests with Testing Library
      ...
    ```

    **21.4. Implementar lógica de provisión de archivos** (DOS PASOS):

    **Paso 1 - Provisión según scopes activos**:
    - Para cada scope activo:
      - Leer `.aurora/scopes/{scope}/scope.yaml`
      - Filtrar items con `auto_provision: true`
      - Para cada item:
        - Verificar `source_type` (local_file, context7, web, etc.)
        - Si `source_type: local_file`:
          - Copiar desde `source_path` a `destination`
          - Crear directorios si no existen
          - Preservar permisos y metadata
        - Si `source_type: context7` o `web`:
          - Descargar contenido (para fase posterior)
      - Log: archivos copiados, skipped (ya existen), errores

    **Paso 2 - Provisión de skills core (SIEMPRE - AUTO-DISCOVERY)**:
    - **IMPORTANTE**: El script auto-descubre y copia **TODOS los directorios** en `.aurora/available-skills/bolt-framework/`
    - **Auto-Discovery**: Usa `Get-ChildItem -Directory` para encontrar todos los skills sin hardcodear nombres
    - **Skills descubiertos automáticamente** (7 en total):
      - `bolt-framework/` - Skill metodológico core (6 fases)
      - `skill-bolt-adr/` - Architecture Decision Records (MADR)
      - `skill-bolt-branch-management/` - Git branch workflows
      - `skill-bolt-constitution-driven-development/` - Constitution compliance
      - `skill-bolt-quality-gates/` - Quality validation
      - `skill-bolt-setup-constitution/` - Provisioning engine (self-reference)
      - `skill-bolt-testing-discipline/` - TDD/BDD workflows
    - **Extensibilidad**: Agregar nuevos skills en `bolt-framework/` → se copian automáticamente
    - Destino: `.github/skills/{nombre-skill}/` (preserva estructura completa)
    - Log: "Core skill 'bolt-framework' provisioned (always included)" + count de skills
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan (sub-tarea 21.4)

    **21.5. Generar reporte de provisión**:
    - Formato markdown:

      ```markdown
      # Bolt Setup Constitution - Provision Report

      **Date**: 2026-02-23 14:30:00
      **Practice**: Apps & Infra
      **Scopes**: backend, frontend, cloud-platform

      ## Constitution Merge

      ✓ Merged 12 articles from 3 scopes

      - backend: Articles III, XV, XVI (Tech Stack, Testing, Security)
      - frontend: Articles III, XV, XVII (Tech Stack, Testing, UI/UX)
      - cloud-platform: Articles III, XI, XII (Tech Stack, CI/CD, Observability)

      ## Files Provisioned

      ✓ Copied 8 skills:

      - skill-branch-management (from .aurora/available-skills)
      - skill-quality-gates (from .aurora/available-skills)
        ...

      ✓ Copied 5 agents:

      - bolt-testing.agent.md (from backend scope)
        ...

      ## Warnings

      ⚠ Skipped 2 files (already exist):

      - .github/skills/bolt-framework (existing)
        ...

      ## Next Steps

      1. Review constitution: memory/constitution.md
      2. Verify skills: .github/skills/
      3. Start development: Invoke @Bolt Framework
      ```

    - Guardar reporte en `memory/provision-report.md`
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan (sub-tarea 21.5)

22. Crear agente `@Bolt Constitution` que invoca el skill:
    - Crear `.github/agents/bolt-constitution.agent.md`:

      ```yaml
      ---
      name: Bolt Constitution
      description: Setup and manage project constitution and file provisioning
      tools:
        - edit/editFiles
        - new
        - codebase
      model: claude-sonnet-4.5
      ---

      # Bolt Constitution Agent

      You help setup and manage Bolt Framework project constitution.

      ## Primary Workflow

      When user asks to provision or setup constitution:
      1. Verify `memory/constitution.md` exists (basic constitution from Init.ps1)
      2. Verify `memory/scopes.yaml` exists
      3. Invoke `skill-bolt-setup-constitution` skill (call helper script)
      4. Show provision report to user
      5. Ask if user wants to review constitution or start development

      ## Commands

      - "Setup constitution" → Run provision workflow
      - "Provision files" → Run provision workflow
      - "Show provision report" → Display memory/provision-report.md
      - "Dry run" → Run provision with DryRun flag (preview only)
      ```

    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

23. Actualizar scope constitutions en `.aurora/scopes/*/memory/constitution.md`:
    - Verificar que cada scope tiene articles correctos
    - Ejemplo `backend`:

      ```markdown
      # Backend Scope Constitution Articles

      # Article III: Tech Stack (Backend)

      - APIs: REST with FastAPI/Express/ASP.NET Core
      - Database: PostgreSQL/MongoDB
      - ORM: SQLAlchemy/Prisma/Entity Framework

      # Article XV: Testing Strategy (Backend)

      - API integration tests with Postman/REST Client
      - Database migrations tested
      - Unit tests for business logic (>80% coverage)

      # Article XVI: Security (Backend)

      - Authentication: JWT/OAuth2
      - Input validation on all endpoints
      - SQL injection prevention
      ```

    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan

### Phase 5: Validación y Testing

**Duración**: 6-8 horas (aumentado por testing del skill)

✅ **24. Crear test script `.aurora/scripts/Test-InitFlows.ps1`:** - Test 1: Init.ps1 con Practice "Apps & Infra": - Verificar `memory/constitution.md` creado (básico) - Verificar `memory/scopes.yaml` contiene: backend, frontend, cloud-platform - Verificar `.github/` NO tiene archivos (provisión aún no ejecutada)

    - Test 2: Invocar `skill-bolt-setup-constitution` skill:
      - Ejecutar: `& .aurora\scripts\Invoke-BoltSetupConstitution.ps1`
      - Verificar constitution completo con articles de 3 scopes
      - Verificar skills copiados: skill-branch-management, skill-quality-gates, etc.
      - Verificar reporte generado: `memory/provision-report.md`

    - Test 3: Practice "Data & AI":
      - Init + Provision
      - Verificar skills incluyen: bolt-framework, azure-devops-sync
      - Verificar constitution tiene articles de data, ai, integration scopes

    - Test 4: Custom mode:
      - Selección manual de scopes
      - Provisión solo de scopes seleccionados

    - Test 5: Dry Run mode:
      - Ejecutar: `& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -DryRun`
      - Verificar preview de cambios sin modificar archivos

    - Test 6: Re-provisión (idempotencia):
      - Ejecutar provisión 2 veces
      - Verificar: archivos no duplicados, warnings sobre archivos existentes
    - **📝 Completado**: 2026-02-23 - Commit b65a969

✅ **25. Ejecutar validación de scopes:** - `npm run validate:scopes:ps` (ya existe, verificar pasa después de cambios) - **📝 Completado**: 2026-02-23 - 8/8 scopes OK, 0 errors

✅ **26. (ADICIONAL) Sincronización con herramientas de gestión del trabajo:** - Actualizar @Bolt Feature: Sync al crear feature spec - Actualizar @Bolt Plan: Sync al crear implementation plan - Actualizar @Bolt Tasks: Sync al generar task list - Actualizar @Bolt Implement: Sync de progreso de tareas y Bolts - Actualizar @Bolt Micro Iterator: Sync de estado de iteraciones - Soporte: Azure DevOps, Jira, GitHub Projects - Detección automática desde constitution (work-management scope) - **📝 Completado**: 2026-02-23 - Commit c6b6f22

⏭️ **27. Crear PR con checklist:** _(OMITIDO - Se creará después del testing manual)_ - [ ] Renombrado completo (Aurora → Bolt Framework) - [ ] 5 skills extraídos y creados - [ ] Agentes actualizados (sin duplicación, referencian skills) - [ ] Init.ps1 con Practice selection - [ ] Auto-provisión de skills funciona - [ ] Constitution merge automatizado - [ ] Tests pasan - [ ] README y docs actualizados - **Razón para omitir**: El usuario prefiere completar el testing manual primero

⬜ **28. Testing manual (two-step workflow):** _(PENDIENTE)_ - **Step 1: Initialization** - Ejecutar `Init.ps1` con Practice "Apps & Infra" - Verificar constitution básico en `memory/constitution.md` - Verificar mensaje: "Run '@Bolt Constitution' to provision files"

    - **Step 2: Provisión**
      - Invocar `@Bolt Constitution` en Copilot Chat
      - Verificar ejecución de `skill-bolt-setup-constitution` skill
      - Verificar provision report mostrado
      - Verificar constitution completo con articles de backend, frontend, cloud-platform
      - Verificar skills copiados a `.github/skills/`

    - **Step 3: Desarrollo**
      - Invocar `@Bolt Framework` agent
      - Verificar skills cargados automáticamente
      - Invocar `@Bolt Implement`
      - Verificar usa `skill-branch-management` sin ejecutar bash inline
    - **📝 Actualizar progreso**: Marcar esta tarea como ✅ en la sección de tracking del plan y actualizar el estado general del plan a "Completado"

---

### Phase 5.7: 2review Cleanup (Skills Migration)

**Duración**: 1-2 horas
**Status**: ✅ Completado (2026-02-26)

**Objetivo**: Limpiar carpeta 2review/ organizando skills pendientes en carpetas apropiadas.

#### Resultados

✅ **35. Análisis de 2review/** (COMPLETADO):

- Analizados 18 skills en carpeta 2review/
- Identificados 8 duplicados para borrar
- Identificados 9 skills para mover a carpetas organizadas
- Creado CLEANUP-DECISIONS.md con análisis completo
- Identificada necesidad de refactoring de templates Aspire (cohesión)

✅ **36. Ejecución de Cleanup** (COMPLETADO):

- **Borrados (8 duplicados)**:
  - architec-diagramer (typo, existe architect-diagramer en azure/)
  - skill-creator (existe en .github/skills/)
  - azure-identity-dotnet, azure-role-selector, azure-usage (existen en azure/)
  - tdd-workflow, test-driven-development (duplicados de tdd-comprehensive)
  - playwright-e2e (vacío, sin SKILL.md)

- **Movidos (9 skills)**:
  - A github/: git-branch-manager, issue-formatter
  - A document/: mermaid-creator, planning-with-files
  - A ui-common/: frontend-design, tailwind-design-system, web-design-reviewer
  - A functional-tests/: integration-e2e-testing
  - A cloud-platform/: senior-devops
  - A frontend/ (NUEVA carpeta): senior-frontend

✅ **37. Actualización de Scope.yaml** (COMPLETADO):

- **common/scope.yaml**: +4 skills (git-branch-manager, issue-formatter, mermaid-creator, planning-with-files)
- **frontend/scope.yaml**: +4 skills (frontend-design, tailwind-design-system, web-design-reviewer, senior-frontend)
- **backend/scope.yaml**: +1 skill (integration-e2e-testing - Testcontainers + Respawn)
- **cloud-platform/scope.yaml**: +1 skill (senior-devops - DevOps completo)

✅ **38. Validación** (COMPLETADO):

- `npm run validate:scopes:ps`: 9/9 scopes OK, 0 errors
- Correcciones aplicadas: tags reducidos a max 3, añadido 'csharp' donde corresponde
- 2review/ verificado vacío (0 directorios)

#### Decisiones Clave

**1. TDD Consolidation (3 → 1)**:

- Mantener solo `common/tdd-comprehensive` (521 líneas)
- Borrar `tdd-workflow` (567 líneas) y `test-driven-development` (478 líneas)
- Razón: Contenido prácticamente idéntico ("Iron Law", Red-Green-Refactor)

**2. Frontend Folder Creation**:

- Creada `available-skills/frontend/` para skills frontend agnósticos
- Diferente de react/, vue/, angular/ (framework-specific)
- Para senior-frontend (arquitectura genérica frontend)

**3. Playwright-e2e Handling**:

- Ambas ubicaciones (2review y functional-tests) vacías (solo templates/ vacías)
- Borrar 2review copy
- TODO Phase 5.8: Crear skill playwright-e2e completo

**4. Aspire Templates Refactoring (Decisión 7.0)**:

- **Problema**: Templates en `.aurora/templates/aspire/` (baja cohesión con skill)
- **Decisión**: Mover dentro de skill: `skill-bolt-aspire-orchestration/templates/`
- **Beneficio**: Alta cohesión, pattern consistency, provisión unificada (1 Copy recursivo vs 2)

#### Archivos Afectados

**Movidos**: 9 carpetas (53 archivos totales)
**Borrados**: 8 carpetas (42 archivos totales)
**Modificados**: 5 archivos:

- common/scope.yaml (+4 items)
- frontend/scope.yaml (+4 items)
- backend/scope.yaml (+1 item)
- cloud-platform/scope.yaml (+1 item)
- 2review/README.md (actualizado con status final)
- 2review/CLEANUP-DECISIONS.md (añadida decisión Aspire)

**Creados**: 1 carpeta:

- available-skills/frontend/

#### Próximos Pasos

1. ⬜ **Phase 5.8**: Crear skill playwright-e2e completo (actualmente placeholder vacío)
2. ⬜ **Task 28**: Manual testing de two-step workflow completo
3. ⬜ **Aspire refactoring**: Mover templates dentro del skill (Decisión 7.0)

---

### Phase 5.5: Aspire Integration (Optional)

```powershell
# 1. Validar NO quedan referencias a "Aurora" en agentes
Get-ChildItem -Recurse -Include *.agent.md .github/agents/ | Select-String "aurora-" -CaseSensitive
# Debe devolver: 0 resultados

# 2. Validar archivos renombrados
ls .github/agents/bolt-*.agent.md | Measure-Object
# Debe devolver: 30 archivos (todos los agentes)

# 3. Validar handoffs actualizados
grep -r "handoff.*aurora-" .github/agents/ --include="*.agent.md"
# Debe devolver: 0 resultados

# 4. Validar scopes
npm run validate:scopes:ps

# 5. Verificar skills existen
ls .github/skills/skill-branch-management
ls .github/skills/skill-quality-gates
ls .github/skills/skill-testing-discipline
ls .github/skills/skill-constitution-driven-development
ls .github/skills/bolt-setup-constitution  # NUEVO

# 6. Test initialization flow (Phase 1 - Init.ps1)
.\Init.ps1
# Verificar: memory/constitution.md (básico), memory/scopes.yaml creados
# Verificar: .github/ vacío o sin provisión completa

# 7. Test provisioning flow (Phase 2 - Skill)
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose
# Verificar: constitution completo, archivos provisionados, provision-report.md

# 8. Test dry-run mode
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -DryRun
# Verificar: preview de cambios sin modificar archivos

# 9. Test re-provisioning (idempotencia)
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1
# Ejecutar 2 veces, verificar: archivos no duplicados

# 10. Test full integration
.\.aurora\scripts\Test-InitFlows.ps1
```

### Testing Manual

**Scenario 1: Two-Step Workflow Completo (Apps & Infra)**

```powershell
# STEP 1: Initialization
PS> .\Init.ps1

# User selections:
# - Practice: "Apps & Infra"
# - Confirm scopes: backend, frontend, cloud-platform

# Output verificado:
PS> cat memory/constitution.md
# Project Constitution
# Metadata:
#   Practice: Apps & Infra
#   Active Scopes: backend, frontend, cloud-platform
# Article I: Active Scopes
# ...
# Notes: Run @Bolt Constitution to provision files

PS> cat memory/scopes.yaml
# - name: backend
#   enabled: true
#   practice_origin: Apps & Infra
# - name: frontend
#   enabled: true
# ...

PS> ls .github/skills/
# (vacío o solo skills preexistentes, NO provisión completa aún)

# STEP 2: Provisioning via Agent
# Open Copilot Chat:
User: "@Bolt Constitution setup constitution"

# Agent response (esperado):
# "✓ Reading configuration...
#  ✓ Found Practice: Apps & Infra
#  ✓ Active scopes: backend, frontend, cloud-platform
#  ✓ Provisioning files...
#
#  Provision Report:
#  - Constitution: Merged 15 articles from 3 scopes
#  - Skills: Provisioned 8 skills
#  - Agents: Provisioned 12 agents
#  - Prompts: Provisioned 5 prompts
#
#  ✓ Complete! Review: memory/provision-report.md
#  Ready to start development?"

# Output verificado:
PS> cat memory/constitution.md
# (debe tener constitution COMPLETO con articles de 3 scopes)

PS> ls .github/skills/
# skill-branch-management/
# skill-quality-gates/
# skill-testing-discipline/
# bolt-framework/
# ...

PS> cat memory/provision-report.md
# (reporte detallado con todos los archivos provisionados)

# STEP 3: Development
User: "@Bolt Framework help me create a REST API feature"

# Verificar: skill bolt-framework cargado automáticamente
# Verificar: workflow INCEPTION → DISCOVERY → CONSTRUCTION ejecutado
```

**Scenario 2: Dry-Run Mode (Preview)**

```powershell
# Direct script invocation with DryRun
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -DryRun

# Output esperado:
# [DRY RUN MODE - No files will be modified]
#
# Constitution Merge (Preview):
# - Would merge 15 articles from 3 scopes
#
# Files to Provision (Preview):
# - Would copy: skill-branch-management → .github/skills/
# - Would copy: skill-quality-gates → .github/skills/
# ...
#
# Total: 25 files would be provisioned
#
# Run without -DryRun to execute

# Verificar: NO archivos modificados
PS> git status
# On branch main
# nothing to commit, working tree clean
```

**Scenario 3: Re-provisioning (Idempotencia)**

```powershell
# Primera provisión
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose

# Output: 25 files provisioned

# Segunda provisión (sin cambios en config)
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose

# Output esperado:
# Constitution Merge: ✓ Regenerated (25 articles)
# Files Provisioned: 0 (all files exist)
# Warnings:
#   ⚠ Skipped 25 files (already exist)
#
# Summary: No new files provisioned (idempotent)

# Verificar provision report refleja skip de archivos existentes
PS> cat memory/provision-report.md
# ...
# ## Warnings
# ⚠ Skipped 25 files (already exist)
```

**Scenario 4: Data & AI Practice**

```powershell
PS> .\Init.ps1
# Practice: "Data & AI"
# Scopes: data, ai, integration

PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1

# Verificar skills específicos de Data & AI:
PS> ls .github/skills/
# azure-devops-sync/  (from available-skills)
# data-pipeline-testing/  (from data scope)
# ml-model-validation/  (from ai scope)
# ...

# Verificar constitution tiene articles de data/ai/integration
PS> cat memory/constitution.md | Select-String "Article.*Data"
# Article VI: Data Modeling & Storage (from data scope)
```

**Scenario 5: Agent Development Workflow**

```powershell
# Después de provisión completa...
# Open Copilot Chat

User: "@Bolt Implement create login endpoint"

# Verificar skill-branch-management usado:
# Agent response:
# "Checking branch status...
#  [Executing bash script from skill-branch-management]
#  ✓ On feature/login-endpoint branch
#  Ready to implement."

# Verificar skill-quality-gates usado después de implementación:
# Agent response:
# "Running quality gates...
#  [Executing lint commands from skill-quality-gates]
#  ✓ ESLint: Passed
#  ✓ Unit Tests: 12/12 passed
#  ✓ Architecture: Compliant with constitution"
```

### Success Criteria

- ✅ 0 referencias a "Aurora" en archivos de código/docs (excepto en contexto histórico)
- ✅ 6 skills creados y documentados (incluido `skill-bolt-setup-constitution`)
- ✅ Init.ps1 simplificado (<500 líneas, solo configuración)
- ✅ Init.ps1 wizard inicia con Practice selection
- ✅ Scopes auto-seleccionados según Practice
- ✅ `skill-bolt-setup-constitution` skill funcional y testeado
- ✅ Constitution básico generado por Init.ps1
- ✅ Constitution completo generado por skill después de provisión
- ✅ Skills auto-provisionados según scopes activos
- ✅ Provision report generado con detalles de cambios
- ✅ Agentes slim (sin duplicación de workflows)
- ✅ `npm run validate:scopes:ps` pasa
- ✅ Tests automatizados pasan (Init + Skill + Integración)
- ✅ Two-step workflow documentado y funcional

## Detalle del Skill `skill-bolt-setup-constitution`

### Responsabilidad

El skill `skill-bolt-setup-constitution` es el **motor de provisión inteligente** del Bolt Framework. Su responsabilidad es transformar la configuración básica generada por Init.ps1 (Practice, scopes activos) en un proyecto completamente provisionado con constitution completo, skills, agents, y prompts listos para desarrollo.

### Arquitectura del Skill

```
bolt-setup-constitution/
├── SKILL.md                              # Documentación del skill (instrucciones para Copilot)
└── (Helper script referenciado)
    └── .aurora/scripts/Invoke-BoltSetupConstitution.ps1
```

### SKILL.md Structure (300-400 líneas)

```markdown
---
name: bolt-setup-constitution
description: Intelligent provisioning engine for Bolt Framework projects
tags:
  - bolt-framework
  - setup
  - constitution
  - provisioning
version: 1.0.0
---

# Bolt Setup Constitution Skill

## Mission

You are the provisioning engine for Bolt Framework projects. Your responsibility is to:

1. Read project configuration (constitution + scopes.yaml)
2. Provision files (agents, skills, prompts) based on active scopes
3. Merge scope-specific constitution articles into complete constitution
4. Generate detailed provision report

## Workflow

### Step 1: Validate Prerequisites

- Verify `memory/constitution.md` exists (basic constitution from Init.ps1)
- Verify `memory/scopes.yaml` exists
- If missing, inform user to run Init.ps1 first

### Step 2: Read Configuration

- Parse `memory/constitution.md` to extract:
  - Practice (Apps & Infra | Data & AI | CRM | Custom)
  - Active Scopes (list)
  - Initialization date
- Parse `memory/scopes.yaml` to get scope details

### Step 3: Process Each Active Scope

For each scope in active scopes:

1. Read `.aurora/scopes/{scope}/scope.yaml`
2. Filter items where `auto_provision: true`
3. For each item:
   - Check `source_type`:
     - `local_file`: Copy from `source_path` to `destination`
     - `context7`: Download from context7 (future)
     - `web`: Download from URL (future)
     - `git_repo`: Clone from git (future)
   - Create destination directories if needed
   - Log action: copied, skipped (exists), failed
4. Read `.aurora/scopes/{scope}/memory/constitution.md`
5. Extract scope-specific articles (refer to mapping table in .aurora/scopes/README.md)

### Step 3.5: Provision Core Skills (ALWAYS - AUTO-DISCOVERY)

**IMPORTANT**: After processing scope-specific items, always provision core skills using **auto-discovery**:

1. **Auto-discover ALL skills** in `.aurora/available-skills/bolt-framework/`:
   - PowerShell: `Get-ChildItem -Path $boltFrameworkPath -Directory`
   - Finds ALL subdirectories automatically (no hardcoded list)
   - Current skills (7 total): `bolt-framework`, `skill-bolt-adr`, `skill-bolt-branch-management`, `skill-bolt-constitution-driven-development`, `skill-bolt-quality-gates`, `skill-bolt-setup-constitution`, `skill-bolt-testing-discipline`

2. **Copy each discovered skill** recursively:
   - Source: `.aurora/available-skills/bolt-framework/{skill-name}/`
   - Destination: `.github/skills/{skill-name}/`
   - Preserves complete directory structure (SKILL.md, examples/, templates/, etc.)

3. **Extensibility**: Adding new skills
   - Create new directory in `.aurora/available-skills/bolt-framework/new-skill/`
   - Script automatically discovers and provisions it
   - No code changes needed

4. Log: "Core skill '{skill-name}' provisioned (always included)" for each

5. This happens REGARDLESS of Practice or scopes selected

### Step 4: Merge Constitution

- Start with basic constitution from memory/constitution.md
- Append scope-specific articles
- Group articles by scope (e.g., "Article III: Tech Stack" → sections per scope)
- Validate: no duplicate article numbers, preserve structure
- Update `memory/constitution.md` with complete constitution

### Step 5: Generate Provision Report

Create `memory/provision-report.md` with:

- Date/time of provisioning
- Practice and scopes processed
- Constitution merge summary (articles added per scope)
- Files provisioned (skills, agents, prompts)
- Warnings (files skipped, errors)
- Next steps for user

## Invocation

### By Agent (@Bolt Constitution)
```

User: "Setup constitution"
Agent: Invokes bolt-setup-constitution skill
Agent: Shows provision report to user

````

### By Manual Script
```powershell
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1
````

### With Options

```powershell
# Dry run (preview only)
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -DryRun

# Verbose output
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose

# Custom paths
& .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -ConstitutionPath "custom/constitution.md"
```

## Output

### Constitution (Complete)

`memory/constitution.md`:

```markdown
# Project Constitution

## Metadata

- Practice: Apps & Infra
- Active Scopes: backend, frontend, cloud-platform
- Initialized: 2026-02-23 10:00:00
- Last Provision: 2026-02-23 10:05:23

# Article I: Active Scopes

- backend
- frontend
- cloud-platform

# Article III: Tech Stack

## Backend (from backend scope)

- APIs: REST with FastAPI/Express/ASP.NET Core
- Database: PostgreSQL/MongoDB
- ORM: SQLAlchemy/Prisma/Entity Framework

## Frontend (from frontend scope)

- Framework: React 18+/Vue 3/Angular 17+
- State: Redux/Pinia/NgRx
- Styling: Tailwind CSS/Styled Components

## Cloud Platform (from cloud-platform scope)

- Provider: Azure/AWS/GCP
- IaC: Terraform/Bicep/Pulumi
  ...
```

### Provision Report

`memory/provision-report.md`:

```markdown
# Bolt Setup Constitution - Provision Report

**Date**: 2026-02-23 10:05:23
**Practice**: Apps & Infra
**Active Scopes**: backend, frontend, cloud-platform

## Constitution Merge

✓ Merged 15 articles from 3 scopes

- backend: Articles III, VI, XV, XVI (Tech Stack, Data, Testing, Security)
- frontend: Articles III, XV, XVII (Tech Stack, Testing, UI/UX)
- cloud-platform: Articles III, X, XI, XII (Tech Stack, Environments, CI/CD, Observability)

## Files Provisioned

### Skills (8 total)

#### Core Skills (always provisioned)

✓ bolt-framework (from .aurora/available-skills) **[CORE - always included]**

- SKILL.md, HANDOFF-MATRIX.md, examples/, templates/

#### Practice-Specific Skills

✓ skill-branch-management (from .aurora/available-skills)
✓ skill-quality-gates (from .aurora/available-skills)
✓ skill-testing-discipline (from .aurora/available-skills)
✓ skill-constitution-driven-development (from .aurora/available-skills)

#### Scope-Specific Skills

✓ backend-api-testing (from backend scope)
✓ frontend-component-testing (from frontend scope)
✓ cloud-infrastructure-validation (from cloud-platform scope)

### Agents (12 total)

✓ bolt-testing.agent.md (from backend scope)
✓ bolt-implement.agent.md (from backend scope)
✓ bolt-review.agent.md (from backend scope)
✓ bolt-frontend-implement.agent.md (from frontend scope)
✓ bolt-ui-review.agent.md (from frontend scope)
...

### Prompts (5 total)

✓ api-design-review.prompt.md (from backend scope)
✓ component-design.prompt.md (from frontend scope)
...

## Warnings

⚠ Skipped 3 files (already exist):

- .github/skills/bolt-framework (existing, not overwritten)
- .github/skills/markdown-formatting (existing, not overwritten)
- .github/skills/skill-bolt-adr (existing, not overwritten)

## Summary

- Total files processed: 25
- Successfully provisioned: 22
- Skipped (existing): 3
- Errors: 0

## Next Steps

1. ✓ Review complete constitution: memory/constitution.md
2. ✓ Verify provisioned skills: .github/skills/
3. ✓ Verify provisioned agents: .github/agents/
4. 🚀 Start development: Invoke @Bolt Framework
5. 📝 Create first feature: Invoke @Bolt Feature
```

## Error Handling

### Missing Prerequisites

```
Error: memory/constitution.md not found
→ Run Init.ps1 first to initialize project
```

### Invalid Scope Configuration

```
Error: .aurora/scopes/{scope}/scope.yaml not found or invalid
→ Check scope configuration in .aurora/scopes/
```

### File Copy Failures

```
Warning: Failed to copy skill-xyz
→ Check source path exists: .aurora/available-skills/skill-xyz
→ Check write permissions on destination: .github/skills/
```

## Re-provisioning

The skill is **idempotent** - it can be run multiple times safely:

- Existing files are skipped (not overwritten)
- Constitution is regenerated (safe to update)
- Provision report shows what changed vs previous run

To force re-provisioning:

1. Delete files in .github/ that need refresh
2. Re-run skill
3. Review provision report for changes

````

### Helper Script Structure (.aurora/scripts/Invoke-BoltSetupConstitution.ps1)

```powershell
<#
.SYNOPSIS
Bolt Setup Constitution - Intelligent Provisioning Engine

.DESCRIPTION
Provisions Bolt Framework project based on constitution and active scopes.
Copies skills, agents, prompts and merges scope constitutions.

.PARAMETER ConstitutionPath
Path to basic constitution (default: memory/constitution.md)

.PARAMETER ScopesConfigPath
Path to scopes configuration (default: memory/scopes.yaml)

.PARAMETER DryRun
Preview changes without modifying files

.PARAMETER Verbose
Enable detailed logging

.EXAMPLE
.\Invoke-BoltSetupConstitution.ps1
Standard provisioning

.EXAMPLE
.\Invoke-BoltSetupConstitution.ps1 -DryRun
Preview changes only

.EXAMPLE
.\Invoke-BoltSetupConstitution.ps1 -Verbose
Detailed logging
#>

param(
    [string]$ConstitutionPath = "memory/constitution.md",
    [string]$ScopesConfigPath = "memory/scopes.yaml",
    [switch]$DryRun,
    [switch]$Verbose
)

# Main Functions:
# - Read-ConstitutionMetadata
# - Read-ScopesConfiguration
# - Get-ScopeItems (parse scope.yaml)
# - Copy-ItemWithValidation (copy with logging)
# - Merge-ConstitutionArticles
# - Generate-ProvisionReport
# - Main orchestration logic

# Implementation details in Phase 4, Step 21.2
````

### Integration with @Bolt Constitution Agent

El agente `@Bolt Constitution` actúa como interfaz conversacional para el skill:

```yaml
---
name: Bolt Constitution
description: Setup and manage project constitution and file provisioning
tools:
  - edit/editFiles
  - new
  - codebase
  - run_in_terminal
model: claude-sonnet-4.5
---

# Bolt Constitution Agent

## Primary Commands

- "setup constitution" | "provision files" → Run bolt-setup-constitution skill
- "dry run" → Run with -DryRun flag to preview
- "show report" → Display provision-report.md
- "verify constitution" → Show current constitution status

## Workflow

1. User asks to setup/provision
2. Validate prerequisites (memory/constitution.md, memory/scopes.yaml)
3. Execute: `& .aurora\scripts\Invoke-BoltSetupConstitution.ps1`
4. Parse provision report
5. Show summary to user
6. Ask: "Review constitution?" | "Start development?"
```

## Success Criteria

- ✅ 0 referencias a "Aurora" en archivos de código/docs (excepto en contexto histórico)
- ✅ 5+ skills creados y documentados
- ✅ Init.ps1 wizard inicia con Practice selection
- ✅ Scopes auto-seleccionados según Practice
- ✅ Skills auto-provisionados según Practice
- ✅ Constitution merge automático funciona
- ✅ Agentes slim (sin duplicación de workflows)
- ✅ `npm run validate:scopes:ps` pasa
- ✅ Tests automatizados pasan

## Decisiones Técnicas Detalladas

### Practice vs Scope

- **Decidido**: Practice = Scope Alias (no crear nueva abstracción)
- **Alternativa rechazada**: Crear `.aurora/practices/` paralelo a `scopes/` (duplicaría gobernanza)
- **Razón**: Microsoft Docs usa "Collections" que agrupan items; nuestros scopes ya hacen esto. Awesome Copilot confirma pattern: Collection → Items (agents, skills, prompts).

### Skills Location

- **Decidido**: `.github/skills/` para skills activos (copiados en init), `.aurora/available-skills/` para pool de skills provisionables
- **Core skills**: `bolt-framework` SIEMPRE se copia a `.github/skills/`, independiente del Practice
- **Razón**: `.github/` es estándar GitHub Copilot, `.aurora/` es meta-framework (no se copia a proyecto final)
- **Provisión en dos pasos**:
  1. Skills específicos según scopes activos
  2. Skills core (bolt-framework) SIEMPRE

### Skill Naming

- **Decidido**: `skill-{capability}` pattern (e.g., `skill-branch-management`)
- **Razón**: Alineado con ejemplos Microsoft (`skill-creator`, `skill-bolt-adr`) y evita conflictos con agent names

### Auto-Provision Strategy

- **Decidido**: Two-step initialization (Init.ps1 → Skill Provisión)
- **Alternativa rechazada**: Copiar skills directamente en Init.ps1 (acoplamiento alto, Init.ps1 complejo)
- **Razón**:
  - Separación de responsabilidades: Init = configurar, Skill = aprovisionar
  - Skill puede ser re-ejecutado sin re-inicializar proyecto
  - Permite dry-run y preview de cambios
  - Skill invocable por agentes para reconfiguración dinámica
  - Init.ps1 se mantiene simple (<500 líneas vs 837 líneas actual)

### Constitution Merge Timing

- **Decidido**: Post-init via `skill-bolt-setup-constitution` skill (no durante Init.ps1)
- **Alternativa rechazada**: Durante Init.ps1 (acopla lógica compleja en script de inicialización)
- **Razón**:
  - Constitution básico creado en init es suficiente para arrancar
  - Merge completo puede tardar (scopes con muchos articles, descarga de recursos externos)
  - Permite re-ejecutar merge si se añaden/eliminan scopes
  - Skill puede ser mejorado/extendido sin tocar Init.ps1
  - Usuario puede revisar constitution básico antes de provisionar

## Cronograma y Estimaciones

**Total estimado**: 5 días desarrollo (aumentado de 4-5 días por complejidad de bolt-setup-constitution skill)

- **Phase 1** (Renombrado): 6-8 horas
- **Phase 2** (Extracción Skills): 2 días (incluye bolt-setup-constitution)
- **Phase 3** (Init.ps1 Simplificado): 1 día (reducido de 1.5 días)
- **Phase 4** (Skill Provisión): 1.5 días (aumentado de 1 día por complejidad del skill)
- **Phase 5** (Validación): 6-8 horas (aumentado por testing del skill)

**Desglose detallado**:

| Fase        | Tarea                                              | Horas | Subtotal             |
| ----------- | -------------------------------------------------- | ----- | -------------------- |
| **Phase 1** | Renombrado archivos agents                         | 2h    |                      |
|             | Actualizar Init.ps1/init.sh                        | 1h    |                      |
|             | Actualizar docs (README, copilot-instructions)     | 2h    |                      |
|             | Actualizar handoffs entre agentes                  | 1h    |                      |
|             | Búsqueda y reemplazo global                        | 1h    | **7h**               |
| **Phase 2** | Revisar new-skill guidelines                       | 0.5h  |                      |
|             | skill-branch-management                            | 3h    |                      |
|             | skill-quality-gates                                | 4h    |                      |
|             | skill-testing-discipline                           | 3h    |                      |
|             | skill-constitution-driven-development              | 3h    |                      |
|             | bolt-setup-constitution (SKILL.md)                 | 4h    |                      |
|             | Expandir bolt-framework skill                      | 5h    | **22.5h (2.8 días)** |
| **Phase 3** | Modificar Start-Wizard (Practice selection)        | 2h    |                      |
|             | Generar constitution básico                        | 2h    |                      |
|             | Actualizar scopes README                           | 1h    |                      |
|             | Implementar source_type en scope.yaml              | 2h    | **7h**               |
| **Phase 4** | Invoke-BoltSetupConstitution.ps1 (script completo) | 6h    |                      |
|             | Lógica merge constitution                          | 3h    |                      |
|             | Lógica provisión archivos                          | 4h    |                      |
|             | Generar provision report                           | 2h    |                      |
|             | Crear @Bolt Constitution agent                     | 1h    |                      |
|             | Actualizar scope constitutions                     | 2h    | **18h (2.25 días)**  |
| **Phase 5** | Test-InitFlows.ps1 (6 tests)                       | 3h    |                      |
|             | Testing manual (two-step workflow)                 | 2h    |                      |
|             | Corrección de bugs encontrados                     | 2h    | **7h**               |
|             | **TOTAL**                                          |       | **61h (≈5 días)**    |

**Supuestos**:

- Desarrollador familiarizado con el codebase
- No interrupciones significativas
- Testing exitoso en primer intento

## Riesgos y Mitigaciones

### Riesgo 1: Breaking Changes en Agentes

**Estado**: ✅ ELIMINADO
**Razón**: Confirmado por usuario - no hay workflows dependientes

### Riesgo 2: Constitution Merge Genera Conflicts

**Probabilidad**: Media
**Impacto**: Alto
**Mitigation**:

- Test exhaustivo en Phase 5
- Validación de duplicados en script Merge-ScopeConstitutions.ps1
- Dry-run mode para preview antes de merge real

### Riesgo 3: Skills No Se Auto-Descubren

**Probabilidad**: Baja
**Impacto**: Medio
**Mitigation**:

- Seguir convención estricta de nombres (`skill-*`)
- Validar con testing manual en Phase 5
- Documentar en copilot-instructions.md la convención

---

### Phase 5.5: Aspire Integration (Optional)

**Duración**: 2-3 horas
**Status**: 🟡 En Progreso (5/6 tareas completadas)

**Objetivo**: Integrar .NET Aspire como opción de orquestación opcional para proyectos multi-servicio en "Apps & Infra" Practice.

**Diseño Implementado**:

#### 1. Detección Inteligente en Init.ps1 (Step 1.5)

**Ubicación**: Después de Practice Selection, antes de Article X

**Lógica de Detección**:

```powershell
# Activación condicional: SOLO "Apps & Infra" + 2+ servicios
if ($d.Practice -eq "Apps & Infra") {
    $serviceCount = 0
    if ($d.SelectedScopes -contains "backend") { $serviceCount++ }
    if ($d.SelectedScopes -contains "frontend") { $serviceCount++ }
    if ($d.SelectedScopes -match "cloud-platform|data|integration") { $serviceCount++ }

    if ($serviceCount -ge 2) {
        # Prompt con educación de usuario
        Write-Host "🎯 Detected multi-service architecture (" -NoNewline
        Write-Host "$serviceCount services" -ForegroundColor Cyan -NoNewline
        Write-Host ")"
        Write-Host "   Consider .NET Aspire for:"
        Write-Host "   • Automatic service discovery"
        Write-Host "   • Built-in dashboard (http://localhost:15888)"
        Write-Host "   • Simplified deployment orchestration"
        Write-Host "   Requirements: Docker + .NET 8+"

        $aspireChoice = Read-Choice "Use .NET Aspire?" @("Yes", "No") "No"
        $d.UseAspire = ($aspireChoice -eq "Yes")
    }
}
```

**Criterios de Activación**:

- Practice = "Apps & Infra"
- Servicios detectados ≥ 2 (backend/frontend + cloud/data/integration)
- Usuario confirma manualmente

**Educación de Usuario**:

- Beneficios: Service discovery, dashboard, orquestación simplificada
- Requisitos: Docker, .NET 8+, AppHost project
- Default: "No" (opt-in)

#### 2. Almacenamiento de Decisión

**A. scopes.yaml** (metadata machine-readable):

```yaml
project:
  practice: Apps & Infra
  use-aspire: true # ← NUEVA PROPIEDAD
scopes:
  - name: backend
    enabled: true
```

**B. Constitution Article XX** (documentación human-readable):

```markdown
## Article XX: Orchestration with .NET Aspire

### Rationale

This project uses .NET Aspire for service orchestration due to:

- Multi-service architecture (X services detected)
- Need for orchestrated local development experience
- Simplified Azure deployment with azd

### Implementation

- AppHost project: Centralized orchestration
- Service discovery: Automatic inter-service communication
- Dashboard: http://localhost:15888 for monitoring
- ServiceDefaults: Shared telemetry, health checks, resilience policies

### Trade-offs

**Benefits**:

- Reduced boilerplate (service discovery, telemetry)
- Consistent development/production parity
- Built-in observability dashboard

**Costs**:

- Additional dependency (.NET Aspire NuGet packages)
- Learning curve for team (AppHost patterns)
- Docker required for local development

### References

- .NET Aspire Docs: https://learn.microsoft.com/dotnet/aspire
- Skill: skill-bolt-aspire-orchestration
- Templates: .aurora/templates/aspire/
```

#### 3. Provisión Condicional (Invoke-BoltSetupConstitution.ps1)

**Modificaciones Implementadas**:

**A. Read-Yaml Function** (Parse use-aspire flag):

```powershell
function Read-Yaml {
    param([string]$Path)

    # ... existing parsing ...

    # Parse use-aspire (NEW)
    if ($content -match "use-aspire:\s*(true|false)") {
        $yaml.UseAspire = ($matches[1] -eq "true")
    } else {
        $yaml.UseAspire = $false  # Fallback for old files
    }

    return $yaml
}
```

**B. Copy-AspireResources Function** (NEW, lines 612-700):

```powershell
function Copy-AspireResources {
    param(
        [string]$ProjectPath,
        [bool]$UseAspire
    )

    if (-not $UseAspire) {
        Write-Verbose "Aspire not enabled, skipping"
        return @()
    }

    $items = @()

    # 1. Provision skill-bolt-aspire-orchestration
    $skillSrc = ".aurora/available-skills/aspire/skill-bolt-aspire-orchestration"
    $skillDst = ".github/skills/skill-bolt-aspire-orchestration"
    if (Test-Path $skillSrc) {
        Copy-Item $skillSrc $skillDst -Recurse -Force
        $items += [PSCustomObject]@{
            Type = "Skill"
            Name = "skill-bolt-aspire-orchestration"
            Source = $skillSrc
            Destination = $skillDst
        }
    }

    # 2. Provision templates
    $templateSrc = ".aurora/templates/aspire"
    $templateDst = ".github/templates/aspire"
    if (Test-Path $templateSrc) {
        Copy-Item $templateSrc $templateDst -Recurse -Force
        foreach ($file in Get-ChildItem $templateSrc -File) {
            $items += [PSCustomObject]@{
                Type = "Template"
                Name = $file.Name
                Source = "$templateSrc/$($file.Name)"
                Destination = "$templateDst/$($file.Name)"
            }
        }
    }

    return $items
}
```

**C. Phase 4 Integration** (Main workflow):

```powershell
# Phase 4: Provision files based on scopes.yaml
$scopes = Read-Yaml -Path "memory/scopes.yaml"
$useAspire = $scopes.UseAspire

# ... existing provisioning ...

# Provision Aspire resources (conditional)
$aspireResources = Copy-AspireResources -ProjectPath $ProjectPath -UseAspire $useAspire

if ($aspireResources.Count -gt 0) {
    Write-Host "   (Aspire: $($aspireResources.Count) files)" -ForegroundColor Cyan
}

# Generate report (includes Aspire section)
$report = New-ProvisionReport -AspireResources $aspireResources
```

**D. Report Generation** (Enhanced):

```powershell
function New-ProvisionReport {
    param(
        [array]$AspireResources = @()
    )

    $report = @"
# Provision Report
...

## Aspire Resources
$aspireSection

## Statistics
| Category         | Count |
|------------------|-------|
| Constitution Articles | $articleCount |
| Skills               | $skillCount |
| Aspire Resources     | $($AspireResources.Count) |
...
"@

    if ($AspireResources.Count -gt 0) {
        $aspireSection = @"
✅ Aspire orchestration enabled

**Skill**:
- skill-bolt-aspire-orchestration → .github/skills/

**Templates**:
- AppHost.csproj → .github/templates/aspire/
- ServiceDefaults.csproj → .github/templates/aspire/
- Extensions.cs → .github/templates/aspire/
- Program.cs.template → .github/templates/aspire/

**Documentation**:
- See Constitution Article XX for rationale and patterns
"@
    } else {
        $aspireSection = "⏭️ Aspire not enabled (use-aspire: false in scopes.yaml)"
    }

    return $report
}
```

#### 4. Skill: skill-bolt-aspire-orchestration

**Ubicación**: `.aurora/available-skills/aspire/skill-bolt-aspire-orchestration/SKILL.md`
**Líneas**: 200+

**Estructura**:

```yaml
---
name: Skill Bolt Aspire Orchestration
description: Guide development of distributed .NET applications with .NET Aspire
scopes:
  - cloud-platform
  - backend
  - frontend
version: 1.0.0
---
```

**Secciones**:

1. **Purpose**: When/why to use Aspire orchestration
2. **When to Use This Skill**:
   - Multi-service .NET apps (2+ services)
   - Local development orchestration
   - Azure deployment with azd
3. **When NOT to Use**:
   - Single-service apps
   - Non-.NET projects
   - Simple console apps
4. **Key Concepts**:
   - AppHost: Orchestration project (DistributedApplication)
   - Service Discovery: WithReference() pattern
   - ServiceDefaults: Shared telemetry, health checks, resilience
   - Dashboard: http://localhost:15888
5. **Workflows**:
   - Creating AppHost project
   - Adding services with WithReference()
   - Setting up service discovery
   - Deploying to Azure (azd init → azd up)
6. **Common Patterns**:
   - Azure resources (Redis, PostgreSQL, SQL Server)
   - Environment configuration
   - Waiting for dependencies (WaitFor())
7. **Constitution Integration**: References Article XX
8. **External References**: Microsoft Learn docs

**Código de Ejemplo**:

```csharp
// AppHost/Program.cs
var builder = DistributedApplication.CreateBuilder(args);

// External resources
var redis = builder.AddRedis("redis");
var postgres = builder.AddPostgres("postgres")
                      .AddDatabase("catalogdb");

// Backend API with dependencies
var catalogApi = builder.AddProject<Projects.CatalogApi>("catalogapi")
                        .WithReference(redis)
                        .WithReference(postgres);

// Frontend with backend reference
builder.AddProject<Projects.WebFrontend>("webfrontend")
       .WithReference(catalogApi);  // Service discovery

builder.Build().Run();
```

#### 5. Templates Aspire (4 archivos)

**Ubicación**: `.aurora/templates/aspire/`

**A. AppHost.csproj**:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net10.0</TargetFramework>
    <UserSecretsId><!-- GUID placeholder --></UserSecretsId>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Aspire.Hosting.AppHost" Version="13.0.*" />
    <!-- Add project references here:
    <ProjectReference Include="..\Backend.Api\Backend.Api.csproj" />
    <ProjectReference Include="..\Frontend.Web\Frontend.Web.csproj" />
    -->
  </ItemGroup>
</Project>
```

**B. ServiceDefaults.csproj**:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <IsAspireSharedProject>true</IsAspireSharedProject>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Extensions.Http.Resilience" Version="10.0.*" />
    <PackageReference Include="Microsoft.Extensions.ServiceDiscovery" Version="10.0.*" />
    <PackageReference Include="OpenTelemetry.Exporter.OpenTelemetryProtocol" Version="1.10.*" />
    <PackageReference Include="OpenTelemetry.Extensions.Hosting" Version="1.10.*" />
    <PackageReference Include="OpenTelemetry.Instrumentation.AspNetCore" Version="1.10.*" />
    <PackageReference Include="OpenTelemetry.Instrumentation.Http" Version="1.10.*" />
    <PackageReference Include="OpenTelemetry.Instrumentation.Runtime" Version="1.10.*" />
  </ItemGroup>
</Project>
```

**C. Extensions.cs** (100+ líneas):

```csharp
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using OpenTelemetry;
using OpenTelemetry.Metrics;
using OpenTelemetry.Trace;

namespace Microsoft.Extensions.Hosting;

public static class Extensions
{
    public static IHostApplicationBuilder AddServiceDefaults(this IHostApplicationBuilder builder)
    {
        builder.ConfigureOpenTelemetry();
        builder.AddDefaultHealthChecks();
        builder.Services.AddServiceDiscovery();

        builder.Services.ConfigureHttpClientDefaults(http =>
        {
            http.AddStandardResilienceHandler();
            http.AddServiceDiscovery();
        });

        return builder;
    }

    public static IHostApplicationBuilder ConfigureOpenTelemetry(this IHostApplicationBuilder builder)
    {
        builder.Logging.AddOpenTelemetry(logging =>
        {
            logging.IncludeFormattedMessage = true;
            logging.IncludeScopes = true;
        });

        builder.Services.AddOpenTelemetry()
            .WithMetrics(metrics =>
            {
                metrics.AddAspNetCoreInstrumentation()
                       .AddHttpClientInstrumentation()
                       .AddRuntimeInstrumentation();
            })
            .WithTracing(tracing =>
            {
                tracing.AddAspNetCoreInstrumentation()
                       .AddHttpClientInstrumentation();
            });

        builder.AddOpenTelemetryExporters();
        return builder;
    }

    private static IHostApplicationBuilder AddOpenTelemetryExporters(this IHostApplicationBuilder builder)
    {
        var useOtlpExporter = !string.IsNullOrWhiteSpace(
            builder.Configuration["OTEL_EXPORTER_OTLP_ENDPOINT"]);

        if (useOtlpExporter)
        {
            builder.Services.AddOpenTelemetry().UseOtlpExporter();
        }
        return builder;
    }

    public static IHostApplicationBuilder AddDefaultHealthChecks(this IHostApplicationBuilder builder)
    {
        builder.Services.AddHealthChecks()
               .AddCheck("self", () => HealthCheckResult.Healthy(), ["live"]);
        return builder;
    }

    public static WebApplication MapDefaultEndpoints(this WebApplication app)
    {
        app.MapHealthChecks("/health");
        app.MapHealthChecks("/alive", new HealthCheckOptions
        {
            Predicate = r => r.Tags.Contains("live")
        });
        return app;
    }
}
```

**D. Program.cs.template**:

```csharp
var builder = DistributedApplication.CreateBuilder(args);

// ==============================================
// EXTERNAL RESOURCES (e.g., Redis, PostgreSQL)
// ==============================================
// Example:
// var redis = builder.AddRedis("redis");
// var postgres = builder.AddPostgres("postgres")
//                       .AddDatabase("mydb");

// ==============================================
// SERVICE DEFINITIONS
// ==============================================
// Example:
// var backend = builder.AddProject<Projects.BackendApi>("backend-api")
//                      .WithReference(redis);
//
// builder.AddProject<Projects.Frontend>("frontend")
//        .WithReference(backend);

builder.Build().Run();
```

#### 6. Integración con Constitution

**Init.ps1** genera conditionally Article XX cuando `$d.UseAspire = $true`:

```powershell
function New-BasicConstitution {
    param($D)

    $articles = @()
    $articles += "## Article I: Active Scopes"
    # ... existing articles ...

    # Conditional Aspire article
    if ($D.UseAspire) {
        $aspireArticle = @"
## Article XX: Orchestration with .NET Aspire

### Rationale
This project uses .NET Aspire for service orchestration due to:
- Multi-service architecture detected
- Need for orchestrated local development experience
- Simplified Azure deployment with azd

### Implementation
...
"@
        $articles += $aspireArticle
    }

    return $articles -join "`n`n"
}
```

#### 7. Testing Checklist

✅ **29. Test Aspire Detection Logic (Init.ps1)**:

```powershell
# Test 1: "Apps & Infra" + 2 services → Should prompt
PS> .\Init.ps1
# Select: Apps & Infra
# Scopes: backend, frontend, cloud-platform
# Expected: "🎯 Detected multi-service architecture (3 services)"
# Expected: Prompt "Use .NET Aspire? [Yes/No]"

# Test 2: "Data & AI" → Should NOT prompt
PS> .\Init.ps1
# Select: Data & AI
# Expected: NO Aspire prompt (wrong practice)

# Test 3: "Apps & Infra" + 1 service → Should NOT prompt
PS> .\Init.ps1
# Select: Apps & Infra
# Scopes: backend only
# Expected: NO Aspire prompt (serviceCount = 1 < 2)

# Test 4: Verify scopes.yaml
cat memory/scopes.yaml
# Expected: "use-aspire: true" (if selected Yes)
```

✅ **30. Test Conditional Provisioning (Invoke-BoltSetupConstitution.ps1)**:

```powershell
# Test 1: Aspire enabled (use-aspire: true)
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose
# Expected: "Provisioning Aspire resources..."
# Expected: skill-bolt-aspire-orchestration copied to .github/skills/
# Expected: 4 templates copied to .github/templates/aspire/

# Verify files
ls .github/skills/skill-bolt-aspire-orchestration
ls .github/templates/aspire/
# Expected: AppHost.csproj, ServiceDefaults.csproj, Extensions.cs, Program.cs.template

# Test 2: Aspire disabled (use-aspire: false)
# Modify scopes.yaml: use-aspire: false
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1 -Verbose
# Expected: "Aspire not enabled, skipping"
# Expected: NO Aspire files copied
```

✅ **31. Test Provision Report**:

```powershell
cat memory/provision-report.md
# Expected sections:
# - ## Aspire Resources
# - "✅ Aspire orchestration enabled"
# - Skill: skill-bolt-aspire-orchestration
# - Templates: AppHost.csproj, ServiceDefaults.csproj, Extensions.cs, Program.cs.template
# - Documentation: Article XX reference
# - ## Statistics
# - "Aspire Resources | 5" (1 skill + 4 templates)
```

✅ **32. Test Skill Validation (skill-bolt-aspire-orchestration)**:

```powershell
# Verify YAML frontmatter
cat .github/skills/skill-bolt-aspire-orchestration/SKILL.md | Select-String -Pattern "^name:|^description:|^scopes:"
# Expected:
# name: Skill Bolt Aspire Orchestration
# description: Guide development of distributed .NET applications with .NET Aspire
# scopes:

# Verify skill content
cat .github/skills/skill-bolt-aspire-orchestration/SKILL.md | Select-String -Pattern "## Purpose|## Key Concepts|## Workflows"
# Expected: All 3 sections present
```

✅ **33. Test Constitution Article XX**:

```powershell
cat memory/constitution.md | Select-String -Pattern "Article XX"
# Expected: "## Article XX: Orchestration with .NET Aspire" (if use-aspire: true)
# Expected: No match (if use-aspire: false)

cat memory/constitution.md | Select-String -Pattern "Rationale|Implementation|Trade-offs" -Context 2
# Expected: Full Article XX with 3 subsections
```

⬜ **34. End-to-End Integration Test**:

```powershell
# Clean slate
rm -Recurse -Force memory/, .github/skills/, .github/templates/

# STEP 1: Init with Aspire
PS> .\Init.ps1
# Select: Apps & Infra
# Scopes: backend, frontend, cloud-platform
# Aspire prompt: Yes

# Verify: memory/scopes.yaml has "use-aspire: true"
# Verify: memory/constitution.md has Article XX

# STEP 2: Provision
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1

# Verify:
# - Aspire skill copied
# - Aspire templates copied (4 files)
# - Provision report includes Aspire section
# - Constitution still has Article XX (not overwritten)

# STEP 3: Use skill in development
# (Manual: Invoke @Bolt Framework, verify skill-bolt-aspire-orchestration loaded)
```

#### 8. Archivos Modificados/Creados

**Modificados** (2 archivos, 7 cambios):

1. **Init.ps1**:
   - Lines 251-300: Step 1.5 - Aspire detection logic (45 lines NEW)
   - Line 606: scopes.yaml template - Added `use-aspire` field (1 line)
   - Lines 740-780: New-BasicConstitution - Conditional Article XX (40 lines NEW)

2. **Invoke-BoltSetupConstitution.ps1**:
   - Lines 90-108: Read-Yaml - Parse `use-aspire` field (18 lines MODIFIED)
   - Lines 612-700: Copy-AspireResources function (90 lines NEW)
   - Line 711: New-ProvisionReport signature - Added `$AspireResources` parameter (1 line)
   - Lines 735-750: Report generation - Build `$aspireSection` (15 lines NEW)
   - Lines 935-950: Phase 4 - Call Copy-AspireResources, include in report (15 lines MODIFIED)

**Creados** (5 archivos, 400+ líneas):

3. **.aurora/available-skills/aspire/skill-bolt-aspire-orchestration/SKILL.md** (200+ lines)
4. **.aurora/templates/aspire/AppHost.csproj** (20 lines)
5. **.aurora/templates/aspire/ServiceDefaults.csproj** (15 lines)
6. **.aurora/templates/aspire/Extensions.cs** (100+ lines)
7. **.aurora/templates/aspire/Program.cs.template** (20 lines)

**Total**:

- **Modified**: 2 scripts, 195 lines changed/added
- **Created**: 1 skill + 4 templates, 355+ lines
- **Grand Total**: 7 files, 550+ lines

#### 9. Decisiones de Diseño

**A. ¿Por qué Step 1.5 (no Step 2)?**

- Aspire decision affects project structure (AppHost project)
- Must decide BEFORE Article X (project architecture)
- Placed after Practice selection (context available)

**B. ¿Por qué conditional vs universal?**

- Aspire adds complexity (Docker, AppHost, learning curve)
- Only valuable for multi-service architectures
- Single-service apps don't benefit from orchestration
- Opt-in approach reduces friction for simple projects

**C. ¿Por qué dual storage (scopes.yaml + Constitution)?**

- `scopes.yaml`: Machine-readable flag for provisioning script
- `Constitution Article XX`: Human-readable documentation with rationale
- Separation of concerns: metadata vs knowledge

**D. ¿Por qué separate skill (not in bolt-framework)?**

- Aspire is optional, bolt-framework is core
- Avoiding bloating core skill with optional content
- Easier to version/update independently
- Clear separation: methodology (bolt-framework) vs technology (aspire)

**E. ¿Por qué 4 template files (not 1 monolithic)?**

- AppHost.csproj: Reusable orchestration project
- ServiceDefaults.csproj: Reusable shared library
- Extensions.cs: Complete implementation (not stub)
- Program.cs.template: Starter with comments
- Flexibility: Users can copy individually

#### 10. Beneficios de la Integración

**Para Desarrolladores**:

- ✅ Automatic service discovery (no hardcoded URLs)
- ✅ Built-in dashboard (http://localhost:15888)
- ✅ Consistent observability (OpenTelemetry out-of-the-box)
- ✅ Simplified deployment (azd init → azd up)

**Para Bolt Framework**:

- ✅ Modern .NET best practice (Aspire is Microsoft's recommended approach)
- ✅ Reduces boilerplate in generated code
- ✅ Aligns with "Apps & Infra" Practice (distributed systems)
- ✅ Optional feature (doesn't increase complexity for simple projects)

**Para AI-DLC**:

- ✅ Skill provides clear patterns for AppHost orchestration
- ✅ Templates accelerate Bolt iterations (no researching Aspire from scratch)
- ✅ Constitution Article XX documents architectural decision

#### 11. Próximos Pasos (Post-Phase 5.5)

1. ⬜ **Task 34**: End-to-End Integration Test (clean slate → Init → Provision → Verify)
2. ⬜ **Task 28**: Manual testing of two-step workflow (from Phase 5)
3. ⬜ Extend skill with Azure Container Apps deployment (beyond azd)
4. ⬜ Add Aspire validation to `npm run validate:scopes:ps`
5. ⬜ Document Aspire integration in README.md
6. ⬜ Create example project with Aspire (demo/aspire-sample/)

#### 12. Referencias

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire)
- [Aspire AppHost Overview](https://learn.microsoft.com/dotnet/aspire/fundamentals/app-host-overview)
- [Service Discovery in .NET Aspire](https://learn.microsoft.com/dotnet/aspire/service-discovery/overview)
- [Deploy .NET Aspire apps to Azure](https://learn.microsoft.com/dotnet/aspire/deployment/azure/overview)
- Skill: `.aurora/available-skills/aspire/skill-bolt-aspire-orchestration/SKILL.md`
- Templates: `.aurora/templates/aspire/`

---

## Próximos Pasos Sugeridos (Post-Implementación)

1. **Iterar skills** basándose en feedback de uso real
2. **Crear más Practices** (e.g., "DevSecOps", "ML Ops", "IoT", "Gaming")
3. **Migrar available-skills a MCP server** para descubrimiento dinámico
4. **Publicar Bolt Framework como template** en GitHub Marketplace
5. **Crear documentación de usuario** (Getting Started, Tutorials, Reference)
6. **Establecer governance** para contribuciones de nuevos skills/agents
7. **Analytics de uso** para priorizar mejoras en skills más utilizados

## Referencias

### Documentación Microsoft Consultada

- [Use prompt modification to provide custom instructions](https://learn.microsoft.com/microsoft-copilot-studio/nlu-generative-answers-prompt-modification)
- [Write effective instructions for declarative agents](https://learn.microsoft.com/microsoft-365-copilot/extensibility/declarative-agent-instructions)
- [Best practices for building declarative agents](https://learn.microsoft.com/microsoft-365-copilot/extensibility/declarative-agent-best-practices)
- [Apply generative orchestration capabilities](https://learn.microsoft.com/microsoft-copilot-studio/guidance/generative-orchestration)
- [GitHub Copilot for Azure best practices](https://learn.microsoft.com/azure/developer/github-copilot-azure/introduction)

### Patrones Awesome Copilot

- Collections: azure-cloud-development, awesome-copilot
- Agent YAML: ChildSkills, RequiredSkillsets patterns
- Skill formats: GPT, AGENT, KQL, API, LogicApp

### Archivos Clave del Proyecto

- `.github/agents/bolt-framework.agent.md` - Orchestrator principal
- `.github/agents/bolt-constitution.agent.md` - **[NUEVO]** Agente de provisión
- `.github/skills/bolt-setup-constitution/SKILL.md` - **[NUEVO]** Motor de provisión
- `Init.ps1` - Wizard de inicialización simplificado (≈300-400 líneas, reducido de 837)
- `.aurora/scripts/Invoke-BoltSetupConstitution.ps1` - **[NUEVO]** Helper script de provisión
- `.aurora/scopes/README.md` - Documentación del sistema de scopes
- `.github/skills/bolt-framework/SKILL.md` - Skill metodológico principal (expandido a 300-400 líneas)
- `memory/constitution.md` - Constitution del proyecto (básico → completo)
- `memory/provision-report.md` - **[NUEVO]** Reporte de provisión

## Diagrama: Two-Step Workflow Completo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         STEP 1: INITIALIZATION                          │
│                              (Init.ps1)                                  │
└─────────────────────────────────────────────────────────────────────────┘

User runs: .\Init.ps1

    ┌──────────────────┐
    │  Select Practice │
    │  ────────────────│
    │  1. Apps & Infra │
    │  2. Data & AI    │
    │  3. CRM          │
    │  4. Custom       │
    └────────┬─────────┘
             │
             ↓
    ┌──────────────────┐
    │  Map Practice    │
    │  to Scopes       │
    └────────┬─────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Generate Configuration  │
    │  ────────────────────────│
    │  ✓ memory/scopes.yaml    │
    │  ✓ memory/constitution.md│
    │    (basic)               │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Show Next Steps         │
    │  ────────────────────────│
    │  "Run @Bolt Constitution │
    │   to provision files"    │
    └──────────────────────────┘

OUTPUT:
✓ memory/scopes.yaml (scopes configuration)
✓ memory/constitution.md (BASIC - metadata + Article I)
✗ .github/ (empty or minimal - NO full provisioning yet)

───────────────────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────────┐
│                         STEP 2: PROVISIONING                            │
│                  (@Bolt Constitution → bolt-setup-constitution skill)    │
└─────────────────────────────────────────────────────────────────────────┘

User invokes: @Bolt Constitution "setup constitution"

    ┌──────────────────────────┐
    │  bolt-setup-constitution │
    │  Skill Invoked           │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Read Configuration      │
    │  ────────────────────────│
    │  • memory/constitution.md│
    │  • memory/scopes.yaml    │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  For Each Active Scope   │
    └────────┬─────────────────┘
             │
             ├─→ Backend
             │   ├─ Read .aurora/scopes/backend/scope.yaml
             │   ├─ Copy items (auto_provision: true)
             │   │  ├─ skill-backend-api-testing → .github/skills/
             │   │  ├─ bolt-testing.agent.md → .github/agents/
             │   │  └─ api-design-review.prompt.md → .github/prompts/
             │   └─ Extract constitution articles (III, XV, XVI)
             │
             ├─→ Frontend
             │   ├─ Read .aurora/scopes/frontend/scope.yaml
             │   ├─ Copy items
             │   └─ Extract constitution articles (III, XV, XVII)
             │
             └─→ Cloud-Platform
                 ├─ Read .aurora/scopes/cloud-platform/scope.yaml
                 ├─ Copy items
                 └─ Extract constitution articles (III, X, XI, XII)
             ↓
    ┌──────────────────────────┐
    │  Merge Constitution      │
    │  ────────────────────────│
    │  Basic + Scope Articles  │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Update Files            │
    │  ────────────────────────│
    │  • memory/constitution.md│
    │    (COMPLETE)            │
    │  • .github/skills/       │
    │  • .github/agents/       │
    │  • .github/prompts/      │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Generate Report         │
    │  ────────────────────────│
    │  memory/provision-       │
    │  report.md               │
    └────────┬─────────────────┘
             │
             ↓
    ┌──────────────────────────┐
    │  Show Report to User     │
    │  ────────────────────────│
    │  "Provisioned 25 files   │
    │   Ready for development" │
    └──────────────────────────┘

OUTPUT:
✓ memory/constitution.md (COMPLETE - all articles merged)
✓ memory/provision-report.md (detailed report)
✓ .github/skills/ (8+ skills provisioned)
✓ .github/agents/ (12+ agents provisioned)
✓ .github/prompts/ (5+ prompts provisioned)

───────────────────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────────┐
│                     STEP 3: DEVELOPMENT (Ready!)                        │
└─────────────────────────────────────────────────────────────────────────┘

User: @Bolt Framework "create a REST API feature"

    Agent loads skills automatically:
    ✓ bolt-framework
    ✓ skill-branch-management
    ✓ skill-quality-gates
    ✓ skill-testing-discipline
    ✓ backend-api-testing

    → Development begins with full Bolt Framework capabilities
```

## Key Benefits of Two-Step Architecture

| Aspect                  | Monolithic (Old)     | Two-Step (New)                   |
| ----------------------- | -------------------- | -------------------------------- |
| **Init.ps1 Complexity** | 837 lines            | ~300-400 lines (52% reduction)   |
| **Initialization Time** | 2-5 minutes          | 30-60 seconds                    |
| **Provisioning Time**   | Coupled              | 1-2 minutes (separate)           |
| **Re-provisioning**     | Re-run full init     | Re-run skill only                |
| **Dry-run Support**     | No                   | Yes (preview changes)            |
| **Extensibility**       | Modify Init.ps1      | Extend skill                     |
| **Testing**             | Monolithic test      | Init + Skill + Integration tests |
| **User Control**        | All-or-nothing       | Step-by-step with review         |
| **Error Recovery**      | Re-init from scratch | Re-run provisioning only         |

---

## Phase 5.6: Universal Skills & Work Management Integration (COMPLETED)

**Duración**: 2-3 horas
**Status**: ✅ Completado (2026-02-26)
**Decisión**: Implementada **Opción B** - Scope `common` centralizado

### Objetivo

Crear scope universal `common` con skills aplicables a TODOS los proyectos, independientemente del Practice. Además, añadir detección de herramienta de gestión de trabajo durante initialization.

### Implementación

#### 1. Scope `common` (Universal Skills)

**Archivo**: `.aurora/scopes/common/scope.yaml`

**Skills incluidos** (auto-provision: true):

1. **markdown-formatting** (document/):
   - CommonMark formatting rules
   - AURORA conventions for .md files
   - Universally useful - todo proyecto tiene documentación

2. **tdd-comprehensive** (tdd/):
   - Test-Driven Development methodology
   - Red-Green-Refactor cycle
   - Aplicable a cualquier lenguaje y stack

3. **gherkin-reqnroll** (functional-tests/):
   - BDD con Gherkin syntax
   - Reqnroll para .NET acceptance testing
   - Patterns Gherkin universales (aunque Reqnroll es .NET-specific)

**Constitution Articles** (`common/memory/constitution.md`):

- **Article XXI**: Documentation Standards (Markdown formatting)
- **Article XXII**: Test-Driven Development (TDD + BDD discipline)

**Provisioning Logic**:

- `Invoke-BoltSetupConstitution.ps1` modificado (línea 220):
  - SIEMPRE añade 'common' a active-scopes si no está presente
  - No requiere configuración manual en scopes.yaml
  - Se provisiona automáticamente con TODOS los proyectos

#### 2. Work Management Tool Integration (Step 1.6)

**Ubicación**: Init.ps1, línea ~318 (después de Step 1.5 Aspire)

**Pregunta añadida**:

```powershell
Select work management tool (or None for manual tracking)
1. None (manual tracking)
2. Azure Boards (Azure DevOps work items)
3. GitHub Projects (GitHub Issues integration)
4. Jira (Atlassian work management)
```

**Almacenamiento**:

- **scopes.yaml**: Campo `project.work-management-tool` (machine-readable)

  ```yaml
  project:
    practice: Apps & Infra
    use-aspire: true
    work-management-tool: azure-boards # ← NUEVO
  ```

- **Constitution** (future): Article sobre integración de trabajo (no implementado en esta fase)

**Values**:

- `none`: Sin integración automática
- `azure-boards`: Azure DevOps Boards
- `github-projects`: GitHub Projects v2
- `jira`: Jira Cloud/Server

**Agent Integration** (existente desde Phase 5):

- `@Bolt Feature`: Sync feature spec → Work item
- `@Bolt Plan`: Sync implementation plan → Tasks
- `@Bolt Tasks`: Sync Bolt task list → Work items
- `@Bolt Implement`: Sync progress updates
- Detección automática desde scopes.yaml (no requiere cambios adicionales)

#### 3. Archivos Modificados

**Creados** (2 archivos):

1. `.aurora/scopes/common/scope.yaml` (60 líneas)
   - 3 skills universales con auto_provision: true
2. `.aurora/scopes/common/memory/constitution.md` (80 líneas)
   - Articles XXI (Documentation) + XXII (TDD/BDD)

**Modificados** (2 archivos):

1. **Init.ps1** (2 cambios):
   - Líneas 318-348: Step 1.6 - Work Management Tool selection (30 líneas NEW)
   - Línea 654: scopes.yaml template - Añadido campo `work-management-tool` (1 línea)

2. **Invoke-BoltSetupConstitution.ps1** (1 cambio):
   - Líneas 220-223: Auto-include 'common' scope (4 líneas NEW)

**Total**: 4 archivos, 175 líneas añadidas

#### 4. Testing Checklist

✅ **Test 1: Scope common provisioning**:

```powershell
# Init sin common explícito
PS> .\Init.ps1
# Select: Apps & Infra
# Expected: common NO aparece en wizard

# Provision
PS> & .aurora\scripts\Invoke-BoltSetupConstitution.ps1
# Expected: "Adding 'common' scope (universal skills always included)"
# Expected: 3 skills copiados (markdown-formatting, tdd-comprehensive, gherkin-reqnroll)
```

✅ **Test 2: Work Management Tool selection**:

```powershell
PS> .\Init.ps1
# Expected: Step 1.6 prompt con 4 opciones
# Select: Azure Boards

# Verify scopes.yaml
cat .aurora/scopes.yaml | Select-String "work-management-tool"
# Expected: "work-management-tool: azure-boards"
```

✅ **Test 3: Constitution merge with common articles**:

```powershell
cat memory/constitution.md | Select-String "Article XXI|Article XXII"
# Expected: Both articles present
# Expected: Documentation Standards + TDD sections
```

#### 5. Decisiones de Diseño

**A. ¿Por qué Opción B (scope common) vs Opción A (duplicar en scopes)?**

- ✅ **Centralización**: 1 solo lugar para mantener skills universales
- ✅ **Reusabilidad**: Evita copiar 3 items × 8 scopes = 24 duplicaciones
- ✅ **Extensibilidad**: Añadir nuevo skill universal = 1 change en common/scope.yaml
- ✅ **Governance**: Clear separation: common (universal) vs scope-specific

**B. ¿Por qué auto-include en provisioning (no en Init.ps1)?**

- ✅ **Transparencia**: Usuario no ve "common" en wizard (reduce complejidad)
- ✅ **Automatización**: Script provisioning sabe que common es universal
- ✅ **Backward compatibility**: Proyectos antiguos sin common → auto-añadido

**C. ¿Por qué Work Management Tool en Step 1.6 (no Article XI)?**

- ✅ **Decisión temprana**: Afecta configuración de agentes (sync capabilities)
- ✅ **Project-wide**: No es específico de scope, aplica a TODO el proyecto
- ✅ **Simple storage**: scopes.yaml suficiente (no requiere article completo aún)

**D. ¿Por qué gherkin-reqnroll en common (es .NET-specific)?**

- ⚠️ **Trade-off aceptado**: Gherkin patterns son universales
- ✅ **BDD methodology**: Given-When-Then aplica a cualquier stack
- ℹ️ **Reqnroll-specific**: Step definitions son .NET, pero skill documenta patterns genéricos
- 🔮 **Futuro**: Podría separarse en gherkin-universal (common) + reqnroll-.net (backend scope)

#### 6. Beneficios Implementados

**Para Desarrolladores**:

- ✅ Skills universales disponibles en TODOS los proyectos (markdown, TDD, BDD)
- ✅ No requiere configuración manual de common scope
- ✅ Work management tool configurable desde inicio (no post-provisioning)

**Para Bolt Framework**:

- ✅ Centralización de skills universales (fácil mantener)
- ✅ Separation of concerns: common (universal) vs scope-specific
- ✅ Extensibilidad: añadir skills a common → automáticamente en todos los proyectos

**Para AI-DLC**:

- ✅ Constitution articles XXI/XXII documentan estándares universales
- ✅ Work management tool detection → agentes pueden sincronizar trabajo automáticamente
- ✅ Patterns consistency: Gherkin BDD disponible por defecto

#### 7. Próximos Pasos Potenciales

1. ⬜ **Article XVIII**: Work Management Integration (documenta sync patterns por herramienta)
2. ⬜ **Skill separation**: gherkin-universal (común) + reqnroll-.net (backend)
3. ⬜ **Common scope expansion**:
   - skill-git-workflow (branching, commits, PR templates)
   - skill-code-review (review checklist, standards)
   - skill-documentation-templates (README, ADR, API docs)
4. ⬜ **Validation**: `npm run validate:scopes:ps` incluir common scope
5. ⬜ **Testing**: End-to-end test con common scope provisioning

#### 8. Métricas

| Métrica              | Antes (Opción A propuesta) | Después (Opción B implementada)         |
| -------------------- | -------------------------- | --------------------------------------- |
| **Items scope.yaml** | 24 (3 skills × 8 scopes)   | 3 (1 scope common)                      |
| **Mantenimiento**    | 8 archivos actualizar      | 1 archivo actualizar                    |
| **Duplicación**      | 100%                       | 0%                                      |
| **Transparencia**    | Skills visibles en wizard  | Auto-provisioned (invisible al usuario) |
| **Extensibilidad**   | Difícil (8 archivos)       | Fácil (1 archivo)                       |

---

### Summary Phase 5.6

**Status**: ✅ **COMPLETADO** (2026-02-26)

**Deliverables**:

1. ✅ Scope `common` con 3 skills universales
2. ✅ Constitution articles XXI + XXII (Documentation + TDD/BDD)
3. ✅ Auto-provisioning de common scope en todos los proyectos
4. ✅ Work Management Tool selection en Init.ps1 Step 1.6
5. ✅ Almacenamiento en scopes.yaml (work-management-tool field)

**Testing**: ✅ Validated (manual verification)

**Next**: Phase 5 Task 28 (Manual testing del two-step workflow completo)

---

## Key Benefits of Two-Step Architecture

| Aspect                  | Monolithic (Old)     | Two-Step (New)                   |
| ----------------------- | -------------------- | -------------------------------- |
| **Init.ps1 Complexity** | 837 lines            | ~300-400 lines (52% reduction)   |
| **Initialization Time** | 2-5 minutes          | 30-60 seconds                    |
| **Provisioning Time**   | Coupled              | 1-2 minutes (separate)           |
| **Re-provisioning**     | Re-run full init     | Re-run skill only                |
| **Dry-run Support**     | No                   | Yes (preview changes)            |
| **Extensibility**       | Modify Init.ps1      | Extend skill                     |
| **Testing**             | Monolithic test      | Init + Skill + Integration tests |
| **User Control**        | All-or-nothing       | Step-by-step with review         |
| **Error Recovery**      | Re-init from scratch | Re-run provisioning only         |
