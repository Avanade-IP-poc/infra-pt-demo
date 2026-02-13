# Plan: Refactorización Arquitectura AURORA → Bolt Framework

> **Versión**: 2.0 | **Fecha**: 2026-02-13 | **Estado**: EN PROGRESO
>
> **Correcciones aplicadas**: 7 correcciones de validación contra documentación oficial VS Code (Feb 2026)
>
> **Fuentes de validación**:
> - [Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)
> - [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills) + [Agent Skills Open Standard](https://agentskills.io)
> - [Agent Tools Reference](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features#_chat-tools)

## 📊 Progress Tracker

| # | Fase | Descripción | Estado | Progreso |
|---|------|-------------|--------|----------|
| 1 | **FASE 1** | Crear Infraestructura del Skill | ⬜ Pendiente | 0/5 pasos |
| 2 | **FASE 2** | Actualizar Agente Principal | ⬜ Pendiente | 0/3 pasos |
| 3 | **FASE 5** | Actualizar copilot-instructions.md | ⬜ Pendiente | 0/3 pasos |
| 4 | **FASE 3** | Actualizar Todos los Agentes (30) | ⬜ Pendiente | 0/30 agentes |
| 5 | **FASE 4** | Simplificar aurora.prompt.md | ⬜ Pendiente | 0/1 pasos |
| 6 | **FASE 6** | Actualizar Referencias | ⬜ Pendiente | 0/2 archivos |
| 7 | **FASE 7** | Validación y Testing | ⬜ Pendiente | 0/10 tests |

---

## 🔍 Problemas Identificados en la Arquitectura Actual

### 1. Tools Inconsistentes

| Problema | Agentes Afectados | Impacto |
|----------|-------------------|---------|
| **Tools inválidas** | Mayoría de agentes usan `'vscode'`, `'execute'`, `'read'`, `'edit'` | Estas tools NO EXISTEN en VS Code |
| **Falta MCP tools críticas** | `aurora-constitution`, `bolt-framework` | No pueden acceder a `context7/*` ni `awesome-copilot/*` |
| **Toolsets mal configurados** | Varios agentes | No usan tool sets como `'edit'`, `'search'`, `'runCommands'` |

### 2. Handoffs Problemáticos

| Problema | Ubicación | Recomendación |
|----------|-----------|---------------|
| **Self-handoff** | `aurora-security.agent.md` | Eliminar handoffs a sí mismo |
| **Handoffs duplicados** | `aurora-gherkin.agent.md` | Consolidar múltiples handoffs al mismo agente |
| **Nombres inconsistentes** | Varios agentes | Estandarizar todos los nombres |

### 3. Duplicación de Metodología

| Contenido Duplicado | Ubicaciones | Líneas Duplicadas |
|---------------------|-------------|-------------------|
| **Lifecycle phases** | `aurora.agent.md`, `aurora.prompt.md`, varios agentes | ~150 líneas |
| **Constitution checks** | `aurora.agent.md`, varios agentes | ~80 líneas |
| **Quality gates** | `aurora-implement`, `aurora-testing`, `aurora-review` | ~120 líneas |
| **Bolt workflow** | `aurora-implement`, `aurora-micro-iterator` | ~200 líneas |

**Total duplicación estimada**: ~550 líneas de contenido metodológico repetido

---

## 🎯 Objetivos del Plan

1. **Crear Bolt Framework Skill** - Fuente única de metodología AURORA
2. **Corregir Toolsets** - Usar tools reales de VS Code + MCP
3. **Incluir MCP Tools Críticas** - context7 y awesome-copilot
4. **Simplificar Todos los Agentes** - Reducir ~50% de contenido
5. **Corregir Handoffs** - Validar y optimizar delegaciones
6. **Renombrar Aurora → Bolt Framework** - Agente principal como orquestador

---

## 📋 FASE 1: Crear Infraestructura del Skill

> 📊 **Progreso**: ⬜ No iniciado | Pasos: 0/5 completados

### Paso 1.1: Crear Estructura de Carpetas

```
.github/skills/bolt-framework/
├── SKILL.md                    # Metodología AURORA completa (~500 líneas)
├── TOOLSETS.md                 # Definición de toolsets con MCP
├── HANDOFF-MATRIX.md           # Matriz de handoffs válidos
├── examples/
│   ├── greenfield-workflow.md
│   ├── brownfield-workflow.md
│   └── hotfix-workflow.md
└── templates/
    ├── constitution-template.md
    ├── bolt-template.md
    └── quality-gate-checklist.md
```

### Paso 1.2: Escribir TOOLSETS.md

#### MCP Tools Fundamentales

**Context7 MCP** - Documentación actualizada de librerías:
- `context7/*` - Todas las tools
- `context7/query-docs` - Buscar documentación
- `context7/resolve-library-id` - Resolver IDs de librerías

**Awesome Copilot MCP** - Ejemplos y colecciones:
- `awesome-copilot/*` - Todas las tools
- `awesome-copilot/list_collections` - Listar colecciones
- `awesome-copilot/load_collection` - Cargar colección
- `awesome-copilot/load_instruction` - Cargar instrucción/agente
- `awesome-copilot/search_instructions` - Buscar instrucciones

**Microsoft Docs MCP** - Documentación Microsoft/Azure:
- `microsoftdocs/*` - Todas las tools
- `microsoftdocs/microsoft_docs_search` - Buscar docs
- `microsoftdocs/microsoft_docs_fetch` - Obtener página completa
- `microsoftdocs/microsoft_code_sample_search` - Buscar código

#### Toolset Categories

> ⚠️ **CORRECCIÓN v2.0**: Se agregan tools faltantes validadas contra la [referencia oficial](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features#_chat-tools):
> `terminalLastCommand`, `testFailure`, `searchResults`, `getTaskOutput`, `runTasks` (tool set)
>
> Nota: `fileSearch` y `textSearch` están incluidos en el tool set `search`, por lo que no se agregan individualmente.

**1. FULL_PLANNING** (Solo lectura):
```yaml
tools:
  - codebase              # Semantic code search
  - search                # Tool set: file/text search
  - usages                # Find references
  - fetch                 # Web content
  - githubRepo            # GitHub repos
  - problems              # Problems panel
  - changes               # Git changes
  - readFile              # Read files
  - listDirectory         # List dirs
  - runSubagent           # Delegate tasks
  - VSCodeAPI             # VS Code APIs
  - terminalLastCommand   # Last terminal command output ⚡NEW
  - searchResults         # Search view results ⚡NEW
  - context7/*            # Documentation lookup
  - awesome-copilot/*     # Examples
  - microsoftdocs/*       # Microsoft docs
```

**Usado por**: Plan, Analyze, Status, Alignment, Architect, Tasks, Improve, Retire, Deps

**2. FULL_IMPLEMENTATION** (Read + Write + Execute):
```yaml
tools:
  - codebase
  - search
  - usages
  - fetch
  - githubRepo
  - problems
  - changes
  - readFile
  - listDirectory
  - edit                  # Tool set: editing
  - editFiles             # Apply edits
  - createFile            # Create files
  - createDirectory       # Create dirs
  - runCommands           # Tool set: terminal
  - runInTerminal         # Execute commands
  - getTerminalOutput     # Get output
  - runTests              # Run tests
  - runTasks              # Tool set: VS Code tasks ⚡NEW
  - testFailure           # Test failure details ⚡NEW
  - terminalLastCommand   # Last terminal output ⚡NEW
  - getTaskOutput         # Task execution output ⚡NEW
  - runSubagent           # Delegate
  - todos                 # Track TODOs
  - VSCodeAPI             # VS Code APIs
  - context7/*            # Documentation
  - awesome-copilot/*     # Examples
  - microsoftdocs/*       # Microsoft docs
```

**Usado por**: Implement, Testing, Review, Micro Iterator

**3. SPEC_FOCUSED** (Especificaciones):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - fetch
  - githubRepo
  - runSubagent
  - VSCodeAPI
  - context7/*            # Research frameworks
  - awesome-copilot/*     # Spec examples
  - microsoftdocs/*       # Technical docs
```

**Usado por**: Feature, Specify, Clarify, Use Case, Gherkin, DDD

**4. DOCS_FOCUSED** (Documentación):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - fetch
  - githubRepo
  - runSubagent
  - VSCodeAPI
  - context7/*            # API docs research
  - awesome-copilot/*     # Doc templates
  - microsoftdocs/*       # Microsoft docs
```

**Usado por**: Documentation, ADR, Postmortem

**5. OPS_FOCUSED** (Operaciones):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - fetch
  - problems
  - changes
  - runCommands
  - runInTerminal
  - getTerminalOutput
  - runTasks              # VS Code tasks
  - getTaskOutput         # Task execution output ⚡NEW
  - terminalLastCommand   # Last terminal output ⚡NEW
  - runSubagent
  - VSCodeAPI
  - context7/*            # Infrastructure docs
  - microsoftdocs/*       # Azure operations docs
```

**Usado por**: Ops, Release, Monitoring

**6. CONSTITUTION_BUILDER** (⭐ Configuración proyecto):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - createDirectory
  - fetch
  - githubRepo
  - runSubagent
  - VSCodeAPI
  - context7/*            # Framework documentation
  - awesome-copilot/*     # ⭐ CRITICAL - Constitution examples
  - microsoftdocs/*       # Microsoft tech stacks
```

**Usado por**: Constitution

**7. CICD_FOCUSED** (CI/CD):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - fetch
  - githubRepo
  - runCommands
  - runInTerminal
  - getTerminalOutput
  - runTasks
  - runTests
  - testFailure           # Test failures
  - terminalLastCommand   # Last terminal output ⚡NEW
  - getTaskOutput         # Task execution output ⚡NEW
  - runSubagent
  - VSCodeAPI
  - context7/*            # CI/CD framework docs
  - awesome-copilot/*     # Pipeline examples
  - microsoftdocs/*       # Azure DevOps docs
```

**Usado por**: CI/CD

**8. SECURITY_FOCUSED** (Seguridad):
```yaml
tools:
  - codebase
  - search
  - usages
  - readFile
  - listDirectory
  - problems
  - changes
  - fetch
  - githubRepo
  - terminalLastCommand   # Last terminal output ⚡NEW
  - runSubagent
  - VSCodeAPI
  - context7/*            # Security framework docs
  - microsoftdocs/*       # Microsoft security best practices
```

**Usado por**: Security

**9. INIT_WORKSPACE** (⭐⭐⭐ Inicialización):
```yaml
tools:
  - codebase
  - search
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - createDirectory
  - runCommands
  - runInTerminal
  - getTerminalOutput
  - terminalLastCommand   # Last terminal output ⚡NEW
  - runTasks              # VS Code tasks ⚡NEW
  - todos                 # Track TODOs ⚡NEW
  - fetch
  - githubRepo
  - runSubagent
  - VSCodeAPI
  - context7/*            # Framework docs
  - awesome-copilot/*     # ⭐⭐⭐ CRITICAL - Templates completos
  - microsoftdocs/*       # Microsoft tech docs
```

**Usado por**: Bolt Framework, Templates

### Paso 1.3: Escribir SKILL.md

> ⚠️ **CORRECCIÓN v2.0**: SKILL.md REQUIERE YAML frontmatter según [Agent Skills Open Standard](https://agentskills.io)

**YAML Frontmatter Requerido**:
```yaml
---
name: bolt-framework
description: >
  AURORA-IA-DLC methodology - AI-Driven Development Lifecycle.
  Defines 6 lifecycle phases (Inception, Discovery, Construction, Transition,
  Production, Retirement), Bolt micro-iterations, quality gates, and
  constitution compliance. Use when orchestrating AURORA projects, routing
  between agents, implementing workflows, or enforcing methodology.
---
```

**Reglas del frontmatter**:
- `name`: lowercase-hyphen, máximo 64 caracteres
- `description`: máximo 1024 caracteres, DEBE incluir "when to use"
- El skill se invoca como slash command: `/bolt-framework`
- Auto-discovery desde `.github/skills/bolt-framework/SKILL.md` (no necesita registro manual)

**Estructura del contenido** (~500 líneas):

1. **Descripción y Cuándo Usar** (30 líneas)
   - Qué es AURORA-IA-DLC
   - 6 lifecycle phases
   - Cuándo invocar el skill

2. **Conceptos Fundamentales** (100 líneas)
   - Constitution (memory/constitution.md)
   - Features (specs/XXX-feature-name/)
   - Bolts (micro-iterations)
   - Quality Gates
   - Agents Ecosystem (30 agentes, incluye aurora-docs)

3. **Lifecycle Phases Detallado** (150 líneas)
   - **INCEPTION**: Constitution, Clarify
   - **DISCOVERY**: Feature, Specify, Use Case, Gherkin, Plan, Tasks
   - **CONSTRUCTION**: Implement, Testing, Review, Analyze, ADR
   - **TRANSITION**: Release
   - **PRODUCTION**: Ops, Improve, Alignment, Status
   - **RETIREMENT**: Retire, Postmortem

4. **Project State Detection** (50 líneas)
   - Algoritmo de detección de fase actual
   - Verificación de estructura
   - Decisiones de routing

5. **Bolt Workflow** (80 líneas)
   - Planning Phase
   - Build Phase
   - Test Phase
   - Review Phase
   - Integration Phase

6. **Quality Gates & Compliance** (60 líneas)
   - Constitution compliance
   - Quality gate definitions
   - Scripts (bash/powershell)

7. **Workflows Comunes** (80 líneas)
   - New Project Setup
   - Feature Development
   - Legacy Modernization
   - Hotfix Process

8. **Agent Coordination** (50 líneas)
   - Handoff patterns
   - Agent responsibilities
   - Escalation paths

### Paso 1.4: Escribir HANDOFF-MATRIX.md

**Matriz de Handoffs Válidos**:

**FROM: Bolt Framework** → TO: Cualquier agente especializado ✅

**FROM: Feature** → TO:
- ✅ Use Case (detallar casos de uso)
- ✅ Gherkin (BDD scenarios)
- ✅ Plan (implementation plan)
- ✅ Implement (implementación directa)
- ❌ Status (no relacionado)
- ❌ Ops (muy temprano en lifecycle)

**FROM: Plan** → TO:
- ✅ Tasks (breakdown en tasks)
- ✅ Analyze (revisar consistencia)
- ❌ Implement (debe ir a Tasks primero)
- ❌ Release (muy temprano)

**FROM: Implement** → TO:
- ✅ Testing (generar tests)
- ✅ Analyze (verificar consistencia)
- ✅ Review (code review)
- ❌ Feature (circular)
- ❌ Plan (ya tiene plan)

**FROM: Testing** → TO:
- ✅ Implement (TDD green phase)
- ✅ Gherkin (BDD scenarios)
- ✅ Review (test quality)
- ✅ Analyze (coverage analysis)
- ❌ Feature (tests vienen de feature)

**FROM: Review** → TO:
- ✅ Implement (fix issues)
- ✅ Testing (mejorar coverage)
- ✅ ADR (documentar decisión)
- ❌ Feature (review no crea features)

**FROM: Security** → TO:
- ✅ Constitution (actualizar standards)
- ✅ Implement (fix vulnerabilities)
- ✅ Testing (security tests)
- ❌ Self-handoff (INVÁLIDO)

**FROM: Ops** → TO:
- ✅ Improve (identificar mejoras)
- ✅ Postmortem (análisis incidentes)
- ✅ Status (estado general)
- ✅ Release (crear deployment)
- ❌ Feature (ops no crea features)

**FROM: Status** → TO:
- ✅ Analyze (análisis profundo)
- ✅ Improve (oportunidades mejora)
- ✅ Alignment (verificar alineación)
- ✅ Ops (salud operacional)
- ❌ Implement (status es read-only)

**Anti-Patterns** ❌:
- Self-handoffs (agente a sí mismo)
- Circular dependencies (A → B → C → A)
- Cross-phase jumps (Discovery → Production sin Construction)
- Duplicate handoffs (múltiples al mismo con prompts similares)

### Paso 1.5: Crear Examples

**examples/greenfield-workflow.md**: Workflow completo desde init hasta deploy

**examples/brownfield-workflow.md**: Migración legacy (COBOL → modern)

**examples/hotfix-workflow.md**: Fix rápido de producción

---

## 📋 FASE 2: Actualizar Agente Principal

> 📊 **Progreso**: ⬜ No iniciado | Pasos: 0/3 completados

### Paso 2.1: Renombrar Archivo

```
mv .github/agents/aurora.agent.md .github/agents/bolt-framework.agent.md
```

### Paso 2.2: Actualizar Frontmatter

```yaml
---
name: Bolt Framework
description: 🌌 AI-Driven Development Lifecycle Orchestrator
tools:
  - codebase
  - search
  - usages
  - fetch
  - githubRepo
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - createDirectory
  - runCommands
  - runInTerminal
  - getTerminalOutput
  - runSubagent
  - todos
  - VSCodeAPI
  - context7/*
  - awesome-copilot/*
  - microsoftdocs/*
# ⚠️ CORRECCIÓN v2.0: Nuevas propiedades del agente
agents: ['*']                    # Permitir delegar a cualquier agente
user-invokable: true             # Invocable por el usuario directamente
model:                           # Array syntax para fallback chain
  - Claude Sonnet 4.5
  - copilot-chat
handoffs:
  # INCEPTION Phase
  - label: 📋 Define Constitution
    agent: Aurora Constitution
    prompt: Create or update project constitution following bolt-framework methodology
    send: false
  
  - label: ❓ Clarify Requirements
    agent: Aurora Clarify
    prompt: Clarify ambiguous requirements through structured questioning
    send: false

  # DISCOVERY Phase
  - label: ✨ Create Feature
    agent: Aurora Feature
    prompt: Create feature specification with stories and acceptance criteria
    send: false
  
  - label: 📝 Create Specification
    agent: Aurora Specify
    prompt: Transform natural language into structured feature spec
    send: false
  
  - label: 🗺️ Create Plan
    agent: Aurora Plan
    prompt: Create technical implementation plan from feature spec
    send: false
  
  - label: ✅ Generate Tasks
    agent: Aurora Tasks
    prompt: Generate Bolt task breakdown from plan
    send: false

  # CONSTRUCTION Phase
  - label: 🏗️ Implement Code
    agent: Aurora Implement
    prompt: Implement code following specs and constitution
    send: false
  
  - label: 🧪 Generate Tests
    agent: Aurora Testing
    prompt: Generate comprehensive test suites
    send: false
  
  - label: 👀 Review Code
    agent: Aurora Review
    prompt: Perform code review with quality checks
    send: false

  # TRANSITION Phase
  - label: 🚀 Release
    agent: Aurora Release
    prompt: Orchestrate release and deployment process
    send: false

  # PRODUCTION Phase
  - label: 🔧 Operations
    agent: Aurora Ops
    prompt: Manage operations and monitoring
    send: false
  
  - label: 📊 Project Status
    agent: Aurora Status
    prompt: Show current project status and progress
    send: false
  
  - label: 📈 Improvements
    agent: Aurora Improve
    prompt: Analyze and identify improvement opportunities
    send: false

  # Cross-Phase
  - label: 🔍 Analyze Consistency
    agent: Aurora Analyze
    prompt: Perform consistency analysis across artifacts
    send: false
  
  - label: ⚖️ Check Alignment
    agent: Aurora Alignment
    prompt: Verify business-technical alignment
    send: false
  
  - label: 🔒 Security Analysis
    agent: Aurora Security
    prompt: Perform security analysis with OWASP compliance
    send: false
  
  - label: 📜 Create ADR
    agent: Aurora ADR
    prompt: Create Architecture Decision Record
    send: false
---
```

### Paso 2.3: Simplificar Contenido

Reducir de 296 a ~80 líneas:

```markdown
# 🌌 Bolt Framework Orchestrator

> AI-Driven Development Lifecycle - AURORA methodology

## Available Scripts

| Script | Bash | PowerShell |
|--------|------|------------|
| **Initialize** | `init.sh` | `Init.ps1` |
| **Status** | `scripts/bash/project-status.sh` | `scripts/powershell/Get-ProjectStatus.ps1` |
| **Quality Gates** | `scripts/bash/quality-gates.sh` | `scripts/powershell/Quality-Gates.ps1` |

## Your Role

You are the Bolt Framework orchestrator, guiding development through AURORA-IA-DLC methodology.

**The bolt-framework skill contains complete methodology.** Your job:

1. **Detect project state** using skill guidelines
2. **Route to appropriate agent** via handoffs
3. **Ensure quality gates** per skill methodology
4. **Guide user** through lifecycle phases

## Quick Actions

### First Time in Project?
Check if initialized: `ls memory/constitution.md specs/ src/`

If missing, run init:
- Bash: `./init.sh my-project green --scope full-stack`
- PowerShell: `.\Init.ps1 -ProjectName "my-project" -Type greenfield`

### What Phase Am I In?
Use skill to detect:
- No constitution? → **PRE_INCEPTION** - Run init
- Constitution but no specs? → **INCEPTION** - Define features
- Specs but no code? → **DISCOVERY** - Plan implementation
- Code but tests failing? → **CONSTRUCTION** - Fix and test
- Tests passing not deployed? → **TRANSITION** - Release
- Deployed? → **PRODUCTION** - Monitor and improve

### Need Help?
- New feature → Handoff to `Aurora Feature`
- Implement code → Handoff to `Aurora Implement`
- Project status → Handoff to `Aurora Status`
- Fix security → Handoff to `Aurora Security`

## Methodology

All details in **bolt-framework skill**. Follow for:
- Lifecycle phases (6 phases)
- Bolt workflows (micro-iterations)
- Quality gates
- Constitution compliance
- Agent coordination

---

**What would you like to do?**
```

---

## 📋 FASE 3: Actualizar Todos los Agentes (30)

> 📊 **Progreso**: ⬜ No iniciado | Agentes: 0/30 completados

### Agent-to-Toolset Mapping

| Agente | Toolset | Notes |
|--------|---------|-------|
| Bolt Framework | INIT_WORKSPACE | ⭐⭐⭐ awesome-copilot crítico |
| aurora-constitution | CONSTITUTION_BUILDER | ⭐ awesome-copilot importante |
| aurora-templates | INIT_WORKSPACE | ⭐⭐ awesome-copilot muy importante |
| aurora-plan | FULL_PLANNING | |
| aurora-implement | FULL_IMPLEMENTATION | |
| aurora-testing | FULL_IMPLEMENTATION | |
| aurora-review | FULL_IMPLEMENTATION | |
| aurora-feature | SPEC_FOCUSED | |
| aurora-specify | SPEC_FOCUSED | |
| aurora-clarify | SPEC_FOCUSED | |
| aurora-usecase | SPEC_FOCUSED | |
| aurora-gherkin | SPEC_FOCUSED | |
| aurora-ddd | SPEC_FOCUSED | |
| aurora-docs | DOCS_FOCUSED | |
| aurora-adr | DOCS_FOCUSED | |
| aurora-postmortem | DOCS_FOCUSED | |
| aurora-ops | OPS_FOCUSED | No awesome-copilot |
| aurora-release | OPS_FOCUSED | No awesome-copilot |
| aurora-monitoring | OPS_FOCUSED | No awesome-copilot |
| aurora-cicd | CICD_FOCUSED | |
| aurora-security | SECURITY_FOCUSED | No awesome-copilot |
| aurora-analyze | FULL_PLANNING | |
| aurora-status | FULL_PLANNING | |
| aurora-alignment | FULL_PLANNING | |
| aurora-improve | FULL_PLANNING | |
| aurora-tasks | FULL_PLANNING | |
| aurora-micro-iterator | FULL_IMPLEMENTATION | |
| aurora-architect | FULL_PLANNING | |
| aurora-retire | FULL_PLANNING | |
| aurora-deps | FULL_PLANNING | |

### Proceso de Refactorización por Agente

Para cada agente:

1. **Actualizar tools** según toolset
2. **Validar handoffs** según HANDOFF-MATRIX.md
3. **Eliminar metodología duplicada**
4. **Mantener contenido específico**
5. **Agregar referencia al skill**
6. **Agregar nuevas propiedades** ⚡NEW (donde aplique):
   - `agents: ['*']` para agentes que delegan (orchestrators)
   - `user-invokable: true/false` para controlar acceso directo
   - `model` array syntax para fallback chain
   - `handoffs.model` para override de modelo por handoff

**Contenido a ELIMINAR**:
- ❌ Explicación de lifecycle phases
- ❌ Descripción de constitution
- ❌ Quality gates generales
- ❌ Workflow AURORA completo
- ❌ Project state detection

**Contenido a MANTENER**:
- ✅ Frontmatter (name, description, tools, handoffs)
- ✅ Scripts específicos
- ✅ Instrucciones específicas de tarea
- ✅ Ejemplos de OUTPUT
- ✅ Checklists específicos

### Ejemplo: aurora-implement.agent.md

**ANTES**: 446 líneas  
**DESPUÉS**: ~200 líneas (55% reducción)

```yaml
---
name: Aurora Implement
description: 🏗️ Execute implementation following Bolt task list
tools:
  - codebase
  - search
  - usages
  - fetch
  - githubRepo
  - problems
  - changes
  - readFile
  - listDirectory
  - edit
  - editFiles
  - createFile
  - createDirectory
  - runCommands
  - runInTerminal
  - getTerminalOutput
  - runTests
  - runSubagent
  - todos
  - VSCodeAPI
  - context7/*
  - awesome-copilot/*
  - microsoftdocs/*
model: Claude Sonnet 4.5
handoffs:
  - label: 🧪 Generate Tests
    agent: Aurora Testing
    prompt: Generate test suite for current implementation
    send: false
  - label: 🔍 Analyze Consistency
    agent: Aurora Analyze
    prompt: Verify implementation consistency with spec
    send: false
  - label: 👀 Review Code
    agent: Aurora Review
    prompt: Perform code review on implementation
    send: false
---

# 🏗️ Implementation Agent

## Available Scripts
- **Bash**: `scripts/bash/quality-gates.sh`
- **PowerShell**: `scripts/powershell/Quality-Gates.ps1`

## Your Role

Execute Bolt implementations following specs and constitution.

**Methodology**: Follow bolt-framework skill (loaded automatically)

## Prerequisites

Read before implementing:
1. **Constitution**: `memory/constitution.md`
2. **Feature Spec**: `specs/[XXX-feature-name]/feature.md`
3. **Plan**: `specs/[XXX-feature-name]/planning/plan.md`
4. **Tasks**: `specs/[XXX-feature-name]/planning/tasks.md`

## Implementation Process

### 1. Branch Management
Auto-create BOLT branch:
```bash
FEATURE_BRANCH=$(git branch --show-current)
BOLT_BRANCH="${FEATURE_BRANCH}/bolt-${N}-${DESCRIPTION}"
git checkout -b "$BOLT_BRANCH"
```

### 2. Implementation Cycle

For each task:
1. Read constitution for standards
2. Write tests first (if TDD)
3. Implement code
4. Run tests
5. Run quality gates
6. Commit incrementally
7. Mark task complete

### 3. Quality Gates

Run before marking complete:
```bash
./scripts/bash/quality-gates.sh
# or
.\scripts\powershell\Quality-Gates.ps1
```

Must pass:
- [ ] Linting
- [ ] Unit tests
- [ ] Constitution compliance
- [ ] No security vulnerabilities

### 4. Handoffs

After Bolt complete:
- Tests passing → `Aurora Review`
- Need tests → `Aurora Testing`
- Verify spec → `Aurora Analyze`

## Constitution Compliance

**ALWAYS verify**:
- Using allowed tech stack?
- Following naming conventions?
- Meeting architecture patterns?
- Passing quality criteria?

See bolt-framework skill for methodology.
```

---

## 📋 FASE 4: Simplificar aurora.prompt.md

> 📊 **Progreso**: ⬜ No iniciado | Pasos: 0/1 completados

**ANTES**: 108 líneas  
**DESPUÉS**: ~15 líneas (86% reducción)

```markdown
# 🌌 Bolt Framework AURORA-IA-DLC

This prompt invokes the Bolt Framework orchestrator.

## Instructions

When invoked:

1. **Delegate to @Bolt Framework agent** with user's context
2. **The agent will**:
   - Load bolt-framework skill automatically
   - Detect project state
   - Route to appropriate specialized agent
   - Apply AURORA methodology

All methodology is in bolt-framework skill.

---

**Action**: Invoke `@Bolt Framework` with user's request.
```

---

## 📋 FASE 5: Actualizar copilot-instructions.md

> 📊 **Progreso**: ⬜ No iniciado | Pasos: 0/3 completados

> ⚠️ **CORRECCIÓN v2.0**: Los skills se **auto-descubren** por convención de directorio.
> NO se necesitan tags `<skill>`. Los skills se descubren desde `.github/skills/<name>/SKILL.md`.
> Fuente: [Agent Skills Open Standard](https://agentskills.io)

### Paso 5.1: Actualizar tabla de Skills

Skills se auto-descubren — solo actualizar la tabla informativa en `.github/copilot-instructions.md`:

| Skill | Domain | Use When |
|-------|--------|----------|
| [bolt-framework](.github/skills/bolt-framework/) | AURORA Methodology | Working on AURORA projects, managing lifecycle |
| [skill-development](.github/skills/skill-development/) | Skill Creation | Creating or improving Copilot skills |

> **Nota**: Eliminar cualquier tag `<skill>` existente. Los skills se auto-descubren desde el directorio.

### Paso 5.2: Actualizar tabla de Agentes

Actualizar tabla de agentes (30 agentes) y cambiar nombre del orchestrator a `@Bolt Framework`.

### Paso 5.3: Agregar YAML frontmatter a skill-development

Verificar que `skill-development/SKILL.md` tenga YAML frontmatter requerido.

> 📊 **Fin FASE 5**: Actualizar progreso al inicio del documento

---

## 📋 FASE 6: Actualizar Referencias

> 📊 **Progreso**: ⬜ No iniciado | Archivos: 0/2 completados

### README.md
- Cambiar `@AURORA` → `@Bolt Framework`
- Agregar sección sobre skill
- Actualizar tabla de agentes

### .github/agents/README.md
```markdown
### 🌌 Orchestrator

| Agent | File | Purpose |
|-------|------|---------|
| **Bolt Framework** | `bolt-framework.agent.md` | Main orchestrator using AURORA methodology |
```

---

## 📋 FASE 7: Validación y Testing

> 📊 **Progreso**: ⬜ No iniciado | Tests: 0/10 completados

### Tests Funcionales

**Test 1: Skill Loading**
- Acción: Preguntar sobre AURORA
- Esperado: Copilot lee SKILL.md
- Validación: Referencias al skill

**Test 2: Routing**
- Acción: Pedir crear feature
- Esperado: Bolt Framework → Aurora Feature
- Validación: Handoff correcto

**Test 3: Tools Funcionan**
- Acción: Buscar en awesome-copilot
- Esperado: Encuentra collections
- Validación: MCP tools activas

**Test 4: MCP Integration**
- Acción: Aurora Constitution crea constitution
- Esperado: Usa awesome-copilot para ejemplos
- Validación: Constitution basada en ejemplos

### Test 5: Init Workspace**
- Acción: Bolt Framework init workspace
- Esperado: Usa awesome-copilot para templates
- Validación: Agents/prompts/skills copiados

**Test 6: Skill Auto-Discovery**
- Acción: Verificar que el skill se carga sin tag `<skill>`
- Esperado: Copilot auto-descubre bolt-framework desde `.github/skills/`
- Validación: Slash command `/bolt-framework` disponible

**Test 7: Agent New Properties**
- Acción: Verificar frontmatter de bolt-framework.agent.md
- Esperado: `agents: ['*']`, `user-invokable: true`, `model` array
- Validación: Propiedades reconocidas por VS Code

**Test 8: SKILL.md Frontmatter**
- Acción: Verificar YAML frontmatter en SKILL.md
- Esperado: `name: bolt-framework`, `description` con "when to use"
- Validación: Skill reconocido por VS Code

**Test 9: Handoff Matrix**
- Acción: Verificar que no hay self-handoffs ni circulares
- Esperado: Todos los handoffs siguen HANDOFF-MATRIX.md
- Validación: No hay anti-patterns

**Test 10: Content Reduction**
- Acción: Verificar líneas por agente post-refactoring
- Esperado: Promedio ≤ 140 líneas, sin duplicación de metodología
- Validación: Métricas cumplen objetivos

---

## ✅ Checklist de Implementación

### Skill
- [ ] SKILL.md creado (~500 líneas metodología)
- [ ] TOOLSETS.md con tools correctas + MCP
- [ ] HANDOFF-MATRIX.md validaciones
- [ ] Examples creados (3 workflows)
- [ ] Templates creados (3 templates)

### Agente Principal
- [ ] aurora.agent.md → bolt-framework.agent.md
- [ ] Frontmatter con tools correctas
- [ ] Contenido reducido (-73%)
- [ ] Handoffs validados

### Agentes Especializados (30)
- [ ] Tools correctas según toolset
- [ ] MCP tools incluidas donde corresponde
- [ ] Handoffs validados
- [ ] Metodología eliminada
- [ ] Contenido específico mantenido
- [ ] Promedio -50% reducción

### Prompt y Referencias
- [ ] aurora.prompt.md simplificado (-86%)
- [ ] Skill registrado en copilot-instructions.md
- [ ] README.md actualizado
- [ ] .github/agents/README.md actualizado

### Testing
- [ ] Skill loading funciona
- [ ] Routing correcto
- [ ] Tools correctas
- [ ] MCP tools accesibles
- [ ] awesome-copilot funciona
- [ ] context7 funciona
- [ ] microsoftdocs funciona

---

## 📊 Impacto Esperado

### Métricas

| Métrica | Antes | Después | Cambio |
|---------|-------|---------|--------|
| Líneas bolt-framework | 296 | ~80 | **-73%** |
| Líneas aurora.prompt | 108 | ~15 | **-86%** |
| Promedio/agente | ~280 | ~140 | **-50%** |
| Total agentes (30) | ~8400 | ~4800 | **-43%** |
| Líneas skill | 0 | ~500 | +500 |
| Fuentes verdad | 4+ | 1 | **-75%** |
| **Total documentación** | ~8228 | ~5655 | **-31%** |

### Beneficios

1. **⬆️⬆️⬆️ Mantenibilidad** - Un solo archivo para metodología
2. **⬆️⬆️⬆️ Consistencia** - Todos usan mismo skill
3. **⬆️⬆️⬆️ MCP Integration** - context7 + awesome-copilot críticos
4. **⬆️⬆️ Reutilización** - Skill usable por nuevos agentes
5. **⬆️⬆️ Claridad** - Agentes enfocados en su tarea
6. **⬆️⬆️ Extensibilidad** - Fácil agregar agentes
7. **⬆️ Validación** - Handoff matrix previene errores

### Casos de Uso Mejorados

**Crear Constitution**:
1. Aurora Constitution busca ejemplos en awesome-copilot
2. Investiga tech stacks con context7
3. Verifica Microsoft guidelines con microsoftdocs
4. Genera constitution personalizada

**Init Workspace**:
1. Bolt Framework busca templates en awesome-copilot
2. Copia agentes/prompts/skills desde collections
3. Adapta según tech stack elegido
4. Ejecuta init script

**Implementar Feature**:
1. Aurora Implement consulta docs con context7
2. Busca ejemplos de código con microsoftdocs
3. Verifica patterns con awesome-copilot
4. Genera código siguiendo constitution

---

## 🎯 Orden de Ejecución Recomendado

1. **FASE 1** - Crear infraestructura skill (base fundamental)
2. **FASE 2** - Actualizar agente principal (orchestrator)
3. **FASE 5** - Actualizar copilot-instructions.md (auto-discovery, sin tags `<skill>`)
4. **FASE 3** - Actualizar agentes especializados (30 agentes, batch)
5. **FASE 4** - Simplificar prompt
6. **FASE 6** - Actualizar referencias
7. **FASE 7** - Testing y validación

---

## 📝 Notas Importantes

### Tools Correctas de VS Code

**NUNCA usar**:
- ❌ `'vscode'` - No existe
- ❌ `'execute'` - Usar `'runInTerminal'` o `'runCommands'`
- ❌ `'read'` - Usar `'readFile'`
- ❌ `'edit'` (individual) - Usar tool set `'edit'` o `'editFiles'`
- ❌ `'web'` - Usar `'fetch'`
- ❌ `'agent'` - Usar `'runSubagent'`
- ❌ `'todo'` - Usar `'todos'`

**SIEMPRE usar**:
- ✅ Tool sets: `'edit'`, `'search'`, `'runCommands'`, `'runTasks'`, `'runNotebooks'`
- ✅ Tools individuales: `'readFile'`, `'editFiles'`, `'createFile'`, `'runInTerminal'`, etc.
- ✅ MCP wildcards: `'context7/*'`, `'awesome-copilot/*'`, `'microsoftdocs/*'`

### MCP Tools Críticas

**context7** - SIEMPRE incluir para:
- Agentes que implementan código
- Agentes que crean specs técnicas
- Agentes que necesitan docs actualizadas

**awesome-copilot** - CRÍTICO para:
- 🌟🌟🌟 Bolt Framework (Init Workspace)
- 🌟 Aurora Constitution
- 🌟🌟 Aurora Templates
- Cualquier agente que necesite ejemplos

**microsoftdocs** - Incluir para:
- Stacks Microsoft (.NET, C#, Azure)
- Ops y deployments Azure
- Security best practices Microsoft

### Handoffs

**Validar SIEMPRE**:
- ❌ No self-handoffs
- ❌ No circulares
- ❌ No duplicados
- ✅ Seguir handoff matrix
- ✅ Respetar lifecycle phases

---

## 🚀 Próximos Pasos

Una vez ejecutado el plan:

1. Probar init workflow completo
2. Validar que awesome-copilot proporciona templates
3. Verificar constitution usa ejemplos
4. Confirmar todos los agentes funcionan
5. Documentar nuevos workflows
6. Crear guías de uso

**¿Listo para ejecutar?**

---

## 📋 Resumen de Correcciones v2.0

| # | Corrección | Área | Descripción |
|---|-----------|------|-------------|
| 1 | **Tools faltantes** | Toolsets | +5 tools: `terminalLastCommand`, `testFailure`, `searchResults`, `getTaskOutput`, `runTasks` (tool set) |
| 2 | **Propiedades de agente** | Phase 2, 3 | Nuevos: `agents`, `user-invokable`, `disable-model-invocation`, `handoffs.model`, `model` array |
| 3 | **SKILL.md frontmatter** | Phase 1 | YAML frontmatter REQUERIDO: `name` (max 64 chars) + `description` (max 1024 chars) |
| 4 | **Skills auto-discovery** | Phase 5 | NO `<skill>` tags — auto-descubrimiento desde `.github/skills/<name>/SKILL.md` |
| 5 | **Conteo de agentes** | Global | 30 agentes (no 29) — incluye `aurora-docs` |
| 6 | **Nombre de archivo** | Ya correcto | `.agent.md` es correcto (antes `.chatmode.md`, renombrado en Feb 2026) |
| 7 | **handoffs.model** | Phase 2 | Override de modelo por handoff disponible |

---

## 📚 Referencia Rápida: Tools Válidas de VS Code (Feb 2026)

> Fuente: [Chat Tools Reference](https://code.visualstudio.com/docs/copilot/reference/copilot-vscode-features#_chat-tools)

### 38 Tools Individuales

| Tool | Descripción |
|------|-------------|
| `changes` | Git changes |
| `codebase` | Semantic code search |
| `createAndRunTask` | Create and run VS Code task |
| `createDirectory` | Create directory |
| `createFile` | Create new file |
| `editFiles` | Apply file edits |
| `editNotebook` | Edit notebook |
| `extensions` | VS Code extensions |
| `fetch` | Web content retrieval |
| `fileSearch` | File search by pattern |
| `getNotebookSummary` | Notebook summary |
| `getProjectSetupInfo` | Project setup info |
| `getTaskOutput` | Task execution output |
| `getTerminalOutput` | Terminal output |
| `githubRepo` | GitHub repos |
| `installExtension` | Install extension |
| `listDirectory` | List directory |
| `newJupyterNotebook` | Create notebook |
| `newWorkspace` | Create workspace |
| `openSimpleBrowser` | Open browser |
| `problems` | Problems panel |
| `readFile` | Read file contents |
| `readNotebookCellOutput` | Read notebook cell |
| `runCell` | Run notebook cell |
| `runInTerminal` | Execute terminal command |
| `runSubagent` | Delegate to subagent |
| `runTask` | Run VS Code task |
| `runTests` | Run test suite |
| `runVscodeCommand` | Execute VS Code command |
| `searchResults` | Search view results |
| `selection` | Current selection |
| `terminalLastCommand` | Last terminal command |
| `terminalSelection` | Terminal selection |
| `testFailure` | Test failure details |
| `textSearch` | Text search in files |
| `todos` | Track TODOs |
| `usages` | Find references |
| `VSCodeAPI` | VS Code API access |

### 5 Tool Sets

| Tool Set | Includes |
|----------|----------|
| `edit` | `createFile`, `editFiles`, `createDirectory` |
| `search` | `fileSearch`, `textSearch` |
| `runCommands` | `runInTerminal`, `getTerminalOutput` |
| `runTasks` | `runTask`, `getTaskOutput`, `createAndRunTask` |
| `runNotebooks` | `runCell`, `editNotebook`, `readNotebookCellOutput`, `getNotebookSummary`, `newJupyterNotebook` |

### 3 MCP Servers

| MCP Server | Wildcard | Tools |
|------------|----------|-------|
| Context7 | `context7/*` | `query-docs`, `resolve-library-id` |
| Awesome Copilot | `awesome-copilot/*` | `list_collections`, `load_collection`, `load_instruction`, `search_instructions` |
| Microsoft Docs | `microsoftdocs/*` | `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search` |

---

## 📚 Referencia: Formato Agent (.agent.md)

> Fuente: [Custom Agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)

```yaml
---
name: Agent Name                    # Display name
description: Description text       # Short description
tools:                              # Available tools
  - toolName
  - mcp-server/*                    # MCP wildcard
agents:                             # ⚡NEW - Subagent control
  - '*'                             # Allow all
  - 'Specific Agent'                # Or specific ones
user-invokable: true                # ⚡NEW - User can invoke directly
disable-model-invocation: false     # ⚡NEW - LLM can invoke
model:                              # Supports array for fallback
  - Claude Sonnet 4.5
  - copilot-chat
handoffs:
  - label: 🏷️ Action Label
    agent: Target Agent
    prompt: Context for handoff
    model: Override Model            # ⚡NEW - Per-handoff model
    send: false
---
```

---

## 📚 Referencia: Formato SKILL.md

> Fuente: [Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills) + [agentskills.io](https://agentskills.io)

```yaml
---
name: skill-name                    # lowercase-hyphen, max 64 chars
description: >                      # max 1024 chars, include "when to use"
  Description of the skill.
  Use when doing X, Y, or Z.
---
```

**Reglas**:
- Auto-discovery desde `.github/skills/<name>/SKILL.md`
- Invocable como slash command: `/skill-name`
- NO necesita registro `<skill>` en copilot-instructions.md
- Progressive disclosure: 3 niveles (discovery → instructions → resources)
- `SKILL.md` es REQUERIDO, `examples/` y `templates/` son opcionales
