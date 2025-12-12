---
description: Generate Gherkin BDD scenarios from user stories and acceptance criteria with step definitions.
handoffs: 
  - label: Generate Unit Tests (BDD)
    agent: aurora.test
    prompt: Generate unit tests derived from Gherkin step definitions using bdd mode
    send: true
  - label: Generate Unit Tests (TDD)
    agent: aurora.test
    prompt: Generate unit tests using TDD approach with tdd mode
    send: true
  - label: Coverage Analysis
    agent: aurora.test
    prompt: Analyze coverage and generate tests for uncovered paths
    send: true
  - label: Review Scenarios
    agent: aurora.review
    prompt: Review Gherkin scenarios and step definitions for completeness
    send: true
scripts:
  sh: scripts/bash/generate-gherkin.sh
  ps: scripts/powershell/Generate-Gherkin.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Generate Behavior-Driven Development (BDD) scenarios in Gherkin syntax from user stories and acceptance criteria.

**AURORA Stage**: DISCOVERY / CONSTRUCTION

**Responsible Agent**: Test Inspector

## Constitution Check

**FIRST**: Read `memory/constitution.md` to understand:
- **Testing Framework** - Cucumber, SpecFlow, Behave, pytest-bdd, etc.
- **Language** - Step definition language
- **Naming Conventions** - Feature file naming
- **Project Structure** - Where .feature files live

## Gherkin Structure

```gherkin
# Language from constitution (e.g., en, es)
@tag1 @tag2
Feature: [Feature Name]
  [Brief description of the feature]
  
  Background:
    Given [common precondition for all scenarios]
  
  @acceptance-criteria @AC-001.1
  Scenario: [Scenario Name]
    Given [initial context]
    And [additional context]
    When [action is performed]
    And [additional action]
    Then [expected outcome]
    And [additional outcome]
  
  @acceptance-criteria @AC-001.2
  Scenario Outline: [Parameterized Scenario]
    Given [context with <parameter>]
    When [action with <input>]
    Then [outcome with <expected>]
    
    Examples:
      | parameter | input | expected |
      | value1    | x     | result1  |
      | value2    | y     | result2  |
```

## Execution Flow

### Step 1: Load Source Documents

```bash
# Read spec with user stories
cat specs/[XXX-feature-name]/requirements/requirements.md

# Read use cases if available
cat specs/[XXX-feature-name]/requirements/use-cases/*.md
```

### Step 2: Map Acceptance Criteria to Scenarios

| Acceptance Criterion | Scenario Type | Gherkin Element |
|---------------------|---------------|-----------------|
| Single behavior | Scenario | One Given/When/Then |
| Multiple variations | Scenario Outline | With Examples table |
| Error condition | Scenario | With error outcome |
| Edge case | Scenario | With boundary values |

### Step 3: Generate Feature Files

Create `specs/[XXX-feature-name]/tests/[feature].feature`:

```gherkin
# language: en
@feature-name @epic-name
Feature: [Feature Name from requirements.md]
  As a [role from user story]
  I want [capability]
  So that [benefit]
  
  # Link to specification
  # Spec: ../requirements/requirements.md
  # User Story: US-001
  
  Background:
    Given the system is initialized
    And I am authenticated as a [role]
  
  # ============================================
  # User Story: US-001 - [Story Title]
  # ============================================
  
  @US-001 @AC-001.1 @happy-path
  Scenario: Successfully [action description]
    Given [precondition from use case]
    And [additional context]
    When I [perform action]
    Then I should see [expected result]
    And [side effect should occur]
  
  @US-001 @AC-001.2 @validation
  Scenario: Reject [action] with invalid [field]
    Given [precondition]
    When I [perform action] with invalid [field]
    Then I should see error "[error message]"
    And [action] should not be completed
  
  @US-001 @AC-001.3 @edge-case
  Scenario Outline: Handle [action] with various [parameter]
    Given [context]
    When I [action] with <parameter>
    Then the result should be <expected>
    
    Examples: Valid values
      | parameter | expected |
      | min_value | success  |
      | max_value | success  |
    
    Examples: Invalid values
      | parameter   | expected      |
      | below_min   | error_message |
      | above_max   | error_message |
  
  # ============================================
  # User Story: US-002 - [Story Title]
  # ============================================
  
  @US-002 @AC-002.1
  Scenario: [Next scenario]
    # ...
```

