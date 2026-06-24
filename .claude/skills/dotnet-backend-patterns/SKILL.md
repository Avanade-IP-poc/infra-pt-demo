---
name: dotnet-backend-patterns
description: Master C# backend development with Clean Architecture, dependency injection, async/await patterns, Entity Framework Core, Dapper, Result pattern, and SOLID principles. Use for .NET APIs, domain logic, data access layers, or service implementations. Triggers => "C# backend", ".NET backend", "dependency injection", "async programming", "EF Core", "Entity Framework", "clean architecture", "backend patterns .NET", "service layer", "repository pattern", "SOLID". ALWAYS use for .NET backend architecture questions.
provisioned_from: .boltf/available-skills/dotnet-backend/dotnet-backend-patterns
provisioned_at: "2026-06-19"
project: SICA Modernization
---

# .NET Backend Patterns — Clean Architecture & Best Practices

Master C# backend development with proven patterns for dependency injection, async programming,
data access, and error handling.

## When to Use

- Developing .NET 8 Web APIs, modular monolith, or backend services
- Implementing Clean Architecture
- Writing async/await code with proper CancellationToken handling
- Setting up DI with correct service lifetimes
- Choosing between EF Core and Dapper
- Implementing Result<T> pattern for explicit error handling
- Configuring multi-layer caching (Memory + Redis)

## Project Structure (SICA)

```
src/
├── Sica.Api/             # Controllers, Middleware, DI composition root
├── Sica.Application/     # Commands, Queries, Handlers (CQRS — no MediatR)
├── Sica.Domain/          # Entities, Value Objects, Domain Events
├── Sica.Infrastructure/  # EF Core 8, Azure integrations, Repositories
└── Sica.Shared/          # Result<T>, Guard clauses, common types
tests/
├── Sica.UnitTests/
├── Sica.IntegrationTests/
├── Sica.CharacterizationTests/   # Golden-master del legacy
└── Sica.E2ETests/
```

## Key Principles

- **Domain** depends on nothing (pure business logic)
- **Application** depends on Domain (orchestrates use cases via CQRS handlers)
- **Infrastructure** depends on Application and Domain (implements interfaces)
- **API** depends on all layers (composition root, DI registration)

## CQRS — Native .NET (NO MediatR)

```csharp
// Commands
public interface ICommand { }
public interface ICommandHandler<in TCommand> where TCommand : ICommand
{
    Task HandleAsync(TCommand command, CancellationToken ct = default);
}
public interface ICommandHandler<in TCommand, TResult> where TCommand : ICommand
{
    Task<TResult> HandleAsync(TCommand command, CancellationToken ct = default);
}

// Queries
public interface IQuery<TResult> { }
public interface IQueryHandler<in TQuery, TResult> where TQuery : IQuery<TResult>
{
    Task<TResult> HandleAsync(TQuery query, CancellationToken ct = default);
}
```

## Dependency Injection Setup

```csharp
// Program.cs
builder.Services
    .AddApplication()
    .AddInfrastructure(builder.Configuration);

// Infrastructure ServiceCollectionExtensions
public static IServiceCollection AddInfrastructure(
    this IServiceCollection services, IConfiguration configuration)
{
    services.AddDbContext<SicaDbContext>(o =>
        o.UseSqlServer(configuration.GetConnectionString("Default")));
    services.AddScoped<IAccessRepository, AccessRepository>();
    services.AddStackExchangeRedisCache(o =>
        o.Configuration = configuration.GetConnectionString("Redis"));
    return services;
}
```

## Async/Await Best Practices

```csharp
// ✅ Always accept CancellationToken, propagate through call chain
public async Task<Result<AccessEntry>> GetAccessAsync(
    string cardId, CancellationToken ct = default)
{
    if (string.IsNullOrWhiteSpace(cardId))
        return Result<AccessEntry>.Failure("INVALID_CARD", "Card ID is required");

    var entry = await _repository.GetByCardIdAsync(cardId, ct);
    return entry is null
        ? Result<AccessEntry>.Failure("NOT_FOUND", $"Card {cardId} not found")
        : Result<AccessEntry>.Success(entry);
}
```

**Golden Rules**:
- ✅ Always `CancellationToken ct = default`
- ✅ Propagate `ct` to all async calls
- ✅ `Task.WhenAll` for parallel operations
- ❌ Never `.Result` or `.Wait()`
- ❌ Never `async void`

## Result Pattern

```csharp
public class Result<T>
{
    public bool IsSuccess { get; }
    public T? Value { get; }
    public string ErrorCode { get; }
    public string ErrorMessage { get; }

    public static Result<T> Success(T value) => ...;
    public static Result<T> Failure(string code, string msg) => ...;
}

// Controller
return result.IsSuccess
    ? Ok(result.Value)
    : result.ErrorCode switch
    {
        "NOT_FOUND" => NotFound(new { error = result.ErrorMessage }),
        "INVALID_CARD" => BadRequest(new { error = result.ErrorMessage }),
        _ => StatusCode(500)
    };
```

## EF Core — Key Rules (SICA Migration)

```csharp
// ✅ CORRECT — parametrized, AsNoTracking for reads
public async Task<AccessLog?> GetByIdAsync(Guid id, CancellationToken ct)
    => await _context.AccessLogs
        .AsNoTracking()
        .FirstOrDefaultAsync(a => a.Id == id, ct);

// ❌ FORBIDDEN — zero concatenated SQL
var sql = $"SELECT * FROM AccessLogs WHERE CardId = '{cardId}'"; // SQL INJECTION
```

## References (source)

Full references and examples in:
`.boltf/available-skills/dotnet-backend/dotnet-backend-patterns/references/`
