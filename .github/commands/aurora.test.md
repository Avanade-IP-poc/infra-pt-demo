---
description: Generate comprehensive test suites with coverage-first approach and mutation testing validation. Supports TDD, BDD, and Coverage-First modes.
handoffs: 
  - label: Implement (TDD Green)
    agent: aurora.implement
    prompt: Execute implementation to make failing tests pass (TDD green phase)
    send: true
  - label: Generate Gherkin (BDD)
    agent: aurora.gherkin
    prompt: Generate Gherkin scenarios from user stories before creating step definitions
    send: true
  - label: Review Quality
    agent: aurora.review
    prompt: Review test coverage, mutation score, and test quality
    send: true
scripts:
  sh: scripts/bash/run-tests.sh --coverage --mutation
  ps: scripts/powershell/Run-Tests.ps1 -Coverage -Mutation
---

## User Input

```text
$ARGUMENTS
```

**Arguments supported:**
- `tdd` or `tdd [feature-name]` - TDD mode: generate failing tests first
- `bdd` or `bdd [feature-name]` - BDD mode: derive unit tests from Gherkin step definitions
- `coverage` or `coverage [path]` - Coverage-first mode: generate tests for uncovered code
- (empty) - Auto-detect best approach based on context

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Generate test suites that achieve coverage targets and validate test quality through mutation testing.

**AURORA Stage**: EXECUTE (coverage-first approach)

**Responsible Agent**: Test Sentinel

## Testing Philosophy

