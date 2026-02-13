# Quick Start - Creando tu Primer Skill en 5 Minutos

Esta guía te lleva paso a paso para crear tu primer skill personalizado para GitHub Copilot.

## Antes de Comenzar

**¿Tienes 5 minutos?** Vamos a crear un skill simple pero útil.

**Prerrequisitos**:

- Proyecto AURORA inicializado
- GitHub Copilot activo en VS Code

## Paso 1: Decide el Dominio (30 segundos)

Piensa en algo que haces repetidamente en tu proyecto. Ejemplos:

- ✅ Crear APIs REST con estructura específica
- ✅ Formatear mensajes de error consistentemente
- ✅ Escribir documentación de funciones
- ✅ Validar inputs de usuario

**Para este tutorial**: Crearemos un skill para formatear error responses.

## Paso 2: Crea la Estructura (30 segundos)

```bash
# Opción A: Comando directo
mkdir -p .github/skills/error-handling

# Opción B: Pide ayuda a Copilot
# En el chat: "Crea la estructura para un skill de error-handling"
```

## Paso 3: Crea el SKILL.md (3 minutos)

Crea `.github/skills/error-handling/SKILL.md` con este contenido mínimo:

````markdown
# Error Handling - API Error Response Standards

## Descripción

Estandariza el formato de respuestas de error en todas las APIs del proyecto.

## Cuándo Usar Este Skill

- Al manejar errores en endpoints REST
- Al crear custom exceptions
- Al formatear error responses

## Instrucciones

### Formato Estándar de Error

Todos los errores deben seguir este formato JSON:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "details": {
      // Información adicional específica del error
    },
    "timestamp": "2026-02-12T10:30:00Z",
    "path": "/api/endpoint"
  }
}
```
````

### Códigos de Error Estándar

- `VALIDATION_ERROR` - Input validation failed
- `NOT_FOUND` - Resource not found
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Insufficient permissions
- `INTERNAL_ERROR` - Unexpected server error

### Ejemplo de Implementación

```typescript
class ApiError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number,
    public details?: any
  ) {
    super(message);
  }

  toJSON() {
    return {
      error: {
        code: this.code,
        message: this.message,
        details: this.details,
        timestamp: new Date().toISOString(),
        path: 'Set by middleware',
      },
    };
  }
}

// Uso
throw new ApiError('NOT_FOUND', 'User not found', 404, { userId });
```

### Middleware de Error

```typescript
app.use((err, req, res, next) => {
  if (err instanceof ApiError) {
    err.path = req.path;
    return res.status(err.statusCode).json(err.toJSON());
  }

  // Error inesperado
  const internalError = new ApiError('INTERNAL_ERROR', 'An unexpected error occurred', 500);
  internalError.path = req.path;
  res.status(500).json(internalError.toJSON());
});
```

## Mejores Prácticas

1. **Nunca exponer stack traces** en producción
2. **Loguear detalles técnicos**, retornar mensajes amigables
3. **Usar HTTP status codes** apropiados
4. **Incluir request ID** para debugging

## Referencias

- [REST API Error Handling](https://www.rfc-editor.org/rfc/rfc7807)
- Constitution: `memory/constitution.md`

````

## Paso 4: Registra el Skill (30 segundos)

Edita `.github/copilot-instructions.md` y agrega en la tabla de skills:

```markdown
| [error-handling](.github/skills/error-handling/) | Error Handling | Handling API errors |
````

## Paso 5: ¡Pruébalo! (30 segundos)

Abre el chat de Copilot y pregunta:

```
"Crea un endpoint POST /users que maneje errores apropiadamente"
```

**Verifica que Copilot**:

- ✅ Use el formato de error que definiste
- ✅ Incluya los códigos de error estándar
- ✅ Siga la estructura JSON especificada

## Resultado Esperado

Copilot debería generar algo como:

```typescript
app.post('/users', async (req, res, next) => {
  try {
    const { email, name } = req.body;

    // Validation
    if (!email || !name) {
      throw new ApiError('VALIDATION_ERROR', 'Email and name are required', 400, {
        missing: !email ? 'email' : 'name',
      });
    }

    // Check if exists
    const existing = await userRepo.findByEmail(email);
    if (existing) {
      throw new ApiError('VALIDATION_ERROR', 'Email already registered', 400, { email });
    }

    // Create user
    const user = await userService.createUser({ email, name });
    res.status(201).json(user);
  } catch (error) {
    next(error); // Handled by error middleware
  }
});
```

## ¡Éxito! 🎉

Acabas de crear tu primer skill. Ahora Copilot:

- Conoce tu estándar de errores
- Lo aplica automáticamente
- Genera código consistente

## Próximos Pasos

### Nivel 1: Mejora el Skill

- Agrega más ejemplos
- Incluye casos de error comunes
- Documenta integraciones con logging

### Nivel 2: Crea Más Skills

Ideas rápidas para más skills:

- **validation-patterns**: Patrones de validación de inputs
- **logging-standards**: Formato consistente de logs
- **dto-patterns**: Creación de Data Transfer Objects
- **api-documentation**: Formato de comentarios OpenAPI/Swagger

### Nivel 3: Skills Avanzados

- **authentication**: Estrategias de auth (JWT, OAuth)
- **caching**: Patrones de caching
- **rate-limiting**: Implementación de rate limiters
- **monitoring**: Instrumentación y métricas

## Tips para Skills Efectivos

### ✅ DO

````markdown
## Instrucciones

Usa este formato exacto:

```typescript
interface User {
  id: string; // UUID v4
  email: string; // Validated format
}
```
````

````

### ❌ DON'T
```markdown
## Instrucciones
Crea interfaces apropiadas para usuarios.
````

**¿Por qué?** El primer ejemplo es específico y accionable. El segundo es vago.

## Atajos

### Templating Rápido

```bash
# Copiar plantill de skill
cp .github/skills/new-skill/templates/skill-template.md \
   .github/skills/nuevo-skill/SKILL.md
```

### Validar Skill

```bash
# Verificar que tiene las secciones requeridas
grep "^## " .github/skills/nuevo-skill/SKILL.md
```

Deberías ver:

```
## Descripción
## Cuándo Usar Este Skill
## Instrucciones
## Ejemplos
```

## Troubleshooting

### "Copilot no parece usar mi skill"

**Solución**:

1. Verifica que el skill está registrado en `copilot-instructions.md`
2. Tu solicitud debe relacionarse con el dominio del skill
3. El archivo debe llamarse exactamente `SKILL.md`
4. Intenta ser más explícito: "Usando el skill de error-handling, crea..."

### "Mi skill es muy largo"

**Solución**:

- Divide en múltiples skills específicos
- Objetivo: 100-500 líneas por skill
- Ejemplo: En vez de "backend-development", crea "api-design", "database-patterns", "auth-strategies"

### "No sé qué poner en el skill"

**Solución**:

1. Revisa tu última semana de código
2. ¿Qué copiaste y pegaste múltiples veces?
3. ¿Qué corregiste en code review repetidamente?
4. ¿Qué patrón explicas a nuevos miembros del equipo?
5. **Eso es un skill!**

## Medición de Éxito

Un skill es exitoso cuando:

- ✅ Te ahorras ≥5 minutos por uso
- ✅ Reduces errores en code review
- ✅ Nuevo código sigue el patrón automáticamente
- ✅ Otros developers lo encuentran útil

## Recursos

- 📖 **Guía completa**: [SKILL.md](../SKILL.md)
- 📝 **Plantilla**: [skill-template.md](../templates/skill-template.md)
- 🎯 **Ejemplo completo**: [example-aurora-testing.md](./example-aurora-testing.md)
- 📚 **Documentación**: [README.md](../../README.md)

## ¿Preguntas?

Pregunta en el chat de Copilot:

```
"@AURORA ¿Cómo mejoro mi skill de [nombre]?"
```

O revisa la documentación completa en [new-skill](../).

---

**Tiempo total**: 5 minutos
**Valor**: Infinito (usarás este skill cientos de veces)
**Próximo skill**: [Lo decides tú]

¡Feliz creación de skills! 🚀
