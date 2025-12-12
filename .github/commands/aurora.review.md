---
description: Perform comprehensive code review following AURORA-IA quality standards.
handoffs: 
  - label: Fix Issues
    agent: aurora.implement
    prompt: Address review findings
    send: true
  - label: Security Scan
    agent: aurora.security
    prompt: Deep security analysis
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Perform systematic code review to ensure quality, maintainability, and adherence to standards.

**AURORA Stage**: VALIDATE

**Responsible Agent**: Code Artisan

## Prerequisites

- Code changes to review (files, PR, or diff)
- `memory/constitution.md` - Coding standards
- `specs/[XXX-feature-name]/requirements/requirements.md` - Requirements context

## Review Dimensions

### 1. Correctness

Does the code do what it should?

| Check | Description |
|-------|-------------|
| Requirements | Implements acceptance criteria correctly |
| Logic | Business logic is correct |
| Edge cases | Handles boundary conditions |
| Error handling | Errors are properly caught and handled |

### 2. Architecture

Does the code follow the architecture?

| Check | Description |
|-------|-------------|
| Layer separation | Domain, Application, Infrastructure properly separated |
| Dependencies | Dependency direction flows inward |
| Abstractions | Proper use of interfaces and abstractions |
| Patterns | Design patterns correctly applied |

### 3. Code Quality

Is the code clean and maintainable?

| Check | Description |
|-------|-------------|
| Naming | Clear, descriptive names |
| Functions | Single responsibility, appropriate size |
| DRY | No unnecessary duplication |
| Comments | Meaningful when needed, not excessive |

### 4. Testing

Is the code properly tested with quality validation?

| Check | Description |
|-------|-------------|
| Line Coverage | Meets minimum thresholds (>= 80%) |
| Branch Coverage | All branches tested (>= 75%) |
| Mutation Score | Tests kill mutants effectively (>= 70%) |
| Assertion Quality | Tests have meaningful assertions |
| Isolation | Unit tests properly isolated |
| Edge cases | Tests cover boundary conditions |

**Mutation Testing Quality Check**:
```
✅ High mutation score (>= 70%) = Tests would catch real bugs
⚠️ Low mutation score = Tests need stronger assertions
```

### 5. Security

Is the code secure?

| Check | Description |
|-------|-------------|
| Input validation | All inputs validated |
| Authentication | Proper auth checks |
| Authorization | Access control enforced |
| Data protection | Sensitive data handled properly |

### 6. Performance

Is the code performant?

| Check | Description |
|-------|-------------|
| Algorithms | Appropriate complexity |
| Queries | Database queries optimized |
| Memory | No memory leaks |
| Caching | Appropriate caching strategy |

## Execution Flow

### Step 1: Gather Context

```bash
# Read constitution for standards
cat memory/constitution.md

# Read spec for requirements
cat specs/[XXX-feature-name]/requirements/requirements.md

# Get changes to review
git diff main..HEAD
# or
git show [commit-hash]
# or review specific files
```

### Step 2: Review Checklist

For each changed file:

```markdown
## File: [path/to/file.ts]

### Summary
[Brief description of changes]

### Correctness ✅/❌
- [ ] Implements requirements correctly
- [ ] Logic is sound
- [ ] Edge cases handled
- [ ] Errors properly managed

### Architecture ✅/❌
- [ ] Correct layer placement
- [ ] Dependencies flow inward
- [ ] Interfaces properly used
- [ ] Patterns correctly applied

### Quality ✅/❌
- [ ] Names are clear
- [ ] Functions are focused
- [ ] No duplication
- [ ] Comments appropriate

### Testing Strategy ✅/❌

**Approach Used** (mark one):
- [ ] TDD (tests written first, Red → Green → Refactor)
- [ ] BDD (Gherkin scenarios → Step definitions → Unit tests)
- [ ] Coverage-First (existing code → coverage analysis → tests)

**Quality Metrics**:
- [ ] Line coverage >= 80%
- [ ] Branch coverage >= 75%
- [ ] Mutation score >= 70%
- [ ] Assertions are specific (not just existence checks)
- [ ] Edge cases and boundaries covered
- [ ] Tests would catch real bugs (strong assertions)

**BDD Compliance** (if applicable):
- [ ] Gherkin scenarios exist for user stories
- [ ] Step definitions implemented
- [ ] Unit tests derived from scenarios

**Mutation Testing Evidence**:
- [ ] Mutation testing ran (`stryker`, `pitest`, `mutmut`)
- [ ] Surviving mutants analyzed
- [ ] Weak tests strengthened

### Security ✅/❌
- [ ] Inputs validated
- [ ] Auth/authz proper
- [ ] Data protected

### Performance ✅/❌
- [ ] No obvious bottlenecks
- [ ] Queries optimized
- [ ] Memory efficient
```

