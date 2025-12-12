---
description: Create Architectural Decision Records (ADRs) for significant technical decisions.
handoffs: 
  - label: Update Plan
    agent: aurora.plan
    prompt: Update plan with ADR implications
    send: true
  - label: Review Decision
    agent: aurora.review
    prompt: Review ADR for completeness
    send: true
scripts:
  sh: scripts/bash/create-adr.sh
  ps: scripts/powershell/Create-ADR.ps1
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Document significant architectural and technical decisions using the ADR (Architectural Decision Record) format.

**AURORA Stage**: DESIGN

**Responsible Agent**: Omega Architect

## Constitution Check

**FIRST**: Read `memory/constitution.md` to understand:
- **Tech Stack** - Ensure decision aligns with approved technologies
- **Architecture Principles** - Decision must respect defined principles
- **Constraints** - Budget, compliance, security requirements
- **Existing Decisions** - Check for conflicts with prior ADRs

## When to Create ADR

Create an ADR when deciding:

| Category | Examples |
|----------|----------|
| Technology Selection | Database choice, framework, library |
| Architecture Pattern | Microservices vs monolith, event-driven |
| Integration Approach | Sync vs async, API style |
| Security Model | Auth mechanism, encryption strategy |
| Data Management | CQRS, event sourcing, caching |
| Infrastructure | Cloud provider, deployment model |
| Quality Tradeoffs | Performance vs maintainability |

## ADR Template

Create `docs/adr/ADR-[XXX]-[title].md`:

```markdown
# ADR-[XXX]: [Decision Title]

## Metadata

| Property | Value |
|----------|-------|
| ADR ID | ADR-[XXX] |
| Status | Proposed / Accepted / Deprecated / Superseded |
| Created | [YYYY-MM-DD] |
| Updated | [YYYY-MM-DD] |
| Deciders | [Names/Roles] |
| Consulted | [Stakeholders consulted] |
| Related | ADR-YYY, ADR-ZZZ |

## Context

### Background

[Describe the situation that led to this decision. What is the problem or opportunity?]

### Driving Forces

- [Force 1]: [Description of constraint or requirement]
- [Force 2]: [Description of constraint or requirement]
- [Force 3]: [Description of constraint or requirement]

### Constraints from Constitution

Per `memory/constitution.md`:
- Tech Stack: [Relevant technology constraints]
- Principles: [Relevant architectural principles]
- Security: [Relevant security requirements]

## Decision Drivers

| Priority | Driver | Description |
|----------|--------|-------------|
| Must | [Driver 1] | [Critical requirement] |
| Must | [Driver 2] | [Critical requirement] |
| Should | [Driver 3] | [Important preference] |
| Could | [Driver 4] | [Nice to have] |

## Options Considered

### Option 1: [Option Name]

**Description**: [Brief description of this option]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Effort**: [Low/Medium/High]
**Risk**: [Low/Medium/High]

### Option 2: [Option Name]

**Description**: [Brief description of this option]

**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Effort**: [Low/Medium/High]
**Risk**: [Low/Medium/High]

### Option 3: [Option Name]

[Similar structure...]

## Decision Matrix

| Criterion | Weight | Option 1 | Option 2 | Option 3 |
|-----------|--------|----------|----------|----------|
| [Driver 1] | 5 | 4 (20) | 3 (15) | 5 (25) |
| [Driver 2] | 4 | 3 (12) | 5 (20) | 3 (12) |
| [Driver 3] | 3 | 5 (15) | 3 (9) | 4 (12) |
| [Driver 4] | 2 | 4 (8) | 4 (8) | 3 (6) |
| **Total** | | **55** | **52** | **55** |

## Decision

**Selected Option**: [Option X] - [Option Name]

### Rationale

[Explain why this option was selected over the alternatives. Reference the decision drivers and how this option best satisfies them.]

### Key Points

1. [Key point 1 that led to this decision]
2. [Key point 2 that led to this decision]
3. [Key point 3 that led to this decision]

## Consequences

### Positive

- [Positive consequence 1]
- [Positive consequence 2]
- [Positive consequence 3]

### Negative

- [Negative consequence 1 - with mitigation]
- [Negative consequence 2 - with mitigation]

### Neutral

- [Neutral consequence / trade-off]

## Implementation Notes

### Actions Required

1. [ ] [Action 1]
2. [ ] [Action 2]
3. [ ] [Action 3]

### Migration Steps (if applicable)

1. [Step 1]
2. [Step 2]

### Timeline

| Milestone | Target Date | Status |
|-----------|-------------|--------|
| [Milestone 1] | [Date] | Pending |
| [Milestone 2] | [Date] | Pending |

## Compliance Check

| Requirement | Status | Notes |
|-------------|--------|-------|
| Constitution Tech Stack | ✅ / ❌ | [Notes] |
| Constitution Principles | ✅ / ❌ | [Notes] |
| Security Policy | ✅ / ❌ | [Notes] |
| Budget Constraints | ✅ / ❌ | [Notes] |

## Review Record

| Date | Reviewer | Decision | Notes |
|------|----------|----------|-------|
| [Date] | [Name] | [Approved/Rejected/Deferred] | [Notes] |

## References

- [Reference 1: Link or document]
- [Reference 2: Link or document]
- [Constitution: memory/constitution.md]

## Changelog

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | [Date] | [Author] | Initial version |
```

## ADR Lifecycle

```
┌─────────┐    ┌──────────┐    ┌────────────┐    ┌────────────┐
│ Proposed │───►│ Accepted │───►│ Deprecated │───►│ Superseded │
└─────────┘    └──────────┘    └────────────┘    └────────────┘
                    │                                    ▲
                    │         Creates new ADR           │
                    └───────────────────────────────────┘
```

## Directory Structure

```
docs/
└── adr/
    ├── README.md           # ADR index and process
    ├── ADR-001-[title].md
    ├── ADR-002-[title].md
    ├── ADR-003-[title].md
    └── template.md         # Empty template
```

## ADR Index

Create `docs/adr/README.md`:

```markdown
# Architectural Decision Records

This directory contains all ADRs for the project.

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-001](ADR-001-tech-stack.md) | Technology Stack Selection | Accepted | 2024-01-15 |
| [ADR-002](ADR-002-database.md) | Database Selection | Accepted | 2024-01-20 |
| [ADR-003](ADR-003-auth.md) | Authentication Strategy | Proposed | 2024-02-01 |

## Process

1. Copy `template.md` to `ADR-XXX-[title].md`
2. Fill in all sections
3. Set status to "Proposed"
4. Submit for review
5. Update status after decision

## Governance

- **Proposer**: Any team member
- **Reviewers**: Tech Lead, Architect
- **Approver**: Project Lead
- **Constitution**: All ADRs must align with `memory/constitution.md`
```

## Output

```markdown
## ADR Created

**ADR ID**: ADR-[XXX]
**Title**: [Decision Title]
**Status**: Proposed

**File**: docs/adr/ADR-[XXX]-[title].md

**Options Evaluated**: [count]
**Selected Option**: [Option Name]

**Constitution Compliance**:
- Tech Stack: ✅
- Principles: ✅
- Security: ✅

**Next Steps**:
1. Review with team
2. Update status to Accepted
3. Implement actions
4. Update plan.md with implications
```

## Quick ADR

For simple decisions:

```text
$ARGUMENTS: quick - [Decision] - [Selected Option] - [Rationale]
```

Creates minimal ADR with decision and rationale only.
