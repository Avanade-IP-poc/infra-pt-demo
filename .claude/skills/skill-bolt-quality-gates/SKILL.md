---
name: skill-bolt-quality-gates
description: "Per-Bolt quality gates with code coverage, mutation testing, and linting thresholds. MANDATORY at the end of every Bolt iteration - no PR merge without passing gates. Use for enforcing quality standards, checking coverage, running mutation tests, or validating linting. Triggers => 'quality gates', 'coverage threshold', 'mutation testing', 'lint check', 'quality check', 'gate validation', 'Bolt gates', 'enforce quality'. NON-OPTIONAL checkpoint."
---

# Quality Gates

## When to Use

- At the end of every BOLT iteration (MANDATORY)
- Before merging BOLT branch to feature branch
- During CI/CD pipeline execution

## Quality Gate Thresholds

| Metric          | Minimum | Recommended | Critical Paths |
| --------------- | ------- | ----------- | -------------- |
| Line Coverage   | 80%     | 90%         | 100%           |
| Branch Coverage | 75%     | 85%         | 100%           |
| Mutation Score  | 70%     | 80%         | 90%            |
| Linting Errors  | 0       | 0           | 0              |
| Test Pass Rate  | 100%    | 100%        | 100%           |

## Equivalence Gate (Brownfield / Modernización)

**Aplica SOLO a proyectos brownfield / migración.** Garantiza que el código modernizado
**preserva el comportamiento del legacy** antes de aceptar un Bolt. Se apoya en la skill
`skill-characterization-testing` y en las reglas `RULE-NNN` de `bolt-legacy-analyst`.

| Métrica | Mínimo | Crítico (rutas P0) |
| --- | --- | --- |
| Equivalence pass rate (legacy ↔ moderno) | 95% | 100% |
| Legacy behavior coverage (comportamientos P0 caracterizados) | 100% P0 | 100% |
| Discrepancias sin decidir (replicar vs. corregir, con SME) | 0 | 0 |

**Tareas obligatorias del Bolt (brownfield):**

| Task ID | Descripción | Umbral |
| --- | --- | --- |
| TXX-EQ | Tests de caracterización para reglas P0 del módulo | 100% P0 cubiertas |
| TXX-EQ | Ejecutar suite de equivalencia (golden master / parity) | pass ≥ 95% |
| TXX-EQ | Revisar discrepancias vs. legacy (defectos sospechosos) | 0 sin decidir |

> Regla: **ningún Bolt de migración pasa** si la equivalence pass rate < umbral o hay
> comportamientos P0 sin caracterizar. Las discrepancias se escalan a SME, no se "arreglan" en silencio.

## MANDATORY Quality Gate Tasks

**Each BOLT MUST include these trackable tasks:**

| Task ID Pattern | Description            | Command                              | Threshold |
| --------------- | ---------------------- | ------------------------------------ | --------- |
| TXX-QG          | Run linting            | `npm run lint` / `dotnet format`     | 0 errors  |
| TXX-QG          | Run all tests          | `npm test` / `dotnet test`           | 100% pass |
| TXX-QG          | Run coverage report    | `npm run test:cov`                   | Generate  |
| TXX-QG          | Verify line coverage   | Check report                         | >= 80%    |
| TXX-QG          | Verify branch coverage | Check report                         | >= 75%    |
| TXX-QG          | Run mutation tests     | `npx stryker run` / `dotnet stryker` | Generate  |
| TXX-QG          | Verify mutation score  | Check report                         | >= 70%    |

## Mutation Testing Tools by Language

| Language       | Mutation Tool   | Coverage Tool  | Config File           |
| -------------- | --------------- | -------------- | --------------------- |
| **Java**       | PIT (Pitest)    | JaCoCo         | `pom.xml`             |
| **.NET/C#**    | Stryker.NET     | coverlet       | `stryker-config.json` |
| **JavaScript** | Stryker Mutator | Istanbul/NYC   | `stryker.conf.js`     |
| **TypeScript** | Stryker Mutator | Istanbul/NYC   | `stryker.conf.js`     |
| **Python**     | mutmut          | coverage.py    | `pyproject.toml`      |
| **Go**         | go-mutesting    | go test -cover | `Makefile`            |

## Setup (First BOLT Only)

### Node.js/TypeScript

```bash
npm install --save-dev @stryker-mutator/core @stryker-mutator/jest-runner @stryker-mutator/typescript-checker
npx stryker init
```

### .NET

```bash
dotnet tool install -g dotnet-stryker
dotnet stryker init
```

## Example Quality Gate Checklist

```markdown
### Quality Gates (MANDATORY)

- [ ] T009-QG Run linting: `npm run lint` or `dotnet format`
- [ ] T010-QG Run all tests: `npm test` or `dotnet test`
- [ ] T011-QG Run coverage report: `npm run test:cov`
- [ ] T012-QG Verify coverage >= 80% (constitution threshold)
- [ ] T013-QG Configure mutation testing tool (Stryker)
- [ ] T014-QG Run mutation tests: `npx stryker run`
- [ ] T015-QG Verify mutation score >= 70%
```

## Quality Gate Failure Policy

- **Coverage < 80%**: BOLT cannot be marked complete
- **Mutation Score < 70%**: Tests need improvement before proceeding
- **Any test failure**: Fix before next task
- **Linting errors**: Must resolve before merge

## References

- @bolt-tasks agent (Quality gate task generation)
- @bolt-testing agent (Coverage and mutation testing)
- `.boltf/memory/constitution.md` (Project thresholds)
