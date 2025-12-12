---
description: Generate actionable Bolt task lists from implementation plan, optimized for AI-DLC micro-iterations.
handoffs: 
  - label: Analyze Consistency
    agent: aurora.analyze
    prompt: Run consistency analysis across artifacts
    send: true
  - label: Start Implementation
    agent: aurora.implement
    prompt: Begin implementation in phases
    send: true
scripts:
  sh: scripts/bash/check-prerequisites.sh --json
  ps: scripts/powershell/Check-Prerequisites.ps1 -Json
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Transform implementation plan into executable Bolt task lists following the AURORA-IA AI-DLC methodology.

**AURORA Stage**: PLAN → EXECUTE preparation

**Responsible Agent**: Micro Iterator

## Prerequisites

Required files in `specs/[XXX-feature-name]/`:
- `requirements/requirements.md` - Feature specification
- `planning/plan.md` - Implementation plan

Optional (enhance task generation):
- `requirements/data-model.md` - Entity definitions
- `contracts/` - API specifications
- `planning/research.md` - Technical decisions

## Bolt Concept

A **Bolt** is a micro-iteration of 2-3 days that produces:
- Complete, tested code increment
- Independently deployable (when possible)
- Validated against acceptance criteria

## Execution Flow

### 1. Load Context

Read from `specs/[XXX-feature-name]/`:
- `planning/plan.md` → Extract Bolts, tech stack, file structure
- `requirements/requirements.md` → Extract user stories with priorities
- `requirements/data-model.md` → Extract entities (if exists)
- `contracts/` → Extract API endpoints (if exists)

### 2. Map User Stories to Bolts

Organize tasks by user story priority:

```
US-001 (P1) → Bolt 1, Bolt 2
US-002 (P2) → Bolt 3
US-003 (P3) → Bolt 4
```

### 3. Generate Task Structure

Create `specs/[XXX-feature-name]/planning/tasks.md`:

```markdown
# Task List: [Feature Name]

## Overview

- **Feature**: [XXX-feature-name]
- **Total Bolts**: [count]
- **Estimated Duration**: [X] days
- **User Stories Covered**: [count]

## Task Format

All tasks use this format:
```
- [ ] [TaskID] [P?] [Story?] Description with file path
```

- `[TaskID]`: Sequential ID (T001, T002...)
- `[P]`: Parallelizable task (optional)
- `[Story]`: User story reference (optional)

---

## Bolt 1: Setup & Foundation

**Duration**: 1-2 days
**Goal**: Project initialization and foundational structure

### Setup Tasks

- [ ] T001 Initialize project structure per constitution
- [ ] T002 Configure linting and formatting (constitution standards)
- [ ] T003 Set up CI/CD pipeline skeleton
- [ ] T004 Configure testing framework

### Foundation Tasks

- [ ] T005 [P] Create base domain structure in src/domain/
- [ ] T006 [P] Create base application structure in src/application/
- [ ] T007 [P] Create base infrastructure structure in src/infrastructure/
- [ ] T008 Configure dependency injection container

---

## Bolt 2: [User Story 1 - Core Implementation]

**Duration**: 2-3 days
**Goal**: [Specific goal from US-001]
**User Story**: US-001

### Model Tasks

- [ ] T009 [P] [US1] Create [Entity] model in src/domain/entities/
- [ ] T010 [P] [US1] Create [ValueObject] in src/domain/value-objects/
- [ ] T011 [US1] Implement [Entity] factory in src/domain/factories/

### Service Tasks

- [ ] T012 [US1] Create [DomainService] in src/domain/services/
- [ ] T013 [US1] Create [UseCase] in src/application/use-cases/
- [ ] T014 [US1] Implement [Repository] interface in src/application/ports/

### Infrastructure Tasks

- [ ] T015 [P] [US1] Implement [Repository] in src/infrastructure/persistence/
- [ ] T016 [US1] Create database migration for [Entity]

### API Tasks

- [ ] T017 [US1] Create [Controller] in src/presentation/api/
- [ ] T018 [US1] Implement request/response DTOs

### Test Tasks

- [ ] T019 [P] [US1] Write unit tests for [Entity]
- [ ] T020 [P] [US1] Write unit tests for [UseCase]
- [ ] T021 [US1] Write integration tests for [Repository]
- [ ] T022 [US1] Write API contract tests for [Controller]

### Validation

- [ ] T023 [US1] Verify all US-001 acceptance criteria
- [ ] T024 [US1] Run quality gates (coverage, lint, security)

---

## Bolt 3: [User Story 2]

**Duration**: 2-3 days
**Goal**: [Specific goal from US-002]
**User Story**: US-002

[Similar structure to Bolt 2...]

---

## Bolt N: Polish & Cross-Cutting

**Duration**: 1-2 days
**Goal**: Finalization and cleanup

### Documentation

- [ ] T0XX [P] Update API documentation
- [ ] T0XX [P] Update README with feature documentation
- [ ] T0XX Create/update ADR for key decisions

### Quality

- [ ] T0XX Final security scan
- [ ] T0XX Performance testing
- [ ] T0XX Code review checklist

### Integration

- [ ] T0XX E2E test suite
- [ ] T0XX Integration with dependent systems

---

## Dependency Graph

```
T001 ──► T005, T006, T007
T008 ──► T012, T013
T013 ──► T015
T015 ──► T016 ──► T017
```

## Parallel Execution Groups

### Group A (T005, T006, T007, T010)
Independent structure creation - run simultaneously

### Group B (T019, T020)
Independent unit tests - run simultaneously

## Implementation Strategy

1. **MVP First**: Complete Bolt 1-2 for core functionality
2. **Incremental**: Each Bolt adds testable increment
3. **Quality Built-in**: Tests with each Bolt, not after

## Statistics

| Metric | Value |
|--------|-------|
| Total Tasks | [count] |
| Parallelizable | [count] |
| Per User Story | [breakdown] |
| Estimated Effort | [X days] |
```

