---
description: Perform consistency analysis across all specification artifacts to detect conflicts and gaps.
handoffs: 
  - label: Clarify Issues
    agent: aurora.clarify
    prompt: Resolve detected inconsistencies
    send: true
  - label: Update Plan
    agent: aurora.plan
    prompt: Revise plan based on analysis findings
    send: true
scripts:
  sh: scripts/bash/validate-specs.sh --check
  ps: scripts/powershell/Validate-Specs.ps1 -Check
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Cross-reference all specification artifacts to ensure consistency, detect conflicts, and identify gaps before implementation begins.

**AURORA Stage**: Quality gate between PLAN and EXECUTE

**Responsible Agent**: Omega Architect

## Prerequisites

Files to analyze in `specs/[XXX-feature-name]/`:
- `requirements/requirements.md` - Feature specification
- `planning/plan.md` - Implementation plan
- `planning/tasks.md` - Task list (if exists)
- `requirements/data-model.md` - Entity definitions (if exists)
- `contracts/*.yaml` - API specifications (if exist)

Required in project root:
- `memory/constitution.md` - Technology governance

## Analysis Categories

### 1. Constitution Alignment

Verify all artifacts respect `memory/constitution.md`:

| Check | Description |
|-------|-------------|
| Tech Stack | Files reference approved technologies only |
| Patterns | Architecture follows defined patterns |
| Standards | Naming and structure follows conventions |
| Constraints | No violations of documented constraints |

```
✅ Plan uses TypeScript (constitution approved)
❌ Plan mentions MongoDB (constitution specifies PostgreSQL)
```

### 2. Specification Completeness

Verify `requirements/requirements.md` contains:

| Element | Required | Status |
|---------|----------|--------|
| Business context | Yes | ☐ |
| User stories (min 1) | Yes | ☐ |
| Acceptance criteria per story | Yes | ☐ |
| Non-functional requirements | Yes | ☐ |
| Out of scope | Yes | ☐ |

```
✅ US-001 has 5 acceptance criteria
❌ US-003 missing acceptance criteria
```

### 3. Plan Coverage

Verify `plan.md` covers all spec requirements:

| User Story | Plan Coverage | Gap |
|------------|---------------|-----|
| US-001 | Bolt 2 | None |
| US-002 | Bolt 3 | None |
| US-003 | Missing | ⚠️ Not planned |

```
✅ All user stories have corresponding Bolts
❌ US-003 not covered in any Bolt
```

### 4. Data Model Consistency

If `data-model.md` exists, verify:

| Check | Description |
|-------|-------------|
| Entity references | All entities mentioned in spec are defined |
| Relationship validity | All relationships reference existing entities |
| Attribute completeness | Required attributes for stories are present |
| Type consistency | Types match across documents |

```
✅ User entity has email attribute (needed for US-001)
❌ Order entity missing customerId (referenced in US-002)
```

### 5. API Contract Consistency

If `contracts/*.yaml` exist, verify:

| Check | Description |
|-------|-------------|
| Endpoint coverage | All user stories have required endpoints |
| Request/response | DTOs match data model entities |
| Status codes | Error scenarios covered |
| Authentication | Security requirements met |

```
✅ POST /users matches CreateUser use case
❌ GET /orders missing pagination (spec requires it)
```

### 6. Task Traceability

If `tasks.md` exists, verify:

| Check | Description |
|-------|-------------|
| Story coverage | Every user story has tasks |
| File paths | Referenced files match plan structure |
| Dependencies | No circular dependencies |
| Completeness | All plan components have tasks |

```
✅ US-001 → T005-T015 (11 tasks)
❌ US-002 → No tasks generated
```

## Execution Flow

### Step 1: Gather Artifacts

```bash
# List all specification files
find specs/[XXX-feature-name]/ -type f -name "*.md" -o -name "*.yaml"

# Read constitution
cat memory/constitution.md

# Read specification
cat specs/[XXX-feature-name]/requirements/requirements.md

# Read plan
cat specs/[XXX-feature-name]/planning/plan.md
```

### Step 2: Extract Cross-References

Build reference maps:

```
User Stories:
  US-001 → [entities: User, Email] [endpoints: POST /users]
  US-002 → [entities: Order, User] [endpoints: GET /orders]

Entities:
  User → [stories: US-001, US-002] [endpoints: /users]
  Order → [stories: US-002] [endpoints: /orders]

Endpoints:
  POST /users → [story: US-001] [entities: User]
  GET /orders → [story: US-002] [entities: Order]
```