### Step 3: Document Findings

Categorize issues:

| Severity | Symbol | Description | Action |
|----------|--------|-------------|--------|
| Critical | 🔴 | Must fix before merge | Block |
| Major | 🟠 | Should fix before merge | Request changes |
| Minor | 🟡 | Nice to fix | Comment |
| Suggestion | 💡 | Improvement idea | Optional |
| Question | ❓ | Need clarification | Discuss |
| Praise | 👍 | Good practice | Acknowledge |

### Step 4: Generate Review Report

```markdown
# Code Review Report

**Branch**: [branch-name]
**Reviewer**: AI Code Artisan
**Date**: [timestamp]
**Status**: [Approved/Changes Requested/Blocked]

## Summary

**Files Reviewed**: [count]
**Lines Changed**: +[added] / -[removed]

| Severity | Count |
|----------|-------|
| 🔴 Critical | [count] |
| 🟠 Major | [count] |
| 🟡 Minor | [count] |
| 💡 Suggestion | [count] |

## Critical Issues

### 🔴 CR-001: [Title]

**File**: `src/domain/entities/user.ts:45`

**Issue**: [Description of the problem]

**Code**:
```typescript
// Current (problematic)
if (password.length > 8) {
  return true;
}
```

**Suggested Fix**:
```typescript
// Fixed
if (password.length >= 8) {
  return true;
}
```

**Reason**: Off-by-one error, password "12345678" (exactly 8 chars) would be rejected.

---

## Major Issues

### 🟠 MJ-001: [Title]

**File**: `src/application/use-cases/create-user.ts:23`

**Issue**: Missing input validation

**Suggested Fix**: Add email validation before processing

---

## Minor Issues

### 🟡 MN-001: [Title]

**File**: `src/infrastructure/persistence/user-repository.ts:12`

**Issue**: Variable name could be clearer

**Current**: `const r = await db.query(...)`
**Suggested**: `const result = await db.query(...)`

---

## Suggestions

### 💡 SG-001: Consider using a factory

**File**: `src/domain/entities/user.ts`

**Suggestion**: Extract validation to a factory method for reusability.

---

## Praise

### 👍 Good use of Result type

**File**: `src/application/use-cases/create-user.ts`

Good implementation of the Result pattern for error handling!

---

## Questions

### ❓ Q-001: Intentional behavior?

**File**: `src/domain/entities/user.ts:67`

**Question**: Is allowing empty name intentional? The spec doesn't mention it.

---

## Overall Assessment

### Architecture
✅ Clean layer separation
✅ Dependencies flow correctly
⚠️ Consider extracting email validation to a shared module

### Code Quality
✅ Good naming conventions
✅ Functions are appropriately sized
⚠️ Some duplication in validation logic

### Testing
✅ Good coverage (87%)
⚠️ Missing edge case for empty email
✅ Tests are well-structured

### Security
✅ Proper input validation
✅ Password not logged
⚠️ Consider rate limiting on registration

---

## Verdict

**Status**: 🟠 Changes Requested

**Blocking Issues**: 1 (CR-001)
**Required Changes**: 2 (MJ-001, MJ-002)

**Next Steps**:
1. Fix critical issue CR-001
2. Address major issues MJ-001, MJ-002
3. Consider suggestions SG-001
4. Re-request review
```

## Output

```markdown
## Review Complete

**Files**: [count]
**Status**: [Approved/Changes Requested/Blocked]

### Summary
- 🔴 Critical: [count]
- 🟠 Major: [count]
- 🟡 Minor: [count]
- 💡 Suggestions: [count]

### Blocking Items
1. [CR-001 description]

### Required Changes
1. [MJ-001 description]
2. [MJ-002 description]

**Report**: specs/[XXX-feature-name]/planning/review-[timestamp].md

**Next Steps**:
1. Address blocking and major issues
2. Run `/aurora.implement` to fix
3. Re-run `/aurora.review` after fixes
```

## Quick Review Mode

For rapid feedback:

```text
$ARGUMENTS: quick
```

Focuses only on:
- Critical issues
- Major issues
- Security concerns

Skips:
- Minor issues
- Suggestions
- Style comments
