# Tasks — Migración SICAWeb (001-migracion-sica)

> **Feature**: 001-migracion-sica
> **Fase Bolt**: EXECUTE (CONSTRUCTION)
> **Fuente**: [plan.md](plan.md) · [data-model.md](../requirements/data-model.md) · [openapi.yaml](../contracts/openapi.yaml)
> **Generado**: 2026-06-24

Leyenda de peso: `[S]` small · `[M]` medium · `[L]` large.

---

## Bolt 1 — Foundation + Characterization

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-foundation`
**Objetivo**: Esqueleto de la solución .NET 8 (Clean Architecture + CQRS nativo),
Shared kernel (Result pattern, Guard clauses), proyectos de test y scaffold de
caracterización. Base buildable sobre la que se asientan los Bolts 2-6.
**User Stories**: US-1
**Estado**: Complete

### Tareas

- [x] T101 [S] Crear `Sica.slnx` y estructura `src/` + `tests/`
- [x] T102 [S] `Sica.Shared` — Result pattern, Error, Guard clauses
- [x] T103 [S] `Sica.Domain` — primitivos base (Entity, ValueObject, IAggregateRoot)
- [x] T104 [S] `Sica.Application` — abstracciones CQRS nativas (ICommand/IQuery + handlers)
- [x] T105 [S] `Sica.Infrastructure` — proyecto base + referencia EF Core 8
- [x] T106 [S] `Sica.Api` — host Web API .NET 8 + endpoint health
- [x] T107 [S] `Sica.UnitTests` — xUnit + FluentAssertions + NSubstitute
- [x] T108 [S] `Sica.CharacterizationTests` — scaffold golden-master (xUnit)
- [x] T109 [S] `.editorconfig` + `Directory.Build.props` (analyzers, nullable, lang version)
- [x] T110 [M] Tests unitarios de `Result`/`Guard`/`ValueObject` (18 tests)
- [x] T111 [S] `dotnet build` + `dotnet test` verdes

### Quality Gates (Bolt 1)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (18 passed, 1 skipped scaffold)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

---

## Bolt 2 — IAM Core (Terminal Authorization)

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-iam-core`
**Objetivo**: Implementar RULE-001 — autorización de terminales por hostname
(case-insensitive) o IP, sólo si el terminal está registrado y activo. Endpoint
`POST /api/v1/iam/terminals/authorize` con resolución de IP vía `X-Forwarded-For`
(primera IP) para clientes detrás de proxy.
**User Stories**: US-2 (IAM)
**Estado**: Complete

### Tareas

- [x] T201 [S] Dominio — `Terminal` aggregate + `TerminalId` + `ITerminalRepository`
- [x] T202 [S] Dominio — RULE-001 en `Terminal.Matches()` (hostname OR IP)
- [x] T203 [S] Application — `AuthorizeTerminalQuery`/`Result`/`Handler` (CQRS nativo)
- [x] T204 [S] Application — `IamErrors` (NotRegistered, Inactive) + DI `AddApplication`
- [x] T205 [M] Infrastructure — `SicaDbContext` + `TerminalConfiguration` (schema sica)
- [x] T206 [S] Infrastructure — `TerminalRepository` + DI `AddInfrastructure`
- [x] T207 [M] API — `IamEndpoints` + resolución `X-Forwarded-For` + wiring `Program.cs`
- [x] T208 [M] Tests — `TerminalTests` (RULE-001 hostname/IP/inactive)
- [x] T209 [M] Tests — `AuthorizeTerminalQueryHandlerTests` (NSubstitute, 3 paths)
- [x] T210 [S] `dotnet build` + `dotnet test` verdes

### Quality Gates (Bolt 2)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (30 passed, 1 skipped)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

**Diferido** (Bolt 2 continuación / Bolts posteriores): CRUD completo de terminales
(list/create/get/update/deactivate), agregado `User`, autenticación Azure AD B2C,
migraciones EF + integration tests con Testcontainers SQL Server, parity harness real.

---

