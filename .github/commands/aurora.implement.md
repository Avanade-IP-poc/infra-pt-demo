---
description: Execute implementation following Bolt task list with AI-DLC quality gates and micro-iteration discipline.
handoffs: 
  - label: Generate Tests
    agent: aurora.test
    prompt: Generate test suite for current implementation
    send: true
  - label: Analyze Consistency
    agent: aurora.analyze
    prompt: Verify implementation consistency with spec
    send: true
  - label: Review Code
    agent: aurora.review
    prompt: Perform code review on implementation
    send: true
scripts:
  sh: scripts/bash/quality-gates.sh --check
  ps: scripts/powershell/Quality-Gates.ps1 -Check
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Purpose

Execute implementation following Bolt structure with quality gates at each step.

**AURORA Stage**: EXECUTE

**Responsible Agents**: Micro Iterator, API Sculptor, Data Shaper, Code Artisan

## Prerequisites

Required files in `specs/[XXX-feature-name]/`:
- `planning/tasks.md` - Generated task list
- `planning/plan.md` - Implementation plan
- `requirements/requirements.md` - Feature specification

Required in project root:
- `memory/constitution.md` - Technology and standards governance

## Implementation Discipline

### The Bolt Rhythm

```
┌─────────────────────────────────────────────────┐
│  Bolt Start                                      │
│  ├── Read tasks for this Bolt                   │
│  ├── Execute task by task                       │
│  │   ├── Write code                             │
│  │   ├── Write test                             │
│  │   ├── Verify passes                          │
│  │   └── Mark checkbox [x]                      │
│  ├── Run quality gates                          │
│  └── Bolt complete → next Bolt                  │
└─────────────────────────────────────────────────┘
```

## Execution Flow

### 1. Load Context

```bash
# Read governing constitution
cat memory/constitution.md

# Read current Bolt tasks
cat specs/[XXX-feature-name]/planning/tasks.md

# Read contracts (if exist)
ls specs/[XXX-feature-name]/contracts/
```

### 2. Begin Bolt Implementation

For each Bolt in `tasks.md`:

#### A. Domain Layer (src/domain/)

```typescript
// Entities - Core business objects
// File: src/domain/entities/[entity].ts

import { EntityId } from '../value-objects/entity-id';

export class [Entity] {
  private constructor(
    private readonly id: EntityId,
    // ... properties
  ) {}

  // Factory method
  static create(props: [Entity]Props): [Entity] {
    // Validation
    // Business rules
    return new [Entity](...);
  }

  // Domain behavior methods
}
```

```typescript
// Value Objects - Immutable domain concepts
// File: src/domain/value-objects/[value-object].ts

export class [ValueObject] {
  private constructor(private readonly value: string) {
    this.validate(value);
  }

  static create(value: string): [ValueObject] {
    return new [ValueObject](value);
  }

  private validate(value: string): void {
    // Validation rules
  }
}
```

#### B. Application Layer (src/application/)

```typescript
// Use Cases - Application orchestration
// File: src/application/use-cases/[use-case].ts

import { Result } from '../common/result';
import { [Entity]Repository } from '../ports/[entity]-repository';

export class [UseCase] {
  constructor(
    private readonly repository: [Entity]Repository,
    // ... dependencies
  ) {}

  async execute(request: [Request]): Promise<Result<[Response]>> {
    // 1. Validate request
    // 2. Load/create domain objects
    // 3. Execute domain logic
    // 4. Persist changes
    // 5. Return result
  }
}
```

```typescript
// Ports - Dependency interfaces
// File: src/application/ports/[entity]-repository.ts

export interface [Entity]Repository {
  findById(id: EntityId): Promise<[Entity] | null>;
  save(entity: [Entity]): Promise<void>;
  // ... operations
}
```

#### C. Infrastructure Layer (src/infrastructure/)

```typescript
// Repository Implementation
// File: src/infrastructure/persistence/[entity]-repository-impl.ts

import { [Entity]Repository } from '../../application/ports/[entity]-repository';

export class [Entity]RepositoryImpl implements [Entity]Repository {
  constructor(private readonly db: Database) {}

  async findById(id: EntityId): Promise<[Entity] | null> {
    // Database query implementation
  }

  async save(entity: [Entity]): Promise<void> {
    // Database persistence implementation
  }
}
```