```
┌─────────────────────────────────────────────────────────────────┐
│                    COVERAGE-FIRST APPROACH                      │
├─────────────────────────────────────────────────────────────────┤
│  1. COVERAGE  →  2. MUTATION  →  3. QUALITY  →  4. CONFIDENCE   │
│                                                                 │
│  "Coverage tells you what code is executed.                     │
│   Mutation testing tells you if your tests would catch bugs."   │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

Required files:
- `specs/[XXX-feature-name]/requirements/requirements.md` - User stories with acceptance criteria
- `memory/constitution.md` - Project governing document (see below for relevant sections)

### Constitution References (CRITICAL)

Before generating tests, read these sections from `memory/constitution.md`:

| Section | Purpose | Key Information |
|---------|---------|----------------|
| **Article I: Project Scope** | Determines testing scope | App-only vs Infra-only vs Full Stack |
| **Article II: Application Configuration** | Language/runtime | .NET 8, Node.js 20, frameworks |
| **Article XIII: Testing Standards** | Testing requirements | Coverage ≥80%, Mutation ≥70% |
| **Section 13.2: Testing Frameworks** | Framework selection | xUnit/.NET, Jest/Node.js, Playwright |
| **Section 13.3: Test Project Structure** | File organization | tests/{Module}.UnitTests/, etc. |
| **Section 3.3: CQRS Configuration** | CQRS pattern | Native interfaces (NO MediatR for .NET) |

Optional (improve test generation):
- `specs/[XXX-feature-name]/planning/tasks.md` - Implementation tasks
- `specs/[XXX-feature-name]/requirements/data-model.md` - Entity definitions
- `specs/[XXX-feature-name]/contracts/*.yaml` - API specifications

## Quality Targets

From `memory/constitution.md` **Article XIII: Testing Standards, Section 13.1**:

| Metric | Minimum | Recommended | Critical Paths | Tool (.NET / Node.js) |
|--------|---------|-------------|----------------|----------------------|
| Line Coverage | 80% | 90% | 100% | coverlet / istanbul |
| Branch Coverage | 75% | 85% | 100% | coverlet / istanbul |
| Mutation Score | 70% | 80% | 90% | Stryker.NET / Stryker |
| Critical Paths | 100% | 100% | 100% | - |

> **⚠️ IMPORTANT**: These thresholds are defined in the project's constitution. Always verify the actual values in `memory/constitution.md` Section 13.1 as they may be customized per project.

## Mutation Testing Tools by Language

| Language | Mutation Tool | Coverage Tool | Config File |
|----------|---------------|---------------|-------------|
| **Java** | PIT (Pitest) | JaCoCo | `pom.xml` / `build.gradle` |
| **.NET/C#** | Stryker.NET | coverlet | `stryker-config.json` |
| **JavaScript** | Stryker Mutator | Istanbul/NYC | `stryker.conf.js` |
| **TypeScript** | Stryker Mutator | Istanbul/NYC | `stryker.conf.js` |
| **Python** | mutmut | coverage.py | `pyproject.toml` |
| **Go** | go-mutesting | go test -cover | `Makefile` |

## Testing Pyramid

```
         ┌─────────┐
         │   E2E   │  10% - User journeys
         ├─────────┤
         │  Integ  │  20% - Component interaction
         ├─────────┤
         │  Unit   │  70% - Isolated logic
         └─────────┘
```

## TDD vs BDD: Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────┐
│                     TESTING APPROACH SELECTOR                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────┐       ┌──────────────────┐                    │
│  │   User Story?    │──YES──▶│   Use BDD/Gherkin │                   │
│  │  Business Rules? │        │   /aurora.gherkin │                   │
│  └────────┬─────────┘        └────────┬─────────┘                   │
│           │NO                         │                             │
│           ▼                           ▼                             │
│  ┌──────────────────┐       ┌──────────────────┐                    │
│  │ Technical Logic? │──YES──▶│    Use TDD        │                   │
│  │ Algorithm/Util?  │        │ /aurora.test tdd  │                   │
│  └────────┬─────────┘        └────────┬─────────┘                   │
│           │NO                         │                             │
│           ▼                           ▼                             │
│  ┌──────────────────┐       ┌──────────────────┐                    │
│  │ Existing Code?   │──YES──▶│  Coverage-First   │                   │
│  │ Legacy System?   │        │ /aurora.test cov  │                   │
│  └──────────────────┘        └──────────────────┘                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

| Scenario | Approach | Command | Output |
|----------|----------|---------|--------|
| User story with ACs | **BDD** | `/aurora.gherkin` | `.feature` + step defs |
| New algorithm/utility | **TDD** | `/aurora.test tdd` | Failing tests first |
| Existing untested code | **Coverage-First** | `/aurora.test coverage` | Tests for uncovered paths |
| Bug fix | **TDD** | `/aurora.test tdd` | Regression test first |
| API endpoint | **BDD + Contract** | `/aurora.gherkin` | Contract + E2E tests |
| Domain entity | **TDD** | `/aurora.test tdd` | Unit tests with invariants |

## Test Categories

### 1. Unit Tests (70%)

Test isolated business logic with **strong assertions**:

```typescript
// File: tests/unit/domain/entities/user.test.ts

import { User } from '@/domain/entities/user';
import { Email } from '@/domain/value-objects/email';

describe('User Entity', () => {
  describe('create', () => {
    it('should create user with valid data', () => {
      // Arrange
      const props = {
        email: 'test@example.com',
        name: 'Test User',
      };

      // Act
      const result = User.create(props);

      // Assert
      expect(result.success).toBe(true);
      expect(result.value.email.value).toBe(props.email);
    });

    it('should reject invalid email', () => {
      // Arrange
      const props = {
        email: 'invalid-email',
        name: 'Test User',
      };

      // Act
      const result = User.create(props);

      // Assert
      expect(result.success).toBe(false);
      expect(result.error.code).toBe('INVALID_EMAIL');
    });
  });
});
```

### 2. Integration Tests (20%)

Test component interactions:

```typescript
// File: tests/integration/repositories/user-repository.test.ts

import { UserRepositoryImpl } from '@/infrastructure/persistence/user-repository-impl';
import { createTestDatabase } from '@tests/helpers/database';

describe('UserRepository Integration', () => {
  let repository: UserRepositoryImpl;
  let db: Database;

  beforeEach(async () => {
    db = await createTestDatabase();
    repository = new UserRepositoryImpl(db);
  });

  afterEach(async () => {
    await db.cleanup();
  });

  it('should persist and retrieve user', async () => {
    // Arrange
    const user = User.create({ email: 'test@example.com', name: 'Test' }).value;

    // Act
    await repository.save(user);
    const retrieved = await repository.findById(user.id);

    // Assert
    expect(retrieved).not.toBeNull();
    expect(retrieved.email.value).toBe(user.email.value);
  });
});
```

### 3. API Contract Tests

Test API endpoints against contracts:

```typescript
// File: tests/contract/api/users-api.test.ts

import { createApp } from '@/app';
import request from 'supertest';

describe('Users API Contract', () => {
  const app = createApp();

  describe('POST /api/users', () => {
    it('should return 201 with created user', async () => {
      // Arrange
      const payload = {
        email: 'new@example.com',
        name: 'New User',
        password: 'SecurePass123!',
      };

      // Act
      const response = await request(app)
        .post('/api/users')
        .send(payload);

      // Assert
      expect(response.status).toBe(201);
      expect(response.body).toMatchObject({
        id: expect.any(String),
        email: payload.email,
        name: payload.name,
      });
    });

    it('should return 400 for invalid email', async () => {
      // Arrange
      const payload = {
        email: 'invalid',
        name: 'New User',
        password: 'SecurePass123!',
      };

      // Act
      const response = await request(app)
        .post('/api/users')
        .send(payload);

      // Assert
      expect(response.status).toBe(400);
      expect(response.body.errors).toContainEqual(
        expect.objectContaining({ field: 'email' })
      );
    });
  });
});
```

### 4. E2E Tests (10%)

Test complete user journeys:

```typescript
// File: tests/e2e/user-registration.test.ts

import { test, expect } from '@playwright/test';

test.describe('User Registration Journey', () => {
  test('should complete registration flow [US-001]', async ({ page }) => {
    // Navigate to registration
    await page.goto('/register');
    
    // Fill form
    await page.fill('[data-testid="email"]', 'user@example.com');
    await page.fill('[data-testid="name"]', 'Test User');
    await page.fill('[data-testid="password"]', 'SecurePass123!');
    
    // Submit
    await page.click('[data-testid="submit"]');
    
    // Verify success
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome"]')).toContainText('Test User');
  });
});
```

## Execution Flow

### Step 1: Extract Test Requirements

From `requirements/requirements.md`, extract:

```markdown
## US-001: User Registration

### Acceptance Criteria
- AC1: User can register with email, name, password
- AC2: Email must be valid and unique
- AC3: Password must be at least 8 characters
- AC4: User receives confirmation email
- AC5: User can log in after registration
```

Map to tests:

```markdown
| Criteria | Test Type | Test File |
|----------|-----------|-----------|
| AC1 | Unit | user.test.ts |
| AC1 | Contract | users-api.test.ts |
| AC2 | Unit | email.test.ts |
| AC2 | Integration | user-repository.test.ts |
| AC3 | Unit | password.test.ts |
| AC4 | Integration | email-service.test.ts |
| AC5 | E2E | user-registration.test.ts |
```

### Step 2: Generate Test Structure

Create test files following project structure:

```
tests/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── user.test.ts
│   │   └── value-objects/
│   │       ├── email.test.ts
│   │       └── password.test.ts
│   └── application/
│       └── use-cases/
│           └── create-user.test.ts
├── integration/
│   ├── repositories/
│   │   └── user-repository.test.ts
│   └── services/
│       └── email-service.test.ts
├── contract/
│   └── api/
│       └── users-api.test.ts
├── e2e/
│   └── user-registration.test.ts
└── helpers/
    ├── database.ts
    ├── factories.ts
    └── mocks.ts
```

### Step 3: Generate Test Cases

For each acceptance criterion:

```markdown
### AC: [Criterion text]

**Positive Tests** (happy path):
- Test 1: [Normal usage scenario]
- Test 2: [Alternative valid scenario]

**Negative Tests** (error handling):
- Test 3: [Invalid input scenario]
- Test 4: [Edge case scenario]

**Boundary Tests**:
- Test 5: [Minimum valid value]
- Test 6: [Maximum valid value]
- Test 7: [Just below minimum]
- Test 8: [Just above maximum]
```

### Step 4: Generate Test Helpers

```typescript
// File: tests/helpers/factories.ts

import { User } from '@/domain/entities/user';

export const UserFactory = {
  create(overrides = {}) {
    return User.create({
      email: 'default@example.com',
      name: 'Default User',
      password: 'DefaultPass123!',
      ...overrides,
    }).value;
  },

  createInvalid(field: string) {
    const invalidValues = {
      email: 'invalid-email',
      name: '',
      password: 'weak',
    };
    return { ...this.create(), [field]: invalidValues[field] };
  },
};
```

```typescript
// File: tests/helpers/mocks.ts

export const mockEmailService = {
  send: jest.fn().mockResolvedValue(true),
  verify: jest.fn().mockResolvedValue(true),
};

export const mockUserRepository = {
  findById: jest.fn(),
  findByEmail: jest.fn(),
  save: jest.fn(),
  delete: jest.fn(),
};
```

## Test Naming Convention

```
[Unit/Class/Method]_[Scenario]_[ExpectedResult]
```

Examples:
- `User_CreateWithValidData_ReturnsUser`
- `Email_CreateWithInvalidFormat_ThrowsValidationError`
- `CreateUserUseCase_WhenEmailExists_ReturnsConflictError`

## Output

```markdown
## Tests Generated

**User Story**: US-001
**Acceptance Criteria**: 5
**Tests Generated**: 24

### By Type
| Type | Count | Files |
|------|-------|-------|
| Unit | 15 | 4 files |
| Integration | 5 | 2 files |
| Contract | 3 | 1 file |
| E2E | 1 | 1 file |

### By Criterion
| AC | Tests | Coverage |
|----|-------|----------|
| AC1 | 6 | ✅ |
| AC2 | 5 | ✅ |
| AC3 | 4 | ✅ |
| AC4 | 5 | ✅ |
| AC5 | 4 | ✅ |

### Files Created
- `tests/unit/domain/entities/user.test.ts`
- `tests/unit/domain/value-objects/email.test.ts`
- `tests/unit/domain/value-objects/password.test.ts`
- `tests/unit/application/use-cases/create-user.test.ts`
- `tests/integration/repositories/user-repository.test.ts`
- `tests/integration/services/email-service.test.ts`
- `tests/contract/api/users-api.test.ts`
- `tests/e2e/user-registration.test.ts`
- `tests/helpers/factories.ts`
- `tests/helpers/mocks.ts`

**Next Steps**:
1. Run `/aurora.implement` with TDD approach
2. Execute `npm test` to verify setup
3. Check coverage with `npm test -- --coverage`
```

## Coverage Requirements

From `memory/constitution.md` **Article XIII, Section 13.1 - Testing Philosophy**:

> **Coverage-First approach validated by Mutation Testing**

| Category | Min Coverage | Min Mutation Score | Rationale |
|----------|--------------|-------------------|----------|
| Domain entities | 95% | 85% | Core business logic, highest risk |
| Use cases | 90% | 80% |
| Repositories | 85% | 70% |
| Controllers | 80% | 70% |
| Overall | 80% | 70% |

## Test-Driven Mode (TDD)

When `$ARGUMENTS: tdd` or `$ARGUMENTS: tdd [feature-name]`:

### TDD Cycle: Red → Green → Refactor → Mutate

```
┌─────────────────────────────────────────────────────────────────────┐
│                         TDD + MUTATION CYCLE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐         │
│   │  🔴 RED │───▶│ 🟢 GREEN│───▶│ 🔵 REFAC│───▶│ 🧬 MUTATE│         │
│   │  Write  │    │  Make   │    │  Clean  │    │ Validate │         │
│   │  Test   │    │  Pass   │    │  Code   │    │ Quality  │         │
│   └─────────┘    └─────────┘    └─────────┘    └────┬────┘         │
│        ▲                                            │               │
│        │              ◄─────────────────────────────┘               │
│        │              (if mutants survive, add assertions)          │
│        └────────────────────────────────────────────────────────────┤
│                        Next requirement                             │
└─────────────────────────────────────────────────────────────────────┘
```

### TDD Workflow Steps

| Step | Action | Command | Success Criteria |
|------|--------|---------|------------------|
| 1. 🔴 RED | Write failing test | Create test file | Test fails with expected error |
| 2. 🟢 GREEN | Minimal implementation | `/aurora.implement` | Test passes |
| 3. 🔵 REFACTOR | Clean code | Manual or assisted | Tests still pass |
| 4. 📊 COVERAGE | Check coverage | `npm test --coverage` | Coverage ≥ 80% |
| 5. 🧬 MUTATE | Run mutation testing | `npx stryker run` | Mutation score ≥ 70% |
| 6. 💪 STRENGTHEN | Kill surviving mutants | Add assertions | All critical mutants killed |

### TDD Test Template

```typescript
// TDD: Write this test FIRST, before implementation exists
describe('[FeatureName]', () => {
  describe('[MethodName]', () => {
    // Happy path - write first
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      const input = /* test data */;
      
      // Act
      const result = featureUnderTest(input);
      
      // Assert - STRONG assertions that kill mutants
      expect(result).toBe(expectedValue);  // Exact value, not just truthy
    });

    // Edge cases - write after happy path passes
    it('should [handle edge case] when [boundary condition]', () => {
      // Test boundary values, nulls, empty inputs
    });

    // Error cases - ensure errors are thrown correctly
    it('should throw [ErrorType] when [invalid condition]', () => {
      expect(() => featureUnderTest(invalidInput)).toThrow(ErrorType);
    });
  });
});
```

## BDD Mode (Behavior-Driven Development)

When `$ARGUMENTS: bdd` or `$ARGUMENTS: bdd [feature-name]`:

### BDD to Unit Test Derivation

From Gherkin scenarios, derive unit tests that validate the same behaviors:

```
┌─────────────────────────────────────────────────────────────────┐
│                    BDD → UNIT TEST PIPELINE                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  .feature file          Step Definitions      Unit Tests        │
│  ┌─────────────┐        ┌─────────────┐      ┌─────────────┐   │
│  │ Given user  │───────▶│ async func  │─────▶│ describe()  │   │
│  │ When action │        │ setup/act   │      │ it() cases  │   │
│  │ Then result │        │ assert      │      │ focused     │   │
│  └─────────────┘        └─────────────┘      └─────────────┘   │
│                                                                 │
│  E2E Test (10%)         Integration (20%)    Unit Test (70%)    │
└─────────────────────────────────────────────────────────────────┘
```

### BDD Workflow Steps

| Step | Action | Output |
|------|--------|--------|
| 1 | Read `.feature` files | Understand scenarios |
| 2 | Extract behaviors | List of Given/When/Then |
| 3 | Identify business logic | Core functions to test |
| 4 | Generate unit tests | 70% of test suite |
| 5 | Generate integration tests | 20% of test suite |
| 6 | Keep E2E as Gherkin | 10% of test suite |

### Example: Gherkin to Unit Tests

**Input Gherkin:**
```gherkin
Feature: Order Status Transitions
  Scenario: Move order from New to InProgress
    Given an order exists with status "New"
    When I change the order status to "InProgress"
    Then the order status should be "InProgress"
