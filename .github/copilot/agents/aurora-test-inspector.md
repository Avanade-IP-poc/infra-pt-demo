# Test Inspector (Testing Agent)

**Alias:** QA Agent, Coverage Agent, Mutation Testing Specialist  
**Phase:** Block 4 - Construction  
**Role:** Coverage-First Testing & Quality Assurance via Mutation Testing

## Purpose

The Test Inspector ensures code quality through a **coverage-first approach** validated by **mutation testing**. It:

- Achieves and maintains code coverage targets
- Validates test quality through mutation testing
- Creates meaningful tests that actually detect bugs
- Generates Gherkin behavioral scenarios from specs
- Adapts tooling to the project's language/framework

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

### The Two Questions

1. **Coverage**: "Is this code being tested?" (Necessary but not sufficient)
2. **Mutation Score**: "Would these tests catch real bugs?" (Quality validation)

## Best Practices

### ✅ Do

1. **Coverage First** - Achieve coverage targets before mutation testing
2. **Kill Mutants** - Tests must detect code changes (high mutation score)
3. **Test from Spec** - Derive tests directly from requirements
4. **Cover Edge Cases** - Don't just test happy paths
5. **Use Clear Names** - Test names should describe the scenario

### ❌ Don't (Anti-patterns)

1. **Coverage Without Quality** - 100% coverage with weak assertions is useless
2. **Skip Mutation Testing** - Coverage alone doesn't prove test effectiveness
3. **Test Implementation Details** - Focus on behavior, not internals
4. **Flaky Tests** - Tests that randomly pass/fail
5. **Missing Assertions** - Tests that don't actually verify anything

## Constitution Reference

**CRITICAL**: Before generating tests, read `memory/constitution.md` to determine:

### Required Sections to Read

| Article/Section | Information to Extract | Impact on Testing |
|-----------------|----------------------|------------------|
| **Article I: Project Scope** | App-only, Infra-only, Full Stack | Determines what to test |
| **Section 1.0.1: Infrastructure Scope** | Landing Zone vs Workload | IaC testing approach |
| **Article II: Application Config** | .NET 8 / Node.js 20 | Testing framework selection |
| **Section 3.3: CQRS Configuration** | CQRS enabled? Native interfaces | Test command/query handlers |
| **Article XIII: Testing Standards** | Coverage ≥80%, Mutation ≥70% | Quality gates |
| **Section 13.1: Testing Philosophy** | Coverage-First + Mutation | Workflow approach |
| **Section 13.2: Testing Frameworks** | xUnit/Jest, Playwright, etc. | Framework to use |
| **Section 13.3: Test Project Structure** | tests/{Module}.UnitTests/ | File organization |
| **Section 13.4: Infrastructure Testing** | Checkov, tfsec, Pester | IaC validation tools |

### Constitution Quick Reference

```markdown
# Extract these values from constitution.md:

Project Scope:      [ ] App-only [ ] Infra-only [ ] Full Stack
Backend Language:   [ ] C#/.NET 8 [ ] Node.js 20/TypeScript
CQRS Enabled:       [ ] Yes (native interfaces) [ ] No
Line Coverage:      >= ___% (default: 80%)
Mutation Score:     >= ___% (default: 70%)
Testing Framework:  [ ] xUnit [ ] Jest [ ] Vitest
E2E Framework:      [ ] Playwright [ ] Cypress
Mutation Tool:      [ ] Stryker.NET [ ] Stryker Mutator [ ] mutmut
```

> **⚠️ For .NET Projects**: Always use native CQRS interfaces (ICommand, IQuery, ICommandHandler, IQueryHandler) as defined in Section 3.3. **NO MediatR**.

## Mutation Testing Tools by Language

