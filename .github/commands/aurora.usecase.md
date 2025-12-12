---
description: Generate detailed use case specifications from user stories following UML/Cockburn style.
handoffs: 
  - label: Generate Gherkin
    agent: aurora.gherkin
    prompt: Generate BDD scenarios from use case flows
    send: true
  - label: Model Domain
    agent: aurora.domain
    prompt: Extract domain entities from use cases
    send: true
scripts:
  sh: scripts/bash/generate-usecases.sh
  ps: scripts/powershell/Generate-UseCases.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Generate detailed use case specifications from user stories, providing full actor-system interaction flows.

**AURORA Stage**: DISCOVERY

**Responsible Agent**: Domain Sage

## Constitution Check

**FIRST**: Read `memory/constitution.md` to understand:
- Documentation format preferences
- Naming conventions
- Architecture style (affects use case granularity)

## Use Case Template

For each user story, generate `specs/[XXX-feature-name]/requirements/use-cases/UC-[XXX].md`:

```markdown
# Use Case: [Use Case Title]

## Metadata

| Property | Value |
|----------|-------|
| UC ID | UC-[XXX] |
| User Story | US-[XXX] |
| Primary Actor | [Actor name] |
| Scope | [System/Subsystem] |
| Level | User Goal / Subfunction |
| Status | Draft |

## Brief Description

[One paragraph summary of what this use case accomplishes]

## Stakeholders and Interests

| Stakeholder | Interest |
|-------------|----------|
| [Actor 1] | [What they want from this interaction] |
| [System] | [System constraints or goals] |
| [Compliance] | [Regulatory requirements if any] |

## Preconditions

1. [Condition that must be true before use case starts]
2. [Another precondition]

## Postconditions (Success Guarantees)

1. [State of system after successful completion]
2. [Data changes that occurred]

## Triggers

- [Event that initiates this use case]

## Main Success Scenario (Basic Flow)

| Step | Actor | System |
|------|-------|--------|
| 1 | [Actor action] | |
| 2 | | [System response] |
| 3 | [Actor action] | |
| 4 | | [System validates...] |
| 5 | | [System persists...] |
| 6 | | [System confirms to actor] |

### Detailed Steps

1. **Actor** initiates [action]
   - Input: [what data is provided]
   
2. **System** validates request
   - Validates: [what is checked]
   - BR-001: [business rule applied]
   
3. **System** processes request
   - Creates/Updates: [what entities]
   - Triggers: [any events/notifications]
   
4. **System** returns result
   - Output: [what is returned]
   - Actor sees: [confirmation/result]

## Extensions (Alternative Flows)

### 2a. Validation Fails

| Step | Actor | System |
|------|-------|--------|
| 2a.1 | | System detects invalid [field] |
| 2a.2 | | System returns error with details |
| 2a.3 | Actor reviews and corrects | |
| 2a.4 | Return to step 1 | |

### 3a. [Resource] Not Found

| Step | Actor | System |
|------|-------|--------|
| 3a.1 | | System cannot locate [resource] |
| 3a.2 | | System returns 404 with message |
| 3a.3 | Actor is notified | |

### 4a. Authorization Denied

| Step | Actor | System |
|------|-------|--------|
| 4a.1 | | System detects insufficient permissions |
| 4a.2 | | System returns 403 Forbidden |
| 4a.3 | Use case ends | |

### *a. System Unavailable (Global)

| Step | Actor | System |
|------|-------|--------|
| *a.1 | | System detects service unavailable |
| *a.2 | | System returns 503 with retry-after |
| *a.3 | Actor may retry later | |

## Special Requirements

- **Performance**: Response within [X]ms
- **Security**: [Authentication/authorization requirements]
- **Audit**: [What must be logged]
- **Concurrency**: [How to handle concurrent access]

## Business Rules Applied

| Rule ID | Description | Enforcement |
|---------|-------------|-------------|
| BR-001 | [Rule description] | Validation at step 2 |
| BR-002 | [Rule description] | Check at step 3 |

## Data Variations

| Variation | Description | Impact |
|-----------|-------------|--------|
| [Variation 1] | [Different data scenario] | [How flow changes] |

## Frequency

- Expected usage: [X] times per [period]
- Peak usage: [X] concurrent

## Open Issues

| ID | Issue | Owner |
|----|-------|-------|
| UC-001-I1 | [Issue description] | [Owner] |

## Related Use Cases

| UC ID | Relationship |
|-------|--------------|
| UC-002 | Includes (called from step 3) |
| UC-003 | Extends (optional additional step) |

## Traceability

- **User Story**: US-[XXX]
- **Acceptance Criteria**: AC-[XXX].1, AC-[XXX].2
- **Test Cases**: TC-[XXX]-001, TC-[XXX]-002
```

## Execution Flow

### Step 1: Load User Stories

```bash
cat specs/[XXX-feature-name]/requirements/requirements.md
```

Extract all user stories (US-XXX).

### Step 2: Generate Use Cases

For each user story:

1. **Identify Primary Actor** from "As a [role]"
2. **Extract Goal** from "I want [capability]"
3. **Determine Benefit** from "So that [benefit]"
4. **Map Acceptance Criteria** to flows

### Step 3: Define Flows

#### Main Success Scenario
- Linear happy path from start to completion
- Each step: Actor action OR System response
- Include validations and business rules

#### Extensions
- Branch from main flow step number
- Cover error conditions
- Cover alternative paths
- Use `*a` for global exceptions

### Step 4: Cross-Reference

Link use cases to:
- User stories (US-XXX)
- Acceptance criteria (AC-XXX.X)
- Business rules (BR-XXX)

## Output

```markdown
## Use Cases Generated

**Feature**: [XXX-feature-name]
**User Stories Processed**: [count]
**Use Cases Created**: [count]

**Files Created**:
- specs/[XXX-feature-name]/requirements/use-cases/UC-001-[name].md
- specs/[XXX-feature-name]/requirements/use-cases/UC-002-[name].md
- specs/[XXX-feature-name]/requirements/use-cases/README.md

**Coverage**:
| User Story | Use Cases |
|------------|-----------|
| US-001 | UC-001, UC-002 |
| US-002 | UC-003 |

**Next Steps**:
1. `/aurora.gherkin` - Generate BDD scenarios
2. Review extensions for completeness
3. Validate with stakeholders
```

## Use Case Granularity

| Level | Description | Example |
|-------|-------------|---------|
| Summary | High-level business goal | "Manage Customer Lifecycle" |
| User Goal | Complete user task | "Register New Customer" |
| Subfunction | Supporting step | "Validate Email Address" |

For AURORA-IA, prefer **User Goal** level for primary use cases.