## Bolt 3 — SMI Anti-Corruption Layer

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-smi-acl`
**Objetivo**: Desacoplar el dominio del cliente SOAP legacy `SMIMethods.asmx`
mediante un puerto ACL (`ISmiService`) que traduce las estructuras SOAP a DTOs
limpios. Adaptador Mock funcional (respuestas capturadas del legacy) para
tests/dev y adaptador SOAP de producción (scaffold con fail-fast hasta capturar
el WSDL real). Toggle por configuración `Smi:Mode`.
**User Stories**: US-2 (infra) — habilita Bolts 4 (Card), 5 (Access), 6 (Monitoring)
**Estado**: Complete

### Tareas

- [x] T301 [S] Application — DTOs ACL (`SmiSmartCard`, `SmiFamily`, `SmiCircuit`, `SmiZone`, `SmiAccessEvent`)
- [x] T302 [S] Application — enum `SmiSmartCardStatus` (valores legacy preservados)
- [x] T303 [M] Application — puerto `ISmiService` (7 operaciones async + cancellation)
- [x] T304 [S] Infrastructure — `SmiOptions` + enum `SmiMode` (Mock/Soap)
- [x] T305 [L] Infrastructure — `SmiMockAdapter` (datos capturados, filtros y update)
- [x] T306 [M] Infrastructure — `SmiSoapAdapter` (scaffold producción, fail-fast)
- [x] T307 [S] Infrastructure — DI `AddSmiIntegration` con toggle por `Smi:Mode`
- [x] T308 [S] API — sección `Smi` en `appsettings.json`
- [x] T309 [L] Tests — `SmiMockAdapterTests` (11 tests: lookup, update, filtros, orden, max)
- [x] T310 [S] `dotnet build` + `dotnet test` verdes

### Quality Gates (Bolt 3)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (41 passed, 1 skipped)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

**Diferido**: cliente SOAP real generado desde WSDL capturado del entorno legacy
(`SmiSoapAdapter` queda como scaffold fail-fast), captura de respuestas reales
para `SmiMockAdapter`, integration tests del adaptador SOAP.

---

## Bolt 4 — Card Management

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-card-management`
**Objetivo**: Modelar el agregado `SmartCard` (tipo derivado del prefijo del código,
RULE-004; sincronización restringida a prefijos válidos, RULE-005) y el agregado
`VisitorCardAssignment` que gobierna la disponibilidad de cartões de visitante
(RULE-008) y la validación de datos obligatorios al asignar (RULE-009). Casos de
uso CQRS: listar cartões disponibles, asignar cartão a visitante (registra entrada)
y registrar salida (libera el cartão). Persistencia EF Core + endpoints REST.
**User Stories**: US-3 (gestión de cartões de visitante)
**Estado**: Complete

### Tareas

- [x] T401 [S] Domain — `CardId`, `CardType`, `CardStatus`, `CardCode` (RULE-004/005)
- [x] T402 [M] Domain — agregado `SmartCard` (`Create`, `SyncFromMaster`, transiciones de estado)
- [x] T403 [L] Domain — agregado `VisitorCardAssignment` (`Assign` RULE-009, `RecordExit` RULE-008)
- [x] T404 [S] Domain — puertos `ISmartCardRepository`, `IVisitorCardAssignmentRepository`
- [x] T405 [S] Application — `IUnitOfWork` + `CardErrors`
- [x] T406 [M] Application — `ListAvailableVisitorCardsQuery` + handler (RULE-008)
- [x] T407 [M] Application — `AssignVisitorCardCommand` + handler (RULE-009, `TimeProvider`)
- [x] T408 [S] Application — `RecordVisitorExitCommand` + handler
- [x] T409 [S] Application — DI: registra handlers Cards + `TimeProvider.System`
- [x] T410 [M] Infrastructure — `SmartCardConfiguration` + `VisitorCardAssignmentConfiguration` (EF)
- [x] T411 [M] Infrastructure — `SmartCardRepository` + `VisitorCardAssignmentRepository`
- [x] T412 [S] Infrastructure — DI: repos Cards + `IUnitOfWork` → `SicaDbContext`
- [x] T413 [M] API — `CardEndpoints` (GET available, POST assign, POST exit)
- [x] T414 [L] Tests — dominio (CardCode/SmartCard/VisitorCardAssignment) + handlers (26 tests)
- [x] T415 [S] `dotnet build` + `dotnet test` verdes

