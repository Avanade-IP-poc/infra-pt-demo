# Propuesta: Sistema de Autoconfiguración Inteligente de Skills

**Fecha**: 2026-02-25
**Estado**: Propuesta
**Autor**: @Bolt Researcher
**Versión**: 1.0.0

## 🎯 Resumen Ejecutivo

Esta propuesta define un sistema de autoconfiguración inteligente para Bolt Framework que provisiona automáticamente skills, prompts, agents e instructions basándose en el **scope**, **tech stack** y **propósito del proyecto** al finalizar la fase de constitución.

**Problema Actual**:

- ❌ Skills se copian mediante flag manual `enabled: true` en scope.yaml
- ❌ No hay lógica condicional basada en tech stack (C# vs Node.js vs Python)
- ❌ Mapeo hardcodeado en descripciones de agentes (@Bolt Provisioner)
- ❌ Desarrolladores deben conocer qué skills son relevantes para su stack

**Solución Propuesta**:

- ✅ Reglas declarativas JSONLogic en cada item del scope.yaml
- ✅ Evaluación polyglot (PowerShell + Node.js)
- ✅ Auto-selección inteligente según constitution + scopes.yaml
- ✅ Extensible mediante custom operators y plugins

## 📊 Análisis de Investigación

### Tecnologías Evaluadas

| Solución               | Complejidad | Polyglot         | Extensibilidad | Soporte PowerShell | Puntuación |
| ---------------------- | ----------- | ---------------- | -------------- | ------------------ | ---------- |
| **JSONLogic** ⭐       | Baja        | ✅ 10+ lenguajes | Media          | ✅ json-everything | **9/10**   |
| JSON Rules Engine      | Media       | ❌ Node.js       | Alta           | ❌                 | 6/10       |
| TypeScript Rule Engine | Media       | ❌ Node.js       | Alta (plugins) | ❌                 | 7/10       |
| JSON Schema + AJV      | Media       | ✅               | Baja           | ✅                 | 5/10       |
| YAML Híbrido           | Muy Baja    | ✅ Custom        | Alta           | ✅                 | 7/10       |

### Justificación de JSONLogic

**Criterios de Selección**:

1. **Polyglot**: Bolt Framework usa PowerShell (Init.ps1) + Node.js (agents)
2. **Simplicidad**: Sintaxis JSON simple `{"operator": ["values"]}`
3. **Sin eval()**: Seguro por diseño, solo lectura de datos
4. **Serializable**: YAML-friendly, version control compatible
5. **Maduro**: Implementaciones verificadas en .NET, JS, Python, Go, Java, C++

**Implementaciones Disponibles**:

- **.NET/PowerShell**: [json-everything](https://github.com/gregsdennis/json-everything) (JsonLogic.Net)
- **Node.js/TypeScript**: [json-logic-js](https://github.com/jwadhams/json-logic-js)
- **Python**: [json-logic-py](https://github.com/nadirizr/json-logic-py)

## 🏗️ Arquitectura Propuesta

### Flujo de Autoconfiguración

```mermaid
graph TD
    A[Init.ps1] --> B[Genera scopes.yaml]
    B --> C[@Bolt Constitution Phases 1-3]
    C --> D[constitution.md merged]
    D --> E{Auto-Provision Phase}
    E --> F[Cargar hechos facts]
    F --> G[activeScopes, techStack, decisions]
    G --> H[Iterar items en scopes/*.yaml]
    H --> I{Evaluar auto_provision_rule}
    I -->|JSONLogic.apply == true| J[Copiar skill/prompt/instruction]
    I -->|false| K[Saltar item]
    J --> L[provision-report.md]
    K --> L
    L --> M[@Bolt Constitution Phase 4.4 Summary]
```

### Fuentes de Hechos (Facts)

| Hecho                          | Fuente                                       | Ejemplo                                     |
| ------------------------------ | -------------------------------------------- | ------------------------------------------- |
| `activeScopes`                 | `.boltf/scopes.yaml`                         | `["backend", "frontend", "cloud-platform"]` |
| `techStack.backend`            | `scopes.yaml → decisions.backend.language`   | `"csharp"`                                  |
| `techStack.frontend`           | `scopes.yaml → decisions.frontend.framework` | `"react"`                                   |
| `decisions.cicd.iacTool`       | `scopes.yaml → decisions.cicd.iacTool`       | `"bicep"`                                   |
| `projectPurpose`               | `scopes.yaml → practice`                     | `"apps-and-infra"`                          |
| `decisions.quality.strategies` | `scopes.yaml → decisions.quality.strategies` | `["tdd", "bdd"]`                            |

### Schema Extendido para scope.yaml

**Antes (estado actual)**:

```yaml
items:
  - id: backend-tdd-xunit
    kind: skills
    enabled: true # ← Manual, no condicional
    tags: ['testing', 'csharp']
    source:
      type: local_file
      path: available-skills/dotnet-backend/tdd-xunit
    destination:
      folder: .github/skills
      name: tdd-xunit
```

**Después (propuesta)**:

```yaml
items:
  - id: backend-tdd-xunit
    kind: skills
    enabled: true
    auto_provision_rule: # ← NUEVO: Regla JSONLogic
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
    tags: ['testing', 'csharp']
    source:
      type: local_file
      path: available-skills/dotnet-backend/tdd-xunit
    destination:
      folder: .github/skills
      name: tdd-xunit
```

## 💻 Implementación Técnica

### Fase 1: PowerShell Evaluator

**Dependencia**: [JsonLogic.Net](https://github.com/gregsdennis/json-everything) (parte de json-everything)

**Instalación**:

```powershell
# En Invoke-BoltSetupConstitution.ps1
# Opción A: NuGet package
Install-Package Json.Logic -Scope CurrentUser

# Opción B: Implementación custom para operadores básicos (sin deps)
# Soportar: ==, in, all, any, or, not
```

**Función Evaluadora**:

```powershell
function Test-AutoProvisionRule {
    param(
        [object]$Rule,
        [hashtable]$Facts
    )

    # Si no hay regla, provisionar siempre
    if (-not $Rule) {
        return $true
    }

    try {
        # Opción A: Usar JsonLogic.Net
        $ruleJson = ConvertTo-Json $Rule -Depth 10 -Compress
        $factsJson = ConvertTo-Json $Facts -Depth 10 -Compress
        $result = [JsonLogic]::Apply($ruleJson, $factsJson)
        return [bool]$result
    }
    catch {
        Write-Warning "Error evaluando regla auto_provision_rule: $_"
        Write-Verbose "Regla: $(ConvertTo-Json $Rule -Depth 5)"
        return $false  # Fallar seguro
    }
}
```

**Integración en Provisioning**:

```powershell
# En Invoke-BoltSetupConstitution.ps1

# 1. Cargar hechos desde scopes.yaml + constitution
$scopesYaml = Get-Content ".boltf/scopes.yaml" | ConvertFrom-Yaml
$constitutionContent = Get-Content "memory/constitution.md" -Raw

$facts = @{
    activeScopes = $scopesYaml.scopes
    techStack = @{
        backend = $scopesYaml.decisions.backend.language
        frontend = $scopesYaml.decisions.frontend.framework
    }
    decisions = $scopesYaml.decisions
    projectPurpose = $scopesYaml.practice
}

Write-Info "Facts para evaluación:"
Write-Info "  - activeScopes: $($facts.activeScopes -join ', ')"
Write-Info "  - techStack.backend: $($facts.techStack.backend)"
Write-Info "  - techStack.frontend: $($facts.techStack.frontend)"

# 2. Iterar items de cada scope
foreach ($scopeName in $facts.activeScopes) {
    $scopeYaml = Get-Content ".boltf/scopes/$scopeName/scope.yaml" | ConvertFrom-Yaml

    foreach ($item in $scopeYaml.items) {
        # Evaluar regla
        $shouldProvision = Test-AutoProvisionRule -Rule $item.auto_provision_rule -Facts $facts

        if ($shouldProvision) {
            Write-Success "✓ Provisioning: $($item.id) (regla cumplida)"
            Copy-SkillItem -Item $item
        }
        else {
            Write-Verbose "⊗ Saltando: $($item.id) (regla no cumplida)"
        }
    }
}
```

### Fase 2: Node.js/TypeScript Evaluator (Agente)

**Dependencia**: [json-logic-js](https://github.com/jwadhams/json-logic-js)

**Instalación**:

```bash
npm install json-logic-js
npm install --save-dev @types/json-logic-js
```

**Implementación en @Bolt Provisioner**:

```typescript
import jsonLogic from 'json-logic-js';
import { load as loadYaml } from 'js-yaml';
import { readFileSync } from 'fs';

interface ProvisionFacts {
  activeScopes: string[];
  techStack: {
    backend?: string;
    frontend?: string;
  };
  decisions: Record<string, any>;
  projectPurpose?: string;
}

async function loadFacts(): Promise<ProvisionFacts> {
  const scopesContent = readFileSync('.boltf/scopes.yaml', 'utf8');
  const scopesYaml = loadYaml(scopesContent) as any;

  return {
    activeScopes: scopesYaml.scopes || [],
    techStack: {
      backend: scopesYaml.decisions?.backend?.language,
      frontend: scopesYaml.decisions?.frontend?.framework,
    },
    decisions: scopesYaml.decisions || {},
    projectPurpose: scopesYaml.practice,
  };
}

async function evaluateAutoProvisionRules() {
  const facts = await loadFacts();

  console.log('📊 Facts:', JSON.stringify(facts, null, 2));

  for (const scopeName of facts.activeScopes) {
    const scopePath = `.boltf/scopes/${scopeName}/scope.yaml`;
    const scopeContent = readFileSync(scopePath, 'utf8');
    const scopeYaml = loadYaml(scopeContent) as any;

    for (const item of scopeYaml.items || []) {
      if (!item.auto_provision_rule) {
        // Sin regla = provisionar siempre
        await provisionItem(item);
        continue;
      }

      try {
        const result = jsonLogic.apply(item.auto_provision_rule, facts);

        if (result) {
          console.log(`✓ Provisioning: ${item.id} (rule passed)`);
          await provisionItem(item);
        } else {
          console.log(`⊗ Skipping: ${item.id} (rule failed)`);
        }
      } catch (error) {
        console.error(`Error evaluating rule for ${item.id}:`, error);
      }
    }
  }
}
```

### Fase 3: Biblioteca de Reglas Comunes

**Archivo**: `.boltf/provisioning-rules.yaml`

```yaml
# Biblioteca de reglas reutilizables
rule_templates:
  scope_active:
    description: Check if a scope is active
    rule:
      in: ['{{scope}}', { 'var': 'activeScopes' }]

  tech_stack_matches:
    description: Check if tech stack matches
    rule:
      '==': [{ 'var': 'techStack.{{layer}}' }, '{{technology}}']

  backend_csharp:
    description: Backend is C#/.NET
    rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }

  backend_nodejs:
    description: Backend is Node.js/TypeScript
    rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'nodejs'] }

  frontend_react:
    description: Frontend is React
    rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.frontend' }, 'react'] }

  frontend_angular:
    description: Frontend is Angular
    rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.frontend' }, 'angular'] }

  iac_bicep:
    description: IaC is Bicep
    rule:
      and:
        - { 'in': ['cloud-platform', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'decisions.cicd.iacTool' }, 'bicep'] }

  quality_tdd:
    description: TDD strategy enabled
    rule:
      in: ['tdd', { 'var': 'decisions.quality.strategies' }]
```

**Uso en scope.yaml con referencia**:

```yaml
items:
  - id: backend-tdd-xunit
    kind: skills
    enabled: true
    auto_provision_rule_ref: backend_csharp # ← Referencia a template
    # O inline:
    # auto_provision_rule:
    #   and:
    #     - { "in": ["backend", { "var": "activeScopes" }] }
    #     - { "==": [{ "var": "techStack.backend" }, "csharp"] }
    source:
      type: local_file
      path: available-skills/dotnet-backend/tdd-xunit
    destination:
      folder: .github/skills
      name: tdd-xunit
```

## 📦 Ejemplos de Reglas por Scope

### Backend Scope

```yaml
# .boltf/scopes/backend/scope.yaml
version: 1
scope: backend
description: Backend APIs, services, domain logic

items:
  # C# / .NET Skills
  - id: backend-tdd-xunit
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
    source:
      type: local_file
      path: available-skills/dotnet-backend/tdd-xunit
    destination:
      folder: .github/skills
      name: tdd-xunit

  - id: backend-integration-tests-dotnet
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
        - { 'in': ['integration-testing', { 'var': 'decisions.quality.strategies' }] }
    source:
      type: local_file
      path: available-skills/dotnet-backend/integration-testing
    destination:
      folder: .github/skills
      name: integration-testing

  # Node.js / TypeScript Skills
  - id: backend-jest-tdd
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'nodejs'] }
    source:
      type: local_file
      path: available-skills/testing-must/jest-tdd
    destination:
      folder: .github/skills
      name: jest-tdd

  - id: backend-nestjs-guidelines
    kind: instructions
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'nodejs'] }
        - { '==': [{ 'var': 'decisions.backend.framework' }, 'nestjs'] }
    source:
      type: awesome_copilot
      collection: nodejs-backend-development
      item_path: instructions/nestjs-best-practices.instructions.md
    destination:
      folder: .github/instructions
      name: nestjs-best-practices.instructions.md
```

### Frontend Scope

```yaml
# .boltf/scopes/frontend/scope.yaml
version: 1
scope: frontend
description: Web/mobile UI, SPA, design systems

items:
  # React Skills
  - id: frontend-react-best-practices
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.frontend' }, 'react'] }
    source:
      type: local_file
      path: available-skills/react/react-best-practices
    destination:
      folder: .github/skills
      name: react-best-practices

  # Angular Skills
  - id: frontend-angular-primeng
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.frontend' }, 'angular'] }
        - { 'in': ['primeng', { 'var': 'decisions.frontend.uiLibrary' }] }
    source:
      type: local_file
      path: available-skills/angular/angular-primeng-frontend
    destination:
      folder: .github/skills
      name: angular-primeng-frontend

  # Vue Skills
  - id: frontend-vue-best-practices
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.frontend' }, 'vue'] }
    source:
      type: local_file
      path: available-skills/vue/vue-best-practices
    destination:
      folder: .github/skills
      name: vue-best-practices

  # E2E Testing (común a todos)
  - id: frontend-playwright-e2e
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['frontend', { 'var': 'activeScopes' }] }
        - { 'in': ['e2e-testing', { 'var': 'decisions.quality.strategies' }] }
    source:
      type: local_file
      path: available-skills/ui-common/playwright-skill
    destination:
      folder: .github/skills
      name: playwright-e2e
```

### Cloud Platform Scope

```yaml
# .boltf/scopes/cloud-platform/scope.yaml
version: 1
scope: cloud-platform
description: Infrastructure, Landing Zones, IaC

items:
  # Bicep Skills
  - id: iac-bicep-best-practices
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['cloud-platform', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'decisions.cicd.iacTool' }, 'bicep'] }
    source:
      type: local_file
      path: available-skills/azure/bicep-best-practices
    destination:
      folder: .github/skills
      name: bicep-best-practices

  # Terraform Skills
  - id: iac-terraform-azure
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['cloud-platform', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'decisions.cicd.iacTool' }, 'terraform'] }
    source:
      type: awesome_skills
      repository: https://github.com/terraform-community/skills
      skill_path: azure-terraform
    destination:
      folder: .github/skills
      name: terraform-azure

  # Azure Architecture
  - id: azure-architect-diagramer
    kind: skills
    enabled: true
    auto_provision_rule:
      in: ['cloud-platform', { 'var': 'activeScopes' }]
    source:
      type: local_file
      path: available-skills/azure/architect-diagramer
    destination:
      folder: .github/skills
      name: architect-diagramer
```

## 🚀 Plan de Implementación

### Semana 1: Fundamentos

**Días 1-2**: Investigación y Decisión ✅ (Completado)

- [x] Investigar soluciones (json-rules-engine, JSONLogic, JSON Schema)
- [x] Seleccionar JSONLogic como solución
- [x] Documentar propuesta

**Días 3-5**: PowerShell Evaluator

- [ ] Instalar/integrar json-everything en scripts PowerShell
- [ ] Implementar `Test-AutoProvisionRule` function
- [ ] Añadir carga de facts desde scopes.yaml + constitution
- [ ] Unit tests para evaluador (Test-Pester)
- [ ] Actualizar `Invoke-BoltSetupConstitution.ps1`

### Semana 2: Agents & Templates

**Días 6-8**: Node.js/TypeScript Evaluator

- [ ] Instalar json-logic-js en package.json
- [ ] Actualizar `@Bolt Provisioner` agent
- [ ] Implementar evaluación de reglas en TypeScript
- [ ] Sincronizar comportamiento PowerShell ↔ Node.js

**Días 9-10**: Actualizar Scopes

- [ ] Actualizar `.boltf/scopes/scope-template.yaml`
- [ ] Añadir `auto_provision_rule` a scopes existentes:
  - [ ] backend/scope.yaml (C# vs Node.js)
  - [ ] frontend/scope.yaml (React, Angular, Vue)
  - [ ] cloud-platform/scope.yaml (Bicep, Terraform)
  - [ ] data/scope.yaml
  - [ ] ai/scope.yaml
  - [ ] integration/scope.yaml
  - [ ] crm/scope.yaml

### Semana 3: Testing & Documentación

**Días 11-13**: Testing End-to-End

- [ ] Test scenario: Backend C# → debe copiar dotnet-backend skills
- [ ] Test scenario: Backend Node.js → debe copiar jest-tdd skills
- [ ] Test scenario: Frontend React → debe copiar react skills
- [ ] Test scenario: Full-stack (backend + frontend) → combinaciones
- [ ] Test scenario: Regla compleja (AND/OR/NOT)

**Días 14-15**: Documentación

- [ ] Crear `.boltf/docs/provisioning-rules.md`
- [ ] Crear biblioteca de reglas comunes (provisioning-rules.yaml)
- [ ] Actualizar README.md con ejemplos de reglas
- [ ] Crear ADR documentando decisión de arquitectura
- [ ] Video/demo demostrando autoconfiguración

## 📝 Criterios de Aceptación

### Must Have (MVP)

- [x] **Investigación completada** - Solución seleccionada y documentada
- [ ] **PowerShell evaluator** - `Test-AutoProvisionRule` funcional
- [ ] **Facts loading** - Extracción desde scopes.yaml + constitution
- [ ] **Reglas en scopes** - Al menos 2 scopes con reglas (backend, frontend)
- [ ] **Operadores básicos** - Soporte para `==`, `in`, `all`, `any`
- [ ] **Tests unitarios** - >80% coverage del evaluador
- [ ] **Documentación** - Guía de uso de reglas

### Should Have

- [ ] **Node.js evaluator** - Agente @Bolt Provisioner actualizado
- [ ] **Biblioteca de reglas** - provisioning-rules.yaml con templates
- [ ] **Regla debugging** - Modo verbose que explica evaluaciones
- [ ] **Todos los scopes** - 7 scopes con reglas completas
- [ ] **Integración E2E** - Init.ps1 + @Bolt Constitution workflow

### Could Have

- [ ] **Custom operators** - Extensibilidad via plugins
- [ ] **Rule validation** - Pre-commit hook validando sintaxis
- [ ] **Visual rule builder** - VSCode extension para crear reglas
- [ ] **Telemetría** - Tracking de qué skills se aprovisionan más

## 🎓 Guía de Uso para Desarrolladores

### Crear una Nueva Regla

**Paso 1**: Identificar condiciones

```text
Pregunta: ¿Cuándo debería copiarse este skill?
Respuesta:
- Cuando scope "backend" está activo
- Y el lenguaje backend es "csharp"
- Y la estrategia de testing incluye "tdd"
```

**Paso 2**: Traducir a JSONLogic

```yaml
auto_provision_rule:
  and:
    - { 'in': ['backend', { 'var': 'activeScopes' }] }
    - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
    - { 'in': ['tdd', { 'var': 'decisions.quality.strategies' }] }
```

**Paso 3**: Añadir a scope.yaml

```yaml
items:
  - id: mi-nuevo-skill
    kind: skills
    enabled: true
    auto_provision_rule:
      and:
        - { 'in': ['backend', { 'var': 'activeScopes' }] }
        - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
        - { 'in': ['tdd', { 'var': 'decisions.quality.strategies' }] }
    source:
      type: local_file
      path: available-skills/dotnet-backend/mi-skill
    destination:
      folder: .github/skills
      name: mi-skill
```

**Paso 4**: Validar

```powershell
# Dry run para ver qué se provisionaría
./Invoke-BoltSetupConstitution.ps1 -DryRun -Verbose
```

### Operadores JSONLogic Soportados

| Operador             | Descripción             | Ejemplo                                                |
| -------------------- | ----------------------- | ------------------------------------------------------ |
| `==`                 | Igualdad estricta       | `{ "==": [{ "var": "techStack.backend" }, "csharp"] }` |
| `!=`                 | Desigualdad             | `{ "!=": [{ "var": "techStack.backend" }, "python"] }` |
| `in`                 | Valor en array          | `{ "in": ["backend", { "var": "activeScopes" }] }`     |
| `and`                | Todos verdaderos        | `{ "and": [cond1, cond2, ...] }`                       |
| `or`                 | Al menos uno verdadero  | `{ "or": [cond1, cond2, ...] }`                        |
| `not`                | Negación                | `{ "not": { "==": [...] } }`                           |
| `>`, `<`, `>=`, `<=` | Comparaciones numéricas | `{ ">": [{ "var": "projectSize" }, 10] }`              |

### Patrones Comunes

#### Patrón 1: Scope Único

```yaml
auto_provision_rule:
  in: ['backend', { 'var': 'activeScopes' }]
```

#### Patrón 2: Tech Stack Match

```yaml
auto_provision_rule:
  '==': [{ 'var': 'techStack.backend' }, 'csharp']
```

#### Patrón 3: Scope + Tech Stack

```yaml
auto_provision_rule:
  and:
    - { 'in': ['frontend', { 'var': 'activeScopes' }] }
    - { '==': [{ 'var': 'techStack.frontend' }, 'react'] }
```

#### Patrón 4: Múltiples Opciones (OR)

```yaml
auto_provision_rule:
  or:
    - { '==': [{ 'var': 'techStack.backend' }, 'csharp'] }
    - { '==': [{ 'var': 'techStack.backend' }, 'fsharp'] }
```

#### Patrón 5: Exclusión (NOT)

```yaml
auto_provision_rule:
  and:
    - { 'in': ['backend', { 'var': 'activeScopes' }] }
    - { 'not': { '==': [{ 'var': 'techStack.backend' }, 'python'] } }
```

## 🔍 Debugging & Troubleshooting

### Modo Verbose

```powershellpowershell
# Ver todas las evaluaciones de reglas
./Invoke-BoltSetupConstitution.ps1 -Provision -Verbose
```

**Output esperado**:

```text
📊 Facts cargados:
  - activeScopes: backend, frontend, cloud-platform
  - techStack.backend: csharp
  - techStack.frontend: react
  - decisions.cicd.iacTool: bicep

📁 Procesando scope: backend
  ✓ backend-tdd-xunit: regla cumplida
    Regla: { "and": [ ... ] }
    Resultado: true
  ⊗ backend-jest-tdd: regla NO cumplida
    Regla: { "and": [ ... ] }
    Resultado: false (techStack.backend = csharp, esperado nodejs)
```

### Validar Regla Manualmente

**PowerShell**:

```powershell
$rule = @{ and = @(
    @{ in = @("backend", @{ var = "activeScopes" }) }
    @{ "==" = @( @{ var = "techStack.backend" }, "csharp" ) }
)}

$facts = @{
    activeScopes = @("backend", "frontend")
    techStack = @{ backend = "csharp" }
}

Test-AutoProvisionRule -Rule $rule -Facts $facts -Verbose
```

**Node.js**:

```javascript
const jsonLogic = require('json-logic-js');

const rule = {
  and: [
    { in: ['backend', { var: 'activeScopes' }] },
    { '==': [{ var: 'techStack.backend' }, 'csharp'] },
  ],
};

const facts = {
  activeScopes: ['backend', 'frontend'],
  techStack: { backend: 'csharp' },
};

console.log(jsonLogic.apply(rule, facts)); // true
```

## 🔒 Seguridad & Validación

### Consideraciones de Seguridad

1. **No eval()**: JSONLogic no ejecuta código arbitrario
2. **Solo lectura**: Rules solo leen facts, no pueden escribir
3. **Sin side effects**: Evaluación determinística
4. **Schema validation**: Validar structure de rules en CI

### Schema de Validación

```yaml
# .boltf/schemas/auto-provision-rule.schema.json
{
  '$schema': 'http://json-schema.org/draft-07/schema#',
  'title': 'Auto Provision Rule',
  'description': 'JSONLogic rule for skill auto-provisioning',
  'oneOf':
    [
      {
        'type': 'object',
        'properties':
          {
            'and': { 'type': 'array' },
            'or': { 'type': 'array' },
            'not': { 'type': 'object' },
            '==': { 'type': 'array', 'minItems': 2, 'maxItems': 2 },
            'in': { 'type': 'array', 'minItems': 2, 'maxItems': 2 },
            'var': { 'type': 'string' },
          },
        'additionalProperties': false,
      },
      { 'type': 'boolean' },
    ],
}
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Validar todas las reglas en scopes/*.yaml
for file in .boltf/scopes/*/scope.yaml; do
  echo "Validating $file..."
  # Extraer auto_provision_rule y validar contra schema
  # (implementación con yq + ajv)
done
```

## 📊 Métricas de Éxito

| Métrica                 | Objetivo | Medición                             |
| ----------------------- | -------- | ------------------------------------ |
| **Tiempo de setup**     | <5 min   | Desde Init.ps1 hasta skills copiados |
| **Skills correctos**    | 100%     | Todos los skills relevantes copiados |
| **Skills innecesarios** | 0%       | Ningún skill irrelevante copiado     |
| **Adopción**            | >80%     | % proyectos usando auto-provision    |
| **Satisfacción**        | >4/5     | Survey a desarrolladores             |

## 🛣️ Roadmap Futuro

### v1.1 - Custom Operators (Q2 2026)

```yaml
# Operador custom: has-azure-service
auto_provision_rule:
  has-azure-service: ['cosmos-db']
```

### v1.2 - Visual Rule Builder (Q3 2026)

VSCode extension para crear reglas visualmente:

```text
[Scope] [is active] [backend]
[AND]
[Tech Stack] [equals] [csharp]
[AND]
[Quality Strategy] [includes] [tdd]

→ Genera YAML automáticamente
```

### v1.3 - AI-Suggested Rules (Q4 2026)

LLM analiza proyecto y sugiere reglas:

```text
@Bolt Constitution: "Analiza mi proyecto y sugiere reglas de provisioning"
→ Detecta patterns, tecnologías usadas, recomienda skills
```

## 🤝 Contribución

### Añadir Nuevo Skill con Regla

1. Crear skill en `.boltf/available-skills/<tech>/<skill-name>/`
2. Añadir item a scope.yaml correspondiente
3. Definir `auto_provision_rule` basada en tech stack
4. Testear con `Init.ps1 -DryRun`
5. Documentar en `.boltf/available-skills/README.md`

### Reportar Bug en Regla

````yaml
---
title: "Regla incorrecta: backend-tdd-xunit"
labels: [provisioning, bug]
---

**Regla actual**:
```yaml
auto_provision_rule:
  and:
    - { "in": ["backend", { "var": "activeScopes" }] }
    - { "==": [{ "var": "techStack.backend" }, "csharp"] }
````

**Problema**: Se copia también cuando backend es F#

**Regla corregida**:

```yaml
auto_provision_rule:
  and:
    - { 'in': ['backend', { 'var': 'activeScopes' }] }
    - {
        'or':
          [
            { '==': [{ 'var': 'techStack.backend' }, 'csharp'] },
            { '==': [{ 'var': 'techStack.backend' }, 'fsharp'] },
          ],
      }
```

## 📚 Referencias

### JSONLogic

- **Website**: <https://jsonlogic.com/>
- **Playground**: <https://jsonlogic.com/play.html>
- **Operations**: <https://jsonlogic.com/operations.html>

### Implementaciones

- **.NET**: [json-everything](https://github.com/gregsdennis/json-everything)
- **Node.js**: [json-logic-js](https://github.com/jwadhams/json-logic-js)
- **Python**: [json-logic-py](https://github.com/nadirizr/json-logic-py)
- **Go**: [jsonlogic](https://github.com/diegoholiveira/jsonlogic)

### Alternativas Evaluadas

- [json-rules-engine](https://github.com/cachecontrol/json-rules-engine) - Node.js only
- [@ali-master/rule-engine](https://github.com/ali-master/rule-engine) - TypeScript native
- [MEF (Managed Extensibility Framework)](https://learn.microsoft.com/dotnet/framework/mef/) - .NET plugin architecture

---

**Versión**: 1.0.0
**Fecha**: 2026-02-25
**Próximo Paso**: Crear ADR formalizando esta decisión arquitectónica
**Owner**: @Bolt Framework Team

```yaml
---
end-of-document: true
---
```
