---
name: backend-testing-dotnet
description: Comprehensive backend testing for .NET with xUnit, Testcontainers, NetArchTest, and Respawn. Use when writing unit tests, integration tests, architecture tests, or test fixtures for .NET backends. Triggers => "test backend .NET", "xUnit tests", "Testcontainers", "architecture tests", "integration testing .NET", "NetArchTest", "Respawn", "mock database", "test fixtures", "backend test patterns", ".NET testing", "SQL Server tests".
---

# Backend Testing for .NET

## When to Use

- Writing unit tests for domain logic, application services, and infrastructure
- Creating integration tests with real databases using Testcontainers
- Enforcing architecture boundaries with NetArchTest
- Achieving coverage targets (80%+ line, 75%+ branch)
- The user or an agent needs to create technical tests for backend

## Quick Start

```bash
# Create test project
dotnet new xunit -n TimeTracking.UnitTests
dotnet add TimeTracking.UnitTests reference ../src/TimeTracking.Domain
dotnet add package FluentAssertions
dotnet add package Moq
dotnet add package coverlet.collector

# Run tests with coverage
dotnet test /p:CollectCoverage=true /p:CoverageThreshold=80
```

## Test Project Structure

```
tests/
├── TimeTracking.UnitTests/          # Domain + Application
│   ├── Domain/
│   │   ├── Entities/
│   │   │   └── TimeEntryTests.cs
│   │   └── ValueObjects/
│   │       └── TimeRangeTests.cs
│   ├── Application/
│   │   ├── Commands/
│   │   │   └── CreateTimeEntryHandlerTests.cs
│   │   └── Queries/
│   │       └── GetTimeEntriesHandlerTests.cs
│   └── Builders/                     # Test data builders
│       └── TimeEntryBuilder.cs
├── TimeTracking.IntegrationTests/   # Infrastructure + API
│   ├── API/
│   │   └── TimeEntriesControllerTests.cs
│   ├── Database/
│   │   └── TimeEntryRepositoryTests.cs
│   └── Fixtures/
│       └── DatabaseFixture.cs
└── Architecture.Tests/               # NetArchTest rules
    └── ArchitectureTests.cs
```

## Unit Tests (xUnit + FluentAssertions + Moq)

```csharp
// tests/TimeTracking.UnitTests/Domain/Entities/TimeEntryTests.cs
using FluentAssertions;
using TimeTracking.Domain.Entities;
using Xunit;

namespace TimeTracking.UnitTests.Domain.Entities;

public class TimeEntryTests
{
    [Fact]
    public void Create_WithValidData_ShouldSucceed()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var accountId = Guid.NewGuid();
        var startTime = DateTime.UtcNow;
        var endTime = startTime.AddHours(2);

        // Act
        var result = TimeEntry.Create(userId, accountId, startTime, endTime);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.UserId.Should().Be(userId);
        result.Value.Duration.Should().Be(TimeSpan.FromHours(2));
    }

    [Theory]
    [InlineData(-1)]  // End before start
    [InlineData(0)]   // Zero duration
    public void Create_WithInvalidDuration_ShouldFail(int hoursToAdd)
    {
        // Arrange
        var userId = Guid.NewGuid();
        var accountId = Guid.NewGuid();
        var startTime = DateTime.UtcNow;
        var endTime = startTime.AddHours(hoursToAdd);

        // Act
        var result = TimeEntry.Create(userId, accountId, startTime, endTime);

        // Assert
        result.IsFailure.Should().BeTrue();
        result.Error.Code.Should().Be("INVALID_TIME_RANGE");
    }

    [Fact]
    public async Task CreateTimeEntryHandler_ShouldCallRepository()
    {
        // Arrange
        var mockRepository = new Mock<ITimeEntryRepository>();
        var handler = new CreateTimeEntryHandler(mockRepository.Object);
        var command = new CreateTimeEntryCommand(
            Guid.NewGuid(),
            Guid.NewGuid(),
            DateTime.UtcNow,
            DateTime.UtcNow.AddHours(2)
        );

        mockRepository
            .Setup(x => x.AddAsync(It.IsAny<TimeEntry>(), default))
            .ReturnsAsync((TimeEntry entry, CancellationToken _) => entry);

        // Act
        var result = await handler.Handle(command, CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        mockRepository.Verify(
            x => x.AddAsync(It.IsAny<TimeEntry>(), default),
            Times.Once
        );
    }
}
```