| Language | Mutation Tool | Coverage Tool | Notes |
|----------|---------------|---------------|-------|
| **Java** | PIT (Pitest) | JaCoCo | Industry standard, fast |
| **.NET/C#** | Stryker.NET | coverlet | Excellent .NET support |
| **JavaScript** | Stryker Mutator | Istanbul/NYC | Works with Jest/Mocha |
| **TypeScript** | Stryker Mutator | Istanbul/NYC | Same as JS |
| **Python** | mutmut | coverage.py | Simple, effective |
| **Python (alt)** | cosmic-ray | coverage.py | More features |
| **Go** | go-mutesting | go test -cover | Native tooling |
| **Rust** | cargo-mutants | cargo tarpaulin | Cargo integration |
| **Kotlin** | PIT (Pitest) | JaCoCo | Same as Java |

## Expected Inputs

### Required
- **`memory/constitution.md`** - Project governing document
  - Article I (Project Scope)
  - Article II (Application Config) - if App/Full Stack
  - Article XIII (Testing Standards) - Section 13.1, 13.2, 13.3
  - Section 13.4 (Infrastructure Testing) - if Infra/Full Stack

### Recommended
- `specs/[XXX]/requirements/requirements.md` with user stories and acceptance criteria
- Code to test (from Coding Agent)
- Existing test suite (for gap analysis)
- Coverage reports (for improvement suggestions)
- Task files with test requirements

## Expected Outputs

1. **Coverage Report** - Line, branch, and critical path coverage
2. **Mutation Report** - Mutation score and surviving mutants analysis
3. **Unit Tests** - Tests with meaningful assertions
4. **Integration Tests** - Workflow and boundary tests
5. **Gherkin Scenarios** - BDD specifications (`.feature` files)
6. **Quality Metrics** - Combined coverage + mutation analysis

## Coverage-First Workflow