### Step 3: Run Consistency Checks

```
For each User Story:
  ✓ Has acceptance criteria?
  ✓ Covered in plan?
  ✓ Has data model entities?
  ✓ Has API contracts?
  ✓ Has implementation tasks?

For each Entity:
  ✓ Referenced in a user story?
  ✓ Has required attributes?
  ✓ Relationships valid?

For each Endpoint:
  ✓ Linked to user story?
  ✓ Request matches entity?
  ✓ Response matches entity?

For each Task:
  ✓ Links to user story?
  ✓ File path exists in plan?
```

### Step 4: Identify Issues

Categorize findings:

| Severity | Description | Action |
|----------|-------------|--------|
| 🔴 Blocker | Prevents implementation | Must fix |
| 🟠 Major | Significant gap or conflict | Should fix |
| 🟡 Minor | Small inconsistency | Nice to fix |
| ⚪ Info | Observation | Document |

## Output Report

Generate `specs/[XXX-feature-name]/planning/analysis-report.md`:

```markdown
# Consistency Analysis Report

**Feature**: [XXX-feature-name]
**Analyzed**: [timestamp]
**Status**: [PASS/FAIL]

## Summary

| Category | ✅ Pass | ⚠️ Warn | ❌ Fail |
|----------|---------|---------|---------|
| Constitution Alignment | 5 | 1 | 0 |
| Spec Completeness | 3 | 0 | 1 |
| Plan Coverage | 4 | 0 | 0 |
| Data Model | 6 | 2 | 1 |
| API Contracts | 4 | 0 | 0 |
| Task Traceability | 8 | 0 | 0 |
| **Total** | 30 | 3 | 2 |

## Blockers (must fix)

### 🔴 B001: Missing Entity Attribute

**Location**: `data-model.md` → Order entity
**Issue**: Missing `customerId` foreign key
**Impact**: US-002 cannot be implemented
**Resolution**: Add `customerId: UUID` to Order entity

### 🔴 B002: Uncovered User Story

**Location**: `plan.md`
**Issue**: US-003 not included in any Bolt
**Impact**: Feature incomplete
**Resolution**: Add Bolt 4 for US-003 implementation

## Major Issues (should fix)

### 🟠 M001: Inconsistent Naming

**Location**: `requirements/requirements.md` vs `requirements/data-model.md`
**Issue**: Spec uses "Customer", data model uses "User"
**Impact**: Confusion during implementation
**Resolution**: Standardize on "User" per constitution

## Minor Issues (nice to fix)

### 🟡 N001: Missing API Error Response

**Location**: `contracts/users-api.yaml`
**Issue**: 409 Conflict not documented for duplicate email
**Impact**: Incomplete API documentation
**Resolution**: Add 409 response schema

## Passed Checks

- ✅ All technologies match constitution
- ✅ Architecture patterns followed
- ✅ Naming conventions respected
- ✅ All user stories have acceptance criteria
- ✅ Task IDs are sequential
- ✅ No circular dependencies

## Recommendations

1. **Before proceeding**: Fix blockers B001 and B002
2. **During implementation**: Address major issue M001
3. **Before release**: Document minor issue N001

## Traceability Matrix

| Story | Spec | Plan | Model | API | Tasks |
|-------|------|------|-------|-----|-------|
| US-001 | ✅ | ✅ | ✅ | ✅ | ✅ |
| US-002 | ✅ | ✅ | ❌ | ✅ | ✅ |
| US-003 | ✅ | ❌ | ✅ | ✅ | ❌ |

---

**Next Steps**:
1. `/aurora.clarify` - Resolve blockers with stakeholders
2. Fix issues in relevant files
3. Re-run `/aurora.analyze` to verify fixes
```

## Quick Analysis Mode

For fast checks during development:

```text
$ARGUMENTS: quick
```

Runs only:
- Constitution alignment
- Task traceability
- Open blockers status

## Integration Points

| When | Run Analysis |
|------|--------------|
| After `/aurora.specify` | Verify spec completeness |
| After `/aurora.plan` | Verify plan coverage |
| After `/aurora.tasks` | Verify task traceability |
| Before `/aurora.implement` | Full consistency check |
| During implementation | Quick mode for changes |

## Validation Passed

Only proceed to implementation when:

```
✅ Zero blockers (🔴)
✅ Major issues acknowledged (🟠)
✅ All user stories traceable
✅ Constitution fully respected
```