### Step 4: Tag Strategy

| Tag Type | Format | Purpose |
|----------|--------|---------|
| Feature | @feature-name | Group by feature |
| Story | @US-XXX | Trace to user story |
| Criteria | @AC-XXX.X | Trace to acceptance criteria |
| Type | @happy-path, @error, @edge-case | Test type |
| Priority | @P1, @P2, @P3 | Execution priority |
| Automation | @manual, @automated | Automation status |
| WIP | @wip | Work in progress |

### Step 5: Step Definition Patterns

#### Given Steps (Preconditions)
```gherkin
Given the system is initialized
Given I am authenticated as a "admin"
Given a user exists with email "test@example.com"
Given the following users exist:
  | email           | role  |
  | user@test.com   | user  |
  | admin@test.com  | admin |
```

#### When Steps (Actions)
```gherkin
When I create a new user with:
  | field    | value           |
  | email    | new@example.com |
  | name     | Test User       |
When I submit the form
When I click the "Save" button
When I call POST "/api/users" with body:
  """json
  {"email": "test@example.com", "name": "Test"}
  """
```

#### Then Steps (Outcomes)
```gherkin
Then I should see "Success" message
Then the user should be created
Then the response status should be 201
Then the response should contain:
  | field | value           |
  | id    | [UUID]          |
  | email | test@example.com|
Then an email should be sent to "test@example.com"
```

## Output Structure

```
specs/[XXX-feature-name]/tests/
├── [feature-name].feature           # Main feature file
├── [feature-name]-admin.feature     # Admin scenarios (if needed)
├── step-definitions/                # Step definition files
│   ├── [feature-name].steps.ts      # TypeScript/JavaScript
│   ├── [feature-name].steps.cs      # C# (SpecFlow)
│   └── [feature-name]_steps.py      # Python (pytest-bdd/behave)
└── README.md                        # Test documentation
```

## Step Definition Generation

After generating `.feature` files, generate corresponding step definitions:

### TypeScript/JavaScript (Cucumber.js)

```typescript
// File: specs/[XXX-feature-name]/tests/step-definitions/[feature].steps.ts

import { Given, When, Then, Before, After } from '@cucumber/cucumber';
import { expect } from 'chai';

let context: TestContext;

Before(async function() {
  context = await createTestContext();
});

After(async function() {
  await context.cleanup();
});

// Given steps - Setup preconditions
Given('the system is running', async function() {
  expect(context.isRunning).to.be.true;
});

Given('a user exists with email {string}', async function(email: string) {
  context.user = await context.createUser({ email });
});

// When steps - Actions
When('I create a new user with:', async function(dataTable) {
  const data = dataTable.rowsHash();
  context.response = await context.api.post('/users', data);
});

// Then steps - Assertions (STRONG for mutation testing)
Then('the response status should be {int}', function(status: number) {
  expect(context.response.status).to.equal(status);  // Exact match
});

Then('the user should have email {string}', function(email: string) {
  expect(context.response.body.email).to.equal(email);  // Exact match
});
```

### C# (SpecFlow)

```csharp
// File: specs/[XXX-feature-name]/tests/step-definitions/[Feature]Steps.cs

using TechTalk.SpecFlow;
using FluentAssertions;

[Binding]
public class UserSteps
{
    private readonly ScenarioContext _context;
    private HttpResponseMessage _response;

    public UserSteps(ScenarioContext context)
    {
        _context = context;
    }

    [Given(@"the system is running")]
    public async Task GivenTheSystemIsRunning()
    {
        var health = await _client.GetAsync("/health");
        health.IsSuccessStatusCode.Should().BeTrue();
    }

    [When(@"I create a new user with email ""(.*)""")]
    public async Task WhenICreateUser(string email)
    {
        _response = await _client.PostAsJsonAsync("/users", new { Email = email });
    }

    [Then(@"the response status should be (\d+)")]
    public void ThenStatusShouldBe(int status)
    {
        ((int)_response.StatusCode).Should().Be(status);  // Exact match
    }
}
```