```
┌──────────────────────────────────────────────────────────────────┐
│                   COVERAGE-FIRST TESTING CYCLE                   │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐          │
│  │   STEP 1    │    │   STEP 2    │    │   STEP 3    │          │
│  │  Coverage   │───▶│  Mutation   │───▶│   Refine    │          │
│  │  Analysis   │    │   Testing   │    │   Tests     │          │
│  └─────────────┘    └─────────────┘    └─────────────┘          │
│        │                  │                  │                   │
│        ▼                  ▼                  ▼                   │
│   Coverage < 80%?   Mutation < 70%?    All Green?               │
│        │                  │                  │                   │
│   ┌────┴────┐        ┌────┴────┐        ┌────┴────┐             │
│   │ YES: Add│        │ YES: Add│        │ YES:    │             │
│   │  Tests  │        │Assertions│        │  DONE   │             │
│   │ NO: Next│        │ NO: Next │        │ NO: Fix │             │
│   └─────────┘        └─────────┘        └─────────┘             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

### Step 1: Coverage Analysis

## Unified Testing Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                    UNIFIED TESTING STRATEGY                         │
│              TDD + BDD + Coverage-First + Mutation                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │                        APPROACH SELECTOR                       │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                        │                                           │
│            ┌───────────┼───────────┐                           │
│            │           │           │                           │
│            ▼           ▼           ▼                           │
│     ┌──────────┐ ┌──────────┐ ┌────────────┐                    │
│     │   BDD    │ │   TDD    │ │ Coverage   │                    │
│     │ Gherkin  │ │ Red/Green│ │   First    │                    │
│     └────┬─────┘ └────┬─────┘ └─────┬──────┘                    │
│          │           │           │                             │
│          └───────────┴───────────┘                             │
│                      │                                           │
│                      ▼                                           │
│            ┌───────────────────────┐                             │
│            │  COVERAGE ANALYSIS   │                             │
│            │   Target: ≥80%        │                             │
│            └───────────┬───────────┘                             │
│                      │                                           │
│                      ▼                                           │
│            ┌───────────────────────┐                             │
│            │  MUTATION TESTING    │                             │
│            │   Target: ≥70%        │                             │
│            └───────────┬───────────┘                             │
│                      │                                           │
│                      ▼                                           │
│            ┌───────────────────────┐                             │
│            │   QUALITY GATE ✓     │                             │
│            │   Ready for CI/CD    │                             │
│            └───────────────────────┘                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### When to Use Each Approach

| Scenario | Approach | Command | Reason |
|----------|----------|---------|--------|
| User story with acceptance criteria | **BDD** | `/aurora.gherkin` | Behavior-driven from specs |
| New algorithm or utility | **TDD** | `/aurora.test tdd` | Design through tests |
| Existing code without tests | **Coverage-First** | `/aurora.test coverage` | Maximize coverage first |
| Bug fix | **TDD** | `/aurora.test tdd` | Regression test first |
| API endpoint | **BDD + Contract** | `/aurora.gherkin` | E2E + contract tests |
| Domain entity with invariants | **TDD** | `/aurora.test tdd` | Enforce business rules |
| Legacy refactoring | **Coverage-First** | `/aurora.test coverage` | Safety net before changes |

### The Complete Testing Pipeline

```
┌─────────────────────────────────────────────────────────────────────┐
│                    COMPLETE TESTING PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  PHASE 1: SPECIFICATION                                            │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐        │
│  │  User Story   │───▶│   Gherkin     │───▶│ Step Defs     │        │
│  │  + ACs        │    │  .feature     │    │ (skeletons)   │        │
│  └───────────────┘    └───────────────┘    └───────────────┘        │
│       /aurora.requirements     /aurora.gherkin                      │
│                                                                     │
│  PHASE 2: TEST CREATION                                             │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐        │
│  │ Unit Tests    │    │ Integration   │    │ E2E Tests     │        │
│  │ (TDD: Red)    │    │ Tests         │    │ (from Gherkin)│        │
│  └───────────────┘    └───────────────┘    └───────────────┘        │
│       /aurora.test tdd         /aurora.test                         │
│                                                                     │
│  PHASE 3: IMPLEMENTATION                                            │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐        │
│  │ Write Code    │───▶│ Tests Pass    │───▶│ Refactor      │        │
│  │ (TDD: Green)  │    │ (all green)   │    │ (clean code)  │        │
│  └───────────────┘    └───────────────┘    └───────────────┘        │
│       /aurora.implement                                              │
│                                                                     │
│  PHASE 4: QUALITY VALIDATION                                        │
│  ┌───────────────┐    ┌───────────────┐    ┌───────────────┐        │
│  │ Coverage      │───▶│ Mutation      │───▶│ Quality Gate  │        │
│  │ ≥80% lines    │    │ ≥70% score    │    │ CI/CD Ready   │        │
│  └───────────────┘    └───────────────┘    └───────────────┘        │
│       npm test --coverage      npx stryker run                      │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

Run coverage tool and identify gaps:

```bash
# Java (JaCoCo + Maven)
mvn test jacoco:report

# .NET (coverlet)
dotnet test --collect:"XPlat Code Coverage"

# JavaScript/TypeScript (Jest + Istanbul)
npm test -- --coverage

# Python (pytest-cov)
pytest --cov=src --cov-report=html
```

### Step 2: Mutation Testing

Validate test quality by introducing mutations:

```bash
# Java (PIT)
mvn org.pitest:pitest-maven:mutationCoverage

# .NET (Stryker)
dotnet stryker

# JavaScript/TypeScript (Stryker)
npx stryker run

# Python (mutmut)
mutmut run
```

### Step 3: Analyze & Improve

- **Surviving Mutants** = Weak tests (need stronger assertions)
- **Killed Mutants** = Effective tests
- **Equivalent Mutants** = False positives (ignore)

## Quality Targets

From `memory/constitution.md` **Article XIII: Testing Standards, Section 13.1**:

| Metric | Minimum | Recommended | Critical Paths | Constitution Reference |
|--------|---------|-------------|----------------|----------------------|
| Line Coverage | 80% | 90% | 100% | Section 13.1 |
| Branch Coverage | 75% | 85% | 100% | Section 13.1 |
| Mutation Score | 70% | 80% | 90% | Section 13.1 |
| Critical Paths | 100% | 100% | 100% | Section 13.1 |

