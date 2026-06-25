# BOLT Framework — Scope Constitution: Integration

> **Proyecto**: SICA Modernization — Integration & Legacy Coexistence
> **Scope**: `integration`
> **Estado**: Ratificado — 2026-06-19
> **Fuente**: `demo/from_old_src/wsSMIServer/` (ASMX SOAP), `SICADataSync` (sync directo)
> **Destino**: `demo/destino.md` (API Gateway, Azure Functions, REST)

---

## Article IV §4.1-4.3: Communication

### §4.1: Communication Style

- [x] **Hybrid** — REST síncrono + mensajería asíncrona vía Azure Service Bus.

### §4.2: Synchronous Communication

- [x] **REST API** — Web API .NET 8 Controllers, expuesta vía Azure API Management.
- GraphQL: [ ] No — no requerido.
- gRPC: [ ] No — no requerido entre servicios internos inicialmente.

### §4.3: Asynchronous Communication

**Message Broker**:
- [x] **Azure Service Bus** — Standard tier.
  - Topics para eventos de dominio (accesos, alarmas, sincronización).
  - Queues para tareas de fondo (DataSync replacement).
  - Dead-letter queue con alertas.

**Background Processing**:
- [x] **Azure Functions** — reemplazo de `SICADataSync` y `wsSMIServer`.
  - Triggers: Service Bus trigger, Timer trigger, HTTP trigger.
  - Runtime: .NET 8 (isolated worker model).

---

## Article XVII: Legacy & Migration

### Estrategia de coexistencia (Strangler Fig)

| Sistema Legacy      | Modo durante Transición | Fase de Decomisión |
| ------------------- | ----------------------- | ------------------- |
| WebForms (SICAWeb)  | Read-only en Azure App Service | Fase 3-4     |
| wsSMIServer (ASMX)  | Proxy → nuevo REST endpoint    | Fase 2       |
| SICADataSync        | Reemplazado por Az Functions   | Fase 2       |

**Regla**: El WebForms legacy NO puede escribir en la misma base de datos que la nueva API
una vez que la API esté en producción. Se introduce un API Gateway como intermediario.

### Patrones de integración

- [x] **Anti-Corruption Layer (ACL)** — entre el dominio nuevo y el esquema legacy.
- [x] **Adapter** — para `wsSMIServer` ASMX hasta que sea decomisionado.
- [x] **Outbox Pattern** — para garantía de entrega en eventos de dominio via Service Bus.

---

## Article XVIII: API Management

- [x] **Azure API Management** (Developer tier en dev, Standard en prod).
  - Centraliza: autenticación JWT, rate limiting, logging, routing.
  - Versioning: `/api/v1/`, `/api/v2/`
  - Portal de desarrolladores: habilitado.
  - Products: interno (backend services) + externo (si aplica en futuro).
  - Policies: validación JWT (Azure AD B2C), CORS, rate limit 100 req/min por cliente.

---

## Article X-XI (Integración): Environments & CI/CD

- Entornos: dev / uat / pre / prod (mismo esquema que backend/cloud-platform).
- Deployment Service Bus topics/queues: gestionado vía Bicep (mismos módulos).
- Tests de integración: verifican contratos de mensajes (Azure Service Bus emulado en tests).

---

## Skills Provisionados (Integration)

- `azure-identity-dotnet` — MSAL, Microsoft.Identity.Web, token validation en API
- `github-actions-templates` — workflows reutilizables para despliegue de Functions y APIM
