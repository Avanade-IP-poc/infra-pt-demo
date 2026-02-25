# Testing Anti-Patterns and Common Rationalizations

## Why Test-First Order Matters

### "I'll write tests after to verify it works"

**The Problem:** Tests written after code pass immediately. Passing immediately proves nothing:

- Might test the wrong thing
- Might test implementation, not behavior
- Might miss edge cases you forgot
- You never saw it catch the bug

**Test-First Forces:**

- Seeing the test fail proves it actually tests something
- Discovering edge cases before implementing
- Designing the API from the consumer's perspective
- Building only what's needed (YAGNI)

### "I already manually tested all the edge cases"

**The Problem:** Manual testing is ad-hoc. You think you tested everything but:

- No record of what you tested
- Can't re-run when code changes
- Easy to forget cases under pressure
- "It worked when I tried it" ≠ comprehensive
- Confirmation bias (test what you built, not what's required)

**Automated Tests Are:**

- Systematic and repeatable
- Executable documentation
- Regression prevention
- Continuous validation

### "Deleting X hours of work is wasteful"

**The Problem:** Sunk cost fallacy. The time is already gone. Your choice now:

- **Option A**: Delete and rewrite with TDD (X more hours, high confidence)
- **Option B**: Keep it and add tests after (30 min, low confidence, likely bugs)

**The Reality:** The "waste" is keeping code you can't trust. Working code without real tests is
technical debt that compounds interest daily.

### "TDD is dogmatic, being pragmatic means adapting"

**TDD IS Pragmatic:**

- Finds bugs before commit (faster than debugging after)
- Prevents regressions (tests catch breaks immediately)
- Documents behavior (tests show how to use code)
- Enables refactoring (change freely, tests catch breaks)
- Reduces debugging time (saves hours/days)

**"Pragmatic" Shortcuts:**

- Skip tests → debugging in production → slower
- Tests after → missed edge cases → customer-found bugs
- "Just this once" → becomes habit → technical debt

### "Tests after achieve the same goals - it's spirit not ritual"

**No. Test Timing Changes Everything:**

**Tests-After Answer:** "What does this code do?"

- Biased by your implementation
- Verify remembered edge cases (incomplete)
- Test what you built, not what's required

**Tests-First Answer:** "What should this code do?"

- Unbiased by implementation (doesn't exist yet)
- Force edge case discovery before coding
- Test requirements, not accidents of implementation

**30 minutes of tests after ≠ TDD:** You get coverage, lose proof tests work. Tests that pass
immediately prove nothing.

## Common Rationalizations

| Excuse                                 | Reality                                                                         |
| -------------------------------------- | ------------------------------------------------------------------------------- |
| "Too simple to test"                   | Simple code breaks. Test takes 30 seconds. Cost vs benefit heavily favors test. |
| "I'll test after"                      | Tests passing immediately prove nothing. You need to see them fail first.       |
| "Tests after achieve same goals"       | Tests-after = "what does this do?" Tests-first = "what should this do?"         |
| "Already manually tested"              | Ad-hoc ≠ systematic. No record, can't re-run, confirmation bias.                |
| "Deleting X hours is wasteful"         | Sunk cost fallacy. Keeping unverified code is technical debt.                   |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. DELETE means DELETE.                     |
| "Need to explore first"                | Fine. Throw away exploration code, start with TDD.                              |
| "Test hard = design unclear"           | Listen to the test. Hard to test = hard to use. Fix the design.                 |
| "TDD will slow me down"                | TDD faster than debugging. Pragmatic = test-first.                              |
| "Manual test faster"                   | Manual doesn't prove edge cases. You'll re-test every change forever.           |
| "Existing code has no tests"           | You're improving it. Add tests for new code. Refactor old code with tests.      |
| "This is a spike/prototype"            | Protect yourself. Mark it clearly. Delete before production. No exceptions.     |

## Red Flags - STOP and Start Over

If you wrote code before the test:

1. **DELETE the code** (don't comment out, DELETE)
2. Write the failing test
3. Watch it fail
4. Rewrite the code (from memory or fresh)
5. Watch test pass

**"But I'll just copy it back"**

If you copy it back, you're testing after. The code influenced the test. You tested "does it do what
I built?" not "does it do what's required?"

You must rebuild from the test's requirements.

## Common Testing Mistakes to Avoid

### ❌ WRONG: Testing Implementation Details

```typescript
// Don't test internal state/structure
expect(component.state.count).toBe(5);
expect(instance._privateMethod).toHaveBeenCalled();
```

**Why Wrong:**

- Breaks when refactoring (even if behavior unchanged)
- Couples test to implementation
- Doesn't verify user-visible behavior

### ✅ CORRECT: Test User-Visible Behavior

```typescript
// Test what users see/experience
expect(screen.getByText("Count: 5")).toBeInTheDocument();
expect(screen.getByRole("button")).toBeEnabled();
```

**Why Correct:**

- Resilient to refactoring
- Tests actual requirements
- Verifies user experience

### ❌ WRONG: Brittle Selectors

```typescript
// Breaks with any HTML changes
await page.click(".btn.btn-primary.mt-4:nth-child(3)");
expect(wrapper.find("div").at(2).text()).toBe("Hello");
```

**Why Wrong:**

- Fragile (breaks with styling changes)
- Unclear intent
- Hard to maintain

### ✅ CORRECT: Semantic Selectors

```typescript
// Robust, accessible, clear intent
await page.click('button[aria-label="Add to cart"]');
expect(screen.getByRole("alert")).toHaveTextContent("Item added");
```

**Why Correct:**

- Resilient to styling changes
- Encourages accessibility
- Clear intent

### ❌ WRONG: Testing Multiple Concerns

```typescript
it("validates email and domain and whitespace and special chars and length", () => {
  // Too many responsibilities
});
```

**Why Wrong:**

- Hard to debug (which part failed?)
- Violates single responsibility
- Poor error messages

### ✅ CORRECT: One Thing Per Test

```typescript
it("rejects email with invalid domain", () => {
  /* ... */
});
it("rejects email with leading whitespace", () => {
  /* ... */
});
it("rejects email with special characters", () => {
  /* ... */
});
it("rejects email exceeding 254 characters", () => {
  /* ... */
});
```

**Why Correct:**

- Clear failure messages
- Easy to debug
- Good documentation

### ❌ WRONG: Over-Mocking

```typescript
// Mocking everything including SUT
const mockValidator = jest.fn(() => true);
const mockTransformer = jest.fn((x) => x);
const mockLogger = jest.fn();
const service = new Service(mockValidator, mockTransformer, mockLogger);
```

**Why Wrong:**

- Tests mocks, not real code
- Tight coupling to implementation
- False confidence (mocks always behave)

### ✅ CORRECT: Minimal Mocking

```typescript
// Mock only external dependencies
const mockEmailService = { send: jest.fn() };
const service = new UserService(mockEmailService); // Real business logic
```

**Why Correct:**

- Tests real implementation
- Verifies actual behavior
- Finds real bugs

### ❌ WRONG: Vague Test Names

```typescript
it("works", () => {
  /* ... */
});
it("test1", () => {
  /* ... */
});
it("should handle input", () => {
  /* ... */
});
```

**Why Wrong:**

- No documentation value
- Hard to understand failures
- Unclear intent

### ✅ CORRECT: Descriptive Test Names

```typescript
it("retries operation 3 times before throwing error", () => {
  /* ... */
});
it("returns 404 when user not found", () => {
  /* ... */
});
it("displays error message when email invalid", () => {
  /* ... */
});
```

**Why Correct:**

- Self-documenting
- Clear failure indication
- Explicit requirements

## Good Test Qualities

| Quality           | Good Example                               | Bad Example                                         |
| ----------------- | ------------------------------------------ | --------------------------------------------------- |
| **Minimal**       | Tests one behavior                         | `test('validates email and domain and whitespace')` |
| **Clear**         | Name describes exact behavior              | `test('test1')` or `test('works')`                  |
| **Independent**   | Can run in any order                       | Depends on previous test's state                    |
| **Fast**          | Milliseconds (unit), seconds (integration) | Minutes per test                                    |
| **Deterministic** | Always same result                         | Flaky (random pass/fail)                            |
| **Shows Intent**  | Demonstrates desired API/behavior          | Obscures what code should do                        |
| **Maintainable**  | Easy to understand and update              | Complex setup, unclear assertions                   |

## The Iron Law Violations

### Violation: Code Before Test

```typescript
// ❌ WRONG: Wrote implementation first
function retryOperation(fn, maxRetries = 3) {
  // ... implementation
}

// Then wrote test
test("retries 3 times", () => {
  /* ... */
});
```

**Consequence:**

- Test proves nothing (passed immediately)
- Likely tests implementation, not requirements
- Missed edge cases

**Fix:** DELETE the implementation. Write failing test. Rewrite implementation.

### Violation: Test Passes Immediately

```bash
$ npm test
PASS  ./retry.test.ts
  ✓ retries 3 times (2 ms)
```

**Red Flag:** Test passed on first run = you didn't see it fail = it might not test anything useful.

**Fix:** Temporarily break implementation to verify test catches it.

### Violation: Skipping Refactor

```typescript
// ❌ WRONG: Test passes, moved to next feature
// Left duplicated code, unclear names, nested complexity
```

**Consequence:**

- Technical debt accumulates
- Code harder to maintain
- Future features slower

**Fix:** After GREEN, always REFACTOR before next test.

## Prevention Checklist

Before writing any production code:

- [ ] Have I written a failing test first?
- [ ] Did I run the test and see it fail?
- [ ] Did it fail for the RIGHT reason (missing feature, not typo)?
- [ ] Am I writing MINIMAL code to pass the test?
- [ ] After green, did I REFACTOR?
- [ ] Do all tests still pass after refactor?

If you answer "no" to any: STOP. Fix it before continuing.