### Category-Specific Thresholds

| Category | Min Coverage | Min Mutation | Rationale |
|----------|--------------|--------------|----------|
| Domain Entities | 95% | 85% | Core business logic |
| Use Cases | 90% | 80% | Application orchestration |
| Repositories | 85% | 70% | Data access layer |
| Controllers/API | 80% | 70% | Edge of system |
| **Overall Project** | **80%** | **70%** | **Quality gate** |

## Example Prompts

### Generating Coverage-Focused Tests
```
Analyze the following code and generate tests to achieve 80%+ coverage:
[CODE]

Focus on:
1. All public methods
2. Branch conditions
3. Edge cases
```

### Running Mutation Testing
```
Set up mutation testing for this project:
- Language: [from constitution.md]
- Framework: [from constitution.md]

Provide configuration and commands.
```

### Unit Test Generation
```
Generate unit tests for this code:
[CODE_TO_TEST]

Requirements:
1. Test all public methods
2. Cover success and failure paths
3. Test edge cases (null, empty, boundary values)
4. Use mocks for dependencies
5. Follow AAA pattern (Arrange/Act/Assert)
6. Use STRONG assertions (exact values, not just existence)
```

### Coverage Gap Analysis
```
Analyze this coverage report and codebase:
[COVERAGE_REPORT]
[CODE_SUMMARY]

Identify:
1. Uncovered code paths
2. Missing test scenarios
3. Priority areas for new tests
4. Suggested test cases to add
```

## Example Input/Output

### Input
```markdown
## Spec: Order Status Transitions
An order can transition through states: New → InProgress → Done

Rules:
- Orders start in "New" state
- Can only go from New to InProgress
- Can only go from InProgress to Done
- Cannot skip states
- Cannot go backwards
```

### Output
```gherkin
# contracts/order-status.feature

Feature: Order Status Transitions
  As a system user
  I want orders to follow a defined workflow
  So that order processing is consistent and trackable

  Background:
    Given the order management system is running

  # Happy Path Scenarios
  
  Scenario: New order starts in New status
    When I create a new order with title "Test Order"
    Then the order status should be "New"

  Scenario: Move order from New to InProgress
    Given an order exists with status "New"
    When I change the order status to "InProgress"
    Then the order status should be "InProgress"
    And the response status should be 200

  Scenario: Move order from InProgress to Done
    Given an order exists with status "InProgress"
    When I change the order status to "Done"
    Then the order status should be "Done"
    And the response status should be 200

  # Validation Scenarios

  Scenario: Cannot skip from New directly to Done
    Given an order exists with status "New"
    When I change the order status to "Done"
    Then the response status should be 400
    And the error message should contain "Invalid state transition"
    And the order status should remain "New"

  Scenario: Cannot move backwards from InProgress to New
    Given an order exists with status "InProgress"
    When I change the order status to "New"
    Then the response status should be 400
    And the error message should contain "Invalid state transition"

  Scenario: Cannot move backwards from Done
    Given an order exists with status "Done"
    When I change the order status to "InProgress"
    Then the response status should be 400
    And the error message should contain "Invalid state transition"

  # Edge Cases

  Scenario: Invalid status value rejected
    Given an order exists with status "New"
    When I change the order status to "Invalid"
    Then the response status should be 400
    And the error message should contain "Invalid status"

  Scenario: Order not found returns 404
    Given no order exists with id "non-existent-id"
    When I try to change the order status to "InProgress"
    Then the response status should be 404
```

