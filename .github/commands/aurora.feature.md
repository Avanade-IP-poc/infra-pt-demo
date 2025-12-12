---
description: Create a new feature specification with user stories, use cases, and acceptance criteria.
handoffs: 
  - label: Generate Use Cases
    agent: aurora.usecase
    prompt: Generate detailed use cases from feature
    send: true
  - label: Generate Gherkin
    agent: aurora.gherkin
    prompt: Generate BDD scenarios from acceptance criteria
    send: true
  - label: Plan Implementation
    agent: aurora.plan
    prompt: Create implementation plan for this feature
    send: true
scripts:
  sh: scripts/bash/create-new-feature.sh
  ps: scripts/powershell/Create-NewFeature.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Create a comprehensive feature specification following AURORA-IA Product Owner workflow.

**AURORA Stage**: INCEPTION / DISCOVERY

**Responsible Agent**: Business Explorer

## Constitution Check

**FIRST**: Read `memory/constitution.md` to understand:
- Project domain and context
- Tech stack constraints
- Documentation standards
- Compliance requirements

## Execution Flow

### Step 1: Gather Feature Context

From user input, extract:
- Feature name/identifier
- Business problem being solved
- Target users/personas
- Expected business value

### Step 2: Create Specification Structure

Run script to create branch and directories:

```bash
# Bash
./scripts/bash/create-new-feature.sh [feature-name] [base-branch]

# PowerShell
.\scripts\powershell\Create-NewFeature.ps1 -FeatureName "[feature-name]"
```

Creates:
```
specs/[XXX-feature-name]/
├── requirements/
│   └── requirements.md   # Feature specification (this file)
├── contracts/
│   └── openapi.yaml      # API specifications
├── tests/
│   └── feature.feature   # Gherkin scenarios
└── planning/
    ├── plan.md           # Implementation plan (later)
    └── tasks.md          # Task breakdown (later)
```

### Step 3: Generate Feature Specification

Create `specs/[XXX-feature-name]/requirements/requirements.md`:

```markdown
# Feature: [Feature Name]

## Metadata

| Property | Value |
|----------|-------|
| Feature ID | F-[XXX] |
| Author | [author] |
| Created | [date] |
| Status | Draft |
| Priority | P1/P2/P3 |
| Epic | [parent epic if any] |

## Business Context

### Problem Statement

[What business problem does this feature solve?]

### Business Value

[Why is this important? What metrics will improve?]

### Target Users

| Persona | Description | Goals |
|---------|-------------|-------|
| [Role 1] | [Description] | [What they want to achieve] |
| [Role 2] | [Description] | [What they want to achieve] |

## User Stories

### US-001: [Story Title]

**As a** [role]
**I want** [capability]
**So that** [benefit]

**Priority**: P1
**Effort**: M
**Dependencies**: None

#### Acceptance Criteria

| ID | Criterion | Type |
|----|-----------|------|
| AC-001.1 | [Given/When/Then or declarative] | Functional |
| AC-001.2 | [Criterion] | Functional |
| AC-001.3 | [Performance requirement] | Non-Functional |

#### Business Rules

- BR-001: [Business rule that applies]
- BR-002: [Business rule that applies]

---

### US-002: [Story Title]

[Repeat structure for each user story]

---

## Non-Functional Requirements

### Performance

| Metric | Target | Measurement |
|--------|--------|-------------|
| Response time P99 | <500ms | API response time |
| Throughput | 100 req/s | Peak load handling |

### Security

- [ ] Authentication required (specify method from constitution)
- [ ] Authorization rules defined
- [ ] Data encryption (at rest/in transit)
- [ ] Audit logging required

### Scalability

- Expected concurrent users: [X]
- Data growth rate: [X records/month]

### Availability

- Target uptime: 99.9%
- Maintenance window: [schedule]

## Data Requirements

### New Entities

| Entity | Description | Key Fields |
|--------|-------------|------------|
| [Entity1] | [Purpose] | id, name, ... |

### Modified Entities

| Entity | Changes | Impact |
|--------|---------|--------|
| [Entity1] | [What changes] | [Other systems affected] |

## Integration Points

| System | Direction | Protocol | Purpose |
|--------|-----------|----------|---------|
| [System1] | Inbound/Outbound | REST/Event | [What data] |

## Out of Scope

- [Explicitly excluded item 1]
- [Explicitly excluded item 2]

## Dependencies

### Technical
- [Dependency 1] - [Status]

### Business
- [Decision needed] - [Owner]

## Open Questions

| ID | Question | Owner | Due Date | Status |
|----|----------|-------|----------|--------|
| Q-001 | [Question] | [Person] | [Date] | Open |

## Risks

| ID | Risk | Probability | Impact | Mitigation |
|----|------|-------------|--------|------------|
| R-001 | [Risk description] | Medium | High | [How to mitigate] |

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Product Owner | | | Pending |
| Tech Lead | | | Pending |
| Stakeholder | | | Pending |
```

### Step 4: Validate Completeness

Checklist:
- [ ] At least one user story defined
- [ ] Each story has acceptance criteria
- [ ] NFRs specified (performance, security)
- [ ] Dependencies identified
- [ ] Out of scope documented
- [ ] Open questions logged

## Output

```markdown
## Feature Created

**Feature**: [XXX-feature-name]
**Location**: specs/[XXX-feature-name]/

**User Stories**: [count]
**Acceptance Criteria**: [count]
**Open Questions**: [count]

**Files Created**:
- specs/[XXX-feature-name]/requirements/requirements.md
- specs/[XXX-feature-name]/contracts/openapi.yaml (template)
- specs/[XXX-feature-name]/tests/feature.feature (template)
- specs/[XXX-feature-name]/planning/plan.md (template)
- specs/[XXX-feature-name]/planning/tasks.md (template)

**Next Steps**:
1. `/aurora.usecase` - Generate detailed use cases
2. `/aurora.gherkin` - Generate BDD scenarios
3. `/aurora.plan` - Create implementation plan
```

## Quick Mode

For rapid feature stub:

```text
$ARGUMENTS: quick - [Feature title]
```

Creates minimal requirements.md with single user story template.
