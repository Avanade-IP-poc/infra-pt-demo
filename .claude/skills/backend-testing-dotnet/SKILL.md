---
name: backend-testing-dotnet
description: Unit tests and architecture tests for .NET backends. Use for xUnit, FluentAssertions, Moq patterns, CQRS handler testing (ICommandHandler/IQueryHandler — no MediatR), test data builders, and architecture enforcement with NetArchTest (MicroserviceConfig pattern). For integration tests (DatabaseFixture, SQL Server, Respawn) and E2E tests use the integration-e2e-testing skill.
provisioned_from: .boltf/available-skills/dotnet-backend/backend-testing-dotnet
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# Backend Testing for .NET

> 🔗 Integration & E2E tests → `integration-e2e-testing` skill
> 🔗 Playwright patterns → `skill-playwright-e2e` skill

## Quick Start

```bash
dotnet add package xunit
dotnet add package FluentAssertions
dotnet add package NSubstitute
dotnet add package coverlet.collector
dotnet add package NetArchTest.Rules

dotnet test Sica.sln
dotnet test --filter "Category=Unit"
dotnet test --filter "Category=Architecture"
dotnet test /p:CollectCoverage=true /p:CoverageThreshold=80 /p:ThresholdType=line
```

## Test Project Structure (SICA)

```
tests/
├── Sica.UnitTests/
│   ├── Commands/
│   ├── Queries/
│   └── Builders/              # Test data builders
├── Sica.IntegrationTests/     # → see integration-e2e-testing skill
├── Sica.CharacterizationTests/# Golden-master del comportamiento legacy
├── Architecture.Tests.Common/
│   └── Rules/
│       ├── LayerDependencyRules.cs
│       ├── CqrsComplianceRules.cs     # No MediatR — ICommandHandler/IQueryHandler
│       └── NamingConventionRules.cs
└── Architecture.Tests.Sica/
    └── SicaArchitectureTests.cs
```

## Unit Tests — AAA Pattern

```csharp
[Trait("Category", "Unit")]
[Trait("Feature", "Access")]
[Trait("Layer", "Application")]
public class GetAccessByCardQueryHandlerTests
{
    private readonly IAccessRepository _repository = Substitute.For<IAccessRepository>();
    private readonly GetAccessByCardQueryHandler _handler;

    public GetAccessByCardQueryHandlerTests()
        => _handler = new GetAccessByCardQueryHandler(_repository);

    [Fact]
    public async Task HandleAsync_WhenCardExists_ReturnsAccessEntry()
    {
        // Arrange
        var cardId = "CARD-001";
        var expected = new AccessEntryBuilder().WithCardId(cardId).Build();
        _repository.GetByCardIdAsync(cardId, Arg.Any<CancellationToken>())
                   .Returns(expected);

        // Act
        var result = await _handler.HandleAsync(
            new GetAccessByCardQuery(cardId), CancellationToken.None);

        // Assert
        result.IsSuccess.Should().BeTrue();
        result.Value.CardId.Should().Be(cardId);
    }
}
```

## Test Data Builders

```csharp
public class AccessEntryBuilder
{
    private Guid _id = Guid.NewGuid();
    private string _cardId = "CARD-DEFAULT";
    private DateTime _accessTime = DateTime.UtcNow;

    public AccessEntryBuilder WithCardId(string cardId)
        { _cardId = cardId; return this; }

    public AccessEntry Build()
        => new AccessEntry(_id, _cardId, _accessTime);
}
```

## Architecture Tests — No MediatR

```csharp
[Fact]
public void Handlers_ShouldNotReferenceMediatR()
{
    var result = Types.InAssembly(typeof(Application.AssemblyMarker).Assembly)
        .Should()
        .NotHaveDependencyOn("MediatR")
        .GetResult();

    result.IsSuccessful.Should().BeTrue();
}

[Fact]
public void Domain_ShouldNotDependOnInfrastructure()
{
    var result = Types.InAssembly(typeof(Domain.AssemblyMarker).Assembly)
        .Should()
        .NotHaveDependencyOn("Sica.Infrastructure")
        .GetResult();

    result.IsSuccessful.Should().BeTrue();
}
```

## Required Traits

```csharp
[Trait("Category", "Unit")]        // Unit | Integration | E2E | Architecture
[Trait("Speed", "Fast")]           // Fast (<100ms) | Medium (<5s) | Slow (>5s)
[Trait("Feature", "Access")]       // Bounded context name
[Trait("Layer", "Application")]    // Domain | Application | Infrastructure
```

## Coverage

- Line ≥ 80%, Branch ≥ 75% (Coverlet)
- Excludes: Migrations, test assemblies, generated code

## Best Practices

- ✅ AAA pattern (Arrange / Act / Assert)
- ✅ NSubstitute (no Moq) — cleaner API
- ✅ FluentAssertions for readable assertions
- ✅ Test data builders for complex objects
- ✅ Theory + InlineData for parameterized tests
- ❌ Don't mock what you don't own
- ❌ Don't use MediatR (forbidden per constitution)

## References (source)

`.boltf/available-skills/dotnet-backend/backend-testing-dotnet/`
