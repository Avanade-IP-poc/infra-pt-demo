# Research — Migración SICAWeb

> **Feature**: 001-migracion-sica
> **Fase Bolt**: REASON (Planning)
> **Fecha**: 2026-06-24

---

## 1. Contexto técnico

### 1.1 Sistema legacy analizado

| Aspecto | Hallazgo |
|---|---|
| **LOC** | ~2 400 líneas VB.NET |
| **Arquitectura** | ASP.NET WebForms 4.0 con code-behind procedural |
| **DAL** | SQLMethods.vb sin ORM, concatenación de SQL sin parametrizar |
| **Integración** | SOAP WCF → wsSMIServer (hardware de acceso físico) |
| **Estado** | ASP.NET Session — no escalable horizontalmente |
| **Seguridad** | 12 puntos SQL injection (OWASP A03), credenciales en Web.config |

📍 **Análisis completo**: [.boltf/analysis/SICAWeb/](../../.boltf/analysis/SICAWeb/)

### 1.2 Bounded Contexts modelados

| Bounded Context | Aggregates | Prioridad |
|---|---|---|
| **Identity & Access Management** | User, Terminal, Session | P0 |
| **Card Management** | SmartCard, VisitorCard | P0 |
| **Access Control** | AccessFamily, AccessPolicy, Circuit | P0 |
| **Physical Access Monitoring** | AccessEvent, Alarm | P1 |

📍 **DDD completo**: [docs/design/ddd/](../../docs/design/ddd/)

---

## 2. Decisiones arquitectónicas

### 2.1 Patrón de migración: Strangler Fig

**Elección**: Strangler Fig con 4 fases (Rehost → API → SPA → Decomisión)

**Alternativas consideradas**:
- ❌ **Big Bang rewrite** — riesgo alto, sin rollback
- ❌ **Replatform puro** — WebForms no soportado en .NET 8, deuda de seguridad persiste
- ✅ **Strangler Fig** — permite validar cada fase con el legacy activo, rollback granular

**Trade-offs**:
- ✅ Riesgo distribuido en fases
- ✅ Rollback por fase
- ⚠️ Periodo de coexistencia (~3-4 meses) con sobrecarga de mantenimiento dual

**ADR**: [ADR-004-migracion-strangler-fig-characterization-tests.md](../../docs/adr/ADR-004-migracion-strangler-fig-characterization-tests.md)

---

### 2.2 Backend: Clean Architecture + CQRS + Modular Monolith

**Elección**: Modular Monolith con Clean Architecture + CQRS en .NET 8

**Stack**:
- **.NET 8** — LTS con soporte hasta nov 2026
- **Minimal APIs** — endpoints ligeros sobre MVC
- **MediatR** — bus in-process para commands/queries
- **Entity Framework Core 8** — ORM con migrations
- **FluentValidation** — validación declarativa
- **Mapster** — mapeo de DTOs

**Estructura de capas**:
```
src/
├── SICA.Api/                      # Presentation (Minimal APIs)
├── SICA.Application/              # Application (CQRS handlers)
│   ├── IAM/
│   ├── CardManagement/
│   ├── AccessControl/
│   └── Monitoring/
├── SICA.Domain/                   # Domain (aggregates, VOs)
│   ├── IAM/
│   ├── CardManagement/
│   ├── AccessControl/
│   └── Monitoring/
├── SICA.Infrastructure/           # Infrastructure (EF, repos, SMI adapter)
│   ├── Persistence/
│   ├── SMI/                       # Anti-Corruption Layer
│   └── Identity/
└── SICA.Contracts/                # DTOs, OpenAPI schemas
```

**ADR**: [ADR-001-backend-stack-dotnet8-modular-monolith-cqrs.md](../../docs/adr/ADR-001-backend-stack-dotnet8-modular-monolith-cqrs.md)

---

### 2.3 Frontend: React 18 SPA + Tailwind CSS

**Elección**: React 18 SPA con Vite, TypeScript, Tailwind CSS v4

**Stack**:
- **React 18** con hooks
- **TypeScript 5** — type safety
- **Vite** — build tool (reemplazo de CRA)
- **Tailwind CSS v4** — utility-first CSS
- **TanStack Query v5** — server state
- **Zustand** — client state ligero
- **React Router v6** — enrutamiento
- **MSAL React** — autenticación Azure AD B2C

**Estructura**:
```
src/
├── features/              # Feature-based slices
│   ├── iam/
│   ├── cards/
│   ├── access-control/
│   └── monitoring/
├── components/            # Componentes compartidos
├── layouts/               # Layouts (Dashboard, Auth)
├── api/                   # Clientes HTTP (TanStack Query)
└── auth/                  # MSAL config
```

**ADR**: [ADR-002-frontend-react18-typescript-vite.md](../../docs/adr/ADR-002-frontend-react18-typescript-vite.md)

---

### 2.4 Infraestructura: Azure PaaS + Bicep

**Elección**: Azure PaaS con Bicep IaC

**Servicios**:
- **Azure App Service** (Plan: P1v3) — Web API + SPA
- **Azure SQL Database** (S1) — base de datos
- **Azure Key Vault** — secretos
- **Azure Application Gateway** — ingress + WAF
- **Azure Monitor + Application Insights** — observabilidad
- **Azure AD B2C** — autenticación

**IaC**:
- **Bicep** (no Terraform) — primera clase en Azure
- **GitHub Actions** — CI/CD
- **ARM what-if** — validación pre-deploy

