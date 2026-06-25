# Tests BDD — Migración SICAWeb

> **Feature**: 001-migracion-sica
> **Fase Bolt**: PLAN (Technical Planning)
> **Framework**: Reqnroll (.NET) + Playwright (frontend)
> **Lenguaje**: Español (España)

---

## Resumen de escenarios

| Archivo | Bounded Context | Reglas cubiertas | Escenarios | @smoke |
|---|---|---|---|---|
| [iam-terminal-authorization.feature](iam-terminal-authorization.feature) | IAM | RULE-001 | 7 | 4 |
| [iam-operator-identity.feature](iam-operator-identity.feature) | IAM | RULE-002 | 5 | 2 |
| [iam-access-whitelist.feature](iam-access-whitelist.feature) | IAM | RULE-003 | 7 | 3 |
| [card-visitor-availability.feature](card-visitor-availability.feature) | Card Management | RULE-008 | 5 | 2 |
| [card-visitor-assignment.feature](card-visitor-assignment.feature) | Card Management | RULE-009 | 6 | 3 |
| [access-control-terminal-policy.feature](access-control-terminal-policy.feature) | Access Control | RULE-007 | 6 | 2 |
| [access-control-card-authorization.feature](access-control-card-authorization.feature) | Access Control | RULE-013 | 6 | 3 |
| [monitoring-circuit-resolution.feature](monitoring-circuit-resolution.feature) | Monitoring | RULE-010 | 4 | 2 |
| [monitoring-event-classification.feature](monitoring-event-classification.feature) | Monitoring | RULE-011 | 7 | 4 |
| [security-sql-injection-elimination.feature](security-sql-injection-elimination.feature) | Seguridad | — | 6 | 4 |
| [characterization-equivalence.feature](characterization-equivalence.feature) | Characterization | — | 6 | 3 |
| [quality-gates.feature](quality-gates.feature) | Quality Gates | — | 8 | 6 |
| **Total** | | **9 reglas P0** | **73** | **38** |

---

## Organización por tags

### @smoke (38 escenarios)
Escenarios críticos que DEBEN pasar antes de hacer merge. Cubren las rutas principales (happy path) y los ACs marcados como críticos en la feature spec.

**Ejecución**:
```bash
# Backend (.NET)
dotnet test --filter "Category=smoke"

# Frontend (Playwright)
npx playwright test --grep @smoke
```

### @characterization (15 escenarios)
Tests de equivalencia Legacy vs Modern. Validan que el sistema modernizado preserva el comportamiento del legacy.

**Patrón**:
```gherkin
Given <precondición conocida del legacy>
When se ejecuta en el sistema Legacy
And se ejecuta en el sistema Modern con los mismos parámetros
Then ambos sistemas producen el mismo resultado
And el resultado del Legacy es equivalente al resultado del Modern
```

**Herramienta**: ApprovalTests.Net (golden-master snapshots)

### @security (6 escenarios)
Tests de seguridad que validan la eliminación de SQL injection y el cumplimiento de security gates.

### @bug (2 escenarios)
Defectos conocidos del legacy que el sistema modern corrige (documentados para regression testing).

### @critical (1 escenario)
Funcionalidades críticas de negocio con alto impacto si fallan.

### @transaction (1 escenario)
Validaciones de integridad transaccional (rollback en caso de error).

---

## Estrategia de testing

### Pirámide de tests

| Nivel | Cobertura objetivo | Herramientas | Escenarios |
|---|---|---|---|
| **E2E** | Smoke paths (@smoke) | Playwright | 10 (frontend) |
| **Integration** | Repositorios + EF | Testcontainers, Respawn | 20 (backend) |
| **Unit** | ≥ 80% | xUnit, FluentAssertions | 150+ (ambos) |
| **BDD** | ACs + reglas P0 | Reqnroll (backend), Playwright (frontend) | 73 (este directorio) |

### Tests de caracterización (golden-master)

**Objetivo**: Capturar el comportamiento real del legacy ANTES de reescribir.

**Proceso**:
1. Ejecutar casos de prueba contra el legacy en un entorno controlado
2. Capturar salidas completas como snapshots (JSON)
3. Guardar snapshots como "golden master" (archivos `.approved.json`)
4. Ejecutar mismos casos contra el sistema modern
5. Comparar salidas byte-a-byte (deben ser idénticas)

**Reglas P0 con characterization tests**:
- RULE-001: Autorización de terminal (100 casos)
- RULE-007: Perfil de acceso de terminal (30 casos)
- RULE-008: Disponibilidad de tarjetas (50 casos)
- RULE-011: Clasificación entrada/salida (50 casos)
- RULE-013: Acceso terminal a tarjeta (40 casos)

**Ubicación**: `tests/Characterization/`

---

## Mapeo de reglas de negocio → escenarios

