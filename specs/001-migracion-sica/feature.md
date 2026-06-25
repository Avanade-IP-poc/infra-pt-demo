---
feature: "001-migracion-sica"
title: "Migración de SICA a arquitectura cloud-native Azure"
phase: REASON
status: planned
language: es-ES
issue: "#TBD"
created: 2026-06-19
updated: 2026-06-24
source-architecture: demo/origen.md
target-architecture: demo/destino.md
scopes: [backend, frontend, cloud-platform, data, integration]
---

# Feature 001 — Migración de SICA a arquitectura cloud-native Azure

## 1. Contexto

SICA es un sistema legacy compuesto por un monolito **ASP.NET Web Forms** con lógica de
negocio en code-behind, un **Data Access Layer procedural** (`SQLMethods.vb`) sin ORM y
con concatenación de SQL sin parametrización, y procesos auxiliares en **VB.NET**
(`SICADataSync`, `wsSMIServer`). El inventario y anti-patrones están documentados en
[demo/origen.md](../../demo/origen.md).

El objetivo es modernizar el sistema hacia la arquitectura cloud-native descrita en
[demo/destino.md](../../demo/destino.md): **SPA React**, **API Gateway**, **Web API .NET 6+**,
**Azure Functions**, **Azure SQL Database**, **Azure AD B2C** y **Azure Monitor**.

## 2. Objetivo de negocio

- Reducir el riesgo de seguridad (eliminar SQL injection y mezcla de capas).
- Facilitar el mantenimiento y la evolución mediante separación de responsabilidades.
- Habilitar escalabilidad horizontal y observabilidad en Azure.
- Migrar sin interrupción del servicio, manteniendo el WebForms legacy en modo
  read-only durante la transición.

## 3. Alcance

### Incluido

- Extracción de la lógica de negocio a una Web API .NET 6+ (Clean Architecture).
- Reescritura del data layer procedural con acceso parametrizado / ORM sobre Azure SQL.
- Nueva SPA en React que consume la API a través del API Gateway.
- Autenticación con Azure AD B2C / Entra ID.
- Infraestructura como código (Bicep) y pipeline de CI/CD en GitHub Actions.
- Observabilidad con OpenTelemetry → Azure Monitor / Application Insights.

### Excluido (por ahora)

- Reescritura de los módulos legacy que permanecen read-only durante la transición.
- Nuevas funcionalidades de producto no presentes en el sistema actual.

## 4. Estrategia de migración (Strangler Fig)

| Fase   | Descripción                                              | Salida                          |
| ------ | -------------------------------------------------------- | ------------------------------- |
| Fase 1 | Rehost de WebForms en Azure App Service                  | Legacy operativo en Azure       |
| Fase 2 | Extracción de APIs y lógica de negocio a .NET 6+         | Web API + dominio modelado      |
| Fase 3 | Migración de la UI a SPA React                           | Frontend moderno en producción  |
| Fase 4 | Sustitución de integraciones y módulos legacy            | Decomisionado del monolito      |

## 5. Historias de usuario (alto nivel)

- **US-1** — Como arquitecto, quiero un análisis del legacy (assess + mapa + reglas de
  negocio) para basar la migración en el comportamiento real del sistema. `@smoke`
- **US-2** — Como desarrollador, quiero una Web API .NET 6+ que exponga la lógica de
  negocio existente vía REST con acceso a datos parametrizado.
- **US-3** — Como usuario, quiero una SPA React que reproduzca las funcionalidades
  actuales de SICA con UI responsiva. `@smoke`
- **US-4** — Como responsable de seguridad, quiero autenticación con Azure AD B2C y
  eliminación de las vulnerabilidades de SQL injection del legacy. `@smoke`
- **US-5** — Como operador, quiero observabilidad (Azure Monitor) y pipeline de CI/CD
  automatizado con quality gates.

## 6. Criterios de aceptación (resumen)

- [ ] El comportamiento del legacy queda fijado con tests de caracterización
      (golden-master) antes de cualquier reescritura.
  - 📋 **Escenarios BDD**: [characterization-equivalence.feature](tests/characterization-equivalence.feature) (6 escenarios)