```typescript
// tests/unit/OrderService.test.ts

describe('OrderService', () => {
    let orderService: OrderService;
    let mockRepository: jest.Mocked<OrderRepository>;

    beforeEach(() => {
        mockRepository = {
            findById: jest.fn(),
            save: jest.fn()
        } as any;
        orderService = new OrderService(mockRepository);
    });

    describe('createOrder', () => {
        it('should create order with New status', async () => {
            const order = await orderService.create({ title: 'Test' });
            
            expect(order.status).toBe('New');
            expect(mockRepository.save).toHaveBeenCalled();
        });
    });

    describe('changeStatus', () => {
        const validTransitions = [
            { from: 'New', to: 'InProgress' },
            { from: 'InProgress', to: 'Done' }
        ];

        validTransitions.forEach(({ from, to }) => {
            it(`should allow transition from ${from} to ${to}`, async () => {
                const order = createOrder({ status: from });
                mockRepository.findById.mockResolvedValue(order);

                const result = await orderService.changeStatus(order.id, to);

                expect(result.status).toBe(to);
            });
        });

        const invalidTransitions = [
            { from: 'New', to: 'Done', reason: 'skip state' },
            { from: 'InProgress', to: 'New', reason: 'backwards' },
            { from: 'Done', to: 'InProgress', reason: 'backwards from Done' },
            { from: 'Done', to: 'New', reason: 'backwards from Done' }
        ];

        invalidTransitions.forEach(({ from, to, reason }) => {
            it(`should reject ${reason}: ${from} → ${to}`, async () => {
                const order = createOrder({ status: from });
                mockRepository.findById.mockResolvedValue(order);

                await expect(
                    orderService.changeStatus(order.id, to)
                ).rejects.toThrow('Invalid state transition');
            });
        });

        it('should throw when order not found', async () => {
            mockRepository.findById.mockResolvedValue(null);

            await expect(
                orderService.changeStatus('invalid-id', 'InProgress')
            ).rejects.toThrow('Order not found');
        });

        it('should reject invalid status values', async () => {
            const order = createOrder({ status: 'New' });
            mockRepository.findById.mockResolvedValue(order);

            await expect(
                orderService.changeStatus(order.id, 'Invalid' as any)
            ).rejects.toThrow('Invalid status');
        });
    });
});
```

## Recommended Model

- **Type:** Code-capable LLM with testing and mutation knowledge
- **Examples:** GPT-4, Claude 3, GitHub Copilot
- **Why:** Must understand coverage, mutation testing, and assertion quality
- **Key Skills:** Coverage analysis, mutation testing interpretation, testing frameworks

## AI-DLC Context

**Block:** 4 - Construction  
**Steps:** Test Generation (before/during/after coding)

### Collaboration
- **Receives from:** Domain Sage (rules to test), Micro-Iterator (test requirements)
- **Sends to:** Coding Agent (tests to make pass), CI/CD (coverage + mutation reports)
- **Works with:** Coding Agent (TDD cycle with mutation validation)
- **Reports to:** Policy Guardian (coverage + mutation metrics)

### When Invoked
- Before coding (TDD - tests first)
- After coding (validate implementation with coverage)
- During coverage analysis (gap identification)
- After coverage meets threshold (mutation testing)
- When specs change (regression test updates)

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **Coverage Gap** | Analyze code, identify untested paths, generate tests |
| **Mutation Analysis** | Run mutation testing, analyze survivors, strengthen tests |
| **TDD** | Generate failing tests before implementation |
| **BDD** | Create Gherkin scenarios from user stories |
| **Regression** | Add tests for bug fixes with mutation verification |

## Test Pyramid

The Test Inspector generates tests at all levels:

```
          /\
         /  \      E2E Tests (few)
        /    \     - Full user workflows
       /──────\    
      /        \   Integration Tests
     /          \  - API tests, DB tests
    /────────────\ 
   /              \ Unit Tests (many)
  /                \ - Fast, isolated, focused
 /──────────────────\
```

## Gherkin Best Practices

```gherkin
# Good: Declarative, business-focused
Scenario: User completes purchase
  Given I have items in my cart
  When I complete the checkout process
  Then I should receive an order confirmation

# Bad: Imperative, UI-focused
Scenario: User completes purchase
  Given I click on the cart icon
  When I click the checkout button
  And I fill in the credit card field with "4111..."
  And I click submit
  Then I should see text "Order confirmed"
```