```

**Derived Unit Tests:**
```typescript
// Derived from Gherkin scenario - tests the business logic directly
describe('OrderService', () => {
  describe('changeStatus', () => {
    it('should transition from New to InProgress', () => {
      // Given - setup from Gherkin
      const order = OrderFactory.create({ status: 'New' });
      
      // When - action from Gherkin
      const result = orderService.changeStatus(order.id, 'InProgress');
      
      // Then - assertion from Gherkin (STRONG)
      expect(result.status).toBe('InProgress');  // Exact match
    });

    // Additional tests derived from same scenario
    it('should not modify other order properties', () => {
      const order = OrderFactory.create({ status: 'New', title: 'Test' });
      const result = orderService.changeStatus(order.id, 'InProgress');
      expect(result.title).toBe('Test');  // Unchanged
    });

    it('should record status change timestamp', () => {
      const before = new Date();
      const order = OrderFactory.create({ status: 'New' });
      const result = orderService.changeStatus(order.id, 'InProgress');
      expect(result.statusChangedAt).toBeInstanceOf(Date);
      expect(result.statusChangedAt.getTime()).toBeGreaterThanOrEqual(before.getTime());
    });
  });
});
```

## Coverage-First Mode

When `$ARGUMENTS: coverage` or `$ARGUMENTS: coverage [path]`:

### Coverage-First Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                    COVERAGE-FIRST WORKFLOW                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. ANALYZE    →   2. IDENTIFY    →   3. GENERATE   →  4. RUN  │
│  existing          uncovered          tests for        & check │
│  coverage          paths              gaps             targets │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Coverage Gap Analysis Template

```markdown
## Coverage Analysis Report

