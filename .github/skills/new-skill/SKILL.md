---
name: new-skill
description: >
  Guide for creating, structuring, and deploying custom GitHub Copilot skills.
  Covers SKILL.md format with YAML frontmatter, progressive disclosure,
  auto-discovery conventions, and best practices for AURORA projects.
  Use when creating new skills or improving existing ones.
---

# Skill Development - Cómo Crear Skills para GitHub Copilot

## Descripción

Este skill proporciona una guía completa sobre cómo crear, estructurar y desplegar skills personalizados para GitHub Copilot en proyectos AURORA.

## ¿Qué es un Skill?

Un **skill** es un conjunto especializado de instrucciones y conocimiento de dominio que GitHub Copilot lee antes de responder a solicitudes específicas. Los skills proporcionan:

- **Capacidades especializadas**: Conocimiento experto en un dominio específico
- **Flujos de trabajo refinados**: Procesos probados para producir outputs de alta calidad
- **Mejores prácticas**: Instrucciones basadas en pruebas para dominios específicos

## Estructura de un Skill

Cada skill debe seguir esta estructura de directorios:

```
.github/skills/
└── nombre-del-skill/
    ├── SKILL.md           # Instrucciones principales del skill (REQUERIDO)
    ├── examples/          # Ejemplos de uso (OPCIONAL)
    └── templates/         # Plantillas reutilizables (OPCIONAL)
```

## Formato del archivo SKILL.md

Un archivo `SKILL.md` debe contener las siguientes secciones:

### 1. Encabezado y Descripción

```markdown
# Nombre del Skill

## Descripción

Una breve explicación (2-3 líneas) de qué hace este skill y cuándo usarlo.
```

### 2. Cuándo Usar Este Skill

```markdown
## Cuándo Usar Este Skill

Lista clara de casos de uso:

- Cuando el usuario solicita X
- Para tareas relacionadas con Y
- Al trabajar con el dominio Z
```

### 3. Instrucciones Principales

```markdown
## Instrucciones

### Requisitos Previos

- Verificar que [condición]
- Asegurar que [requisito]

### Proceso Paso a Paso

1. Primer paso con detalles específicos
2. Segundo paso con ejemplos
3. Tercer paso con validaciones

### Mejores Prácticas

- Práctica 1: Explicación y justificación
- Práctica 2: Ejemplos concretos
- Práctica 3: Casos de error comunes a evitar
```

### 4. Ejemplos

```markdown
## Ejemplos

### Ejemplo 1: [Caso de Uso]

[Descripción del escenario]

**Entrada del Usuario:**
```

[ejemplo de solicitud]

```

**Salida Esperada:**
```

[ejemplo de respuesta]

```

### Ejemplo 2: [Otro Caso]
[Más ejemplos...]
```

### 5. Referencias

```markdown
## Referencias

- Documentación relacionada
- Enlaces a recursos externos
- Otros skills relacionados
```

## Cómo Crear un Nuevo Skill

### Paso 1: Identificar el Dominio

Antes de crear un skill, identifica:

- ¿Qué dominio o capacidad cubre?
- ¿Es lo suficientemente específico pero no demasiado estrecho?
- ¿Se usará frecuentemente?

**Buenos candidatos para skills:**

- Testing strategies (unit, integration, E2E)
- API design patterns
- Security best practices
- Performance optimization
- Domain-specific architectures (DDD, CQRS, etc.)
- Documentation standards
- UI/UX patterns

**No crear skills para:**

- Tareas únicas o muy raras
- Conocimiento que cambia constantemente
- Información ya cubierta por la constitution

### Paso 2: Crear la Estructura

```bash
# Crear directorio del skill
mkdir -p .github/skills/nombre-del-skill

# Crear archivo principal
touch .github/skills/nombre-del-skill/SKILL.md
```

### Paso 3: Escribir el Contenido

Sigue la plantilla de formato descrita arriba. **Importante:**

- Usa lenguaje claro y directo
- Incluye ejemplos concretos
- Proporciona contexto sobre CUÁNDO usar cada práctica
- Incluye casos de error comunes
- Valida con ejemplos reales

### Paso 4: Registrar el Skill

Actualiza `.github/copilot-instructions.md` para incluir referencia al nuevo skill:

```markdown
<skills>
...
<skill>
<name>nombre-del-skill</name>
<description>Descripción breve del skill y cuándo usarlo</description>
<file>f:\repos\aurora-ai\.github\skills\nombre-del-skill\SKILL.md</file>
</skill>
</skills>
```

### Paso 5: Probar el Skill

1. Haz una solicitud que debería activar el skill
2. Verifica que Copilot lea el archivo SKILL.md
3. Valida que la respuesta siga las instrucciones del skill
4. Itera y refina según necesidad

## Mejores Prácticas para Skills

### ✅ DO - Hacer

1. **Especificidad**: Skills deben ser específicos a un dominio
   - ✅ "API Design for RESTful Services"
   - ❌ "General Programming"

2. **Accionable**: Proporciona pasos concretos
   - ✅ "1. Crear endpoint con formato `/api/v1/{resource}`"
   - ❌ "Diseña buenos endpoints"

3. **Ejemplos reales**: Incluye código y casos de uso

   ```typescript
   // ✅ Ejemplo concreto
   interface User {
     id: string;
     email: string;
   }
   ```

4. **Validación**: Incluye criterios de éxito
   - ✅ "El endpoint debe retornar 404 si el recurso no existe"
   - ❌ "Maneja errores apropiadamente"

5. **Contexto**: Explica el "por qué"
   - ✅ "Usa DTOs para separar la representación de la lógica de dominio"
   - ❌ "Usa DTOs"