### Python (pytest-bdd)

```python
# File: specs/[XXX-feature-name]/tests/step-definitions/[feature]_steps.py

import pytest
from pytest_bdd import given, when, then, parsers

@pytest.fixture
def context():
    return TestContext()

@given("the system is running")
def system_running(context):
    assert context.is_running is True

@given(parsers.parse('a user exists with email "{email}"'))
def user_exists(context, email):
    context.user = context.create_user(email=email)

@when(parsers.parse('I create a new user with email "{email}"'))
def create_user(context, email):
    context.response = context.api.post('/users', json={'email': email})

@then(parsers.parse('the response status should be {status:d}'))
def check_status(context, status):
    assert context.response.status_code == status  # Exact match
```

## BDD to Unit Test Bridge

```
┌─────────────────────────────────────────────────────────────────────┐
│                     BDD → TEST PIPELINE                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. USER STORY     2. GHERKIN        3. STEP DEFS    4. UNIT TESTS │
│  ┌──────────┐     ┌──────────┐    ┌──────────┐   ┌──────────┐  │
│  │ As a... │────▶│ Scenario │───▶│ Given/   │──▶│ Unit     │  │
│  │ I want..│     │ Given..  │    │ When/    │   │ Tests    │  │
│  │ So that.│     │ When..   │    │ Then     │   │ (derived)│  │
│  └──────────┘     │ Then..   │    │ impl.    │   └──────────┘  │
│                   └──────────┘    └──────────┘                  │
│                                                                     │
│  /aurora.gherkin   ────────▶       /aurora.test bdd               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

Each Gherkin scenario should map to:
- **E2E Test**: The scenario itself (10%)
- **Integration Tests**: Step definition implementations (20%)
- **Unit Tests**: Business logic extracted from steps (70%)

## Output

```markdown
## Gherkin Scenarios Generated

**Feature**: [XXX-feature-name]
**User Stories Processed**: [count]
**Scenarios Created**: [count]

**Files Created**:
- `specs/[XXX-feature-name]/tests/[feature].feature`
- `specs/[XXX-feature-name]/tests/step-definitions/[feature].steps.[ext]`

**Coverage**:
| User Story | Scenarios | Tags | Step Defs |
|------------|-----------|------|------------|
| US-001 | 5 | @happy-path, @validation | 12 steps |
| US-002 | 3 | @happy-path, @error | 8 steps |

**Scenario Types**:
- Happy Path: [count]
- Validation/Error: [count]
- Edge Cases: [count]
- Scenario Outlines: [count]

**Step Definition Summary**:
| Step Type | Count | Reusable |
|-----------|-------|----------|
| Given | [n] | [n] |
| When | [n] | [n] |
| Then | [n] | [n] |

**Test Quality Targets**:
| Metric | Target | Notes |
|--------|--------|-------|
| E2E Coverage | 100% scenarios | All scenarios executable |
| Step Coverage | 100% | All steps implemented |
| Mutation Score | ≥70% | After unit test derivation |

**Next Steps**:
1. `/aurora.test bdd` - Generate unit tests from step definitions
2. Review scenarios with stakeholders
3. Run `npm test:bdd` (or equivalent)
4. Check coverage: `npm test -- --coverage`
5. Run mutation: `npx stryker run`
```

## Best Practices

### ✅ Do
- One scenario = one behavior
- Use domain language (ubiquitous language)
- Keep scenarios independent
- Use Background for common setup
- Use Scenario Outline for data variations

### ❌ Don't
- Multiple behaviors in one scenario
- Technical jargon in steps
- Dependencies between scenarios
- Over-complicated Given sections
- Duplicate step implementations

## Language Examples

### For .NET (SpecFlow from Constitution)
```gherkin
# language: en
@specflow
Feature: User Registration
```

### For Python (pytest-bdd from Constitution)
```gherkin
# language: en
@pytest-bdd
Feature: User Registration
```

### For JavaScript (Cucumber.js from Constitution)
```gherkin
# language: en
@cucumber-js
Feature: User Registration
```