- [ ] Cada endpoint migrado preserva la equivalencia funcional con el legacy.
  - 📋 **Tag**: `@characterization` — 15 escenarios de comparación Legacy vs Modern
- [ ] No existe SQL concatenado sin parametrizar en el código nuevo.
  - 📋 **Escenarios BDD**: [security-sql-injection-elimination.feature](tests/security-sql-injection-elimination.feature) (6 escenarios @security)
- [ ] La SPA cubre los UserControls/páginas críticos identificados en `origen.md`.
  - 📋 **Playwright E2E**: 10 escenarios @smoke en features de frontend
- [ ] Cobertura ≥ 80% y mutation score ≥ 70% en los módulos nuevos.
  - 📋 **Escenarios BDD**: [quality-gates.feature](tests/quality-gates.feature) (8 escenarios)
- [ ] Pipeline CI/CD verde con security scan sin críticos.
  - 📋 **Escenarios BDD**: [quality-gates.feature](tests/quality-gates.feature) + [security-sql-injection-elimination.feature](tests/security-sql-injection-elimination.feature)

## 7. Requisitos no funcionales

- **Seguridad**: TLS 1.2+, secretos en Key Vault, cumplimiento GDPR, WAF.
- **Rendimiento**: escalado horizontal en App Service / Functions.
- **Observabilidad**: trazas distribuidas, health checks `/health`, alertas.
- **Disponibilidad**: despliegue Blue-Green con Azure Deployment Slots.

## 8. Riesgos

| Riesgo                                            | Mitigación                                      |
| ------------------------------------------------- | ----------------------------------------------- |
| Lógica de negocio no documentada en code-behind   | Análisis legacy + tests de caracterización      |
| SQL injection en el data layer procedural         | Reescritura parametrizada + security scan       |
| Alta duplicación de UserControls y SQLMethods     | Modelado DDD para consolidar dominio            |
| Migración de datos con inconsistencias            | Pruebas de paridad y validación de datos        |

## 9. Próximos pasos

✅ **Completado**:
- [x] Análisis legacy completo ([.boltf/analysis/SICAWeb/](../../.boltf/analysis/SICAWeb/))
  - ASSESSMENT.md — inventario, top-10 deuda, dead code
  - TOPOLOGY.md — call graph, data lineage, SPOFs
  - BUSINESS_RULES.md — 17 reglas extraídas en Given/When/Then
  - DATA_OBJECTS.md — 9 tablas, 4 vistas, 6 DTOs SMI
- [x] Modelado DDD ([docs/design/ddd/](../../docs/design/ddd/))
  - 4 bounded contexts core (IAM, Card Management, Access Control, Monitoring)
  - 9 aggregates modelados
  - Context map + ubiquitous language
- [x] Plan técnico ([planning/](planning/))
  - research.md — decisiones arquitectónicas (ADRs referenciados)
  - data-model.md — modelo EF Core con 10 tablas nuevas + vistas compatibilidad
  - openapi.yaml — contrato API REST contract-first (35 endpoints)
  - plan.md — desglose en 13 Bolts (~6,5 semanas)
- [x] Escenarios BDD ([tests/](tests/))
  - 12 archivos .feature en español
  - 73 escenarios totales (38 marcados @smoke)
  - Cobertura de 9 reglas de negocio P0
  - Tests de caracterización (golden-master) + security + quality gates

🔜 **Siguiente fase — PLAN**:
1. **Generar tasks.md**: Invocar `@Bolt Tasks` para desglosar cada Bolt en tareas ejecutables
2. **Crear GitHub Issue**: Sustituir `issue: "#TBD"` por número de issue real
3. **Crear feature branch**: `feature/001-migracion-sica`

🚀 **Después — EXECUTE (CONSTRUCTION)**:
- Invocar `@Bolt Implement` para comenzar Bolt 1 (Rehost + Characterization tests)

1. `@Bolt Legacy Analyst` — análisis del código en `demo/from_old_src/` (assess, mapa,
   reglas de negocio en Given/When/Then).
2. `@Bolt DDD` — modelado del dominio (bounded contexts, agregados).
3. `@Bolt Plan` — plan técnico y desglose en Bolts.
4. `@Bolt Tasks` — lista de tareas por Bolt.