### 4. Task Generation Rules

#### Task ID Format
```
- [ ] T001 [P] [US1] Description with src/path/file.ts
```

| Component | Required | Description |
|-----------|----------|-------------|
| Checkbox | Yes | `- [ ]` markdown checkbox |
| Task ID | Yes | Sequential T001, T002... |
| [P] | If parallel | Task can run in parallel |
| [USn] | For story tasks | Links to user story |
| Description | Yes | Action with file path |

#### Correct Examples
```
✅ - [ ] T001 Create project structure per plan
✅ - [ ] T005 [P] Implement auth middleware in src/middleware/auth.ts
✅ - [ ] T012 [P] [US1] Create User model in src/domain/entities/user.ts
✅ - [ ] T014 [US1] Implement UserService in src/application/services/
```

#### Incorrect Examples
```
❌ - [ ] Create User model (missing ID)
❌ T001 [US1] Create model (missing checkbox)
❌ - [ ] [US1] Create model (missing ID)
❌ - [ ] T001 [US1] Create model (missing file path)
```

### 5. Bolt Organization

| Phase | Content | Story Label |
|-------|---------|-------------|
| Bolt 1: Setup | Project initialization | No |
| Bolt 2+: User Stories | Story implementation | Yes ([US1], [US2]...) |
| Final: Polish | Cross-cutting concerns | No |

## Output

```
## Tasks Generated

**File**: specs/[XXX-feature-name]/planning/tasks.md

**Summary**:
- Total Tasks: [count]
- Parallelizable: [count] ([percentage]%)
- Bolts: [count]

**Per User Story**:
- US-001: [count] tasks (Bolt 2)
- US-002: [count] tasks (Bolt 3)

**MVP Scope**: Bolt 1-2 ([X] days)

**Next Steps**:
1. Run `/aurora.analyze` for consistency check
2. Run `/aurora.implement` to start coding
```

## Validation Rules

- [ ] Every task has checkbox + ID
- [ ] Every story task has [USn] label
- [ ] Every task has file path (where applicable)
- [ ] Bolts are 2-3 days each
- [ ] Dependencies are documented
- [ ] Parallel groups identified
