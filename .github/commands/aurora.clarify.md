---
description: Structured questioning to resolve ambiguities and underspecified areas in requirements.
handoffs: 
  - label: Update Specification
    agent: aurora.specify
    prompt: Incorporate clarified requirements into spec
    send: true
  - label: Revise Plan
    agent: aurora.plan
    prompt: Adjust plan based on clarifications
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Drive structured questioning to resolve ambiguities identified during specification or analysis phases.

**AURORA Stage**: UNDERSTAND (clarification loop)

**Responsible Agent**: Business Explorer

## When to Use

| Trigger | Source |
|---------|--------|
| Vague requirement | `/aurora.specify` |
| Missing acceptance criteria | `/aurora.analyze` |
| Conflicting requirements | Analysis report |
| Technical ambiguity | `/aurora.plan` |
| Stakeholder misalignment | Review feedback |

## Question Categories

### 1. Functional Clarification

For vague user stories or requirements:

```markdown
## Clarification: [Requirement ID]

**Original Statement**: "[vague requirement text]"

**Ambiguity Type**: Missing behavior specification

### Questions

1. **Actor**: Who specifically performs this action?
   - [ ] End user
   - [ ] Admin user
   - [ ] System (automated)
   - [ ] External service

2. **Trigger**: What initiates this action?
   - [ ] User clicks button
   - [ ] Scheduled time
   - [ ] External event
   - [ ] System condition

3. **Expected Outcome**: What should happen?
   - Describe the exact result...

4. **Error Scenarios**: What can go wrong?
   - Scenario 1: ...
   - Scenario 2: ...

5. **Edge Cases**: What about unusual situations?
   - Empty input: ...
   - Maximum values: ...
```

### 2. Data Clarification

For unclear data requirements:

```markdown
## Clarification: [Entity/Field]

**Context**: Data model for [feature]

### Questions

1. **Required Fields**: Which fields are mandatory?
   - [ ] Field A
   - [ ] Field B
   - [ ] Field C

2. **Validation Rules**: What constraints apply?
   - Field A: (min/max, format, pattern)
   - Field B: (min/max, format, pattern)

3. **Relationships**: How does this relate to other entities?
   - Relationship to X: (1:1, 1:N, N:N)
   - Cascade behavior: (delete, nullify, restrict)

4. **Historical Data**: Do we need to track changes?
   - [ ] No history needed
   - [ ] Soft delete only
   - [ ] Full audit trail

5. **Default Values**: What are the defaults?
   - Field A: [default]
   - Field B: [default]
```

### 3. Business Rule Clarification

For complex business logic:

```markdown
## Clarification: [Business Rule]

**Context**: [Feature/Process name]

### Questions

1. **Rule Definition**: State the rule precisely
   - WHEN: [condition]
   - THEN: [action]
   - ELSE: [alternative]

2. **Exceptions**: Are there any exceptions?
   - Exception 1: ...
   - Exception 2: ...

3. **Priority**: If rules conflict, which wins?
   - Rule A vs Rule B: [winner]
   - Rule B vs Rule C: [winner]

4. **Time Sensitivity**: Does timing matter?
   - [ ] Real-time enforcement
   - [ ] Batch validation
   - [ ] Async processing

5. **Audit**: Do we need to log rule execution?
   - [ ] No logging
   - [ ] Log decisions only
   - [ ] Full execution trace
```

### 4. Integration Clarification

For external system interactions:

```markdown
## Clarification: [Integration Point]

**External System**: [System name]

### Questions

1. **Protocol**: How do we communicate?
   - [ ] REST API
   - [ ] GraphQL
   - [ ] Message queue
   - [ ] File transfer
   - [ ] Other: ___

2. **Authentication**: How do we authenticate?
   - [ ] API Key
   - [ ] OAuth 2.0
   - [ ] mTLS
   - [ ] Other: ___

3. **Data Format**: What format for data?
   - [ ] JSON
   - [ ] XML
   - [ ] Protocol Buffers
   - [ ] Other: ___

4. **Error Handling**: What if the system is down?
   - [ ] Fail immediately
   - [ ] Retry with backoff
   - [ ] Queue for later
   - [ ] Fallback behavior

5. **SLA**: What are the expectations?
   - Response time: [ms]
   - Availability: [%]
   - Rate limits: [requests/min]
```