#### D. Presentation Layer (src/presentation/)

```typescript
// API Controller
// File: src/presentation/api/[controller].ts

import { [UseCase] } from '../../application/use-cases/[use-case]';

export class [Controller] {
  constructor(private readonly useCase: [UseCase]) {}

  async handle(request: HttpRequest): Promise<HttpResponse> {
    // 1. Parse request
    // 2. Execute use case
    // 3. Format response
  }
}
```

### 3. Quality Gates Per Task

After each task, verify:

```bash
# Type checking (if TypeScript)
npm run typecheck

# Linting
npm run lint

# Unit tests for affected code
npm test -- --watch --related

# Coverage threshold
npm test -- --coverage --changedSince=main
```

### 4. Task Completion Protocol

When task is complete:

1. **Update tasks.md**: Change `- [ ]` to `- [x]`
2. **Commit**: Atomic commit for the task
3. **Verify**: All tests pass

```bash
# Example commit message
git commit -m "T005: Create User entity in src/domain/entities/

- Implemented User entity with factory method
- Added email and password value objects
- Unit tests passing with 95% coverage

Refs: US-001"
```

### 5. Bolt Completion Protocol

When all Bolt tasks are `[x]`:

```bash
# Run full quality gate suite
npm run quality:full

# This should include:
# - Full test suite
# - Coverage report (>80%)
# - Lint/format check
# - Security scan
# - Type check
```

### 6. Implementation Patterns

#### Pattern: Result Type for Error Handling

```typescript
// File: src/application/common/result.ts

export type Result<T, E = Error> = 
  | { success: true; value: T }
  | { success: false; error: E };

export const ok = <T>(value: T): Result<T> => ({ success: true, value });
export const err = <E>(error: E): Result<never, E> => ({ success: false, error });
```

#### Pattern: Repository Factory

```typescript
// File: src/infrastructure/factories/repository-factory.ts

export class RepositoryFactory {
  static createUserRepository(db: Database): UserRepository {
    return new UserRepositoryImpl(db);
  }
}
```

#### Pattern: Use Case Request/Response

```typescript
// Always define clear input/output types
interface CreateUserRequest {
  email: string;
  password: string;
  name: string;
}

interface CreateUserResponse {
  userId: string;
  createdAt: Date;
}
```

## Code Quality Standards

### From Constitution

Always reference `memory/constitution.md` for:

- **Language/Framework versions**
- **Naming conventions**
- **File organization patterns**
- **Error handling approach**
- **Logging standards**

### Universal Rules

```
1. No business logic in infrastructure layer
2. No framework dependencies in domain layer
3. All use cases return Result type
4. All entities created via factory methods
5. All value objects are immutable
6. Test coverage > 80% per Bolt
```

## Output

After implementing a Bolt:

```markdown
## Bolt [N] Implementation Complete

**Tasks Completed**: [count]/[total]
**Coverage**: [percentage]%
**Quality Gates**: ✅ All passing

**Files Modified**:
- `src/domain/entities/user.ts` (new)
- `src/domain/value-objects/email.ts` (new)
- `src/application/use-cases/create-user.ts` (new)
- `tests/unit/entities/user.test.ts` (new)

**Commits**:
1. T005: Create User entity...
2. T006: Create Email value object...
3. T007: Implement CreateUser use case...

**Next Steps**:
1. Continue with Bolt [N+1]
2. Run `/aurora.analyze` for consistency check
3. Run `/aurora.review` for code review
```

## Error Recovery

If a task fails:

1. **Don't skip it** - Fix the issue
2. **Update plan if needed** - Add clarification ADR
3. **Document blocker** - Add to `specs/[XXX-feature-name]/planning/blockers.md`
4. **Escalate if major** - Run `/aurora.clarify` for resolution

## Parallel Task Execution

Tasks marked with `[P]` can run in parallel:

```bash
# Terminal 1
Implement T005 [P] User entity

# Terminal 2  
Implement T006 [P] Email value object

# Terminal 3
Implement T007 [P] Password value object
```

Sync after parallel batch before dependencies.
