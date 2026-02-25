---
name: integration-e2e-testing
description:
  Comprehensive integration and E2E testing with Testcontainers and Respawn for .NET. Use when
  writing integration tests, E2E tests, database tests, or any test requiring real infrastructure.
  CRITICAL - NEVER use SQLite for integration tests, ALWAYS use Testcontainers with SQL Server. Use
  Respawn for fast database state management between tests.
---

# Integration & E2E Testing with Testcontainers & Respawn

Complete testing skill for integration and E2E tests using real infrastructure.

## 🚨 CRITICAL RULE - NO SQLITE FOR INTEGRATION TESTS

**NEVER use SQLite in-memory databases for integration testing.**

### Why SQLite is Prohibited

1. **SQL Syntax Incompatibility**: SQL Server features not supported by SQLite
   - `IDENTITY` columns, `MAX()` in specific contexts
   - `DATEADD()`, `GETUTCDATE()` functions
   - Window functions, transaction isolation levels differ

2. **False Positives**: Tests pass with SQLite but fail in production
   - Column types behave differently
   - Constraints validation differs
   - Query execution plans differ

3. **Real-World Issues**: Bolt 4 example
   ```
   SQLite Error: 'near "max": syntax error'
   14/15 integration tests FAILED → 0% confidence
   ```

### ✅ ALWAYS Use Testcontainers + Podman

- **Real SQL Server**: `mcr.microsoft.com/mssql/server:2022-latest`
- **Podman** (no license): Create `.testcontainers.properties`:
  ```text
  docker.host=npipe://./pipe/podman-machine-default
  ```

### ✅ ALWAYS Use Respawn

- **Do NOT** start/stop SQL per test → start once, **reset state with Respawn**
- Respawn: ~0.3s reset vs 5s container restart

---

## When to Activate This Skill

**Triggers**: integration test, E2E test, database test, repository test, testcontainers, respawn,
reset database, test isolation, SQLite error

---

## Quick Start

### 1. Installation

```bash
dotnet add package Testcontainers
dotnet add package Testcontainers.MsSql
dotnet add package Respawn --version 6.2.1
dotnet add package Microsoft.Data.SqlClient
```

### 2. Base Test Class (with Respawn)

```csharp
// File: tests/Tests.Shared/IntegrationTestBase.cs

using Respawn;
using Testcontainers.MsSql;
using Microsoft.EntityFrameworkCore;
using Microsoft.Data.SqlClient;
using Xunit;

public abstract class IntegrationTestBase : IAsyncLifetime
{
    private MsSqlContainer? _mssqlContainer;
    private Respawner? _respawner;
    private string? _connectionString;

    protected DbContextOptions<YourDbContext>? DbContextOptions;

    public async Task InitializeAsync()
    {
        // 1. Start SQL Server container ONCE
        _mssqlContainer = new MsSqlBuilder()
            .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
            .WithPassword("YourStrong!Passw0rd")
            .Build();

        await _mssqlContainer.StartAsync();
        _connectionString = _mssqlContainer.GetConnectionString();

        // 2. Configure DbContext
        DbContextOptions = new DbContextOptionsBuilder<YourDbContext>()
            .UseSqlServer(_connectionString)
            .Options;

        // 3. Run migrations ONCE
        await using var context = new YourDbContext(DbContextOptions);
        await context.Database.MigrateAsync();

        // 4. Initialize Respawn AFTER migrations
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();

        _respawner = await Respawner.CreateAsync(connection, new RespawnerOptions
        {
            DbAdapter = DbAdapter.SqlServer, // REQUIRED
            SchemasToInclude = new[] { "dbo" },
            TablesToIgnore = new[]
            {
                new Table("__EFMigrationsHistory") // Preserve migrations
            }
        });
    }

    public async Task DisposeAsync()
    {
        if (_mssqlContainer != null)
        {
            await _mssqlContainer.StopAsync();
            await _mssqlContainer.DisposeAsync();
        }
    }

    protected YourDbContext CreateDbContext() => new YourDbContext(DbContextOptions!);

    /// <summary>
    /// Resets database to clean state. Call at START of each test.
    /// </summary>
    protected async Task ResetDatabaseAsync()
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        await _respawner!.ResetAsync(connection);
    }
}
```

### 3. Write Tests

```csharp
public class UserRepositoryTests : IntegrationTestBase
{
    [Fact]
    public async Task SaveUser_ShouldPersistToDatabase()
    {
        // ✅ RESET AT START - Clean state guaranteed
        await ResetDatabaseAsync();

        await using var context = CreateDbContext();
        var repository = new UserRepository(context);

        var user = Usuario.Create(
            new Email("test@example.com"),
            new FullName("Test", "User"),
            TenantId.Create(Guid.NewGuid())
        );

        // Act
        await repository.SaveAsync(user);
        await context.SaveChangesAsync();

        // Assert
        var savedUser = await repository.GetByIdAsync(user.Id);
        savedUser.Should().NotBeNull();
        savedUser!.Email.Value.Should().Be("test@example.com");
    }
}
```

