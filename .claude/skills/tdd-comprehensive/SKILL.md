---
name: tdd-comprehensive
description: Comprehensive TDD/BDD discipline with Red-Green-Refactor cycle, mutation testing, and coverage-first approach for both .NET backend and React frontend. Use when driving development with tests first, checking coverage thresholds, or validating mutation scores. Triggers => "TDD", "BDD", "red green refactor", "mutation testing", "coverage", "test first", "Stryker", "Vitest TDD". See also skill-tdd-red-green-refactor for the cycle details.
provisioned_from: .boltf/available-skills/tdd/tdd-comprehensive
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# TDD Comprehensive — Red-Green-Refactor + Mutation Testing

> See also the detailed cycle in `skill-tdd-red-green-refactor`.

## When to Use

- Starting any new feature (test FIRST, code second)
- Validating quality gates (coverage ≥ 80%, mutation ≥ 70%)
- Refactoring legacy code from `SQLMethods.vb` / code-behind
- Characterization tests for legacy behavior before rewrite

## The Cycle

```
🔴 RED   — Write a failing test that describes desired behaviour
🟢 GREEN — Write the MINIMAL code to make the test pass
🔵 REFACTOR — Improve the code keeping tests green
```

**Rule**: Never write production code without a failing test first.

## Backend (.NET 8 / xUnit)

```csharp
// 1. RED — failing test
[Fact]
public async Task GetAccessByCardId_WhenCardNotFound_ReturnsFailure()
{
    _repository.GetByCardIdAsync("UNKNOWN", Arg.Any<CancellationToken>())
               .Returns((AccessEntry?)null);

    var result = await _handler.HandleAsync(
        new GetAccessByCardQuery("UNKNOWN"), default);

    result.IsSuccess.Should().BeFalse();
    result.ErrorCode.Should().Be("NOT_FOUND");
}

// 2. GREEN — minimal implementation
public async Task<Result<AccessEntry>> HandleAsync(
    GetAccessByCardQuery query, CancellationToken ct)
{
    var entry = await _repository.GetByCardIdAsync(query.CardId, ct);
    return entry is null
        ? Result<AccessEntry>.Failure("NOT_FOUND", $"Card {query.CardId} not found")
        : Result<AccessEntry>.Success(entry);
}
```

## Frontend (React / Vitest + RTL)

```typescript
// 1. RED — failing test
it('shows error message when card not found', async () => {
  server.use(
    http.get('/api/v1/access/:cardId', () =>
      HttpResponse.json({ error: 'NOT_FOUND' }, { status: 404 })
    )
  );
  render(<AccessDetail cardId="UNKNOWN" />);
  expect(await screen.findByText(/card not found/i)).toBeInTheDocument();
});

// 2. GREEN — minimal component
export function AccessDetail({ cardId }: { cardId: string }) {
  const { data, error } = useQuery({ queryKey: ['access', cardId], ... });
  if (error) return <p>Card not found</p>;
  return <div>{data?.cardId}</div>;
}
```

## Mutation Testing

### .NET — Stryker.NET

```bash
dotnet tool install -g dotnet-stryker
dotnet stryker --threshold-high 80 --threshold-low 70 --threshold-break 60
```

Minimum acceptable score: **70%** (mutation score = killed / total mutants)

### Frontend — Stryker JS

```bash
npx stryker run
# stryker.config.json → thresholds: { high: 80, low: 70, break: 60 }
```

## Quality Gates (mandatory per Bolt)

| Metric          | Minimum | Tool               |
| --------------- | ------- | ------------------ |
| Line Coverage   | ≥ 80%   | Coverlet / Istanbul|
| Branch Coverage | ≥ 75%   | Coverlet / Istanbul|
| Mutation Score  | ≥ 70%   | Stryker            |

## Characterization Tests (Legacy)

Before rewriting ANY module from `SQLMethods.vb` or code-behind:

```csharp
// Golden-master: capture real output from legacy system
[Fact]
public async Task LegacyGetAccessLogs_ProducesKnownOutput()
{
    // Run legacy SQLMethods (via adapter) and capture result
    var legacyResult = await _legacyAdapter.GetAccessLogsAsync("ZONE-01");
    // Snapshot assertion
    legacyResult.Should().BeEquivalentTo(_expectedSnapshot);
}
```

See `skill-characterization-testing` for full golden-master patterns.

## References (source)

`.boltf/available-skills/tdd/tdd-comprehensive/`