### 5. Non-Functional Clarification

For quality attributes:

```markdown
## Clarification: [NFR Category]

**Requirement Area**: [Performance/Security/Scalability/etc.]

### Questions

1. **Performance Targets**:
   - Response time P50: [ms]
   - Response time P99: [ms]
   - Throughput: [requests/sec]

2. **Scalability Requirements**:
   - Expected users: [count]
   - Peak load: [multiplier]
   - Growth projection: [timeline]

3. **Availability**:
   - Target uptime: [%]
   - Maintenance windows: [schedule]
   - DR requirements: [RTO/RPO]

4. **Security**:
   - Data classification: [level]
   - Encryption requirements: [at-rest/in-transit]
   - Compliance: [standards]
```

## Execution Flow

### Step 1: Identify Ambiguity Source

```bash
# Check analysis report for issues
cat specs/[XXX-feature-name]/planning/analysis-report.md | grep "🔴\|🟠"

# Or from user input
# $ARGUMENTS: "US-002 acceptance criteria unclear"
```

### Step 2: Generate Targeted Questions

Based on ambiguity type, select question template:

| Ambiguity Type | Template |
|----------------|----------|
| Vague behavior | Functional Clarification |
| Missing data details | Data Clarification |
| Complex logic | Business Rule Clarification |
| External system | Integration Clarification |
| Quality attributes | Non-Functional Clarification |

### Step 3: Present Questions

Format for stakeholder review:

```markdown
# Clarification Request

**Feature**: [feature-name]
**Date**: [timestamp]
**Priority**: [High/Medium/Low]
**Blocking**: [Yes/No]

## Context

We encountered the following ambiguity during specification/analysis:

> [Original ambiguous text]

## Questions Requiring Answers

### Q1: [Category] - [Brief title]

[Detailed question with options]

**Default assumption if no answer**: [state assumption]

### Q2: [Category] - [Brief title]

[Detailed question with options]

**Default assumption if no answer**: [state assumption]

---

**Response requested by**: [date]
**Contact**: [person/channel]
```

### Step 4: Record Answers

Save clarifications to `specs/[XXX-feature-name]/requirements/clarifications.md`:

```markdown
# Clarifications Log

## CLR-001: [Title]

**Date**: [timestamp]
**Source**: [stakeholder]
**Related**: US-002, AC-003

### Question
[Original question]

### Answer
[Stakeholder response]

### Impact
- Updated: `requirements.md` section 3.2
- Updated: `data-model.md` User entity
- No plan changes needed

---

## CLR-002: [Title]

...
```

### Step 5: Update Artifacts

After clarification received:

1. Update `requirements/requirements.md` with clarified requirements
2. Update `requirements/data-model.md` if data affected
3. Update `planning/plan.md` if scope changed
4. Re-run `/aurora.analyze` to verify consistency

## Output

```markdown
## Clarification Request Generated

**Ambiguity**: [brief description]
**Questions**: [count]
**Priority**: [High/Medium/Low]
**Blocking**: [items blocked]

**File**: specs/[XXX-feature-name]/requirements/clarifications/CLR-[number].md

**Questions Summary**:
1. [Q1 title]
2. [Q2 title]
3. [Q3 title]

**Default Assumptions** (if no response):
- Q1: [assumption]
- Q2: [assumption]

**Next Steps**:
1. Share with stakeholder for answers
2. Once answered, run `/aurora.specify` to update spec
3. Re-run `/aurora.analyze` to verify resolution
```

## Quick Clarification Mode

For simple yes/no questions:

```text
$ARGUMENTS: quick - Does US-002 require email notification?
```

Generates single-question clarification request.

## Escalation

If clarification not received within timeline:

1. **Document assumption** in clarification log
2. **Mark as assumption** in requirements.md
3. **Add validation task** in tasks.md to verify assumption
4. **Continue implementation** with assumption
5. **Create follow-up** to confirm with stakeholder
