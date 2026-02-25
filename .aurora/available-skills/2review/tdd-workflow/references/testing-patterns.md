# Testing Patterns - Detailed Examples

## Unit Test Patterns

### Component Testing (React Testing Library)

```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { Button } from './Button'

describe('Button Component', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click</Button>)

    fireEvent.click(screen.getByRole('button'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click</Button>)
    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

### Good Test Examples

<Good>
```typescript
test('retryOperation retries 3 times before failing', async () => {
    var attempts = 0;
    const operation = async () => {
        attempts++;
        if (attempts < 3) throw new Error('fail');
        return 'success';
    };

    const result = await retryOperation(operation);

    expect(result).toBe('success');
    expect(attempts).toBe(3);

});

````

```csharp
[Fact]
public async Task RetryOperation_Retries3TimesBeforeFailing()
{
    var attempts = 0;
    Func<Task<string>> operation = () =>
    {
        attempts++;
        if (attempts < 3) throw new InvalidOperationException("fail");
        return Task.FromResult("success");
    };

    var result = await RetryOperation(operation);

    result.Should().Be("success");
    attempts.Should().Be(3);
}
````

**Why Good:**

- Clear name describing behavior
- Tests real behavior, not mocks
- One thing per test
- Shows intended usage </Good>

### Bad Test Examples

<Bad>
```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(3);
});
```

```csharp
[Fact]
public async Task RetryWorks()
{
    var mock = new Mock<Func<Task<string>>>();
    mock.SetupSequence(m => m())
        .ThrowsAsync(new Exception())
        .ThrowsAsync(new Exception())
        .ReturnsAsync("success");
    await RetryOperation(mock.Object);
    mock.Verify(m => m(), Times.Exactly(3));
}
```

**Why Bad:**

- Vague name ("works" tells nothing)
- Tests mock behavior, not real code
- Doesn't verify actual return value
- Multiple concerns mixed </Bad>

## API Integration Test Patterns

### Next.js API Route Testing

```typescript
import { NextRequest } from "next/server";
import { GET } from "./route";

describe("GET /api/markets", () => {
  it("returns markets successfully", async () => {
    const request = new NextRequest("http://localhost/api/markets");
    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.success).toBe(true);
    expect(Array.isArray(data.data)).toBe(true);
  });

  it("validates query parameters", async () => {
    const request = new NextRequest("http://localhost/api/markets?limit=invalid");
    const response = await GET(request);

    expect(response.status).toBe(400);
  });

  it("handles database errors gracefully", async () => {
    // Mock database failure
    const request = new NextRequest("http://localhost/api/markets");
    // Test error handling
  });
});
```

### .NET API Controller Testing

```csharp
public class UsersControllerTests
{
    private readonly UsersController _controller;
    private readonly Mock<IUserRepository> _userRepo;

    public UsersControllerTests()
    {
        _userRepo = new Mock<IUserRepository>();
        _controller = new UsersController(_userRepo.Object);
    }

    [Fact]
    public async Task GetUser_ReturnsUser_WhenExists()
    {
        // Arrange
        var userId = Guid.NewGuid();
        var user = new User { Id = userId, Email = "test@example.com" };
        _userRepo.Setup(r => r.GetByIdAsync(userId))
            .ReturnsAsync(user);

        // Act
        var result = await _controller.GetUser(userId);

        // Assert
        var okResult = result.Should().BeOfType<OkObjectResult>().Subject;
        var returnedUser = okResult.Value.Should().BeOfType<User>().Subject;
        returnedUser.Id.Should().Be(userId);
    }

    [Fact]
    public async Task GetUser_ReturnsNotFound_WhenNotExists()
    {
        // Arrange
        var userId = Guid.NewGuid();
        _userRepo.Setup(r => r.GetByIdAsync(userId))
            .ReturnsAsync((User?)null);

        // Act
        var result = await _controller.GetUser(userId);

        // Assert
        result.Should().BeOfType<NotFoundResult>();
    }
}
```

## E2E Test Patterns (Playwright)

### User Flow Testing

```typescript
import { test, expect } from "@playwright/test";

