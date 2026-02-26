---
name: skill-bolt-quality-gates
description: Per-BOLT quality gates with coverage, mutation, and linting thresholds
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