**ADR**: [ADR-003-infra-azure-appservice-bicep-ghactions.md](../../docs/adr/ADR-003-infra-azure-appservice-bicep-ghactions.md)

---

### 2.5 SMI Anti-Corruption Layer

**Problema**: wsSMIServer es una caja negra SOAP sin contrato formal, único punto de integración con hardware.

**Elección**: Adapter con interfaz propia + mock para tests

**Diseño**:
```csharp
// Dominio puro
public interface ISMIService
{
    Task<SmartCardProperties> GetCardByIdAsync(CardId id);
    Task<IEnumerable<AccessEvent>> GetLastEventsAsync(CircuitId circuitId, int hours, int maxEvents);
    Task UpdateCardStatusAsync(CardId id, CardStatus status);
}

// Infraestructura
public class SMISoapAdapter : ISMIService
{
    private readonly SMIMethodsSoapClient _client;
    // Mapeo de DTOs SOAP → Domain
}

// Tests
public class SMIMockAdapter : ISMIService
{
    // Respuestas predefinidas para characterization tests
}
```

**Beneficios**:
- ✅ Mockeable para tests sin hardware
- ✅ Domain desacoplado del protocolo SOAP
- ✅ Sustituible si cambia el hardware

---

## 3. Estrategia de testing

### 3.1 Tests de caracterización (golden-master)

**Prioridad**: P0 — bloqueante antes de cualquier reescritura

**Reglas P0 a fijar** (de [BUSINESS_RULES.md](../../.boltf/analysis/SICAWeb/BUSINESS_RULES.md)):
- RULE-001: Autorización de terminal por IP o nombre
- RULE-007: Perfil de acceso de terminal
- RULE-008: Tarjeta disponible sólo si tiene hora de salida
- RULE-011: Clasificación de movimiento como Entrada/Salida
- RULE-013: Acceso del terminal a la tarjeta

**Herramientas**:
- **ApprovalTests.Net** — golden-master snapshots
- **Reqnroll** (BDD) — escenarios From/To legacy→modern

**Ejemplo**:
```csharp
[Fact]
public async Task RULE_001_TerminalAuthorization_Legacy_Vs_Modern()
{
    var legacyResult = await LegacyFacade.VerificaAcesso("TERM01", "192.168.1.100");
    var modernResult = await ModernApi.AuthorizeTerminalAsync(new("TERM01", "192.168.1.100"));
    
    ApprovalTests.Approvals.VerifyJson(new { legacyResult, modernResult });
}
```

📍 **Skill**: [skill-characterization-testing](../../.claude/skills/skill-characterization-testing/SKILL.md)

---

### 3.2 Pirámide de testing

| Nivel | Cobertura objetivo | Herramientas |
|---|---|---|
| **Unit** | ≥ 80% | xUnit, FluentAssertions |
| **Integration** | Repositorios + EF | Testcontainers (SQL Server), Respawn |
| **E2E** | Smoke paths (`@smoke`) | Playwright |
| **Mutation** | ≥ 70% | Stryker.NET |

---

## 4. Dependencias externas y riesgos

### 4.1 wsSMIServer (SPOF crítico)

| Aspecto | Estado |
|---|---|
| **Contrato formal** | ❌ No existe — inferido del WSDL + code-behind |
| **Mock disponible** | ❌ No — se creará en B3 |
| **Documentación** | ❌ No — reverse engineering del legacy |
| **Equipo propietario** | ⚠️ Desconocido — vendor externo posible |

**Mitigación**:
1. Bolt 3 incluye creación del mock SMI con respuestas del legacy capturadas.
2. ACL (`ISMIService`) desacopla el dominio del SOAP client.
3. Fallback: si SMI no responde, API retorna 503 con mensaje descriptivo.

---

### 4.2 Base de datos Alizes/REFER

| Aspecto | Estado |
|---|---|
| **Propiedad** | ⚠️ Externa — equipo REFER |
| **Dependencia** | Media — usada en ActivarCartoes + LogHistorico |
| **Migración** | ⚠️ No controlada por este proyecto |

**Mitigación**:
- Mantener acceso read-only vía connection string secundaria.
- Si REFER migra su BD, actualizar connection string sin cambiar código.

---

## 5. Quality gates obligatorios (per-Bolt)

| Gate | Threshold | Herramienta |
|---|---|---|
| **Linting** | 0 warnings as errors | Roslyn analyzers |
| **Unit coverage** | ≥ 80% | Coverlet |
| **Mutation score** | ≥ 70% | Stryker.NET |
| **Architecture compliance** | 0 violations | NetArchTest |
| **Security scan** | 0 Critical/High | Trivy / OWASP Dependency Check |

---

## 6. Estimación de complejidad

| Módulo | Complejidad | Justificación |
|---|---|---|
| **IAM** | Media | RULE-001, 002, 003 — lógica clara |
| **Card Management** | Alta | Sincronización SMI + clasificación por prefijo |
| **Access Control** | Alta | Modelo de permisos Terminal↔Familia↔Circuito |
| **Monitoring** | Media | Mayormente consulta, poca lógica |
| **SMI ACL** | Alta | Sin spec, reverse engineering |
| **Frontend** | Media | Reproducir 7 páginas legacy |
| **Infra** | Baja | Bicep estándar Azure PaaS |

**Riesgo mayor**: SMI ACL sin contrato formal (alta incertidumbre).