---

## Performance: Shared Container Pattern

**For test suites with 20+ tests**, use shared container for optimal speed:

```csharp
// File: tests/Tests.Shared/DatabaseFixture.cs

public class DatabaseFixture : IAsyncLifetime
{
    private MsSqlContainer? _container;
    private Respawner? _respawner;

    public string ConnectionString { get; private set; } = string.Empty;
    public DbContextOptions<YourDbContext> DbContextOptions { get; private set; } = null!;

    public async Task InitializeAsync()
    {
        // Container starts ONCE for entire suite
        _container = new MsSqlBuilder()
            .WithImage("mcr.microsoft.com/mssql/server:2022-latest")
            .WithPassword("YourStrong!Passw0rd")
            .Build();

        await _container.StartAsync();
        ConnectionString = _container.GetConnectionString();

        DbContextOptions = new DbContextOptionsBuilder<YourDbContext>()
            .UseSqlServer(ConnectionString)
            .Options;

        await using var context = new YourDbContext(DbContextOptions);
        await context.Database.MigrateAsync();

        await using var connection = new SqlConnection(ConnectionString);
        await connection.OpenAsync();

        _respawner = await Respawner.CreateAsync(connection, new RespawnerOptions
        {
            DbAdapter = DbAdapter.SqlServer,
            SchemasToInclude = new[] { "dbo" },
            TablesToIgnore = new[] { new Table("__EFMigrationsHistory") }
        });
    }

    public async Task DisposeAsync()
    {
        if (_container != null)
        {
            await _container.StopAsync();
            await _container.DisposeAsync();
        }
    }

    public async Task ResetDatabaseAsync()
    {
        await using var connection = new SqlConnection(ConnectionString);
        await connection.OpenAsync();
        await _respawner!.ResetAsync(connection);
    }
}

[CollectionDefinition("Database")]
public class DatabaseCollection : ICollectionFixture<DatabaseFixture> { }
```

**Usage**:

```csharp
[Collection("Database")] // Shared container
public class UserTests
{
    private readonly DatabaseFixture _fixture;

    public UserTests(DatabaseFixture fixture) => _fixture = fixture;

    [Fact]
    public async Task Test1()
    {
        await _fixture.ResetDatabaseAsync(); // ~0.3s reset

        await using var context = new YourDbContext(_fixture.DbContextOptions);
        // Test logic
    }
}
```

**Performance: 50 tests**

- Container per test: ~750s ❌
- Shared container + Respawn: **~25s** ✅

---

## Reference Documentation

**Complete guides** in [`references/`](./references/) folder:

- **[testcontainers-setup.md](./references/testcontainers-setup.md)** - Detailed setup,
  configuration, timeout handling, CI troubleshooting
- **[respawn-usage.md](./references/respawn-usage.md)** - Respawn patterns, advanced config, seed
  data preservation, troubleshooting
- **[test-patterns.md](./references/test-patterns.md)** - Repository tests, event handler tests, E2E
  tests, complex scenarios
- **[ci-cd-integration.md](./references/ci-cd-integration.md)** - GitHub Actions, Azure Pipelines,
  coverage, quality gates

---

## Summary

### ✅ DO

- ✅ Use Testcontainers with SQL Server (NEVER SQLite)
- ✅ Use Podman (no license) with `.testcontainers.properties`
- ✅ **Use Respawn to reset database state between tests**
- ✅ **Call `ResetDatabaseAsync()` at START of each test**
- ✅ Run migrations on container startup (once)
- ✅ Preserve `__EFMigrationsHistory` table in Respawn config
- ✅ Use shared container + Respawn for 20+ tests (optimal performance)
- ✅ Test SQL Server-specific features confidently

### ❌ DON'T

- ❌ Use SQLite for integration tests (syntax incompatibility)
- ❌ **Reset database at END of test** (reset at START instead)
- ❌ Create new container per test (use Respawn instead)
- ❌ Forget to specify `DbAdapter.SqlServer` in RespawnerOptions
- ❌ Skip migrations (schema mismatch)
- ❌ Share DbContext between tests (not isolated)
- ❌ Use Respawn on production databases (Testcontainers only!)

---

**Coverage Target**: >= 80% Infrastructure layer | >= 90% Repository layer

**Keywords**: integration test, E2E test, testcontainers, respawn, database test, SQLite error, test
isolation