### Quality Gates (Bolt 4)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (77 passed, 1 skipped — 26 nuevos)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

**Diferido**: agregado `User` (titulares de cartões de empleado), CRUD completo de
cartões + endpoints de administración, comando de sincronización SMI→SmartCard usando
`ISmiService` (RULE-005), migraciones EF Core, integration tests de los repositorios.

---

## Bolt 5 — Access Control

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-access-control`
**Objetivo**: Modelar el control de accesos físicos: agregado `AccessFamily`
(grupos de acceso con membresía de usuarios), `Circuit` (puntos de acceso físicos,
jerarquía por grupo) y `TerminalAccessPolicy` (perfil de acceso por terminal).
RULE-007: actualizar el perfil de un terminal reemplaza por completo la configuración
anterior (delete + insert) de forma atómica vía unit of work — corrige el defecto
legacy sin transacción que dejaba el terminal en estado inconsistente. Casos de uso
CQRS: listar/crear familias, actualizar membresía, listar circuitos, leer y actualizar
la política de terminal. Persistencia EF Core + endpoints REST.
**User Stories**: US-2 (parcial) — habilita Bolt 6 (Monitoring)
**Estado**: Complete

### Tareas

- [x] T501 [S] Domain — `AccessFamilyId`, `CircuitId`, `TerminalAccessPolicyId`
- [x] T502 [M] Domain — agregado `AccessFamily` (`Create`, `Rename`, `ReplaceMembers`)
- [x] T503 [S] Domain — agregado `Circuit` (`Register`, jerarquía `CircuitGroupId`)
- [x] T504 [L] Domain — agregado `TerminalAccessPolicy` (`ReplaceRules` RULE-007)
- [x] T505 [S] Domain — puertos `IAccessFamilyRepository`, `ICircuitRepository`, `ITerminalAccessPolicyRepository`
- [x] T506 [S] Application — `AccessControlErrors`
- [x] T507 [M] Application — `ListAccessFamiliesQuery` + `CreateAccessFamilyCommand` + handlers
- [x] T508 [S] Application — `UpdateFamilyMembersCommand` + handler
- [x] T509 [S] Application — `ListCircuitsQuery` + handler
- [x] T510 [M] Application — `GetTerminalPolicyQuery` + `UpdateTerminalPolicyCommand` + handlers (RULE-007)
- [x] T511 [S] Application — DI: registra 6 handlers Access Control
- [x] T512 [M] Infrastructure — configs EF (`AccessFamily`, `Circuit`, `TerminalAccessPolicy`)
- [x] T513 [M] Infrastructure — 3 repositorios + DbSets + DI
- [x] T514 [M] API — `AccessControlEndpoints` (familias, miembros, circuitos, política terminal)
- [x] T515 [L] Tests — dominio (`AccessFamily`, `TerminalAccessPolicy`) + handlers (21 tests)
- [x] T516 [S] `dotnet build` + `dotnet test` verdes

### Quality Gates (Bolt 5)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (98 passed, 1 skipped — 21 nuevos)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

**Diferido**: tablas de unión normalizadas `TerminalPolicyRules` (producto Familia×Circuito;
se usa columna serializada por consistencia con el patrón establecido), log de auditoría
`PolicyUpdated` (a Bolt 6 Monitoring / domain events), validación de existencia del terminal
contra IAM, sincronización SMI→AccessFamily/Circuit, migraciones EF Core, integration tests
transaccionales del rollback RULE-007.

---

## Bolt 6 — Monitoring

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-monitoring`
**User Stories**: US-2 (parcial) — monitorización de accesos físicos en tiempo (cuasi) real
**Estado**: Complete

**Objetivo**: Exponer los eventos de acceso y la ocupación por zona consultados
directamente del SMI (read-only, sin persistencia en MVP — data-model §5.1), aplicando
la clasificación de movimiento RULE-011 (Entrada/Salida/Desconocido).

