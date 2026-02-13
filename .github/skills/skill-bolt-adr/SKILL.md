---
name: skill-bolt-adr
description: Create and manage Architecture Decision Records (ADRs) using MADR format. Defines ADR structure, workflow, categories, and best practices for documenting architectural decisions. Use when documenting technology selections, architecture patterns, design decisions, or significant technical choices that impact the project.
---

# Architecture Decision Records (ADR) - MADR Format

## Descripción

Guía completa para crear y gestionar Architecture Decision Records (ADRs) usando el formato MADR (Markdown Architecture Decision Records). Los ADRs capturan decisiones arquitectónicas importantes junto con su contexto, alternativas consideradas, y consecuencias.

## Cuándo Usar Este Skill

- Cuando necesitas documentar una decisión arquitectónica importante
- Al seleccionar tecnologías, frameworks, o librerías principales
- Para decisiones sobre patrones arquitectónicos (microservices, monolith, CQRS, etc.)
- Al elegir entre alternativas técnicas con impacto significativo
- Cuando una decisión afecta la estructura del sistema a largo plazo
- Para documentar el "por qué" de elecciones técnicas críticas

## Convenciones de Formato

### Diagramas: Preferencia por Mermaid

**IMPORTANTE:** Para todos los diagramas en ADRs, usar **Mermaid** en lugar de ASCII art.

