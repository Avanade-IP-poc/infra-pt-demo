# BOLT Framework — Scope Constitution: Backend

> **Proyecto**: SICA Modernization — Migración VB.NET WebForms → .NET 8 Web API
> **Scope**: `backend`
> **Estado**: Ratificado — 2026-06-19
> **Fuente legacy**: `demo/from_old_src/` (VB.NET, SQL concatenado, sin ORM)
> **Destino**: `demo/destino.md` (Web API .NET 8, Clean Architecture, Azure SQL)

---

## Article II §2.1: Backend Language & Runtime 🔴 CRITICAL

- [x] **C# / .NET**
  - Version: [x] .NET 8 (LTS)
  - API Style: [x] Controllers (MVC) + [x] Azure Functions (procesamiento async)

**Justificación**: El stack destino definido en `destino.md` especifica `.NET 6+`. Se selecciona
.NET 8 LTS por soporte extendido. Controllers para la Web API REST y Azure Functions para
procesamiento asíncrono (integración, eventos).

---

## Article III §3.1/3.3/3.4: Architecture

### §3.1: Backend Architecture Style 🔴 CRITICAL

- [x] **Modular Monolith** — Deployment único, límites de módulo bien definidos.

**Justificación**: El sistema legacy es un monolito WebForms. La estrategia Strangler Fig
requiere extraer gradualmente módulos. Un Modular Monolith permite la transición progresiva
sin over-engineering inicial. Cada módulo puede extraerse como microservicio si el volumen
lo justifica.

### §3.3: CQRS Configuration 🟡 IMPORTANT

- CQRS Enabled: [x] Yes
- Patrón: [x] **Simple CQRS** — Mismo modelo, handlers separados, sin MediatR.

Interfaces nativas .NET (ver skill `dotnet-backend-patterns`):
```csharp
public interface ICommandHandler<in TCommand> where TCommand : ICommand { ... }
public interface IQueryHandler<in TQuery, TResult> where TQuery : IQuery<TResult> { ... }
```

### §3.4: Event Sourcing

- Event Sourcing Enabled: [ ] No — No requerido para la migración inicial.

---

## Article IV §4.1-4.3: Communication

- §4.1: [x] **Hybrid** — REST sincrónico + mensajería asíncrona
- §4.2: [x] **REST API** (Controllers, versionado v1/v2)
- §4.3 Broker: [x] **Azure Service Bus** — cola de eventos para sincronización de datos (reemplaza `SICADataSync`)
- §4.3 Background: [x] **Azure Functions** — triggers de Service Bus + timer triggers

---

## Article V: Data Storage (Transaccional)

> *Nota: El scope `data` de Bolt cubre analytics/Lakehouse. El almacenamiento transaccional
> se gobierna aquí (backend scope).*

- [x] **Azure SQL Database** — Migración del esquema SQL Server existente.
- ORM: [x] **Entity Framework Core 8** — reemplaza `SQLMethods.vb` y SQL concatenado.
- Migraciones: [x] EF Core Migrations (code-first sobre esquema existente)
- Patrón repositorio: [x] Repository + Unit of Work (sobre EF Core DbContext)

**Seguridad crítica**: CERO SQL concatenado. Toda consulta vía EF Core o
`SqlParameter` parametrizado.

---

## Article VI: Caching

- [x] **Azure Cache for Redis** — Caché de sesión y resultados frecuentes.
- Estrategia: Cache-Aside.

---

## Article VII §7.1-7.2: Identity & Access Management (Backend)

- Proveedor: [x] **Azure AD B2C / Entra ID**
- Flow: [x] **Authorization Code + PKCE** (SPA → API)
- API Auth: [x] **JWT Bearer tokens** (Microsoft.Identity.Web)
- Autorización: [x] **Policy-Based** (.NET Authorization Policies)

---

## Article VIII §8.1-8.2: Containers & Orchestration

