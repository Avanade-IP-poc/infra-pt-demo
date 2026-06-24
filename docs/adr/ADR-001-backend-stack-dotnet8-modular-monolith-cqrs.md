# ADR-001: Backend Stack — C#/.NET 8, Modular Monolith, CQRS Nativo, EF Core 8

> **Estado**: Accepted
> **Fecha**: 2026-06-19
> **Proyecto**: SICA Modernization
> **Scope**: backend

---

## Contexto

El sistema legacy SICA está implementado en VB.NET con ASP.NET WebForms (monolito),
lógica de negocio en code-behind y un Data Access Layer procedural (`SQLMethods.vb`)
con concatenación de SQL sin parametrizar. Hay 29 violaciones críticas de código
(principalmente SQL injection) y elevada duplicación.

Se necesita definir el stack técnico para el sistema de destino descrito en
`demo/destino.md`.

## Decisión

Adoptamos **C#/.NET 8 LTS** como lenguaje y runtime backend, con:

1. **ASP.NET Core Controllers** para la Web API REST
2. **Azure Functions (Isolated Worker .NET 8)** para procesamiento asíncrono
3. **Modular Monolith** como arquitectura (Clean Architecture interno)
4. **Simple CQRS nativo .NET** sin MediatR
5. **EF Core 8** como ORM sobre Azure SQL Database

## Opciones Consideradas

| Opción | Pros | Contras | Decisión |
| ------ | ---- | ------- | -------- |
| C#/.NET 8 LTS | Stack destino especificado, LTS 3 años, ecosistema Azure nativo | — | ✅ Elegida |
| .NET 6 LTS | Compatible con `destino.md` | EOL Nov 2024 | ❌ |
| Node.js / TypeScript | Mismo lenguaje que frontend | Skill gap del equipo, ecosistema Azure C# es más maduro | ❌ |
| Microservicios desde día 1 | Mayor escalabilidad | Over-engineering para migración, Strangler Fig requiere evolución gradual | ❌ |
| MediatR | Pipeline de comportamientos, comunidad grande | Dependencia adicional, abstracción innecesaria para Simple CQRS | ❌ |
| Dapper (solo) | Performance máximo | Sin change tracking, más código boilerplate | ❌ uso híbrido |

## Consecuencias

**Positivas**:
- .NET 8 LTS garantiza soporte hasta Nov 2026 (alineado con timeline del proyecto)
- Clean Architecture facilita los tests de caracterización y la migración módulo a módulo
- CQRS nativo sin MediatR reduce dependencias y complejidad (se puede auditar por arquitectura tests)
- EF Core 8 elimina el SQL concatenado del legacy (cero SQL injection)
- Azure Functions en Isolated Worker permite upgrade independiente de la Web API

**Negativas / Riesgos**:
- El equipo debe aprender Clean Architecture si viene del modelo WebForms
- La migración Database-First a Code-First requiere scaffolding inicial del esquema legacy
- La complejidad de Modular Monolith aumenta si los límites de módulo no se definen bien con DDD

## Compliance

- ✅ Constitution Art. II §2.1: C#/.NET 8, Controllers + Functions
- ✅ Constitution Art. III §3.1/3.3: Modular Monolith, CQRS Simple nativo
- ✅ Constitution Art. V: EF Core 8, Azure SQL
- ✅ Constitution Art. XIII: xUnit, Coverlet ≥80%, Stryker ≥70%