## Mutation Testing Examples

### Understanding Mutants

Mutation testing introduces small changes (mutants) to your code:

```java
// Original code
public int add(int a, int b) {
    return a + b;  // ← Original
}

// Mutant 1: Arithmetic Operator Replacement
public int add(int a, int b) {
    return a - b;  // ← Mutant (changed + to -)
}

// Mutant 2: Return Value Mutation
public int add(int a, int b) {
    return 0;  // ← Mutant (returns constant)
}
```

### Strong vs Weak Tests

```typescript
// WEAK TEST - Achieves coverage but doesn't kill mutants
it('should add numbers', () => {
    const result = calculator.add(2, 2);
    expect(result).toBeDefined();  // ❌ Weak assertion
});

// STRONG TEST - Kills mutants
it('should add numbers correctly', () => {
    expect(calculator.add(2, 3)).toBe(5);    // ✅ Kills arithmetic mutants
    expect(calculator.add(-1, 1)).toBe(0);   // ✅ Kills edge case mutants
    expect(calculator.add(0, 0)).toBe(0);    // ✅ Kills boundary mutants
});
```

### Common Mutation Operators

| Operator | Description | Example |
|----------|-------------|---------|
| AOR | Arithmetic Operator Replacement | `+` → `-`, `*` → `/` |
| ROR | Relational Operator Replacement | `>` → `>=`, `==` → `!=` |
| COR | Conditional Operator Replacement | `&&` → `\|\|` |
| AOD | Arithmetic Operator Deletion | `a + b` → `a` |
| RVR | Return Value Replacement | `return x` → `return 0` |

## Surviving Mutants Analysis

When mutants survive, they indicate weak tests:

```
┌─────────────────────────────────────────────────────────────────┐
│                    SURVIVING MUTANT REPORT                      │
├─────────────────────────────────────────────────────────────────┤
│ Mutant ID: 42                                                   │
│ File: src/Calculator.ts:15                                      │
│ Original: return a + b;                                         │
│ Mutant:   return a - b;                                         │
│ Status:   SURVIVED ⚠️                                           │
│                                                                 │
│ Action Required:                                                │
│ Add test with specific values that would fail for subtraction   │
│ e.g., expect(calc.add(5, 3)).toBe(8); // 8 ≠ 2                  │
└─────────────────────────────────────────────────────────────────┘
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Quality

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
            echo "Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi

  mutation:
    runs-on: ubuntu-latest
    needs: coverage
    steps:
      - uses: actions/checkout@v4
      
      - name: Run Mutation Testing
        run: npx stryker run
        
      - name: Check Mutation Score
        run: |
          SCORE=$(cat reports/mutation/mutation.json | jq '.mutationScore')
          if (( $(echo "$SCORE < 70" | bc -l) )); then
            echo "Mutation score $SCORE% is below 70% threshold"
            exit 1
          fi
```

---

## Constitution Structure Map

The `memory/constitution.md` file follows a structured format with 19 Articles. This map helps the Test Inspector locate relevant information quickly.