**Current Coverage**: 65%
**Target Coverage**: 80%
**Gap**: 15% (need ~X more tests)

### Uncovered Areas

| File | Uncovered Lines | Suggested Tests |
|------|-----------------|-----------------|
| `src/service.ts` | 45-52, 78-85 | Error handling, edge cases |
| `src/validator.ts` | 23-30 | Invalid input scenarios |
| `src/utils.ts` | 15-18 | Boundary conditions |

### Generated Tests for Gap
- `service.test.ts`: 5 new tests for error handling
- `validator.test.ts`: 3 new tests for invalid inputs
- `utils.test.ts`: 2 new tests for boundaries
```

## Mutation Testing Workflow

### Step 1: Run Coverage First

```bash
# JavaScript/TypeScript
npm test -- --coverage

# .NET
dotnet test --collect:"XPlat Code Coverage"

# Java
mvn test jacoco:report

# Python
pytest --cov=src --cov-report=html
```

### Step 2: Check Coverage Meets Threshold

If coverage < 80%:
- Identify uncovered lines/branches
- Generate additional tests
- Repeat until threshold met

### Step 3: Run Mutation Testing

```bash
# JavaScript/TypeScript (Stryker)
npx stryker run

# .NET (Stryker.NET)
dotnet stryker

# Java (PIT)
mvn org.pitest:pitest-maven:mutationCoverage