### ❌ DON'T - No Hacer

1. **No duplicar la constitution**: Si está en `memory/constitution.md`, no va en un skill
2. **No crear skills demasiado amplios**: Divide en múltiples skills específicos
3. **No incluir información que cambia frecuentemente**: Usa referencias en su lugar
4. **No usar lenguaje vago**: Sé específico y prescriptivo
5. **No olvidar ejemplos**: Cada instrucción debe tener al menos un ejemplo

## Integración con AURORA

Los skills se integran con AURORA de la siguiente manera:

### Durante DISCOVERY

- Skills de análisis de requisitos
- Skills de diseño de features
- Skills de especificación técnica

### Durante CONSTRUCTION

- Skills de patrones de código
- Skills de testing
- Skills de revisión de código

### Durante TRANSITION

- Skills de documentación
- Skills de deployment
- Skills de release notes

## Ciclo de Vida de un Skill

1. **Creación**: Identificar necesidad y crear estructura
2. **Refinamiento**: Probar con casos reales y ajustar
3. **Documentación**: Asegurar que sea autoexplicativo
4. **Validación**: Verificar que mejora la calidad de las respuestas
5. **Mantenimiento**: Actualizar cuando cambien las prácticas
6. **Deprecación**: Marcar como obsoleto si ya no se usa

## Plantilla Completa

````markdown
# [Nombre del Skill]

## Descripción

[2-3 líneas explicando qué hace este skill]

## Cuándo Usar Este Skill

- Cuando [caso 1]
- Para [caso 2]
- Al [caso 3]

## Instrucciones

### Requisitos Previos

- [ ] Verificar [requisito 1]
- [ ] Asegurar [requisito 2]

### Proceso Paso a Paso

#### 1. [Primer paso]

[Explicación detallada]

**Ejemplo:**

```[lenguaje]
[código de ejemplo]
```
````

#### 2. [Segundo paso]

[Explicación detallada]

**Validación:**

- Criterio 1
- Criterio 2

### Mejores Prácticas

#### Práctica 1: [Nombre]

**Por qué:** [Justificación]

**Cómo:** [Implementación]

**Ejemplo:**

```[lenguaje]
[código]
```

#### Práctica 2: [Nombre]

[Repetir formato]

### Errores Comunes

#### Error 1: [Descripción]

**Problema:**

```[lenguaje]
[código problemático]
```

**Solución:**

```[lenguaje]
[código correcto]
```

## Ejemplos

### Ejemplo Completo 1: [Escenario]

[Descripción del caso de uso]

**Contexto:**
[Situación]

**Solicitud:**

```
[Lo que pide el usuario]
```

**Respuesta Esperada:**

```
[Salida completa siguiendo el skill]
```

## Referencias

- [Recurso 1](url)
- [Recurso 2](url)
- Skill relacionado: [nombre]

## Changelog

- [Fecha]: Versión inicial
- [Fecha]: Actualización [descripción]

````

## Comandos Útiles

### Listar todos los skills
```bash
find .github/skills -name "SKILL.md"
````

### Validar formato de un skill

```bash
# Verificar que tenga las secciones requeridas
grep -E "^## (Descripción|Cuándo Usar|Instrucciones|Ejemplos)" .github/skills/*/SKILL.md
```

### Crear nuevo skill desde plantilla

```bash
# Copiar plantilla
cp .github/skills/new-skill/templates/skill-template.md .github/skills/nuevo-skill/SKILL.md
```

## FAQ

### ¿Cuántos skills debería tener?

Crea skills cuando identifiques patrones repetitivos en las solicitudes. Comienza con 5-10 skills corecubriendo tus dominios más frecuentes.

### ¿Qué tan largo debe ser un skill?

Entre 100-500 líneas. Si es más largo, considera dividirlo en múltiples skills.

### ¿Puedo combinar skills?

Sí, Copilot puede cargar múltiples skills si una solicitud aplica a varios dominios.

### ¿Cómo sé si mi skill funciona?

Haz una solicitud específica y verifica:

1. Que Copilot lea el archivo SKILL.md
2. Que la respuesta siga las instrucciones del skill
3. Que la calidad mejore comparado con no tener el skill

### ¿Debo versionar los skills?

Sí, incluye un changelog en cada SKILL.md y usa versionado semántico en los commits que los modifican.

## Ejemplos de Skills Útiles para AURORA

### Skills sugeridos para implementar:

1. **aurora-testing**: Estrategias de testing para proyectos AURORA
2. **aurora-api-design**: Diseño de APIs RESTful siguiendo principios AURORA
3. **aurora-ddd**: Implementación de Domain-Driven Design
4. **aurora-security**: Security best practices
5. **aurora-performance**: Performance optimization patterns
6. **aurora-documentation**: Estándares de documentación
7. **aurora-error-handling**: Manejo de errores y excepciones
8. **aurora-database**: Diseño y optimización de bases de datos
9. **aurora-ci-cd**: Pipelines y automatización
10. **aurora-monitoring**: Observabilidad y logging

## Conclusión

Los skills son una herramienta poderosa para estandarizar y mejorar la calidad de las respuestas de GitHub Copilot. Siguiendo esta guía, puedes crear skills que:

- Proporcionan conocimiento especializado
- Mejoran la consistencia
- Reducen errores comunes
- Aceleran el desarrollo
- Mantienen estándares de calidad

**Recuerda**: Un skill bien diseñado debe ser bloqueante - Copilot DEBE leerlo antes de responder a solicitudes en su dominio.

---

**Autor**: AURORA AI Assistant
**Versión**: 1.0.0
**Fecha**: 2026-02-12