test("user can search and filter markets", async ({ page }) => {
  // Navigate to markets page
  await page.goto("/");
  await page.click('a[href="/markets"]');

  // Verify page loaded
  await expect(page.locator("h1")).toContainText("Markets");

  // Search for markets
  await page.fill('input[placeholder="Search markets"]', "election");

  // Wait for debounce and results
  await page.waitForTimeout(600);

  // Verify search results displayed
  const results = page.locator('[data-testid="market-card"]');
  await expect(results).toHaveCount(5, { timeout: 5000 });

  // Verify results contain search term
  const firstResult = results.first();
  await expect(firstResult).toContainText("election", { ignoreCase: true });

  // Filter by status
  await page.click('button:has-text("Active")');

  // Verify filtered results
  await expect(results).toHaveCount(3);
});

test("user can create a new market", async ({ page }) => {
  // Login first
  await page.goto("/creator-dashboard");

  // Fill market creation form
  await page.fill('input[name="name"]', "Test Market");
  await page.fill('textarea[name="description"]', "Test description");
  await page.fill('input[name="endDate"]', "2025-12-31");

  // Submit form
  await page.click('button[type="submit"]');

  // Verify success message
  await expect(page.locator("text=Market created successfully")).toBeVisible();

  // Verify redirect to market page
  await expect(page).toHaveURL(/\/markets\/test-market/);
});
```

### Authentication Flow Testing

```typescript
test("user can register and login", async ({ page }) => {
  // Register
  await page.goto("/register");
  await page.fill('input[name="email"]', "newuser@test.com");
  await page.fill('input[name="password"]', "SecurePass123!");
  await page.fill('input[name="confirmPassword"]', "SecurePass123!");
  await page.click('button[type="submit"]');

  // Verify redirect to dashboard
  await expect(page).toHaveURL("/dashboard");

  // Logout
  await page.click('[data-testid="user-menu"]');
  await page.click("text=Logout");

  // Login again
  await page.goto("/login");
  await page.fill('input[name="email"]', "newuser@test.com");
  await page.fill('input[name="password"]', "SecurePass123!");
  await page.click('button[type="submit"]');

  // Verify logged in
  await expect(page).toHaveURL("/dashboard");
  await expect(page.locator('[data-testid="user-email"]')).toContainText("newuser@test.com");
});
```

## Test File Organization

```text
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx          # Unit tests
│   │   └── Button.stories.tsx       # Storybook
│   └── MarketCard/
│       ├── MarketCard.tsx
│       └── MarketCard.test.tsx
├── app/
│   └── api/
│       └── markets/
│           ├── route.ts
│           └── route.test.ts         # Integration tests
└── e2e/
    ├── markets.spec.ts               # E2E tests
    ├── trading.spec.ts
    └── auth.spec.ts
```

## Testing Best Practices

### ✅ DO: Test User-Visible Behavior

```typescript
// Test what users see
expect(screen.getByText("Count: 5")).toBeInTheDocument();
```

### ❌ DON'T: Test Implementation Details

```typescript
// Don't test internal state
expect(component.state.count).toBe(5);
```

### ✅ DO: Use Semantic Selectors

```typescript
// Accessible, robust
await page.click('button[aria-label="Add to cart"]');
```

### ❌ DON'T: Use Brittle Selectors

```typescript
// Breaks easily
await page.click(".btn-primary:nth-child(3)");
```

### ✅ DO: Test One Thing Per Test

```typescript
it("displays error message when email is invalid", () => {
  // Single concern
});
```

### ❌ DON'T: Test Multiple Concerns

```typescript
it("validates email and domain and whitespace and special chars", () => {
  // Too many things
});
```