# Python (mutmut)
mutmut run
```

### Step 4: Analyze Surviving Mutants

```
┌─────────────────────────────────────────────────────────────────┐
│                    SURVIVING MUTANT ANALYSIS                    │
├─────────────────────────────────────────────────────────────────┤
│ Surviving mutants indicate WEAK TESTS that need strengthening:  │
│                                                                 │
│ • Add specific value assertions (not just existence checks)     │
│ • Test boundary conditions explicitly                           │
│ • Verify error messages/codes specifically                      │
│ • Assert on side effects (mock calls, state changes)            │
└─────────────────────────────────────────────────────────────────┘
```

### Example: Weak vs Strong Tests

```typescript
// ❌ WEAK - Achieves coverage but doesn't kill mutants
it('should calculate total', () => {
    const result = calculator.add(2, 3);
    expect(result).toBeDefined();  // Weak: only checks existence
});

// ✅ STRONG - Kills arithmetic operator mutants
it('should add numbers correctly', () => {
    expect(calculator.add(2, 3)).toBe(5);     // Exact value
    expect(calculator.add(-1, 1)).toBe(0);    // Edge case
    expect(calculator.add(0, 0)).toBe(0);     // Boundary
    expect(calculator.add(100, -50)).toBe(50); // Different values
});
```

## Output

```markdown
## Tests Generated