Revisa el formato en [MADR Format](https://adr.github.io/madr/)

**Ventajas de Mermaid:**

- ✅ Renderizado automático en GitHub/Markdown viewers
- ✅ Fácil de modificar y mantener
- ✅ Sintaxis declarativa y legible
- ✅ Múltiples tipos: flowchart, sequence, class, ERD, etc.

**Ejemplo de diagrama de arquitectura:**

Ver [examples/diagram-architecture-basic.md](examples/diagram-architecture-basic.md) para un ejemplo completo de arquitectura básica.

**Tipos de diagramas Mermaid útiles para ADRs:**

- **Flowchart** (`graph TB`): Flujos de decisión, arquitectura de componentes
- **Sequence** (`sequenceDiagram`): Interacciones entre sistemas
- **Class** (`classDiagram`): Modelos de datos, estructuras
- **C4** (`C4Context`): Arquitectura C4 (Context, Container, Component)

**Ejemplos según tipo de decisión:**

1. **Decisión de Arquitectura** - Usar flowchart:
   - Ver [examples/diagram-architecture-comparison.md](examples/diagram-architecture-comparison.md)

2. **Decisión de Integración** - Usar sequence diagram:
   - Ver [examples/diagram-integration-sequence.md](examples/diagram-integration-sequence.md)

3. **Decisión de Modelo de Datos** - Usar ER diagram:
   - Ver [examples/diagram-data-model.md](examples/diagram-data-model.md)

## Instrucciones

### Requisitos Previos

- [ ] Verificar que la decisión requiere un ADR (ver tabla "¿Necesita ADR?")
- [ ] Leer `memory/constitution.md` para validar constraints existentes
- [ ] Identificar el problema o necesidad que motiva la decisión
- [ ] Listar al menos 2-3 alternativas a considerar

### ¿Necesita un ADR?

| Escenario                      | Ejemplo                                | ADR Requerido              |
| ------------------------------ | -------------------------------------- | -------------------------- |
| Framework/biblioteca principal | React vs Vue, Django vs FastAPI        | ✅ SIEMPRE                 |
| Base de datos                  | PostgreSQL vs MongoDB                  | ✅ SIEMPRE                 |
| Patrón arquitectónico          | Microservices vs Monolith, CQRS        | ✅ SIEMPRE                 |
| Estilo de API                  | REST vs GraphQL vs gRPC                | ✅ SIEMPRE                 |
| Infraestructura                | AWS vs Azure, Kubernetes vs Serverless | ✅ SIEMPRE                 |
| Biblioteca secundaria          | Axios vs Fetch, Lodash vs Ramda        | ⚠️ DEPENDE                 |
| Convención de código           | Tabs vs Spaces, naming conventions     | ❌ NO (va en constitution) |
| Herramienta de desarrollo      | VSCode extensions, linters             | ❌ NO (va en constitution) |

### Proceso Paso a Paso

#### 1. Determinar Número y Nombre del ADR

**Convención de nombres:**

```
docs/adr/ADR-NNNN-title-in-kebab-case.md
```

**Encontrar siguiente número:**

Usar el script apropiado según tu sistema operativo:

**Linux / macOS / WSL:**

```bash
NUM=$(.github/skills/skill-bolt-adr/scripts/get-next-adr-number.sh)
echo "Next ADR: ADR-$NUM"
```

**Windows (PowerShell):**

```powershell
$Num = .\.github\skills\skill-bolt-adr\scripts\Get-NextAdrNumber.ps1
Write-Host "Next ADR: ADR-$Num"
```

**Detección automática del sistema:**

```bash
# Para scripts que necesitan detectar el OS automáticamente
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash)
    NUM=$(powershell.exe -File .github/skills/skill-bolt-adr/scripts/Get-NextAdrNumber.ps1)
else
    # Linux / macOS / WSL
    NUM=$(.github/skills/skill-bolt-adr/scripts/get-next-adr-number.sh)
fi
```

**Scripts disponibles:**

- **Bash**: `.github/skills/skill-bolt-adr/scripts/get-next-adr-number.sh`
- **PowerShell**: `.github/skills/skill-bolt-adr/scripts/Get-NextAdrNumber.ps1`

**Ejemplo:** `docs/adr/ADR-0005-adopt-postgresql-for-user-service.md`

#### 2. Usar Plantilla MADR

Selecciona la plantilla apropiada según el contexto:

| Plantilla           | Cuándo Usar                                  |
| ------------------- | -------------------------------------------- |
| `madr-standard.md`  | Decisiones técnicas generales                |
| `madr-business.md`  | Decisiones con fuerte impacto de negocio     |
| `madr-technical.md` | Decisiones puramente técnicas/implementación |

**Ubicación plantillas:** `.github/skills/skill-architect/templates/`

#### 3. Completar Secciones del ADR

##### Sección: Status

```markdown
## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXXX]
```

**Estados:**

- **Proposed**: En discusión, no implementado
- **Accepted**: Aprobado e implementándose/implementado
- **Deprecated**: Ya no aplicable, pero no reemplazado
- **Superseded by ADR-XXXX**: Reemplazado por otra decisión

##### Sección: Context

```markdown
## Context

### Background

[Historia: ¿Qué nos llevó aquí? ¿Cuál es la situación actual?]

### Problem Statement

[Problema específico: ¿Qué necesitamos resolver?]

### Forces

[Factores que influyen en la decisión:]

- **Performance**: [Requisito de performance]
- **Team Expertise**: [Conocimiento del equipo]
- **Cost**: [Restricciones de costo]
- **Time to Market**: [Urgencia]
- **Maintainability**: [Mantenibilidad a largo plazo]
```

**Ejemplo:**

```markdown
## Context

### Background

Our monolithic application handles 10M users but deployment takes 45 minutes.
As we grow to 50M users, we need better scalability and faster releases.

### Problem Statement

How do we architect the system to support 50M users with deployment time < 5 minutes
while maintaining team productivity?

### Forces

- **Scale**: Must handle 5x current load
- **Team Size**: 8 developers (can't split into many teams)
- **Expertise**: Strong in Node.js, minimal DevOps experience
- **Budget**: $50K/month infrastructure budget
- **Timeline**: 6 months to implement
```

##### Sección: Decision Drivers

```markdown
## Decision Drivers

- [Driver 1]: [Descripción y por qué es importante]
- [Driver 2]: [Descripción]
- [Driver 3]: [Descripción]
```

**Clasificar por prioridad:**

- **Must Have**: Requisitos críticos, no negociables
- **Should Have**: Muy importantes, pero algo de flexibilidad
- **Could Have**: Deseables pero no críticos

**Ejemplo:**

```markdown
## Decision Drivers

- **MUST: Handle 50M users** - Business requirement for growth
- **MUST: < $50K/month cost** - Budget constraint
- **SHOULD: < 5 min deployment** - Developer productivity
- **SHOULD: Minimal learning curve** - Team constraint
- **COULD: Multi-region support** - Future expansion
```

##### Sección: Considered Options

```markdown
## Considered Options

1. [Option 1]: [Brief description]
2. [Option 2]: [Brief description]
3. [Option 3]: [Brief description]
```

**Mínimo 2 opciones, ideal 3-4.**

##### Sección: Decision Outcome

```markdown
## Decision Outcome

Chosen option: "[Option Name]", because [2-3 sentence justification].

### Positive Consequences

- [Benefit 1]
- [Benefit 2]
- [Benefit 3]

### Negative Consequences

- [Tradeoff 1]
- [Tradeoff 2]
```

**Importante:** Ser honesto sobre consecuencias negativas.

##### Sección: Pros and Cons of the Options

Para **cada opción** considerada:

```markdown
### [Option Name]

[1-2 párrafos describiendo la opción]

**Pros:**

- ✅ Good, because [argument a]
- ✅ Good, because [argument b]

**Cons:**

- ❌ Bad, because [argument c]
- ❌ Bad, because [argument d]

**Why not chosen:** [1-2 sentences] (solo si no fue elegida)
```

#### 4. Validar Compliance con Constitution

**CRÍTICO:** Todo ADR debe validarse contra `memory/constitution.md`

```markdown
## Constitution Compliance

Per `memory/constitution.md`:

- [x] Tech Stack: [PostgreSQL está en la lista aprobada]
- [x] Security: [Cumple requisito de encriptación at-rest]
- [x] Architecture: [Compatible con Clean Architecture principle]
- [ ] Cost: [Verificar si excede presupuesto definido]
```

**Si el ADR viola la constitution:**

- Opción A: Actualizar la constitution (crear ADR para eso también)
- Opción B: Elegir opción compatible

#### 5. Categorizar el ADR

| Categoría      | Prefijo | Ejemplos                                  |
| -------------- | ------- | ----------------------------------------- |
| Architecture   | ARCH    | Patrones, capas, separación de concerns   |
| Technology     | TECH    | Frameworks, librerías, lenguajes          |
| Data           | DATA    | Bases de datos, formatos, schemas         |
| Security       | SEC     | Autenticación, autorización, encriptación |
| Integration    | INT     | APIs, protocolos, mensajería              |
| Infrastructure | INFRA   | Hosting, CI/CD, contenedores              |

**Agregar tag en el título:**

```markdown
# ADR-0005: [DATA] Adopt PostgreSQL for User Service
```

#### 6. Crear/Actualizar Índice de ADRs

Mantener `docs/adr/README.md` actualizado:

```markdown
# Architecture Decision Records

## Index

| ID                                      | Title              | Status   | Category | Date       |
| --------------------------------------- | ------------------ | -------- | -------- | ---------- |
| [0001](ADR-0001-clean-architecture.md)  | Clean Architecture | Accepted | ARCH     | 2024-01-15 |
| [0002](ADR-0002-typescript-frontend.md) | TypeScript         | Accepted | TECH     | 2024-01-16 |
| [0003](ADR-0003-postgresql-users.md)    | PostgreSQL         | Accepted | DATA     | 2024-01-17 |

## By Category

### ARCH - Architecture

- [ADR-0001](ADR-0001-clean-architecture.md) - Clean Architecture Pattern

### TECH - Technology

- [ADR-0002](ADR-0002-typescript-frontend.md) - Adopt TypeScript

### DATA - Data

- [ADR-0003](ADR-0003-postgresql-users.md) - PostgreSQL for Users
```

#### 7. Workflow de Review y Aprobación

El siguiente diagrama muestra el flujo completo desde la creación hasta el mantenimiento de un ADR:

**Ver:** [examples/diagram-workflow-adr.md](examples/diagram-workflow-adr.md)

**Review Checklist:**

- [ ] Problema claramente definido
- [ ] Al menos 2-3 alternativas evaluadas
- [ ] Pros y cons honestos para cada opción
- [ ] Justificación clara de elección
- [ ] Consecuencias negativas documentadas
- [ ] Validado contra constitution
- [ ] Referencias incluidas
- [ ] Stakeholders consultados

### Mejores Prácticas

#### Práctica 1: Documenta el "Por Qué", No el "Qué"

**Por qué:** El código muestra QUÉ hiciste, el ADR explica POR QUÉ.

**Cómo:**

- ✅ "Elegimos PostgreSQL porque necesitamos ACID para transacciones financieras"
- ❌ "Elegimos PostgreSQL porque es bueno"

**Ejemplo:**

```markdown
## Decision Outcome

Chosen option: "PostgreSQL", because:

1. Financial transactions require ACID compliance (MySQL MyISAM doesn't provide this)
2. Complex joins needed for reporting (MongoDB would require application-level joins)
3. Team has 5 years PostgreSQL experience (learning curve = 0)
4. JSONB support allows schema flexibility where needed
```

#### Práctica 2: Sé Honesto sobre Tradeoffs

**Por qué:** Toda decisión tiene costos. Documentarlos evita sorpresas futuras.

**Cómo:** Siempre incluir consecuencias negativas reales.

**Ejemplo:**

```markdown
### Negative Consequences

- ❌ PostgreSQL hosting costs $200/month more than MySQL
- ❌ Requires PostgreSQL expertise for query optimization
- ❌ Initial setup more complex than SQLite
- ❌ Connection pooling needed for high concurrency
```

#### Práctica 3: Usa Datos, No Opiniones

**Por qué:** Decisiones basadas en evidencia son defendibles.

**Cómo:** Incluye benchmarks, comparaciones, experiencias previas.

**Malo:**

```markdown
MongoDB is faster than PostgreSQL.
```

**Bueno:**

```markdown
Based on our load testing:

- PostgreSQL: 2,500 reads/sec, 800 writes/sec
- MongoDB: 3,200 reads/sec, 1,200 writes/sec

However, our app is read-heavy (95% reads) and PostgreSQL's
stronger consistency guarantees outweigh the 28% read speed advantage.
```

#### Práctica 4: Relaciona ADRs Entre Sí

**Por qué:** Las decisiones no existen en vacío.

**Cómo:** Usa sección `## Links` para conectar ADRs relacionados.

**Ejemplo:**

```markdown
## Links

- Relates to [ADR-0001: Clean Architecture](ADR-0001-clean-architecture.md)
  - PostgreSQL será usado en el Data Layer
- Supersedes [ADR-0003: Use SQLite](ADR-0003-use-sqlite.md)
  - SQLite no escala a 50M users
- Informs [ADR-0006: Caching Strategy](ADR-0006-caching-strategy.md)
  - PostgreSQL performance influye en necesidad de cache
```

#### Práctica 5: Actualiza ADRs Cuando el Contexto Cambia

**Por qué:** Las circunstancias evolucionan.

**Cómo:**

- Si una decisión se revierte → Status: "Superseded by ADR-XXXX"
- Si se descubren problemas → Añadir "## Update [Date]"
- Si cambian assumptions → Documentar en "## Notes"

**Ejemplo:**

```markdown
## Status

~~Accepted~~ **Superseded by ADR-0012**

## Update 2026-08-15

After 6 months in production, PostgreSQL costs exceeded budget by 3x
due to unexpected query complexity. See ADR-0012 for migration to ScyllaDB.
```

#### Práctica 6: Usa Diagramas Mermaid para Claridad Visual

**Por qué:** Un diagrama vale más que mil palabras. Mermaid hace diagramas mantenibles y versionables.

**Cómo:** Incluir diagramas que muestren:

- Arquitectura antes/después de la decisión
- Flujos de interacción entre componentes
- Modelos de datos o estructuras

**Ejemplo - Comparación de opciones:**

Para un ejemplo completo de cómo comparar arquitecturas (Monolito vs Microservicios) con diagramas Mermaid y análisis de pros/cons, ver:

**→** [examples/diagram-architecture-comparison.md](examples/diagram-architecture-comparison.md)

````

**Tipos de diagramas por tipo de decisión:**

| Tipo de Decisión | Diagrama Recomendado | Ejemplo |
|------------------|---------------------|---------|
| **Arquitectura de sistema** | Flowchart (`graph TB`) | Capas, componentes, flujo de datos |
| **Integración entre servicios** | Sequence Diagram | Llamadas API, flujo de mensajes |
| **Modelo de datos** | ER Diagram / Class Diagram | Entidades, relaciones, schemas |
| **Proceso de deployment** | Flowchart (`graph LR`) | Pipeline CI/CD, pasos de release |
| **Decisión de infraestructura** | C4 Diagram | Contexto, contenedores, componentes |

### Errores Comunes

#### Error 1: ADR Demasiado Corto

**Problema:**

```markdown
# ADR-0005: Use PostgreSQL

We chose PostgreSQL because it's good for our use case.
````

**Solución:**

```markdown
# ADR-0005: [DATA] Adopt PostgreSQL for User Service

## Context

Our user service currently uses an in-memory store (Redis).
We need persistence, ACID transactions, and complex queries.

## Decision Drivers

- ACID compliance for financial data
- Complex relational queries
- Team PostgreSQL expertise

## Considered Options

1. PostgreSQL - Relational, ACID
2. MongoDB - Document, flexible schema
3. MySQL - Relational, popular

## Decision Outcome

Chosen option: "PostgreSQL", because ACID compliance is
critical for financial transactions and team has expertise.

[... resto de secciones ...]
```

#### Error 2: No Documentar Alternativas

**Problema:**

```markdown
## Decision Outcome

We chose PostgreSQL.
```

**Solución:**

```markdown
## Considered Options

1. PostgreSQL
2. MongoDB
3. MySQL

## Pros and Cons of the Options

### PostgreSQL

- ✅ ACID compliance
- ✅ Team expertise
- ❌ More expensive

### MongoDB

- ✅ Flexible schema
- ❌ No ACID transactions
- ❌ Learning curve

### MySQL

- ✅ Cheaper hosting
- ❌ Team unfamiliar
- ❌ Less advanced features
```

#### Error 3: Ignorar Constitution

**Problema:**
Crear ADR para usar Python cuando constitution especifica "TypeScript/Node.js only"

**Solución:**

```markdown
## Constitution Compliance

⚠️ **CONFLICT DETECTED**

Per `memory/constitution.md`:

- Tech Stack: "TypeScript/Node.js only"

**Resolution Options:**

1. **Update Constitution** - If Python is justified, create ADR to modify constitution
2. **Choose Compliant Option** - Select Node.js instead
3. **Create Exception** - Document specific exception with approval

**Chosen:** Option 2 - Use Node.js with TypeScript
```

#### Error 4: Status Incorrecto

**Problema:**

```markdown
## Status

Accepted

[... pero el ADR fue creado hace 5 minutos y nadie lo revisó ...]
```

**Solución:**

```markdown
## Status

Proposed

## Review Process

- [ ] Technical Lead review
- [ ] Team discussion (scheduled 2026-02-20)
- [ ] Approval by Engineering Manager

Will change to "Accepted" after team approval.
```

## Scripts de Automatización

Los siguientes scripts automatizan la creación de ADRs:

### Bash Script

**Ubicación:** `.aurora/scripts/bash/create-adr.sh`

```bash
./create-adr.sh "database-selection"
```

**Características:**

- Auto-incrementa número de ADR
- Crea archivo con plantilla MADR
- Actualiza índice `docs/adr/README.md`
- Valida contra `memory/constitution.md`

### PowerShell Script

**Ubicación:** `.aurora/scripts/powershell/Create-ADR.ps1`

```powershell
.\Create-ADR.ps1 -Title "database-selection"
```

**Características:**

- Equivalente al script bash
- Compatible con Windows
- Mismo formato y validaciones

## Plantillas Disponibles

### 1. MADR Standard (`templates/madr-standard.md`)

**Cuándo usar:** Decisiones técnicas generales

**Características:**

- Formato MADR completo
- Balance entre contexto técnico y de negocio
- Secciones completas de pros/cons

### 2. MADR Business (`templates/madr-business.md`)

**Cuándo usar:** Decisiones con fuerte impacto de negocio

**Características:**

- Decision drivers enfocados en negocio
- Sección de stakeholders
- Matriz de decisión con scoring
- Timeline y milestones

### 3. MADR Technical (`templates/madr-technical.md`)

**Cuándo usar:** Decisiones puramente técnicas

**Características:**

- Enfoque en detalles de implementación
- Code snippets y ejemplos técnicos
- Performance benchmarks
- Compliance checklist técnico

## Ejemplos

Ver ejemplos completos en:

- `examples/adr-typescript-adoption.md` - Decisión de tecnología
- `examples/adr-database-selection.md` - Decisión de infraestructura
- `examples/adr-architecture-pattern.md` - Decisión arquitectónica

## Referencias

### Documentación MADR

- [MADR Website](https://adr.github.io/madr/) - Formato oficial
- [ADR GitHub Organization](https://adr.github.io/) - Recursos y herramientas
- [Documenting Architecture Decisions](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) - Artículo original de Michael Nygard

### Integración Bolt Framework

- Skill relacionado: `bolt-framework` - Lifecycle y quality gates
- Skill relacionado: `new-skill` - Crear skills personalizados
- Agent: `@Bolt ADR` - Automatizar creación de ADRs
- Agent: `@Aurora Architect` - Consultoría arquitectónica

### Herramientas

- [adr-tools](https://github.com/npryce/adr-tools) - CLI para gestión de ADRs
- [log4brains](https://github.com/thomvaill/log4brains) - ADR management con UI

## Changelog

- 2026-02-13: Versión inicial del skill
- Consolidado desde bolt-adr.agent.md
- Templates migrados de múltiples ubicaciones
- Scripts bash/PowerShell documentados
