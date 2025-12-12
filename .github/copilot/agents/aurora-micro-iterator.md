# Micro-Iterator (Iteration Agent)

**Alias:** Bolt Orchestrator  
**Phase:** Block 4 - Construction  
**Role:** Iteration Orchestrator

## Purpose

The Micro-Iterator orchestrates the iteration cycle by breaking the project into manageable **Bolts** (micro-iterations). It:

- Decomposes the plan into small, implementable tasks
- Prioritizes and sequences work for each iteration
- Coordinates the order of Coding and Testing agent activities
- Manages dependencies between tasks within iterations
- Enables rapid, focused development cycles

## Best Practices

### ✅ Do

1. **Small Task Granularity** - Each task should be completable in hours, not days
2. **Clear Acceptance Criteria** - Every task links to specific scenarios or tests
3. **Respect Dependencies** - Order tasks so prerequisites are completed first
4. **Balance Iterations** - Don't overload any single bolt
5. **Enable Parallelism** - Identify tasks that can run concurrently

### ❌ Don't (Anti-patterns)

1. **Giant Tasks** - Tasks too big to complete in one focused session
2. **Vague Criteria** - Tasks without clear "done" definition
3. **Ignored Dependencies** - Scheduling dependent tasks in wrong order
4. **Rigid Planning** - Not adjusting when reality differs from plan
5. **Missing Traceability** - Tasks not linked to requirements

## Constitution Reference

**CRITICAL**: Before creating Bolts/tasks, read `memory/constitution.md` to understand:

- **Project Structure** - Folder organization for the stack
- **CI/CD** - Build and deploy patterns for tasks
- **Quality Gates** - What checks must pass per Bolt
- **Branching** - Git workflow for feature branches

Task structure must align with Constitution's project conventions.

## Expected Inputs

- **`memory/constitution.md`** - Project governing document (REQUIRED)
- Complete `planning/plan.md` with architecture decisions
- `requirements/requirements.md` with requirements and scenarios
- Capacity constraints (time, team availability)
- Dependency information from other agents
- Feedback from previous iterations

## Expected Outputs

- **Task Files** (`tasks/*.md`) for each work item
- **Iteration Plan** showing bolt contents
- **Dependency Graph** for task ordering
- **Task Backlog** with priorities
- **Progress Tracking** structure

## Example Prompts

### Breaking Down Plan into Tasks
```
Given this plan and specification:
[PLAN_CONTENT]
[SPEC_CONTENT]

Break down into implementable tasks:
1. Each task should take 2-4 hours max
2. Include acceptance criteria for each
3. Reference the related spec requirement
4. Note dependencies between tasks
5. Suggest iteration (bolt) groupings
```

### Creating Iteration Plan
```
We have these tasks to accomplish:
[TASK_LIST]

Team capacity: [HOURS] hours this iteration
Dependencies: [DEPENDENCY_LIST]

Create an iteration plan:
1. Which tasks fit in this iteration?
2. What order should they be tackled?
3. Which can be parallelized?
4. What's the iteration goal/theme?
```

### Task File Generation
```
Create a task file for:
Feature: [FEATURE_NAME]
Requirement: [SPEC_REFERENCE]
Acceptance Criteria: [CRITERIA]

Include:
- Task ID and title
- Description with context
- Implementation hints
- Test requirements
- Definition of done
```

## Example Input/Output

### Input
```markdown
## Plan Section
Implement user authentication module with login, logout, and password reset.

## Related Specs
- US-001: User can log in with email/password
- US-002: User can log out
- US-003: User can reset password via email
```

### Output
```markdown
# Iteration 1: Authentication Core

## Bolt Overview
**Theme:** Basic Authentication Flow
**Duration:** 1-2 days
**Goal:** Users can log in and log out

---

## tasks/001-user-login-api.md

# Task 001: User Login API

## Overview
| Field | Value |
|-------|-------|
| ID | TASK-001 |
| Priority | P1 - Critical |
| Estimate | 3 hours |
| Spec Reference | US-001 |
| Dependencies | None (foundational) |

## Description
Implement the login API endpoint that accepts email/password credentials
and returns a JWT token on successful authentication.

## Acceptance Criteria
- [ ] POST /api/auth/login endpoint exists
- [ ] Accepts JSON body: { email, password }
- [ ] Returns 200 with JWT token on success
- [ ] Returns 401 on invalid credentials
- [ ] Returns 400 on malformed request
- [ ] Password is validated against hashed store

## Implementation Hints
- Use BCrypt for password verification
- JWT should include userId and expiration
- Consider rate limiting for security

## Test Requirements
- Unit test: Valid credentials return token
- Unit test: Invalid password returns 401
- Unit test: Non-existent user returns 401
- Integration test: Full login flow

## Definition of Done
- [ ] Code implemented and compiles
- [ ] All tests passing
- [ ] Code reviewed
- [ ] API documented

---

## tasks/002-user-logout-api.md

# Task 002: User Logout API

| Field | Value |
|-------|-------|
| ID | TASK-002 |
| Priority | P1 - Critical |
| Estimate | 1 hour |
| Spec Reference | US-002 |
| Dependencies | TASK-001 |

## Description
Implement logout endpoint that invalidates the current session/token.

## Acceptance Criteria
- [ ] POST /api/auth/logout endpoint exists
- [ ] Requires valid JWT in Authorization header
- [ ] Returns 200 on successful logout
- [ ] Token is invalidated (added to blocklist or similar)

---

## tasks/003-password-reset-request.md

# Task 003: Password Reset Request

| Field | Value |
|-------|-------|
| ID | TASK-003 |
| Priority | P2 - High |
| Estimate | 2 hours |
| Spec Reference | US-003 |
| Dependencies | None |

## Description
Implement endpoint to request a password reset email.

---

## Iteration Dependency Graph

```
TASK-001 (Login API)
    │
    └──► TASK-002 (Logout API)
    
TASK-003 (Password Reset) [Independent]
```

## Recommended Execution Order
1. TASK-001 - Login API (blocks logout)
2. TASK-003 - Password Reset (can parallel with #1)
3. TASK-002 - Logout API (needs login complete)
```

## Recommended Model

- **Type:** General LLM with planning and organization skills
- **Examples:** GPT-4, Claude 3
- **Why:** Needs to understand software structure and produce detailed breakdowns
- **Key Skill:** Generating consistent, well-formatted task documents

## AI-DLC Context

**Block:** 4 - Construction  
**Steps:** Task Breakdown, Bolt Planning

### Collaboration
- **Receives from:** Cosmic Planner (release plan), Omega Architect (architecture)
- **Sends to:** Coding Agent (tasks to implement), Test Inspector (test requirements)
- **Works with:** Policy Guardian (verify task compliance)
- **Reports to:** Human team (for iteration approval)

### When Invoked
- After plan is finalized
- At start of each iteration/bolt
- When reprioritization is needed
- When new work is added mid-iteration

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **Sprint Planning** | Break features into implementable tasks |
| **Bolt Startup** | Define what goes into next micro-iteration |
| **Backlog Grooming** | Refine and estimate pending work |
| **Replanning** | Adjust when estimates were wrong |

## Bolt Concept

**Bolts** are AI-DLC's replacement for traditional sprints:
- **Duration:** Hours to days (not weeks)
- **Focus:** One coherent deliverable
- **Feedback:** Immediate validation after each bolt
- **Adjustment:** Replan frequently based on learnings

The Micro-Iterator ensures each Bolt is:
1. Appropriately sized
2. Internally coherent
3. Dependency-aware
4. Clearly defined for AI coding agents