## Integration Tests (Testcontainers)

```csharp
// tests/TimeTracking.IntegrationTests/Fixtures/DatabaseFixture.cs
using Microsoft.EntityFrameworkCore;
using Testcontainers.PostgreSql;
using Xunit;

namespace TimeTracking.IntegrationTests.Fixtures;

public class DatabaseFixture : IAsyncLifetime
{
    private readonly PostgreSqlContainer _container = new PostgreSqlBuilder()
        .WithImage("postgres:16-alpine")
        .WithDatabase("timetracking_test")
        .WithUsername("test")
        .WithPassword("test")
        .Build();

    public string ConnectionString => _container.GetConnectionString();

    public async Task InitializeAsync()
    {
        await _container.StartAsync();

        // Run migrations
        var options = new DbContextOptionsBuilder<TimeTrackingDbContext>()
            .UseNpgsql(ConnectionString)
            .Options;

        await using var context = new TimeTrackingDbContext(options);
        await context.Database.MigrateAsync();
    }

    public async Task DisposeAsync()
    {
        await _container.DisposeAsync();
    }
}

// tests/TimeTracking.IntegrationTests/Database/TimeEntryRepositoryTests.cs
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Xunit;

namespace TimeTracking.IntegrationTests.Database;

public class TimeEntryRepositoryTests : IClassFixture<DatabaseFixture>
{
    private readonly DatabaseFixture _fixture;

    public TimeEntryRepositoryTests(DatabaseFixture fixture)
    {
        _fixture = fixture;
    }

    [Fact]
    public async Task AddAsync_ShouldPersistEntity()
    {
        // Arrange
        var options = new DbContextOptionsBuilder<TimeTrackingDbContext>()
            .UseNpgsql(_fixture.ConnectionString)
            .Options;

        await using var context = new TimeTrackingDbContext(options);
        var repository = new TimeEntryRepository(context);

        var timeEntry = TimeEntry.Create(
            Guid.NewGuid(),
            Guid.NewGuid(),
            DateTime.UtcNow,
            DateTime.UtcNow.AddHours(2)
        ).Value;

        // Act
        var result = await repository.AddAsync(timeEntry);
        await context.SaveChangesAsync();

        // Assert
        var retrieved = await context.TimeEntries
            .FirstOrDefaultAsync(x => x.Id == result.Id);

        retrieved.Should().NotBeNull();
        retrieved!.Duration.Should().Be(TimeSpan.FromHours(2));
    }
}
```

## Architecture Tests (NetArchTest)

```csharp
// tests/Architecture.Tests/ArchitectureTests.cs
using FluentAssertions;
using NetArchTest.Rules;
using Xunit;

namespace Architecture.Tests;

public class ArchitectureTests
{
    private const string DomainNamespace = "TimeTracking.Domain";
    private const string ApplicationNamespace = "TimeTracking.Application";
    private const string InfrastructureNamespace = "TimeTracking.Infrastructure";
    private const string WebNamespace = "TimeTracking.Web";

    [Fact]
    public void Domain_ShouldNotHaveDependencyOnOtherLayers()
    {
        // Arrange
        var assembly = typeof(TimeTracking.Domain.AssemblyReference).Assembly;

        // Act
        var result = Types.InAssembly(assembly)
            .ShouldNot()
            .HaveDependencyOnAny(ApplicationNamespace, InfrastructureNamespace, WebNamespace)
            .GetResult();

        // Assert
        result.IsSuccessful.Should().BeTrue();
    }

    [Fact]
    public void Application_ShouldNotHaveDependencyOnInfrastructure()
    {
        // Arrange
        var assembly = typeof(TimeTracking.Application.AssemblyReference).Assembly;

        // Act
        var result = Types.InAssembly(assembly)
            .ShouldNot()
            .HaveDependencyOnAny(InfrastructureNamespace, WebNamespace)
            .GetResult();

        // Assert
        result.IsSuccessful.Should().BeTrue();
    }

    [Fact]
    public void Controllers_ShouldHaveSuffix()
    {
        // Arrange
        var assembly = typeof(TimeTracking.Web.AssemblyReference).Assembly;

        // Act
        var result = Types.InAssembly(assembly)
            .That()
            .ResideInNamespace("TimeTracking.Web.Controllers")
            .Should()
            .HaveNameEndingWith("Controller")
            .GetResult();

        // Assert
        result.IsSuccessful.Should().BeTrue();
    }

    [Fact]
    public void Handlers_ShouldHaveSuffix()
    {
        // Arrange
        var assembly = typeof(TimeTracking.Application.AssemblyReference).Assembly;

        // Act
        var result = Types.InAssembly(assembly)
            .That()
            .ResideInNamespace("TimeTracking.Application")
            .And()
            .ImplementInterface(typeof(IRequestHandler<,>))
            .Should()
            .HaveNameEndingWith("Handler")
            .GetResult();

        // Assert
        result.IsSuccessful.Should().BeTrue();
    }
}
```