**User Story**: US-001
**Acceptance Criteria**: 5
**Tests Generated**: 24

### Quality Metrics
| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Line Coverage | 92% | 80% | ✅ |
| Branch Coverage | 85% | 75% | ✅ |
| Mutation Score | 78% | 70% | ✅ |
| Killed Mutants | 156/200 | - | - |
| Surviving Mutants | 44 | - | ⚠️ |

### By Test Type
| Type | Count | Files |
|------|-------|-------|
| Unit | 15 | 4 files |
| Integration | 5 | 2 files |
| Contract | 3 | 1 file |
| E2E | 1 | 1 file |

### Files Created
- `tests/unit/domain/entities/user.test.ts`
- `tests/unit/domain/value-objects/email.test.ts`
- `tests/unit/application/use-cases/create-user.test.ts`
- `tests/integration/repositories/user-repository.test.ts`
- `tests/e2e/user-registration.test.ts`
- `stryker.conf.js` (if not exists)

**Next Steps**:
1. Run `npm test -- --coverage` to verify coverage
2. Run `npx stryker run` to validate test quality
3. Analyze surviving mutants and strengthen weak tests
4. Iterate until mutation score >= 70%
```

## CI/CD Integration

```yaml
# .github/workflows/test-quality.yml
name: Test Quality Gate

