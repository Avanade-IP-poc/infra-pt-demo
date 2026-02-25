# Mocking Guide for External Services

## When to Mock vs Real

### Use Real When Possible

- **Unit Tests**: Use real implementations for pure logic
- **Integration Tests**: Use Testcontainers for databases
- **E2E Tests**: Use real services or test environments

### Mock When Necessary

- External APIs (third-party services)
- Payment gateways
- Email services
- Time-sensitive operations
- Expensive operations (AI models)

## Supabase Mocking

### Basic Query Mock

```typescript
jest.mock("@/lib/supabase", () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() =>
          Promise.resolve({
            data: [{ id: 1, name: "Test Market" }],
            error: null,
          })
        ),
      })),
    })),
  },
}));
```

### Insert Mock

```typescript
jest.mock("@/lib/supabase", () => ({
  supabase: {
    from: jest.fn(() => ({
      insert: jest.fn((data) =>
        Promise.resolve({
          data: [{ ...data, id: 1, created_at: new Date().toISOString() }],
          error: null,
        })
      ),
    })),
  },
}));
```

### Error Handling Mock

```typescript
jest.mock("@/lib/supabase", () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() =>
        Promise.resolve({
          data: null,
          error: { message: "Database connection failed", code: "PGRST301" },
        })
      ),
    })),
  },
}));
```

## Redis Mocking

### Vector Search Mock

```typescript
jest.mock("@/lib/redis", () => ({
  searchMarketsByVector: jest.fn(() =>
    Promise.resolve([
      { slug: "test-market-1", similarity_score: 0.95 },
      { slug: "test-market-2", similarity_score: 0.87 },
    ])
  ),

  checkRedisHealth: jest.fn(() =>
    Promise.resolve({
      connected: true,
      latency: 5,
    })
  ),
}));
```

### Cache Mock

```typescript
jest.mock("@/lib/redis", () => ({
  get: jest.fn((key) => {
    if (key === "market:123") {
      return Promise.resolve(JSON.stringify({ id: "123", name: "Cached Market" }));
    }
    return Promise.resolve(null);
  }),

  set: jest.fn(() => Promise.resolve("OK")),

  del: jest.fn(() => Promise.resolve(1)),
}));
```

## OpenAI Mocking

### Embedding Generation Mock

```typescript
jest.mock("@/lib/openai", () => ({
  generateEmbedding: jest.fn(() =>
    Promise.resolve(
      new Array(1536).fill(0.1) // Mock 1536-dimension embedding
    )
  ),
}));
```

### Chat Completion Mock

```typescript
jest.mock("openai", () => ({
  OpenAI: jest.fn().mockImplementation(() => ({
    chat: {
      completions: {
        create: jest.fn(() =>
          Promise.resolve({
            choices: [
              {
                message: {
                  content: "This is a test response from the AI model.",
                },
              },
            ],
          })
        ),
      },
    },
  })),
}));
```

### Error Scenarios Mock

```typescript
jest.mock("@/lib/openai", () => ({
  generateEmbedding: jest.fn(() => Promise.reject(new Error("Rate limit exceeded"))),
}));
```

## Database Mocking (.NET)

### Entity Framework Mock

```csharp
public class MockDbContext : DbContext
{
    public DbSet<User> Users { get; set; } = null!;

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseInMemoryDatabase("TestDb");
    }
}

// Usage in tests
var options = new DbContextOptionsBuilder<AppDbContext>()
    .UseInMemoryDatabase(databaseName: "TestDatabase")
    .Options;

using var context = new AppDbContext(options);
context.Users.Add(new User { Email = "test@example.com" });
context.SaveChanges();
```

### Repository Mock

```csharp
var mockRepo = new Mock<IUserRepository>();
mockRepo.Setup(r => r.GetByIdAsync(It.IsAny<Guid>()))
    .ReturnsAsync((Guid id) => new User { Id = id, Email = "test@example.com" });

mockRepo.Setup(r => r.CreateAsync(It.IsAny<User>()))
    .ReturnsAsync((User user) =>
    {
        user.Id = Guid.NewGuid();
        user.CreatedAt = DateTime.UtcNow;
        return user;
    });
```

## HTTP Client Mocking

### Fetch Mock (JavaScript)

```typescript
global.fetch = jest.fn(() =>
  Promise.resolve({
    ok: true,
    status: 200,
    json: () => Promise.resolve({ data: "test" }),
  } as Response)
);

// Usage
const response = await fetch("/api/test");
expect(global.fetch).toHaveBeenCalledWith("/api/test");
```

### HttpClient Mock (.NET)

```csharp
var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
mockHttpMessageHandler
    .Protected()
    .Setup<Task<HttpResponseMessage>>(
        "SendAsync",
        ItExpr.IsAny<HttpRequestMessage>(),
        ItExpr.IsAny<CancellationToken>()
    )
    .ReturnsAsync(new HttpResponseMessage
    {
        StatusCode = HttpStatusCode.OK,
        Content = new StringContent("{\"data\":\"test\"}")
    });

var httpClient = new HttpClient(mockHttpMessageHandler.Object);
```

## Time Mocking

### JavaScript Date Mock

```typescript
// Mock current time
jest.useFakeTimers();
jest.setSystemTime(new Date("2025-01-01"));

// Test code that uses new Date()
const now = new Date();
expect(now.getFullYear()).toBe(2025);

// Restore real timers
jest.useRealTimers();
```

### .NET DateTime Mock

```csharp
public interface IDateTimeProvider
{
    DateTime UtcNow { get; }
}

public class SystemDateTimeProvider : IDateTimeProvider
{
    public DateTime UtcNow => DateTime.UtcNow;
}

// In tests
var mockDateTime = new Mock<IDateTimeProvider>();
mockDateTime.Setup(d => d.UtcNow)
    .Returns(new DateTime(2025, 1, 1, 0, 0, 0, DateTimeKind.Utc));
```

## Best Practices

### ✅ DO

- Mock external services (APIs, payment gateways)
- Use real implementations for internal logic
- Verify mock interactions when behavior matters
- Reset mocks between tests

```typescript
afterEach(() => {
  jest.clearAllMocks();
});
```

### ❌ DON'T

- Mock everything (over-mocking)
- Mock the system under test
- Create tight coupling to implementation
- Forget to verify important calls

```typescript
// Verify important interactions
expect(mockEmailService.send).toHaveBeenCalledWith({
  to: "user@example.com",
  subject: "Welcome",
});
```

### Minimal Mocking Example

```typescript
// Good: Mock only external dependency
const mockEmailService = {
  send: jest.fn(() => Promise.resolve({ sent: true })),
};

// Test real business logic with mocked dependency
const userService = new UserService(mockEmailService);
await userService.registerUser({ email: "test@example.com" });

expect(mockEmailService.send).toHaveBeenCalled();
```

## Progressive Enhancement

Start with real implementations and mock only when necessary:

1. **First**: Write test with real implementations
2. **If slow**: Mock external services
3. **If flaky**: Mock time-dependent operations
4. **If expensive**: Mock AI/API calls

Don't mock preemptively. Real tests find more bugs.