| ID | Tarea | Estado |
|----|-------|--------|
| T601 | `AccessEventType` enum (Entry/Exit/Unknown) | [x] |
| T602 | `MovementClassifier` (RULE-011: descripción prioritaria + fallback por parámetro) | [x] |
| T603 | `ListAccessEventsQuery` + DTO + handler (ACL SMI, clamp horas/maxEvents) | [x] |
| T604 | `CountUsersByZoneQuery` + DTO + handler (ocupación por zona) | [x] |
| T605 | `MonitoringEndpoints` GET /events, GET /zones + wiring Program.cs | [x] |
| T606 | Registro DI de handlers Monitoring | [x] |
| T607 | Tests: `MovementClassifier` (todos los escenarios RULE-011) | [x] |
| T608 | Tests: handlers `ListAccessEvents` (mapeo/clasificación/clamp) y `CountUsersByZone` | [x] |

### Quality Gates (Bolt 6)

- [x] Linting: PASS (0 warnings, TreatWarningsAsErrors)
- [x] Unit tests: PASS (116 passed, 1 skipped — 18 nuevos)
- [x] Build: PASS (Release, 0 errors / 0 warnings)

**Diferido**: agregado `Alarm` (fuera de MVP), persistencia de `AccessEvent` y resolución
de `UserId`, resolución RULE-010 por grupo de circuitos, endpoint `zones/{id}/users`,
cliente SOAP real de eventos, integration tests del ACL SMI.

---