on: [push, pull_request]

jobs:
  coverage:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Tests with Coverage
        run: npm test -- --coverage
        
      - name: Check Coverage Threshold
        run: |
          COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "❌ Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
          echo "✅ Coverage: $COVERAGE%"

  mutation:
    runs-on: ubuntu-latest
    needs: coverage  # Only run if coverage passes
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Mutation Testing
        run: npx stryker run
        
      - name: Check Mutation Score
        run: |
          SCORE=$(cat reports/mutation/mutation.json | jq '.mutationScore')
          if (( $(echo "$SCORE < 70" | bc -l) )); then
            echo "❌ Mutation score $SCORE% is below 70% threshold"
            exit 1
          fi
          echo "✅ Mutation Score: $SCORE%"
```

---

## Constitution Reference Map

The `memory/constitution.md` is the single source of truth for this project. This section maps relevant constitution sections to testing activities.

### Quick Reference: Testing-Related Sections

```
┌─────────────────────────────────────────────────────────────────────────┐
│                 CONSTITUTION SECTIONS FOR TESTING                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ⭐ PRIMARY: Article XIII - Testing Standards                           │
│  ├── Section 13.1: Testing Philosophy                                   │
│  │   └── Coverage-First + Mutation Testing approach                     │
│  │   └── Thresholds: Line ≥80%, Branch ≥75%, Mutation ≥70%             │
│  ├── Section 13.2: Testing Frameworks                                   │
│  │   └── .NET: xUnit, Testcontainers, SpecFlow, Playwright             │
│  │   └── Node: Jest/Vitest, Cucumber.js, Playwright                    │
│  ├── Section 13.3: Test Project Structure                               │
│  │   └── .NET: tests/{Module}.UnitTests/, etc.                         │
│  │   └── Node: src/modules/{module}/__tests__/                         │
│  └── Section 13.4: Infrastructure Testing (if Infra scope)              │
│      └── IaC Lint, Checkov, tfsec, Pester, Terratest                   │
│                                                                         │
│  📋 CONTEXT: Article I - Project Scope                                  │
│  └── Determines what testing applies:                                   │
│      └── App-only → Sections 13.1-13.3                                 │
│      └── Infra-only → Section 13.4                                     │
│      └── Full Stack → All of Article XIII                              │
│                                                                         │
│  🔧 ARCHITECTURE: Article III - Application Architecture                │
│  └── Section 3.3: CQRS Configuration                                   │
│      └── ⚠️ Native interfaces (NO MediatR for .NET)                    │
│      └── ICommand, IQuery, ICommandHandler, IQueryHandler              │
│      └── IDomainEvent, IDomainEventHandler                             │
│                                                                         │
│  🏗️ STRUCTURE: Article XV - Project Structure Templates                │
│  └── Template A: C# + Modular Monolith                                 │
│  └── Template B: C# + Microservices                                    │
│  └── Template C: Node.js + Modular Monolith                            │
│  └── Template D: Node.js + Microservices                               │
│  └── Template E: Infrastructure Only - Landing Zone                    │
│  └── Template F: Infrastructure Only - Workload                        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Pre-Test Generation Checklist

