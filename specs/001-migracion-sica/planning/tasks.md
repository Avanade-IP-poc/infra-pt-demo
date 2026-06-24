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

## Bolts siguientes (resumen — ver plan.md §5)

| # | Nombre | Estado |
|---|--------|--------|
| 2 | Backend: IAM Core | Planned |
| 3 | Backend: SMI ACL | Planned |
| 4 | Backend: Card Management | Planned |
| 5 | Backend: Access Control | Planned |
| 6 | Backend: Monitoring | Planned |
| 7 | Frontend: Foundation | Planned |
| 8 | Frontend: Dashboard | Planned |
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
