---
description: Create technical implementation plan from feature specification, aligned with AURORA-IA AI-DLC methodology.
handoffs: 
  - label: Generate Bolt Tasks
    agent: aurora.tasks
    prompt: Break the plan into Bolt tasks
    send: true
  - label: Review Architecture
    agent: omega-architect
    prompt: Review implementation plan architecture
scripts:
  sh: scripts/bash/setup-plan.sh --json
  ps: scripts/powershell/Setup-Plan.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Transform a feature specification into a detailed technical implementation plan, following the AURORA-IA AI-DLC methodology with Bolts (micro-iterations).

**AURORA Stage**: REASON + PLAN

**Responsible Agent**: Omega Architect

## Prerequisites

1. Feature specification exists at `specs/[XXX-feature-name]/requirements/requirements.md`
2. Constitution exists at `/memory/constitution.md`

## Execution Flow

### 1. Load Context

Read and analyze:
- `/memory/constitution.md` - Tech stack, principles, gates
- `specs/[XXX-feature-name]/requirements/requirements.md` - Feature requirements

Extract:
- Tech stack from constitution
- Functional requirements from spec
- Non-functional requirements from spec
- User stories with priorities

### 2. Constitution Compliance Check

Validate against constitution principles:

```markdown
## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| [Principle 1] | ✓ PASS / ✗ FAIL | [Notes] |
| [Principle 2] | ✓ PASS / ✗ FAIL | [Notes] |
```

**STOP if critical violations found. Request constitution amendment or spec revision.**

### 3. Technical Context Analysis

Identify and document:

```markdown
## Technical Context

### Stack Selection (from Constitution)
- Frontend: [FRAMEWORK] + [LANGUAGE]
- Backend: [FRAMEWORK] + [LANGUAGE]  
- Database: [DATABASE]
- Infrastructure: [CLOUD] + [IAC]

### Dependencies
- [Library 1]: [Version] - [Purpose]
- [Library 2]: [Version] - [Purpose]

### Integration Points
- [System 1]: [Protocol] - [Purpose]
- [System 2]: [Protocol] - [Purpose]

### Unknown/Research Needed
- [NEEDS RESEARCH: Topic 1]
- [NEEDS RESEARCH: Topic 2]
```

### 4. Phase 0: Research

For each `NEEDS RESEARCH` item:

1. Analyze options
2. Compare alternatives
3. Document decision rationale

Output: `specs/[XXX-feature-name]/planning/research.md`

```markdown
# Technical Research

## [Topic 1]

### Decision
[What was chosen]

### Rationale
[Why chosen]

### Alternatives Considered
- [Alternative 1]: [Pros/Cons]
- [Alternative 2]: [Pros/Cons]

### Risks
- [Risk]: [Mitigation]
```

### 5. Phase 1: Data Model Design

From entities in spec, create: `specs/[XXX-feature-name]/requirements/data-model.md`

```markdown
# Data Model

## Entities

### [Entity Name]

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| id | UUID | Yes | Primary Key |
| [field] | [type] | [yes/no] | [constraints] |

**Relationships**:
- Has many [Related Entity]
- Belongs to [Parent Entity]

**Invariants**:
- [Business rule that must always be true]

## Database Schema

```sql
CREATE TABLE [table_name] (
  ...
);
```
```

### 6. Phase 1: API Contract Design

From requirements, create: `specs/[XXX-feature-name]/contracts/`

For REST APIs:
```yaml
# contracts/openapi.yaml
openapi: 3.0.3
info:
  title: [Feature Name] API
  version: 1.0.0
paths:
  /api/[resource]:
    get:
      summary: [Description]
      responses:
        '200':
          description: Success
```

For events:
```yaml
# contracts/events.yaml
events:
  - name: [EventName]
    version: 1
    payload:
      - field: [name]
        type: [type]
```

### 7. Implementation Plan Structure

Create: `specs/[XXX-feature-name]/planning/plan.md`

```markdown
# Implementation Plan: [Feature Name]

## Overview

### Feature Reference
- Spec: `../requirements/requirements.md`
- Feature: [XXX-feature-name]

### Tech Stack (from Constitution)
[Extracted stack]

### Architecture Pattern
[Pattern from constitution]

## Constitution Check

[Compliance table]

## Bolt Planning

### Bolt 1: Foundation (2-3 days)
**Goal**: [Specific goal]
**Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]

**Success Criteria**:
- [Measurable criterion]

### Bolt 2: Core Implementation (2-3 days)
**Goal**: [Specific goal]
**Deliverables**:
- [ ] [Deliverable 1]
- [ ] [Deliverable 2]

**Success Criteria**:
- [Measurable criterion]

### Bolt 3: Integration (2-3 days)
...

## File Structure

```
src/
├── domain/
│   └── [feature]/
│       ├── entities/
│       └── services/
├── application/
│   └── [feature]/
│       └── use-cases/
└── infrastructure/
    └── [feature]/
        └── persistence/
```

## Quality Gates

| Gate | Requirement | Verification |
|------|-------------|--------------|
| Unit Tests | >= 80% coverage | CI pipeline |
| Integration | All boundaries | CI pipeline |
| Security | No critical vulns | Security scan |

## Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [Risk] | High/Med/Low | High/Med/Low | [Strategy] |

## Dependencies

| Dependency | Type | Status |
|------------|------|--------|
| [Dep] | Blocking/Non-blocking | [Status] |
```

### 8. Quickstart Validation

Create: `specs/[XXX-feature-name]/planning/quickstart.md`

Key scenarios to validate implementation:

```markdown
# Quickstart Validation

## Scenario 1: [Happy Path]
1. [Step 1]
2. [Step 2]
3. Expected: [Result]

## Scenario 2: [Error Case]
1. [Step 1]
2. Expected Error: [Error message]
```

## Output

```
## Plan Created

**Feature**: [XXX-feature-name]

**Generated Files**:
- specs/[XXX-feature-name]/planning/plan.md
- specs/[XXX-feature-name]/planning/research.md
- specs/[XXX-feature-name]/requirements/data-model.md
- specs/[XXX-feature-name]/contracts/openapi.yaml
- specs/[XXX-feature-name]/planning/quickstart.md

**Bolt Summary**:
- Bolt 1: [Goal] (Est: 2 days)
- Bolt 2: [Goal] (Est: 3 days)
- Bolt 3: [Goal] (Est: 2 days)
- Total: [X] days

**Constitution Status**: ✓ COMPLIANT

**Next Steps**:
1. Review generated artifacts
2. Run `/aurora.tasks` to generate task list
```

## Validation Rules

- [ ] All NEEDS RESEARCH resolved
- [ ] Constitution compliance verified
- [ ] Data model complete
- [ ] API contracts defined
- [ ] Bolts are 2-3 days each
- [ ] Quality gates specified
- [ ] Risks documented