Before generating tests, verify these constitution values:

```markdown
# Extract from memory/constitution.md:

## Project Scope (Article I, Section 1.0)
- [ ] Infrastructure Only → Use Section 13.4
- [ ] Application Development Only → Use Sections 13.1-13.3
- [ ] Full Stack → Use ALL of Article XIII

## Backend Stack (Article II, Section 2.1)
- [ ] C#/.NET 8 → xUnit, Stryker.NET, SpecFlow
- [ ] Node.js 20 → Jest/Vitest, Stryker Mutator, Cucumber.js

## CQRS (Article III, Section 3.3)
- [ ] CQRS Enabled → Test ICommandHandler, IQueryHandler
- [ ] CQRS Disabled → Standard service tests
- [ ] ⚠️ .NET: NO MediatR (use native interfaces)

## Thresholds (Article XIII, Section 13.1)
- Line Coverage: >= ___% (default: 80%)
- Branch Coverage: >= ___% (default: 75%)
- Mutation Score: >= ___% (default: 70%)

## Testing Frameworks (Section 13.2)
- Unit Framework: ____________
- Integration: ____________
- E2E: ____________
- BDD: ____________
- Mutation: ____________
```

### CQRS Test Patterns (if Section 3.3 enabled)

For projects using native CQRS interfaces:

```csharp
// Testing ICommandHandler<TCommand>
[Fact]
public async Task Handle_ValidCommand_ShouldPersistEntity()
{
    // Arrange
    var command = new CreateOrderCommand { /* ... */ };
    var handler = new CreateOrderCommandHandler(_mockRepository.Object);
    
    // Act
    await handler.HandleAsync(command, CancellationToken.None);
    
    // Assert
    _mockRepository.Verify(r => r.AddAsync(It.IsAny<Order>()), Times.Once);
}

// Testing IQueryHandler<TQuery, TResult>
[Fact]
public async Task Handle_ExistingId_ShouldReturnDto()
{
    // Arrange
    var query = new GetOrderByIdQuery { OrderId = Guid.NewGuid() };
    _mockRepository.Setup(r => r.GetByIdAsync(query.OrderId))
        .ReturnsAsync(CreateTestOrder());
    var handler = new GetOrderByIdQueryHandler(_mockRepository.Object);
    
    // Act
    var result = await handler.HandleAsync(query, CancellationToken.None);
    
    // Assert - STRONG assertion (kills mutants)
    Assert.NotNull(result);
    Assert.Equal(query.OrderId, result.Id);
}
```

```typescript
// Testing ICommandHandler (Node.js/TypeScript)
describe('CreateOrderCommandHandler', () => {
  it('should persist order when command is valid', async () => {
    // Arrange
    const command: CreateOrderCommand = { /* ... */ };
    const mockRepo = { save: jest.fn() };
    const handler = new CreateOrderCommandHandler(mockRepo);
    
    // Act
    await handler.handle(command);
    
    // Assert
    expect(mockRepo.save).toHaveBeenCalledWith(
      expect.objectContaining({ id: expect.any(String) })
    );
  });
});
```
    needs: coverage  # Only run if coverage passes
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Mutation Testing
        run: npx stryker run
        
      - name: Check Mutation Score
        run: |
          SCORE=$(cat reports/mutation/mutation.json | jq '.mutationScore')
          if (( $(echo "$SCORE < 70" | bc -l) )); then
            echo "❌ Mutation score $SCORE% is below 70% threshold"
            exit 1
          fi
          echo "✅ Mutation Score: $SCORE%"
```