## Test Data Builders

```csharp
// tests/TimeTracking.UnitTests/Builders/TimeEntryBuilder.cs
namespace TimeTracking.UnitTests.Builders;

public class TimeEntryBuilder
{
    private Guid _userId = Guid.NewGuid();
    private Guid _accountId = Guid.NewGuid();
    private DateTime _startTime = DateTime.UtcNow;
    private DateTime _endTime = DateTime.UtcNow.AddHours(2);

    public TimeEntryBuilder WithUserId(Guid userId)
    {
        _userId = userId;
        return this;
    }

    public TimeEntryBuilder WithDuration(TimeSpan duration)
    {
        _endTime = _startTime.Add(duration);
        return this;
    }

    public TimeEntry Build()
    {
        return TimeEntry.Create(_userId, _accountId, _startTime, _endTime).Value;
    }
}
```

## Coverage Configuration

```xml
<!-- coverlet.runsettings -->
<?xml version="1.0" encoding="utf-8"?>
<RunSettings>
  <DataCollectionRunSettings>
    <DataCollectors>
      <DataCollector friendlyName="XPlat code coverage">
        <Configuration>
          <Format>cobertura,json,lcov,opencover</Format>
          <Exclude>[*.Tests]*,[*]*.Migrations.*</Exclude>
          <Include>[TimeTracking.*]*</Include>
          <ExcludeByAttribute>Obsolete,GeneratedCodeAttribute,CompilerGeneratedAttribute</ExcludeByAttribute>
          <SingleHit>false</SingleHit>
          <UseSourceLink>true</UseSourceLink>
        </Configuration>
      </DataCollector>
    </DataCollectors>
  </DataCollectionRunSettings>
</RunSettings>
```

## Running Tests

```bash
# Run all tests
dotnet test

# Run with coverage
dotnet test --settings coverlet.runsettings /p:CollectCoverage=true

# Run specific category
dotnet test --filter Category=Unit
dotnet test --filter Category=Integration

# Fail on coverage threshold
dotnet test /p:CollectCoverage=true /p:CoverageThreshold=80 /p:ThresholdType=line

# Generate HTML report
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura
reportgenerator -reports:coverage.cobertura.xml -targetdir:coverage-report
```

## Best Practices

### Unit Tests

- ✅ AAA pattern (Arrange, Act, Assert)
- ✅ One assertion per test (or related assertions)
- ✅ Use FluentAssertions for readable assertions
- ✅ Use Theory + InlineData for parameterized tests
- ✅ Test data builders for complex objects
- ❌ Don't mock what you don't own
- ❌ Don't test framework code

### Integration Tests

- ✅ Use Testcontainers for real database
- ✅ IClassFixture for shared setup
- ✅ Clean database between tests
- ✅ Test repository implementations
- ✅ Test API endpoints end-to-end
- ❌ Don't share state between tests
- ❌ Don't use in-memory databases for production-like tests

### Architecture Tests

- ✅ Enforce layer dependencies
- ✅ Validate naming conventions
- ✅ Check for forbidden dependencies
- ✅ Run in CI pipeline
- ❌ Don't skip architecture tests

## References

- [xUnit Documentation](https://xunit.net/)
- [FluentAssertions](https://fluentassertions.com/)
- [Testcontainers for .NET](https://dotnet.testcontainers.org/)
- [NetArchTest](https://github.com/BenMorris/NetArchTest)
