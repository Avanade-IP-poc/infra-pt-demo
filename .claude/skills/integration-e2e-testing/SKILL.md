---
name: integration-e2e-testing
description: Comprehensive integration and E2E testing with Playwright, Aspire, Testcontainers and Respawn for .NET. Use when writing integration tests, E2E tests, database tests, or any test requiring real infrastructure. CRITICAL — NEVER use SQLite for integration tests — SQL Server only.
provisioned_from: .boltf/available-skills/functional-tests/integration-e2e-testing
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Integration & E2E Testing

## 🚨 CRITICAL RULES

- **NEVER use SQLite** for integration tests — SQL Server only (Testcontainers).
- **NEVER reset database at END of test** — always reset at **START**.
- **NEVER create a new container per test** — use the shared `GlobalTestContainers`.

## Infrastructure Overview

| Layer             | Infrastructure                                 | Reset          |
| ----------------- | ---------------------------------------------- | -------------- |
| Integration tests | `DatabaseFixture<SicaDbContext>` + Respawn      | START of test  |
| Shared container  | `GlobalTestContainers` (one SQL Server per run)| Once per suite |
| E2E (Playwright)  | `DatabaseHelper` (via HTTP API)                | Per test       |

**Respawn reset time**: ~200-300ms

## Integration Test Pattern

```csharp
[Collection("Database")]
[Trait("Category", "Integration")]
[Trait("Database", "Required")]
[Trait("Feature", "Access")]
public class AccessRepositoryTests : IAsyncLifetime
{
    private readonly DatabaseFixture<SicaDbContext> _fixture;

    public AccessRepositoryTests(DatabaseFixture<SicaDbContext> fixture)
        => _fixture = fixture;

    public async Task InitializeAsync()
        => await _fixture.ResetDatabaseAsync(); // Reset at START

    public Task DisposeAsync() => Task.CompletedTask;

    [Fact]
    public async Task GetByCardId_WhenExists_ReturnsEntry()
    {
        // Arrange — seed via repository
        var card = new AccessEntryBuilder().WithCardId("CARD-TEST").Build();
        await _fixture.DbContext.AccessEntries.AddAsync(card);
        await _fixture.DbContext.SaveChangesAsync();

        // Act
        var repo = new AccessRepository(_fixture.DbContext);
        var result = await repo.GetByCardIdAsync("CARD-TEST", default);

        // Assert
        result.Should().NotBeNull();
        result!.CardId.Should().Be("CARD-TEST");
    }
}
```

## DatabaseFixture Setup

```csharp
// tests/Sica.IntegrationTests/Infrastructure/DatabaseCollection.cs
[CollectionDefinition("Database")]
public class DatabaseCollection
    : ICollectionFixture<DatabaseFixture<SicaDbContext>> { }
```

## GlobalTestContainers (CI)

```csharp
// One shared SQL Server container for all integration tests
// Activated when USE_TESTCONTAINERS=true (set in GitHub Actions)
public static class GlobalTestContainers
{
    public static readonly MsSqlContainer SqlServer = new MsSqlBuilder()
        .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
        .Build();
}
```

## Playwright Database Reset

```typescript
// e2e/helpers/database-helper.ts
const db = new DatabaseHelper(request);
await db.resetAndSeed(); // POST /api/testing/{workerIndex}/reset-and-seed-all
```

## Tag Classification

| Tag            | Purpose                          | CI?        |
| -------------- | -------------------------------- | ---------- |
| `@smoke`       | Critical happy-path pre-deploy   | pre-deploy |
| `@regression`  | Full suite on every PR           | always     |
| `@integration` | Requires DB + backend            | always     |
| `@manual`      | Never auto-runs                  | ❌          |

## Required C# Traits

```csharp
[Trait("Category", "Integration")]
[Trait("Speed", "Medium")]
[Trait("Feature", "Access")]          // Bounded context
[Trait("Database", "Required")]       // MANDATORY for DB tests
```

## Running Tests

```bash
# Local (LocalDB)
dotnet test --filter "Category=Integration"

# CI (Testcontainers)
USE_TESTCONTAINERS=true dotnet test --filter "Category=Integration"
```

## Coverage Targets

- Infrastructure layer ≥ 80%
- Repository layer ≥ 90%

## References (source)

`.boltf/available-skills/functional-tests/integration-e2e-testing/`
- `examples/DatabaseFixture.cs`
- `examples/GlobalTestContainers.cs`
- `examples/integration-test.cs`
