# Ejemplo: Creación de un Skill para Testing

Este ejemplo muestra paso a paso cómo crear un skill completo para estrategias de testing en proyectos AURORA.

## Contexto

Queremos crear un skill que guíe a Copilot en la creación de tests siguiendo:
- Test-Driven Development (TDD)
- Behavior-Driven Development (BDD)
- Mutation Testing
- Coverage mínimo del 80%

## Paso 1: Identificar el Dominio

**Dominio**: Testing Strategies para AURORA  
**Nombre del skill**: `aurora-testing`  
**Casos de uso frecuentes**:
- Generar tests unitarios
- Crear tests de integración
- Escribir specs de Gherkin
- Configurar mutation testing

**Justificación**: AURORA requiere disciplina TDD/BDD, pero los detalles específicos no están en la constitution. Un skill dedicado asegura consistencia.

## Paso 2: Crear la Estructura

```bash
# Crear directorio
mkdir -p .github/skills/aurora-testing

# Crear subdirectorios opcionales
mkdir -p .github/skills/aurora-testing/examples
mkdir -p .github/skills/aurora-testing/templates
```

## Paso 3: Escribir el SKILL.md

```markdown
# Aurora Testing - Testing Strategies & Best Practices

## Descripción
Guía completa para implementar testing en proyectos AURORA siguiendo TDD/BDD con mutation testing y cobertura ≥80%.

## Cuándo Usar Este Skill
- Al generar tests unitarios o de integración
- Al escribir especificaciones Gherkin/BDD
- Al configurar pipelines de testing
- Al validar cobertura de código
- Al implementar mutation testing

## Instrucciones

### Requisitos Previos
- [ ] Verificar que existe `memory/constitution.md` con frameworks de testing
- [ ] Asegurar que la feature tiene especificación en `specs/`
- [ ] Revisar que existen acceptance criteria definidos

### Proceso Paso a Paso

#### 1. Análisis de Requisitos de Testing

Antes de escribir tests, identifica:
- **Unidad bajo test**: ¿Qué función/clase/módulo?
- **Casos límite**: ¿Qué inputs extremos pueden fallar?
- **Dependencias**: ¿Qué mocks/stubs necesitas?
- **Coverage objetivo**: Minimum 80%, aim for 95%+

**Ejemplo de análisis:**
```typescript
// Unidad: UserService.createUser()
// Casos límite:
// - Email inválido
// - Email duplicado
// - Password débil
// - Nombre vacío
// Dependencias: UserRepository, EmailService
```

#### 2. Escribir Tests Antes del Código (TDD)

**Red → Green → Refactor**

**Paso 2a: Red (Test que falla)**
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should reject invalid email format', async () => {
      // Arrange
      const service = new UserService();
      const invalidUser = {
        email: 'not-an-email',
        password: 'SecurePass123!',
        name: 'John Doe'
      };

      // Act & Assert
      await expect(service.createUser(invalidUser))
        .rejects.toThrow('Invalid email format');
    });
  });
});
```

**Paso 2b: Green (Implementación mínima)**
```typescript
class UserService {
  async createUser(data: CreateUserDto): Promise<User> {
    if (!this.isValidEmail(data.email)) {
      throw new Error('Invalid email format');
    }
    // ... implementación
  }

  private isValidEmail(email: string): boolean {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  }
}
```

**Paso 2c: Refactor (Mejorar sin romper tests)**
```typescript
// Extraer validación a un validator dedicado
class EmailValidator {
  private static readonly EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

  static validate(email: string): boolean {
    return EmailValidator.EMAIL_REGEX.test(email);
  }
}
```

#### 3. Estructura de Test (AAA Pattern)

**SIEMPRE** usa el patrón Arrange-Act-Assert:

```typescript
it('should create user when data is valid', async () => {
  // Arrange - Preparar datos y mocks
  const mockRepo = {
    save: jest.fn().mockResolvedValue({ id: '123', ...userData }),
    findByEmail: jest.fn().mockResolvedValue(null)
  };
  const service = new UserService(mockRepo);
  const userData = {
    email: 'john@example.com',
    password: 'SecurePass123!',
    name: 'John Doe'
  };

  // Act - Ejecutar la acción
  const result = await service.createUser(userData);

  // Assert - Verificar resultados
  expect(result).toHaveProperty('id');
  expect(result.email).toBe(userData.email);
  expect(mockRepo.save).toHaveBeenCalledTimes(1);
  expect(mockRepo.findByEmail).toHaveBeenCalledWith(userData.email);
});
```

