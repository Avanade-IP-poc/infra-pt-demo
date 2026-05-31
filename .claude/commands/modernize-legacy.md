---
description: Orquesta una modernización de legacy con Bolt Framework (discovery → transform) apalancando los pasos modernize-*. Cliente Claude Code.
argument-hint: "[opcional: overrides de parámetros, p. ej. ALCANCE=un-modulo ESTRATEGIA=transform]"
---

# Modernización de legacy con Bolt Framework (cliente: Claude Code)

## Parámetros (rellena antes de ejecutar; admite overrides en $ARGUMENTS)
- LEGACY_PATH:   <ruta al código legacy, p. ej. ./legacy o C:\repos\sistema-viejo>
- TARGET_STACK:  <stack destino, p. ej. .NET 9 + Aspire + Angular | Node/TS + React | ...>
- ALCANCE:       <"un-modulo" (prueba acotada) | "completo">
- ESTRATEGIA:    <"transform" (reescritura idiomática por módulo) | "reimagine" (greenfield)>
- IDIOMA:        <Español (España) | English>
- RIESGO:        <"bajo-riesgo-alto-valor" u otro criterio para elegir el primer módulo>

Overrides recibidos: $ARGUMENTS

## Rol y método
Actúa como orquestador del **Bolt Framework** (subagente `bolt-framework`) para modernizar
el sistema en LEGACY_PATH hacia TARGET_STACK. Combinas el ciclo de vida Bolt (gobernanza,
constitution, specs, quality gates) con el plugin `code-modernization` (`modernize-*` +
agentes `legacy-analyst`, `business-rules-extractor`, `security-auditor`, `test-engineer`,
`architecture-critic`). Toda interacción y documentación en IDIOMA.

**Reglas:**
- Trabaja por fases; **párate en cada checkpoint HITL** y espera mi validación antes de seguir.
- No reescribas nada sin tests de equivalencia que fijen el comportamiento legacy.
- Respeta la constitution (`.boltf/memory/constitution.md`) y las quality gates
  (`skill-bolt-quality-gates`). Versiona todo en `specs/`, `docs/adr/`, `migration/`.
- Por cada feature/bolt, crea/actualiza el issue de GitHub correspondiente (ver CLAUDE.md).

## Pipeline a ejecutar

### Fase 1 — INCEPTION
1. Verifica que el proyecto es brownfield (`legacy/`, `.boltf/`, `.claude/` presentes).
   Si falta, indícame ejecutar `./init.sh --type brown --source LEGACY_PATH` (cliente Claude).
2. Subagente `bolt-constitution`: redacta/ajusta la constitution con TARGET_STACK,
   estándares, arquitectura y constraints.
   ⏸ **CHECKPOINT 1**: muéstrame la constitution y espera OK.

### Fase 2 — DISCOVERY
3. Skill `modernize-assess` (+ agente `legacy-analyst`); si el plugin no está disponible, usa
   el agente nativo `bolt-legacy-analyst`. Inventario, complejidad, deuda,
   dead code y estimación. Guarda el informe en `.boltf/analysis/`.
4. Si ALCANCE = "un-modulo": propón el módulo según RIESGO y justifícalo.
   ⏸ **CHECKPOINT 2**: confírmame el módulo (o el alcance completo).
5. Skill `modernize-map` (acotado al módulo + dependencias): call graphs / data lineage,
   renderizados con `mermaid-creator`/`bolt-datamodel-diagramer` en `docs/`.
6. Skill `modernize-extract-rules` (+ `business-rules-extractor`): reglas de negocio en
   Given/When/Then. Alimenta con ellas a `bolt-feature` → `bolt-specify` → `bolt-gherkin`
   para crear los specs en `specs/<feature>/`. `bolt-analyze` valida consistencia.
   ⏸ **CHECKPOINT 3**: revisa specs + escenarios Gherkin.

### Fase 3 — PLAN
7. Skill `modernize-brief`: plan de modernización por fases.
8. Subagentes `bolt-plan` (+ `bolt-architect`, `bolt-adr`): plan técnico, data model,
   contratos API y **desglose en Bolts** (micro-iteraciones), reconciliado con `bolt-tasks`.
   ⏸ **CHECKPOINT 4**: aprueba el brief + los Bolts.
9. (Opcional) `modernize-harden` (+ `security-auditor`) y `bolt-security`: hallazgos de
   seguridad a remediar durante la transformación.

### Fase 4 — CONSTRUCTION (por cada Bolt)
10. `test-engineer`: tests de **caracterización/equivalencia** que fijan el comportamiento legacy.
11. `bolt-implement` + (`modernize-transform` si ESTRATEGIA=transform, o `modernize-reimagine`
    si greenfield) + disciplina TDD (`tdd-red`/`tdd-green`/`tdd-refactor`, skill
    `skill-tdd-red-green-refactor`). E2E con `skill-playwright-e2e` si aplica.
12. Quality gates (cobertura, mutación, arquitectura) **+ gate de equivalencia**
    (`skill-bolt-quality-gates`: pass ≥ 95%, 100% comportamiento P0 caracterizado).
    `bolt-review` + `architecture-critic`
    (revisión adversarial).
    ⏸ **CHECKPOINT 5** (por Bolt): resultados de tests de equivalencia + review.

### Fase 5 — TRANSITION
13. `bolt-docs` + `bolt-adr`: documenta decisiones y resultados. `bolt-release` si procede.
14. Anota en `migration/` el módulo legacy modernizado y candidatos a retirada (dead code
    de `modernize-assess`) para `bolt-retire`.

## Entregable de cada checkpoint
Resumen breve de lo hecho, rutas de los artefactos generados, y la decisión que necesitas
de mí para continuar. Empieza por la **Fase 1**.