| Regla | Prioridad | Feature | Escenarios @smoke |
|---|---|---|---|
| RULE-001: Autorización terminal | P0 | iam-terminal-authorization.feature | 4 |
| RULE-002: Identidad operador | P0 | iam-operator-identity.feature | 2 |
| RULE-003: Whitelist páginas | P0 | iam-access-whitelist.feature | 3 |
| RULE-007: Política terminal | P0 | access-control-terminal-policy.feature | 2 |
| RULE-008: Disponibilidad tarjetas | P0 | card-visitor-availability.feature | 2 |
| RULE-009: Asignación visitante | P0 | card-visitor-assignment.feature | 3 |
| RULE-010: Resolución circuitos | P1 | monitoring-circuit-resolution.feature | 2 |
| RULE-011: Clasificación eventos | P0 | monitoring-event-classification.feature | 4 |
| RULE-013: Acceso tarjeta | P0 | access-control-card-authorization.feature | 3 |

---

## Quality gates (por Bolt)

Cada Bolt debe pasar estos gates ANTES de merge:

| Gate | Threshold | Feature |
|---|---|---|
| Linting | 0 warnings | quality-gates.feature |
| Unit coverage | ≥ 80% | quality-gates.feature |
| Mutation score | ≥ 70% | quality-gates.feature |
| Architecture compliance | 0 violations | quality-gates.feature |
| Security scan | 0 Critical/High | security-sql-injection-elimination.feature |
| BDD @smoke | 100% passing | Todos los .feature con @smoke |

---

## Ejecución local

### Backend (.NET)

```bash
# Todos los tests BDD
dotnet test tests/BDD/

# Sólo smoke
dotnet test tests/BDD/ --filter "Category=smoke"

# Characterization tests
dotnet test tests/Characterization/

# Con coverage
dotnet test tests/BDD/ /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
```

### Frontend (React + Playwright)

```bash
# Todos los tests E2E BDD
npx playwright test specs/001-migracion-sica/tests/

# Sólo smoke
npx playwright test --grep @smoke

# Con UI
npx playwright test --ui

# Debug
npx playwright test --debug
```

---

## Estructura de step definitions

### Backend (Reqnroll)

```
tests/
├── BDD/
│   ├── Features/                    # Archivos .feature (symlink a specs/*/tests/)
│   ├── Steps/
│   │   ├── IAM/
│   │   │   ├── TerminalAuthorizationSteps.cs
│   │   │   ├── OperatorIdentitySteps.cs
│   │   │   └── AccessWhitelistSteps.cs
│   │   ├── Cards/
│   │   │   ├── VisitorAvailabilitySteps.cs
│   │   │   └── VisitorAssignmentSteps.cs
│   │   ├── AccessControl/
│   │   │   ├── TerminalPolicySteps.cs
│   │   │   └── CardAuthorizationSteps.cs
│   │   └── Monitoring/
│   │       ├── CircuitResolutionSteps.cs
│   │       └── EventClassificationSteps.cs
│   ├── Hooks/
│   │   ├── DatabaseFixture.cs       # Setup/teardown BD con Respawn
│   │   └── TestContext.cs           # Context compartido entre steps
│   └── Drivers/
│       ├── ApiDriver.cs             # Cliente HTTP para API
│       └── LegacyDriver.cs          # Cliente para legacy (characterization)
└── Characterization/
    ├── GoldenMasters/
    │   ├── TerminalAuthorization.approved.json
    │   ├── CardAvailability.approved.json
    │   └── ...
    └── CharacterizationTestBase.cs
```

### Frontend (Playwright)

```
e2e/
├── specs/                           # Archivos .feature (symlink)
├── steps/
│   ├── iam/
│   ├── cards/
│   ├── access-control/
│   └── monitoring/
├── pages/                           # Page Object Model
│   ├── LoginPage.ts
│   ├── DashboardPage.ts
│   ├── VisitorsPage.ts
│   └── ConfigPage.ts
└── fixtures/
    └── test.ts                      # Fixtures compartidos (auth, DB)
```

---

## Próximos pasos

1. **Bolt 1**: Implementar step definitions para characterization tests (@characterization)
2. **Bolt 2-6**: Implementar step definitions por bounded context según se implementa cada Bolt
3. **Bolt 7-10**: Implementar Page Objects + Playwright steps para frontend
4. **Continuo**: Mantener cobertura @smoke al 100% en cada merge

---

## Referencias

- **Skill BDD**: [.claude/skills/gherkin-reqnroll/](../../../.claude/skills/gherkin-reqnroll/)
- **Skill Characterization**: [.claude/skills/skill-characterization-testing/](../../../.claude/skills/skill-characterization-testing/)
- **Business Rules**: [.boltf/analysis/SICAWeb/BUSINESS_RULES.md](../../../.boltf/analysis/SICAWeb/BUSINESS_RULES.md)
- **Use Cases**: [docs/legacy/specs/use-cases/](../../../docs/legacy/specs/use-cases/)