- §8.1: [x] **None** — PaaS only (Azure App Service para la API, Azure Functions)
- §8.2: [x] **Azure App Service** — Plan Standard S2 mínimo.

**Justificación Fase 1**: El rehost del WebForms ya usa App Service. La API .NET 8
se despliega también en App Service para simplificar las primeras fases. Docker
puede añadirse en Fase 4 si se extraen microservicios.

---

## Article XIII §13.1-13.3: Testing Standards (Backend)

| Métrica         | Mínimo | Recomendado | Herramienta         |
| --------------- | ------ | ----------- | ------------------- |
| Line Coverage   | ≥ 80%  | ≥ 90%       | Coverlet            |
| Branch Coverage | ≥ 75%  | ≥ 85%       | Coverlet            |
| Mutation Score  | ≥ 70%  | ≥ 80%       | Stryker.NET         |

| Tipo               | Framework                           |
| ------------------ | ----------------------------------- |
| Unit Tests         | xUnit + FluentAssertions + NSubstitute |
| Integration Tests  | Testcontainers (SQL Server real)    |
| Caracterización    | xUnit Golden-Master (legacy parity) |
| E2E / API          | Reqnroll (Gherkin) + HttpClient     |
| Performance        | NBomber / k6                        |

---

## Article XIV: Code Standards (Backend)

| Elemento    | Convención      | Ejemplo                |
| ----------- | --------------- | ---------------------- |
| Namespaces  | PascalCase      | `Sica.Domain.Access`   |
| Clases      | PascalCase      | `AccessControlService` |
| Interfaces  | I + PascalCase  | `IAccessControlService`|
| Métodos     | PascalCase      | `GetAccessByCardId`    |
| Variables   | camelCase       | `cardId`               |
| Constantes  | UPPER_SNAKE     | `MAX_RETRY_COUNT`      |

- Formateo: EditorConfig + dotnet format
- Longitud de línea: 120 caracteres
- Análisis estático: Roslyn Analyzers + SonarQube

---

## Article XV: Project Structure (Backend)

```
src/
├── Sica.Api/             # Controllers, Middleware, DI configuration
├── Sica.Application/     # Commands, Queries, Handlers (CQRS)
├── Sica.Domain/          # Entities, Value Objects, Domain Events
├── Sica.Infrastructure/  # EF Core, Azure integrations, Repositories
└── Sica.Shared/          # Common types, Result pattern, Guard clauses
tests/
├── Sica.UnitTests/
├── Sica.IntegrationTests/
├── Sica.CharacterizationTests/   # Golden-master del legacy
└── Sica.E2ETests/
```

---

## Article XVII: Legacy & Migration Strategy

- Patrón: **Strangler Fig** — convivencia del WebForms (read-only) durante la transición.
- Fases: Rehost → Extract API → Migrate UI → Decommission.
- Tests de caracterización OBLIGATORIOS antes de reescribir cualquier módulo.
- `SQLMethods.vb` → reemplazado módulo a módulo por Repositories EF Core.
- `SICADataSync` → reemplazado por Azure Functions + Service Bus.
- `wsSMIServer` ASMX → reemplazado por endpoint REST en la Web API.

---

## Article XVIII: API Management

- [x] **Azure API Management** — gateway centralizado (autenticación, rate limiting, routing).
- Versioning: URL path (`/api/v1/`, `/api/v2/`)
- OpenAPI: [x] Swashbuckle / Scalar en Development

---

## Skills Provisionados (Backend)

- `dotnet-backend-patterns` — Clean Architecture, CQRS nativo, Result pattern
- `backend-testing-dotnet` — xUnit, Testcontainers, Coverlet, Stryker
- `tdd-comprehensive` — Red-Green-Refactor, mutation testing discipline
- `integration-e2e-testing` — Testcontainers SQL Server, Respawn
- `gherkin-reqnroll` — BDD scenarios .NET, step definitions
- `azure-identity-dotnet` — Microsoft.Identity.Web, Azure AD B2C
