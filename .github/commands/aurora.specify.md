---
description: Create or update feature specifications from natural language descriptions, aligned with AURORA-IA methodology.
handoffs: 
  - label: Create Technical Plan
    agent: aurora.plan
    prompt: Create implementation plan. I am building with...
  - label: Clarify Requirements
    agent: aurora.clarify
    prompt: Clarify ambiguous requirements
    send: true
scripts:
  sh: scripts/bash/create-feature.sh --json "{ARGS}"
  ps: scripts/powershell/Create-Feature.ps1 -Json "{ARGS}"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Transform a natural language feature description into a structured specification document following AURORA-IA methodology.

**AURORA Stage**: PERCEIVE + ANALYZE

**Responsible Agent**: Business Explorer

## Prerequisites

1. Constitution exists at `/memory/constitution.md`
2. Read constitution to understand tech stack and constraints

## Execution Flow

### 1. Parse Feature Description

Extract from user input:
- **Core Functionality**: What the feature does
- **Actors**: Who uses it (users, systems, admins)
- **Actions**: What actions are performed
- **Data**: What data is involved
- **Constraints**: Limitations or requirements

### 2. Generate Feature Branch

Create semantic branch name:
```
Pattern: [NNN]-[short-name]
Example: 001-user-authentication
```

Rules:
- Scan existing branches/specs for highest number
- Increment by 1
- Generate 2-4 word short name from description
- Use action-noun format (e.g., "add-user-auth")

### 3. Create Spec Directory

```
specs/[XXX-feature-name]/
├── requirements/
│   └── requirements.md   # Feature specification
├── contracts/
│   └── openapi.yaml      # API contracts (created by /aurora.plan)
├── tests/
│   └── feature.feature   # Gherkin scenarios (created by /aurora.gherkin)
└── planning/
    ├── plan.md           # Implementation plan (created by /aurora.plan)
    ├── tasks.md          # Task list (created by /aurora.tasks)
    └── research.md       # Technical research (created by /aurora.plan)
```

### 4. Generate Specification

Generate specification using the following template:

```markdown
# Feature: [Feature Name]

## Overview

### Context
[Business context and motivation]

### Problem Statement
[What problem does this solve]

### Proposed Solution
[High-level solution description]

## Functional Requirements

### FR-001: [Requirement Name]
**Priority**: P1/P2/P3
**Description**: [Detailed description]
**Acceptance Criteria**:
- Given [context], when [action], then [outcome]

## Non-Functional Requirements

### NFR-001: [Requirement Name]
**Category**: Performance/Security/Scalability
**Requirement**: [Measurable requirement]

## User Stories

### US-001: [User Story Title]
**As a** [actor]
**I want to** [action]
**So that** [benefit]

**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Key Entities

| Entity | Description | Key Attributes |
|--------|-------------|----------------|
| [Entity] | [Description] | [Attributes] |

## Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| [Case] | [Behavior] |

## Out of Scope

- [Explicitly excluded item]

## Open Questions

- [Question needing clarification]
```

### 5. Constitution Alignment Check

Validate spec against constitution:
- [ ] Tech stack compatible
- [ ] Architecture principles followed
- [ ] Security requirements addressed
- [ ] Quality gates defined
- [ ] No constitution violations

### 6. Clarity Assessment

For unclear aspects:
- Make informed assumptions based on context
- Mark critical unknowns with `[NEEDS CLARIFICATION: question]`
- **LIMIT**: Maximum 3 clarification markers
- Prioritize by impact: scope > security > UX > technical

## Output

```
## Specification Created

**Feature**: [XXX-feature-name]
**Spec File**: specs/[XXX-feature-name]/requirements/requirements.md

**Summary**:
- Functional Requirements: [count]
- Non-Functional Requirements: [count]
- User Stories: [count]
- Entities: [count]

**Clarifications Needed**: [count]
[List of NEEDS CLARIFICATION items if any]

**Next Steps**:
1. Review specification
2. Run `/aurora.clarify` if clarifications needed
3. Run `/aurora.plan` to create implementation plan

**Suggested Command**:
/aurora.plan [tech stack preferences from constitution]
```

## Validation Rules

Before completing:
- [ ] All requirements are testable
- [ ] User stories have acceptance criteria
- [ ] Entities are identified
- [ ] Edge cases documented
- [ ] Constitution alignment verified
- [ ] Maximum 3 clarification markers

## Error Conditions

| Error | Action |
|-------|--------|
| Empty description | ERROR: "No feature description provided" |
| No constitution | WARN: "Constitution not found, using defaults" |
| Cannot determine actors | ERROR: "Cannot identify feature actors" |
| Too many unknowns (>5) | ERROR: "Feature too ambiguous, provide more detail" |