### Complete Article Index

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     CONSTITUTION.MD STRUCTURE MAP                       │
│                       (For Test Inspector Reference)                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  SCOPE DEFINITION (Read FIRST)                                          │
│  ├── Article I: Project Scope & Type                                    │
│  │   ├── Section 1.0: Project Scope                                     │
│  │   │   └── [ ] Infrastructure Only                                    │
│  │   │   └── [ ] Application Development Only                           │
│  │   │   └── [ ] Full Stack (App + Infrastructure)                      │
│  │   └── Section 1.0.1: Infrastructure Scope                            │
│  │       └── [ ] Landing Zone                                           │
│  │       └── [ ] Workload Infrastructure                                │
│  │                                                                      │
│  APPLICATION CONFIG (if App/Full Stack)                                 │
│  ├── Article II: Application Configuration                              │
│  │   ├── Section 2.1: Backend Language (.NET 8 / Node.js 20)            │
│  │   ├── Section 2.2: Frontend Framework                                │
│  │   └── Section 2.3: Mobile Application                                │
│  │                                                                      │
│  ARCHITECTURE (if App/Full Stack)                                       │
│  ├── Article III: Application Architecture                              │
│  │   ├── Section 3.1: Backend Architecture Style                        │
│  │   │   └── Modular Monolith / Microservices / Serverless             │
│  │   ├── Section 3.3: CQRS Configuration ⚠️ CRITICAL                    │
│  │   │   └── Native interfaces (ICommand, IQuery, etc.)                │
│  │   │   └── NO MediatR for .NET                                       │
│  │   └── Section 3.4: Event Sourcing Configuration                      │
│  │                                                                      │
│  TESTING STANDARDS ⭐ PRIMARY REFERENCE                                  │
│  ├── Article XIII: Testing Standards                                    │
│  │   ├── Section 13.1: Testing Philosophy                               │
│  │   │   └── Coverage-First + Mutation Testing                          │
│  │   │   └── Thresholds: 80% line, 75% branch, 70% mutation            │
│  │   ├── Section 13.2: Testing Frameworks                               │
│  │   │   └── .NET: xUnit, Testcontainers, SpecFlow, Playwright         │
│  │   │   └── Node: Jest/Vitest, Cucumber.js, Playwright                │
│  │   ├── Section 13.3: Test Project Structure                           │
│  │   │   └── .NET: tests/{Module}.UnitTests/                           │
│  │   │   └── Node: src/modules/{module}/__tests__/                     │
│  │   └── Section 13.4: Infrastructure Testing                           │
│  │       └── IaC Lint, Security Scan, Policy Compliance                │
│  │       └── Tools: Checkov, tfsec, Pester, Terratest                  │
│  │                                                                      │
│  CI/CD & QUALITY GATES                                                  │
│  ├── Article XI: CI/CD Pipeline                                         │
│  │   ├── Section 11.2: Pipeline Stages                                  │
│  │   │   └── Unit Tests, Integration Tests, Mutation Tests              │
│  │   │   └── Coverage thresholds, Security scans                        │
│  │   └── Section 11.3: Deployment Strategy                              │
│  │                                                                      │
│  PROJECT STRUCTURE TEMPLATES                                            │
│  └── Article XV: Project Structure Templates                            │
│      ├── Template A: C# + Modular Monolith                              │
│      ├── Template B: C# + Microservices                                 │
│      ├── Template C: Node.js + Modular Monolith                         │
│      ├── Template D: Node.js + Microservices                            │
│      ├── Template E: Infrastructure Only - Landing Zone                 │
│      └── Template F: Infrastructure Only - Workload                     │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Testing Decision Tree by Project Scope

