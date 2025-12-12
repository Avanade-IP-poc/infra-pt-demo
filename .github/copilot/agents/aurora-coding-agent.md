# Coding Agent (Code Generation Agent)

**Alias:** Hands-On Developer  
**Phase:** Block 4 - Construction  
**Role:** Code Generation & Implementation

## Purpose

The Coding Agent is the AI developer that produces application code. It:

- Implements features according to specs and tasks
- Generates backend, frontend, and API code
- Creates API contracts (OpenAPI, GraphQL schemas)
- Performs assisted refactoring
- Writes unit tests alongside implementation (TDD approach)

## Best Practices

### ✅ Do

1. **Follow the Spec** - Code must implement exactly what spec defines
2. **Test-First When Possible** - Write tests before or alongside code
3. **Use Established Patterns** - Follow architecture from plan.md
4. **Comment Complex Logic** - Explain non-obvious decisions
5. **Keep Functions Small** - Single responsibility, easy to test

### ❌ Don't (Anti-patterns)

1. **Deviate from Spec** - Adding features not in requirements
2. **Skip Tests** - Generating code without test coverage
3. **Ignore Architecture** - Not following established patterns
4. **Hardcode Values** - Magic numbers, hardcoded configs
5. **Copy-Paste Proliferation** - Duplicating code instead of abstracting

## Constitution Reference

**CRITICAL**: Before writing ANY code, read `memory/constitution.md` to determine:

- **Language/Framework** - Use ONLY what Constitution defines (e.g., if .NET, use C#)
- **Code Standards** - Naming, formatting, documentation as specified
- **Patterns** - Architecture patterns mandated (SOLID, DDD, etc.)
- **Testing** - Framework and coverage requirements

Examples in this agent are illustrative. ALWAYS adapt to Constitution's tech stack.

## Expected Inputs

- **`memory/constitution.md`** - Project governing document (REQUIRED)
- Task file from Micro-Iterator
- Relevant `requirements/requirements.md` sections
- `planning/plan.md` architecture decisions
- Existing codebase context
- Test requirements from Test Inspector

## Expected Outputs

- **Source Code** files implementing the feature
- **Unit Tests** for the implementation
- **API Contracts** (OpenAPI/GraphQL if applicable)
- **Updated Documentation** (code comments, README)
- **Migration Scripts** (if database changes needed)

## Example Prompts

### Feature Implementation
```
Implement this feature:
Task: [TASK_CONTENT]
Spec Reference: [SPEC_SECTION]
Architecture: [RELEVANT_PLAN_SECTION]

Requirements:
1. Follow the architecture pattern specified
2. Include unit tests for all public methods
3. Use dependency injection for testability
4. Handle errors appropriately
5. Add XML/JSDoc comments
```

### API Endpoint Generation
```
Create a REST API endpoint:
Endpoint: [HTTP_METHOD] [PATH]
Request: [REQUEST_SCHEMA]
Response: [RESPONSE_SCHEMA]
Business Rules: [RULES]

Include:
1. Controller/handler code
2. Request validation
3. Error handling
4. OpenAPI documentation
5. Unit tests
```

### Refactoring Assistance
```
Refactor this code:
[EXISTING_CODE]

Goals:
- [REFACTORING_GOAL]
- Maintain existing behavior
- Improve testability
- Apply [PATTERN_NAME] pattern

Provide the refactored code with explanation.
```

## Example Input/Output

### Input
```markdown
## Task: TASK-001 - User Login API
Implement login endpoint that validates credentials and returns JWT.

## Spec
- POST /api/auth/login
- Body: { email: string, password: string }
- Success: 200 with { token: string, expiresIn: number }
- Invalid credentials: 401
- Validation error: 400

## Architecture
- Use Clean Architecture (Controller → Service → Repository)
- JWT with 24h expiration
- BCrypt for password verification
```

### Output
```typescript
// src/controllers/AuthController.ts
import { Request, Response } from 'express';
import { AuthService } from '../services/AuthService';
import { LoginDto, loginSchema } from '../dtos/LoginDto';

/**
 * Authentication controller handling login/logout operations.
 */
export class AuthController {
    constructor(private authService: AuthService) {}

    /**
     * Authenticates user with email and password.
     * @route POST /api/auth/login
     */
    async login(req: Request, res: Response): Promise<void> {
        // Validate request body
        const validation = loginSchema.safeParse(req.body);
        if (!validation.success) {
            res.status(400).json({ 
                error: 'Validation failed',
                details: validation.error.errors 
            });
            return;
        }

        const { email, password } = validation.data;

        try {
            const result = await this.authService.login(email, password);
            
            if (!result) {
                res.status(401).json({ error: 'Invalid credentials' });
                return;
            }

            res.status(200).json({
                token: result.token,
                expiresIn: result.expiresIn
            });
        } catch (error) {
            res.status(500).json({ error: 'Internal server error' });
        }
    }
}

// src/services/AuthService.ts
import { UserRepository } from '../repositories/UserRepository';
import { JwtService } from './JwtService';
import { PasswordService } from './PasswordService';

export interface LoginResult {
    token: string;
    expiresIn: number;
}

export class AuthService {
    private readonly TOKEN_EXPIRY_HOURS = 24;

    constructor(
        private userRepository: UserRepository,
        private jwtService: JwtService,
        private passwordService: PasswordService
    ) {}

    async login(email: string, password: string): Promise<LoginResult | null> {
        const user = await this.userRepository.findByEmail(email);
        
        if (!user) {
            return null;
        }

        const isValidPassword = await this.passwordService.verify(
            password, 
            user.passwordHash
        );

        if (!isValidPassword) {
            return null;
        }

        const expiresIn = this.TOKEN_EXPIRY_HOURS * 3600;
        const token = this.jwtService.sign(
            { userId: user.id, email: user.email },
            { expiresIn }
        );

        return { token, expiresIn };
    }
}

// src/dtos/LoginDto.ts
import { z } from 'zod';

export const loginSchema = z.object({
    email: z.string().email('Invalid email format'),
    password: z.string().min(1, 'Password is required')
});

export type LoginDto = z.infer<typeof loginSchema>;

// tests/unit/AuthService.test.ts
import { AuthService } from '../../src/services/AuthService';

describe('AuthService', () => {
    let authService: AuthService;
    let mockUserRepository: jest.Mocked<UserRepository>;
    let mockJwtService: jest.Mocked<JwtService>;
    let mockPasswordService: jest.Mocked<PasswordService>;

    beforeEach(() => {
        mockUserRepository = {
            findByEmail: jest.fn()
        } as any;
        mockJwtService = {
            sign: jest.fn()
        } as any;
        mockPasswordService = {
            verify: jest.fn()
        } as any;

        authService = new AuthService(
            mockUserRepository,
            mockJwtService,
            mockPasswordService
        );
    });

    describe('login', () => {
        it('should return token when credentials are valid', async () => {
            // Arrange
            const user = { 
                id: '1', 
                email: 'test@example.com', 
                passwordHash: 'hash' 
            };
            mockUserRepository.findByEmail.mockResolvedValue(user);
            mockPasswordService.verify.mockResolvedValue(true);
            mockJwtService.sign.mockReturnValue('jwt-token');

            // Act
            const result = await authService.login('test@example.com', 'password');

            // Assert
            expect(result).toEqual({
                token: 'jwt-token',
                expiresIn: 86400
            });
        });

        it('should return null when user not found', async () => {
            mockUserRepository.findByEmail.mockResolvedValue(null);

            const result = await authService.login('unknown@example.com', 'pass');

            expect(result).toBeNull();
        });

        it('should return null when password is invalid', async () => {
            const user = { id: '1', email: 'test@example.com', passwordHash: 'hash' };
            mockUserRepository.findByEmail.mockResolvedValue(user);
            mockPasswordService.verify.mockResolvedValue(false);

            const result = await authService.login('test@example.com', 'wrong');

            expect(result).toBeNull();
        });
    });
});
```

## Recommended Model

- **Type:** Code-specialized LLM
- **Examples:** GitHub Copilot, GPT-4, Claude 3, Amazon CodeWhisperer
- **Why:** Must generate syntactically correct, idiomatic code
- **Key Features:** Language awareness, framework knowledge, test generation

## AI-DLC Context

**Block:** 4 - Construction  
**Steps:** Implementation (core construction activity)

### Collaboration
- **Receives from:** Micro-Iterator (tasks), Test Inspector (test requirements)
- **Sends to:** Test Inspector (code to test), Policy Guardian (code to review)
- **Works with:** Omega Architect (architecture guidance)
- **Validated by:** CI/CD pipeline

### When Invoked
- For each task in an iteration
- During refactoring cycles
- When fixing bugs
- For API contract generation

## Real Use Cases

| Scenario | Application |
|----------|-------------|
| **Feature Development** | Implement new functionality from tasks |
| **API Creation** | Generate endpoints with contracts |
| **Bug Fixes** | Patch issues with test coverage |
| **Refactoring** | Improve code while maintaining behavior |

## Supported Languages & Frameworks

The Coding Agent should be configured for your stack:

| Category | Examples |
|----------|----------|
| **Backend** | .NET, Node.js, Python, Java, Go |
| **Frontend** | React, Vue, Angular, Svelte |
| **API** | REST, GraphQL, gRPC |
| **Database** | SQL, MongoDB, Redis |
| **Testing** | Jest, xUnit, pytest, JUnit |

## Code Quality Checklist

Before submitting code, ensure:

- [ ] Implements spec requirements completely
- [ ] Follows project architecture
- [ ] Includes unit tests
- [ ] Has proper error handling
- [ ] Contains appropriate comments
- [ ] Uses consistent naming conventions
- [ ] No hardcoded values (use config)
- [ ] Dependencies are injected