#### 4. Testing de Casos Límite

**SIEMPRE** testea:
- ✅ Happy path (caso exitoso)
- ✅ Boundary values (límites)
- ✅ Error cases (errores esperados)
- ✅ Edge cases (casos extremos)

```typescript
describe('UserService.createUser - Boundary Tests', () => {
  it('should accept minimum valid password length', async () => {
    const user = { ...validUser, password: 'Aa1!' }; // 8 chars mínimo
    await expect(service.createUser(user)).resolves.toBeDefined();
  });

  it('should reject password below minimum length', async () => {
    const user = { ...validUser, password: 'Aa1' }; // 7 chars
    await expect(service.createUser(user))
      .rejects.toThrow('Password must be at least 8 characters');
  });

  it('should handle maximum name length', async () => {
    const user = { ...validUser, name: 'a'.repeat(255) };
    await expect(service.createUser(user)).resolves.toBeDefined();
  });

  it('should reject name exceeding maximum length', async () => {
    const user = { ...validUser, name: 'a'.repeat(256) };
    await expect(service.createUser(user))
      .rejects.toThrow('Name too long');
  });
});
```

#### 5. Mocking y Stubs

**Regla de oro**: Mock dependencias externas, NO la unidad bajo test.

```typescript
// ✅ CORRECTO - Mock de dependencias
const mockEmailService = {
  sendWelcomeEmail: jest.fn().mockResolvedValue(true)
};
const mockUserRepo = {
  save: jest.fn(),
  findByEmail: jest.fn()
};
const service = new UserService(mockUserRepo, mockEmailService);

// ❌ INCORRECTO - Mock de la unidad bajo test
const mockService = {
  createUser: jest.fn().mockResolvedValue({ id: '123' })
};
// Esto no prueba nada real!
```

**Verificar interacciones con mocks:**
```typescript
it('should send welcome email after user creation', async () => {
  await service.createUser(validUser);

  expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalledWith(
    expect.objectContaining({
      to: validUser.email,
      name: validUser.name
    })
  );
});
```

#### 6. BDD con Gherkin (Para Features Completas)

Para funcionalidades de negocio, escribe specs Gherkin PRIMERO:

```gherkin
# specs/001-user-management/requirements/create-user.feature
Feature: User Registration
  As a potential user
  I want to create an account
  So that I can access the platform

  Background:
    Given the system is operational
    And the email service is available

  Scenario: Successful registration with valid data
    Given I am not registered
    When I provide valid registration details:
      | email           | password      | name      |
      | john@example.com | SecurePass123! | John Doe  |
    Then my account should be created
    And I should receive a welcome email
    And I should be logged in automatically

  Scenario: Registration with duplicate email
    Given a user exists with email "john@example.com"
    When I try to register with email "john@example.com"
    Then I should see error "Email already registered"
    And no new account should be created
    And no email should be sent

  Scenario Outline: Registration with invalid data
    When I try to register with <field> as "<value>"
    Then I should see error "<error>"
    And no account should be created

    Examples:
      | field    | value          | error                              |
      | email    | invalid-email  | Invalid email format               |
      | password | weak           | Password does not meet requirements |
      | name     |                | Name cannot be empty               |
      | email    |                | Email is required                  |
```

**Implementar step definitions:**
```typescript
import { Given, When, Then } from '@cucumber/cucumber';

Given('I am not registered', function() {
  this.mockUserRepo.findByEmail.mockResolvedValue(null);
});

When('I provide valid registration details:', async function(dataTable) {
  const [data] = dataTable.hashes();
  this.result = await this.userService.createUser(data);
});

Then('my account should be created', function() {
  expect(this.result).toHaveProperty('id');
  expect(this.mockUserRepo.save).toHaveBeenCalled();
});

Then('I should receive a welcome email', function() {
  expect(this.mockEmailService.sendWelcomeEmail).toHaveBeenCalledWith(
    expect.objectContaining({ to: this.result.email })
  );
});
```

#### 7. Tests de Integración

Tests de integración verifican que componentes múltiples funcionen juntos:

```typescript
describe('User Registration Integration', () => {
  let app: Application;
  let database: DatabaseConnection;

  beforeAll(async () => {
    // Setup real database (test environment)
    database = await setupTestDatabase();
    app = await createTestApp(database);
  });

  afterAll(async () => {
    await database.close();
  });

  beforeEach(async () => {
    // Clean database before each test
    await database.clear();
  });

  it('should create user end-to-end', async () => {
    // Act - Real HTTP request
    const response = await request(app)
      .post('/api/users')
      .send({
        email: 'john@example.com',
        password: 'SecurePass123!',
        name: 'John Doe'
      });

    // Assert - HTTP response
    expect(response.status).toBe(201);
    expect(response.body).toHaveProperty('id');

    // Assert - Database state
    const savedUser = await database.users.findOne({
      email: 'john@example.com'
    });
    expect(savedUser).toBeDefined();
    expect(savedUser.name).toBe('John Doe');

    // Assert - Password is hashed
    expect(savedUser.password).not.toBe('SecurePass123!');
    expect(await bcrypt.compare('SecurePass123!', savedUser.password))
      .toBe(true);
  });
});
```

#### 8. Mutation Testing

Después de lograr 80%+ coverage, valida calidad de tests con mutation testing:

```bash
# Install Stryker
npm install --save-dev @stryker-mutator/core @stryker-mutator/typescript-checker

# Configure stryker.conf.json
{
  "mutator": "typescript",
  "testRunner": "jest",
  "coverageAnalysis": "perTest",
  "thresholds": { "high": 80, "low": 60, "break": 50 }
}

# Run mutation tests
npx stryker run
```

**Interpretar resultados:**
```
Mutants tested: 100
Killed: 85 (tests detected the mutation)
Survived: 10 (tests DIDN'T detect - BAD!)
Timeout: 2
No coverage: 3
```

**Mejorar tests basado en mutantes supervivientes:**
```typescript
// Mutante superviviente: > cambió a >=
// Original: if (password.length > 8)
// Mutación: if (password.length >= 8)
// Test existente no detectó el cambio!

// ❌ Test débil
it('should validate password length', () => {
  expect(validatePassword('short')).toBe(false);
  expect(validatePassword('longenough')).toBe(true);
});

// ✅ Test mejorado - detecta la mutación
it('should require password longer than 8 characters', () => {
  expect(validatePassword('8chars!!')).toBe(false); // exactamente 8
  expect(validatePassword('9chars!!!')).toBe(true);  // 9 chars
});
```

### Mejores Prácticas

#### Práctica 1: Tests Independientes y Aislados
**Por qué**: Tests dependientes crean flakiness y dificultan debugging.

**Cómo**:
```typescript
// ❌ MAL - Tests dependientes
let userId;
it('should create user', async () => {
  const user = await service.createUser(data);
  userId = user.id; // ⚠️ Estado compartido
});
it('should update user', async () => {
  await service.updateUser(userId, updates); // Depende del test anterior
});

// ✅ BIEN - Tests independientes
describe('UserService', () => {
  let testUser;

  beforeEach(async () => {
    testUser = await createTestUser(); // Cada test tiene su propio usuario
  });

  it('should update user', async () => {
    await service.updateUser(testUser.id, updates);
    // Test funciona independientemente
  });
});
```

#### Práctica 2: Nombres Descriptivos
**Por qué**: Tests son documentación viva del comportamiento del sistema.

```typescript
// ❌describe('User', () => {
  it('test1', () => { ... });
  it('should work', () => { ... });
});

// ✅ BIEN
describe('UserService.createUser', () => {
  it('should hash password before saving to database', () => { ... });
  it('should throw ValidationError when email format is invalid', () => { ... });
  it('should send welcome email asynchronously without blocking user creation', () => { ... });
});
```

#### Práctica 3: One Assertion per Concept
**Por qué**: Tests focaliza facilitan debugging cuando fallan.

```typescript
// ❌ MAL - Múltiples conceptos
it('should create and notify user', async () => {
  const user = await service.createUser(data);
  expect(user.id).toBeDefined(); // Concept 1: Creation
  expect(user.email).toBe(data.email); // Concept 1: Creation
  expect(mockEmailService.send).toHaveBeenCalled(); // Concept 2: Notification
  expect(mockLogger.info).toHaveBeenCalled(); // Concept 3: Logging
});

// ✅ BIEN - Un concepto por test
it('should create user with provided data', async () => {
  const user = await service.createUser(data);
  expect(user).toMatchObject({
    email: data.email,
    name: data.name
  });
});

it('should send welcome email after user creation', async () => {
  await service.createUser(data);
  expect(mockEmailService.send).toHaveBeenCalledWith(
    expect.objectContaining({ type: 'welcome', to: data.email })
  );
});

it('should log user creation event', async () => {
  await service.createUser(data);
  expect(mockLogger.info).toHaveBeenCalledWith(
    'User created',
    expect.objectContaining({ email: data.email })
  );
});
```