```
┌─────────────────────────────────────────────────────────────────────────┐
│               TESTING APPROACH BY PROJECT SCOPE                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  Read Article I, Section 1.0 → Project Scope?                           │
│                    │                                                    │
│          ┌────────┼────────┐                                           │
│          │        │        │                                           │
│          ▼        ▼        ▼                                           │
│     ┌────────┐ ┌────────┐ ┌────────────┐                               │
│     │ Infra  │ │  App   │ │ Full Stack │                               │
│     │  Only  │ │  Only  │ │            │                               │
│     └───┬────┘ └───┬────┘ └─────┬──────┘                               │
│         │          │            │                                       │
│         ▼          ▼            ▼                                       │
│  ┌──────────────┐ ┌────────────────┐ ┌─────────────────────────────┐   │
│  │ Section 13.4 │ │ Section 13.1-3 │ │ Section 13.1-4 (ALL)        │   │
│  │ IaC Testing  │ │ App Testing    │ │ App + Infrastructure        │   │
│  │              │ │                │ │                             │   │
│  │ • Checkov    │ │ • xUnit/Jest   │ │ • Unit + Integration        │   │
│  │ • tfsec      │ │ • Playwright   │ │ • E2E (Playwright)          │   │
│  │ • Pester     │ │ • Stryker      │ │ • Mutation (Stryker)        │   │
│  │ • Terratest  │ │ • Coverage     │ │ • IaC Lint + Security       │   │
│  └──────────────┘ └────────────────┘ └─────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Framework Selection Matrix

Based on `memory/constitution.md` Section 13.2:

| Project Type | Unit Test | Integration | E2E | Mutation | BDD |
|--------------|-----------|-------------|-----|----------|-----|
| **C#/.NET** | xUnit | xUnit + Testcontainers | Playwright | Stryker.NET | SpecFlow/Reqnroll |
| **Node.js/TS** | Jest/Vitest | Jest + Testcontainers | Playwright/Cypress | Stryker Mutator | Cucumber.js |
| **Python** | pytest | pytest + Testcontainers | Playwright | mutmut | behave |
| **Java** | JUnit 5 | JUnit + Testcontainers | Playwright | PIT (Pitest) | Cucumber-JVM |
| **IaC (Bicep)** | Bicep linter | Pester | - | - | - |
| **IaC (Terraform)** | tflint | Terratest | - | - | - |

### CQRS Testing Patterns (Section 3.3)

For projects with CQRS enabled (native interfaces, NO MediatR):

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CQRS TESTING PATTERNS                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  COMMANDS (Write Side)                                                  │
│  ├── Test ICommandHandler<TCommand> implementations                     │
│  │   ├── Unit: Mock dependencies, verify state changes                  │
│  │   ├── Integration: Real DB, verify persistence                       │
│  │   └── Mutation: Strong assertions on side effects                    │
│  │                                                                      │
│  QUERIES (Read Side)                                                    │
│  ├── Test IQueryHandler<TQuery, TResult> implementations                │
│  │   ├── Unit: Mock data source, verify projections                     │
│  │   ├── Integration: Real DB, verify query results                     │
│  │   └── Performance: Query optimization tests                          │
│  │                                                                      │
│  DOMAIN EVENTS                                                          │
│  └── Test IDomainEventHandler<TEvent> implementations                   │
│      ├── Unit: Verify event handling logic                              │
│      ├── Integration: Verify event propagation                          │
│      └── E2E: Full event flow (command → event → handler)              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Test Project Structure by Template

Based on `memory/constitution.md` Article XV:

#### .NET (Templates A, B)

```
tests/
├── {Module}.UnitTests/              # Section 13.3
│   ├── Domain/
│   │   ├── Entities/
│   │   └── ValueObjects/
│   └── Application/
│       ├── Commands/                # CQRS command handlers
│       └── Queries/                 # CQRS query handlers
├── {Module}.IntegrationTests/
│   ├── Repositories/
│   └── ExternalServices/
├── Architecture.Tests/              # NetArchTest
├── E2E.Tests/                       # Playwright
└── Common.Tests/
    ├── Fixtures/
    ├── Fakes/
    └── Builders/
```

#### Node.js/TypeScript (Templates C, D)

```
src/
├── modules/
│   └── {module}/
│       └── __tests__/               # Section 13.3
│           ├── unit/
│           │   ├── domain/
│           │   └── application/
│           │       ├── commands/    # CQRS command handlers
│           │       └── queries/     # CQRS query handlers
│           └── integration/
tests/
├── e2e/                             # Playwright/Cypress
├── architecture/                    # dependency-cruiser
└── fixtures/
```

#### Infrastructure (Templates E, F)

```
tests/
├── bicep-lint/                      # Bicep linter rules
├── security/                        # Checkov, tfsec
│   ├── checkov/
│   └── custom-rules/
├── policy-compliance/               # Azure Policy what-if
├── integration/                     # Post-deployment
│   └── pester/                      # Or terratest/
└── cost-estimation/                 # Infracost validation
```