## Bolt 7 — Frontend: Foundation

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-frontend-foundation`
**User Stories**: US-3 (setup)
**Estado**: Complete

**Objetivo**: Scaffold de la SPA (`frontend/`) con React 18 + TypeScript + Vite,
design system Tailwind v4, autenticación MSAL (Azure AD B2C, Auth Code + PKCE),
TanStack Query, enrutado protegido y componentes base reutilizables.

| ID | Tarea | Estado |
|----|-------|--------|
| T701 | Proyecto Vite + TS (`package.json`, `tsconfig*`, `vite.config.ts`, `index.html`) | [x] |
| T702 | Design system Tailwind v4 con tokens (`src/index.css`) | [x] |
| T703 | MSAL: config + instancia + `RequireAuth` (Auth Code + PKCE) | [x] |
| T704 | TanStack Query + cliente API autenticado (`apiFetch`, `ApiError`) | [x] |
| T705 | Componentes base: `Button`, `Input`, `Card`, `Table`, `Modal` | [x] |
| T706 | Layouts: `DashboardLayout`, `AuthLayout` | [x] |
| T707 | Páginas `/login` (redirect AAD) y `/dashboard` (home) + router | [x] |
| T708 | Bootstrap MSAL (`main.tsx`) + providers (`App.tsx`) | [x] |
| T709 | Tests Vitest + RTL: `Button`, `Card`, `apiFetch`, `cn` | [x] |
| T710 | ESLint config + `.env.example` + README frontend | [x] |

### Quality Gates (Bolt 7)

- [x] Build: PASS (`tsc -b && vite build`, 0 errors)
- [x] Unit tests: PASS (15 passed — Vitest + Testing Library)
- [x] Security: `npm audit --omit=dev` → 0 vulnerabilidades en producción

**Diferido**: valores reales de Azure AD B2C (tenant/clientId/scope), páginas de negocio
(Dashboard de monitorización B-08, Visitantes B-09, secundarias B-10), code-splitting del
bundle (>500 kB), Zustand stores concretos, Stryker JS (mutation), Playwright E2E, 6
vulnerabilidades dev-only de tooling.

---

## Bolt 8 — Frontend: Dashboard

**Tracker**: gh#TBD
**Branch**: `bolt/001-migracion-sica-frontend-dashboard`
**User Stories**: US-3 (PagPrincipal — monitorización)
**Estado**: Complete

**Objetivo**: Reproducir la página principal legacy de monitorización consumiendo los
endpoints del Bolt 6 (Monitoring) y del Bolt 5 (Access Control): selección de circuito,
log de eventos recientes con polling y ocupación por zona.

| ID | Tarea | Estado |
|----|-------|--------|
| T801 | Tipos y cliente API del feature `monitoring` (circuits/events/zones, envelope `items`) | [x] |
| T802 | Hooks TanStack Query: `useCircuits`, `useAccessEvents` (poll 5s), `useZoneOccupancy` (poll 15s) | [x] |
| T803 | `CircuitSelector` (dropdown de circuitos) | [x] |
| T804 | `EventLog` (tabla de eventos) + `EventTypeBadge` (RULE-011 Entrada/Saída/Desconhecido) | [x] |
| T805 | `ZoneOccupancyPanel` (ocupación por zona) | [x] |
| T806 | `DashboardPage` compuesta + auto-selección del primer circuito | [x] |
| T807 | Util `formatTime` (locale pt-PT) | [x] |
| T808 | Tests Vitest: api (envelope/query), `EventTypeBadge`, `EventLog`, `formatTime` | [x] |

### Quality Gates (Bolt 8)

- [x] Build: PASS (`tsc -b && vite build`, 0 errors)
- [x] Unit tests: PASS (28 passed — 13 nuevos)
- [x] Security: `npm audit --omit=dev` → 0 vulnerabilidades en producción

**Diferido**: componente `UserDetail` (foto + ficha del último evento, requiere resolución
de `UserId` en backend), filtros de horas/maxEvents en la UI, tests de hooks con polling,
code-splitting del bundle, Playwright E2E del dashboard.

---

## Bolts siguientes (resumen — ver plan.md §5)

| # | Nombre | Estado |
|---|--------|--------|
| 2 | Backend: IAM Core | Complete |
| 3 | Backend: SMI ACL | Complete |
| 4 | Backend: Card Management | Complete |
| 5 | Backend: Access Control | Complete |
| 6 | Backend: Monitoring | Complete |
| 7 | Frontend: Foundation | Complete |
| 8 | Frontend: Dashboard | Complete |
| 9 | Frontend: Visitantes | Planned |
| 10 | Frontend: Secundarias | Planned |
| 11 | Infra: Azure Bicep | Planned |
| 12 | Observability | Planned |
| 13 | Data Migration + Decomisión | Planned |

---

## Velocity

| Bolt | Planned | Completed | Days | Notes |
|------|---------|-----------|------|-------|
| B-01 | 11 tasks | 11 tasks | 1 | Foundation buildable; rehost a Azure + parity harness real diferidos a infra/Bolt 2 |
| B-02 | 10 tasks | 10 tasks | 1 | RULE-001 terminal authorization; 12 tests nuevos (30 total). CRUD/User/B2C diferidos |
| B-03 | 10 tasks | 10 tasks | 1 | SMI ACL: puerto `ISmiService` + Mock/SOAP adapters; 11 tests nuevos (41 total). Cliente SOAP real diferido |
| B-04 | 15 tasks | 15 tasks | 1 | Card Management: agregados `SmartCard` + `VisitorCardAssignment` (RULE-004/005/008/009); 3 casos de uso CQRS + endpoints; 26 tests nuevos (77 total). User/CRUD/sync SMI/migraciones diferidos |
| B-05 | 16 tasks | 16 tasks | 1 | Access Control: agregados `AccessFamily` + `Circuit` + `TerminalAccessPolicy` (RULE-007 reemplazo transaccional); 6 casos de uso CQRS + endpoints; 21 tests nuevos (98 total). Join tables normalizadas/auditoría/sync SMI diferidos |
| B-06 | 8 tasks | 8 tasks | 1 | Monitoring: `MovementClassifier` (RULE-011 read-only desde SMI) + 2 queries CQRS (eventos/zonas) + endpoints; 18 tests nuevos (116 total). Agregado `Alarm`, persistencia de eventos y RULE-010 por grupo diferidos |
| B-07 | 10 tasks | 10 tasks | 1 | Frontend Foundation: scaffold SPA React 18 + TS + Vite, design system Tailwind v4, MSAL (Auth Code+PKCE), TanStack Query + cliente API, 5 componentes base + 2 layouts + login/dashboard; 15 tests Vitest. AAD real/páginas de negocio/E2E/mutation diferidos |
| B-08 | 8 tasks | 8 tasks | 1 | Frontend Dashboard: feature `monitoring` (api/hooks con polling) + `CircuitSelector`/`EventLog`/`EventTypeBadge`/`ZoneOccupancyPanel` + `DashboardPage` consumiendo Monitoring (RULE-011) y Access Control; 13 tests nuevos (28 total). `UserDetail`/filtros UI/E2E diferidos |