### Errores Comunes

#### Error 1: Testing Implementation Details
**Problema**:
```typescript
// ❌ Test acoplado a implementación
it('should call validateEmail method', () => {
  const spy = jest.spyOn(service, 'validateEmail');
  service.createUser(data);
  expect(spy).toHaveBeenCalled(); // Frágil!
});
```

**Solución**:
```typescript
// ✅ Test del comportamiento
it('should reject invalid email formats', async () => {
  await expect(service.createUser({ ...data, email: 'invalid' }))
    .rejects.toThrow('Invalid email');
});
```

#### Error 2: Tests Flaky (Intermitentes)
**Problema**:
```typescript
// ❌ Depende de timing
it('should process async task', async () => {
  service.processAsync(data);
  setTimeout(() => {
    expect(result).toBeDefined(); // Race condition!
  }, 100);
});
```

**Solución**:
```typescript
// ✅ Espera apropiada
it('should process async task', async () => {
  const result = await service.processAsync(data);
  expect(result).toBeDefined();
});
```

## Criterios de Calidad

- [ ] Coverage ≥ 80% (líneas, branches, functions)
- [ ] Mutation score ≥ 70%
- [ ] Tests pasan en < 10 segundos (unit tests)
- [ ] Cero tests flaky (intermitentes)
- [ ] Cada test tiene nombre descriptivo
- [ ] Arrange-Act-Assert es claramente visible
- [ ] Mocks solo de dependencias, no de unidad bajo test
- [ ] Tests independientes (pueden ejecutarse en cualquier orden)

## Referencias

### Testing Frameworks
- [Jest Documentation](https://jestjs.io/)
- [Cucumber/Gherkin](https://cucumber.io/)
- [Stryker Mutator](https://stryker-mutator.io/)

### Best Practices
- [Test Pyramid](https://martinfowler.com/articles/practical-test-pyramid.html)
- [TDD by Example](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

### AURORA Related
- Constitution: `memory/constitution.md`
- Feature Specs: `specs/*/feature.md`
- Skill: skill-development

## Changelog
- 2026-02-12: Versión inicial

---
```

## Paso 4: Registrar el Skill

Actualizar `.github/copilot-instructions.md`:

```markdown
## Skills - Specialized Capabilities

| Skill | Domain | Use When |
|-------|--------|----------|
| [skill-development](.github/skills/skill-development/) | Skill Creation | Creating or improving Copilot skills |
| [aurora-testing](.github/skills/aurora-testing/) | Testing Strategies | Writing unit/integration tests, BDD specs |
```

## Paso 5: Probar el Skill

### Test 1: Solicitud Simple
**Input**: "Genera tests unitarios para la función calculateDiscount"

**Verificación**:
- ✅ Copilot lee `aurora-testing/SKILL.md`
- ✅ Tests usan patrón AAA (Arrange-Act-Assert)
- ✅ Incluye casos límite (0%, 100%, valores negativos)
- ✅ Nombres descriptivos de tests

### Test 2: Solicitud BDD
**Input**: "Crea una spec Gherkin para el checkout process"

**Verificación**:
- ✅ Copilot genera archivo .feature
- ✅ Usa formato Given-When-Then
- ✅ Incluye Background, Scenarios, y Scenario Outlines
- ✅ Propone step definitions correspondientes

### Test 3: Validar Calidad
**Input**: "Revisa estos tests y sugiere mejoras"

**Verificación**:
- ✅ Identifica tests acoplados a implementación
- ✅ Sugiere agregar casos límite faltantes
- ✅ Recomienda mutation testing
- ✅ Verifica patterns AAA

## Resultados Esperados

Después de implementar este skill:

1. **Consistencia**: Todos los tests siguen las mismas convenciones
2. **Cobertura**: Automáticamente se incluyen casos límite
3. **Calidad**: Tests son mantenibles y no frágiles
4. **Velocidad**: Menos tiempo creando boilerplate de tests

## Iteraciones Futuras

Basado en uso real, el skill puede evolucionar para incluir:
- Patrones específicos de mocking para cada framework
- Templates de tests para arquitecturas específicas (CQRS, Event Sourcing)
- Integración con herramientas de CI/CD
- Estrategias de testing para microservicios

---

**Tiempo estimado de creación**: 2-3 horas  
**Valor entregado**: Ahorra ~30 minutos por feature en testing  
**ROI**: Positivo después de ~5-6 features
