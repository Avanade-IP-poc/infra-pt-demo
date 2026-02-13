---
name: markdown-formatting
description: >
  Comprehensive guide for writing well-formatted Markdown documents following CommonMark specification.
  Covers syntax rules, linting guidelines, best practices, and AURORA-specific conventions.
  Use when creating or editing any Markdown file (.md, .agent.md, .prompt.md, etc.).
---

# Markdown Formatting - CommonMark & Best Practices

## Descripción

Guía completa para escribir documentos Markdown bien formateados siguiendo la especificación CommonMark. Incluye reglas de sintaxis, convenciones de linting, mejores prácticas y estándares específicos para proyectos AURORA.

## Cuándo Usar Este Skill

- Al crear nuevos documentos Markdown (`.md`, `.agent.md`, `.prompt.md`, etc.)
- Al editar especificaciones de features, ADRs, o documentación técnica
- Al revisar formato y consistencia de documentación
- Al configurar linters (markdownlint, remark-lint)
- Al escribir contenido para GitHub, documentación de usuario, o READMEs

## Instrucciones

### Requisitos Previos

- [ ] Verificar que el documento tiene propósito claro (feature spec, ADR, README, etc.)
- [ ] Revisar si existen plantillas en `.github/skills/markdown-formatting/templates/`
- [ ] Conocer la audiencia del documento (desarrolladores, usuarios, AI agents)

### Proceso Paso a Paso

#### 1. Estructura del Documento

**Frontmatter YAML (cuando aplica):**

```yaml
---
description: 'Brief description of the document'
name: document-name # Para agents/prompts
agent: 'agent' # Para prompts
tools: [] # Para prompts/agents
applyTo: '**/*.ext' # Para instructions
---
```

**Jerarquía de Headings:**

```markdown
# Título Principal del Documento (H1) - Solo UNO por archivo

## Sección Principal (H2)

### Subsección (H3)

#### Detalles (H4)

##### Notas menores (H5)

###### Raramente usado (H6)
```

**Reglas:**

- Un solo `#` (H1) por documento - es el título principal
- No saltarse niveles (H2 → H4 es INCORRECTO)
- Usar ATX headings (`#`) en lugar de Setext (`===`, `---`)
- Espacio obligatorio después del `#`: `# Heading` ✅, `#Heading` ❌

#### 2. Formato de Texto

**Emphasis (Énfasis):**

```markdown
_italic text_ ✅ Preferido en AURORA
_italic text_ ✅ Alternativa válida

**bold text** ✅ Preferido en AURORA
**bold text** ✅ Alternativa válida

**_bold italic_** ✅ Combinación
**bold with _italic_ inside** ✅ Anidado válido
```

**Convención AURORA:** Usar `*` para consistencia (no mezclar `*` y `_` sin razón).

**Code Inline:**

```markdown
Use backticks para código en línea: `const x = 42`
Para literal backtick: `` ` `` o ` `` `
```

#### 3. Code Blocks (Bloques de Código)

**SIEMPRE usar fenced code blocks con lenguaje especificado:**

````markdown
```typescript
interface User {
  id: string;
  name: string;
  email: string;
}
```

```bash
npm install markdown-it
```

```json
{
  "name": "example",
  "version": "1.0.0"
}
```
````

**Lenguajes comunes en AURORA:**

- `typescript`, `javascript`, `jsx`, `tsx`
- `python`, `java`, `csharp`, `go`
- `bash`, `powershell`, `sh`
- `json`, `yaml`, `toml`, `xml`
- `markdown`, `html`, `css`
- `sql`, `graphql`
- `gherkin` (para BDD specs)
- `plaintext` (para output de terminal)

**❌ NO usar indented code blocks:**

`````markdown
❌ EVITAR:
function hello() {
return "world"
}

✅ USAR:

````javascript
function hello() {
  return "world"
}
\```
````
`````

`````

**Beneficio:** Syntax highlighting + claridad del lenguaje.

#### 4. Lists (Listas)

**Unordered Lists (Listas no ordenadas):**

```markdown
- Item 1
- Item 2
  - Nested item 2.1
  - Nested item 2.2
- Item 3

* También válido

- También válido

✅ AURORA prefiere '-' para consistencia
```

**Ordered Lists (Listas ordenadas):**

```markdown
1. First item
2. Second item
   1. Nested numbered
   2. Another nested
3. Third item

# También válido (auto-numeración):

1. First
1. Second
1. Third

# Se renderiza como 1, 2, 3
```

**Task Lists (GitHub-Flavored Markdown):**

```markdown
- [ ] Task not completed
- [x] Task completed
- [ ] Another pending task
```

**Reglas de indentación:**

- 2 o 4 espacios para anidar listas
- Ser consistente en todo el documento
- AURORA usa **2 espacios** por defecto

**Párrafos en listas:**

```markdown
1. First item with paragraph

   This is a continuation of item 1.
   Indented with 3 spaces.

2. Second item
   - Nested list
   - Another nested item
```

#### 5. Links e Imágenes

**Links inline:**

```markdown
[Link text](https://example.com)
[Link with title](https://example.com 'Hover title')
[Link to heading](#section-name)
[Relative link](../docs/guide.md)
```

**Reference-style links:**

```markdown
[Link text][reference-id]
[Another link][ref2]

[reference-id]: https://example.com
[ref2]: https://example.com/page 'Optional title'
```

**Imágenes:**

```markdown
![Alt text](image.jpg)
![Alt text](image.jpg 'Image title')
![Alt text][image-ref]

[image-ref]: image.jpg 'Optional title'
```

**Links automáticos:**

```markdown
<https://example.com>
<email@example.com>
```

**AURORA convenciones:**

- Usar links relativos para documentación interna
- Especificar `alt text` descriptivo en imágenes
- Preferir reference-style para links repetidos

#### 6. Blockquotes (Citas)

```markdown
> Single line quote

> Multi-line quote
> that continues here
> and here

> Nested quotes:
>
> > Inner quote
> > Still inner
>
> Back to outer quote
```

**Uso en AURORA:**

- Disclaimers importantes
- Notas de advertencia
- Citando requisitos o especificaciones externas

#### 7. Horizontal Rules (Separadores)

```markdown
---

---

---

✅ AURORA prefiere '---' para consistencia
```

**Regla:** Línea en blanco antes y después del separador.

#### 8. Tables (Tablas - GFM Extension)

```markdown
| Header 1 | Header 2 | Header 3 |
| -------- | -------- | -------- |
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |

# Con alineación:

| Left align | Center align | Right align |
| :--------- | :----------: | ----------: |
| Text       |     Text     |        Text |
| More       |     More     |        More |

# Alineación:

| :--- | Left
| :---: | Center
| ---: | Right
```

**Mejores prácticas:**

- Alinear pipes `|` para legibilidad (pero no obligatorio)
- Incluir header row siempre
- Usar para datos tabulares, no para layout

#### 9. Escaping (Caracteres especiales)

```markdown
Use backslash \ para escapar:

\* Not italic \*
\# Not a heading
\[Not a link\](url)
\`Not code\`

Caracteres que pueden necesitar escape:
\ ` \* \_ { } [ ] ( ) # + - . ! |
```

#### 10. HTML en Markdown

**CommonMark permite HTML, pero úsalo con moderación:**

```markdown
✅ Aceptable para casos especiales:

<details>
<summary>Click to expand</summary>

Hidden content here.

</details>

<kbd>Ctrl</kbd> + <kbd>C</kbd>

❌ Evitar para contenido regular:

<p>Use Markdown syntax instead</p>
<strong>Use **Markdown** instead</strong>
```

### Mejores Prácticas

#### Práctica 1: One Sentence Per Line (Recomendado)

**Por qué:** Facilita diff/review en Git, mejor control de versiones.

**Ejemplo:**

```markdown
✅ RECOMENDADO:
This is the first sentence.
This is the second sentence.
This makes Git diffs cleaner.

❌ EVITAR:
This is the first sentence. This is the second sentence. This makes Git diffs harder to read when reviewing changes.
```

**Beneficio:** Cambios más granulares en Git, reviews más fáciles.

#### Práctica 2: Blank Lines (Líneas en blanco)

**Por qué:** Claridad y correcta interpretación del parser.

**Reglas:**

````markdown
✅ Línea en blanco ANTES Y DESPUÉS de:

- Headings
- Code blocks
- Lists
- Blockquotes
- Horizontal rules
- Tables

# Heading

Paragraph text.

````code
block
\```

- List item
- Another item

---

> Blockquote
`````

`````

**Excepciones:**

- Entre items de listas consecutivas
- Dentro de blockquotes multi-línea

#### Práctica 3: Trailing Whitespace (Espacios al final)

**Por qué:** Pueden causar hard line breaks no intencionados.

```markdown
❌ EVITAR espacios al final:
This line has trailing spaces.
This creates a hard break.

✅ PREFERIR:
Use explicit <br> if you need line break.<br>
Or just use paragraph breaks.

O simplemente usa párrafos separados.
```

**AURORA:** Configurar editor para eliminar trailing whitespace automáticamente.

#### Práctica 4: Consistent Style (Estilo consistente)

**Convenciones AURORA:**

````markdown
✅ Preferir:

- ATX headings (#) sobre Setext (===)
- Fenced code blocks (```) sobre indented
- Asteriscos (\*) para emphasis
- Guiones (-) para unordered lists
- 2 espacios para indentación de listas
- '---' para horizontal rules

❌ Evitar mezclar:

# Heading 1

## Heading 2

_italic_ and _italic_ mixed

- bullet and \* bullet mixed
`````

#### Práctica 5: Link References al Final

**Por qué:** Mantiene el contenido legible, links centralizados.

```markdown
✅ ESTRUCTURA RECOMENDADA:

# Document Title

Content with [link 1][ref1] and [link 2][ref2].

More content with [link 3][ref3].

## References

[ref1]: https://example.com/page1
[ref2]: https://example.com/page2
[ref3]: https://example.com/page3
```

#### Práctica 6: Descriptive Link Text

```markdown
❌ EVITAR:
Click [here](url) for more info.
See [this link](url).

✅ USAR:
Read the [CommonMark specification](url) for details.
Check [GitHub's Markdown guide](url).
```

**Beneficio:** Mejor accesibilidad, SEO, y claridad.

#### Práctica 7: Semantic Line Breaks

**Por qué:** Legibilidad en source + mejores diffs.

```markdown
✅ Romper líneas en:

- Después de oraciones completas
- En comas lógicas de listas largas
- Después de conjunciones en oraciones complejas

This is a sentence.
This is another sentence with a point,
and this continues with a related idea.
```

### Linting y Validación

#### Markdownlint Rules

**Principales reglas a seguir:**

```yaml
# .markdownlint.json
{
  'MD001': true, # Heading levels increment by one
  'MD003': { 'style': 'atx' }, # ATX style headings
  'MD004': { 'style': 'dash' }, # Unordered list style
  'MD007': { 'indent': 2 }, # List indentation (2 spaces)
  'MD009': true, # No trailing spaces
  'MD010': true, # No hard tabs
  'MD012': { 'maximum': 1 }, # No multiple blank lines
  'MD013': false, # Line length (disabled for flexibility)
  'MD022': true, # Headings surrounded by blank lines
  'MD024': false, # Allow duplicate headings in different sections
  'MD025': true, # Single H1 per document
  'MD026': true, # No trailing punctuation in headings
  'MD029': { 'style': 'ordered' }, # Ordered list numbering
  'MD030': true, # Spaces after list markers
  'MD031': true, # Fenced code blocks surrounded by blanks
  'MD032': true, # Lists surrounded by blank lines
  'MD033': { 'allowed_elements': ['details', 'summary', 'kbd', 'br'] },
  'MD034': true, # No bare URLs
  'MD040': true, # Fenced code blocks should have language
  'MD041': true, # First line should be H1
  'MD046': { 'style': 'fenced' }, # Code block style
  'MD047': true, # Files should end with newline
  'MD049': { 'style': 'asterisk' }, # Emphasis style
  'MD050': { 'style': 'asterisk' }, # Strong style
}
```

#### Comandos de Validación

```bash
# Instalar markdownlint-cli
npm install -g markdownlint-cli

# Validar archivo
markdownlint document.md

# Validar todos los .md
markdownlint "**/*.md"

# Autofix (cuando posible)
markdownlint --fix document.md
```

### Errores Comunes y Soluciones

#### Error 1: Headers sin espacio después del

**Problema:**

```markdown
❌ #Heading without space
❌ ##Subheading
```

**Solución:**

```markdown
✅ # Heading with space
✅ ## Subheading
```

#### Error 2: Niveles de heading inconsecuentes

**Problema:**

```markdown
❌ # Title
❌ ### Skipped H2
```

**Solución:**

```markdown
✅ # Title
✅ ## Section
✅ ### Subsection
```

#### Error 3: Code blocks sin lenguaje

**Problema:**

```markdown
❌ `
code here
\`
```

**Solución:**

```markdown
✅ `javascript
code here
\`
```

#### Error 4: Listas sin líneas en blanco

**Problema:**

```markdown
❌ Paragraph text.

- List item
- Another item
```

**Solución:**

```markdown
✅ Paragraph text.

- List item
- Another item
```

#### Error 5: URLs desnudas (bare URLs)

**Problema:**

```markdown
❌ Visit https://example.com for more info.
```

**Solución:**

```markdown
✅ Visit <https://example.com> for more info.
✅ Visit [the documentation](https://example.com) for more info.
```

#### Error 6: Múltiples H1

**Problema:**

```markdown
❌ # First Title

# Second Title
```

**Solución:**

```markdown
✅ # Document Title
✅ ## First Section
✅ ## Second Section
```

## Ejemplos Completos

### Ejemplo 1: Feature Specification Document

**Contexto:** Crear especificación de feature para AURORA.

**Estructura recomendada:**

````markdown
---
feature-id: XXX
status: draft
---

# Feature: User Authentication

## Overview

Brief description of the feature in 2-3 sentences.
Explain the business value and target users.

## User Stories

### US-001: User Registration

**As a** new user
**I want to** create an account
**So that** I can access the platform

**Acceptance Criteria:**

- [ ] User can register with email and password
- [ ] System validates email format
- [ ] Password must meet security requirements
- [ ] Confirmation email is sent

### US-002: User Login

**As a** registered user
**I want to** log into my account
**So that** I can access protected features

**Acceptance Criteria:**

- [ ] User can login with email and password
- [ ] Invalid credentials show error message
- [ ] Successful login redirects to dashboard

## Use Cases

### UC-001: Register New User

**Actor:** Unregistered User

**Preconditions:**

- User has valid email
- User is on registration page

**Main Flow:**

1. User enters email address
2. User creates password
3. User confirms password
4. System validates inputs
5. System creates user account
6. System sends confirmation email

**Alternative Flows:**

**4a. Email already exists:**

1. System shows "Email already registered" error
2. User can choose "Forgot Password" or try different email

**4b. Password too weak:**

1. System shows password requirements
2. User creates stronger password
3. Return to step 4

## Technical Considerations

### Architecture

```typescript
// User entity
interface User {
  id: string;
  email: string;
  passwordHash: string;
  emailVerified: boolean;
  createdAt: Date;
}

// Registration DTO
interface RegisterUserDto {
  email: string;
  password: string;
}
```
````

### Security Requirements

- Passwords hashed with bcrypt (cost factor 12)
- Email verification required before access
- Rate limiting: 5 attempts per 15 minutes

## Dependencies

| Service        | Purpose                         |
| -------------- | ------------------------------- |
| EmailService   | Send verification emails        |
| AuthService    | Token generation and validation |
| UserRepository | Data persistence                |

## References

- [ADR-001: Authentication Strategy](../adrs/001-auth-strategy.md)
- [Security Guidelines](../security/guidelines.md)
- [API Specification](../api/auth-endpoints.md)

---

**Author:** Development Team
**Created:** 2026-02-13
**Last Updated:** 2026-02-13

````

### Ejemplo 2: Agent Definition (.agent.md)

```markdown
---
description: 'Create comprehensive feature specifications with user stories and acceptance criteria'
model: claude-sonnet-4
tools:
  - edit/editFiles
  - search/codebase
  - github
---

# Aurora Feature

Expert in creating detailed feature specifications following AURORA methodology.

## Mission

Transform user requirements into comprehensive feature specifications including:

- User stories with acceptance criteria
- Use cases with flows
- Technical considerations
- Dependencies and constraints

## Workflow

### 1. Gather Requirements

Ask clarifying questions to understand:

- What is the business goal?
- Who are the users?
- What problem does this solve?
- Are there existing similar features?

### 2. Create Feature Specification

Generate specification following this structure:

```markdown
# Feature: [Name]

## Overview
[2-3 sentence summary]

## User Stories
[List of user stories with acceptance criteria]

## Use Cases
[Detailed use cases with flows]

## Technical Considerations
[Architecture, dependencies, constraints]
````

### 3. Validate Specification

Ensure:

- [ ] All user stories have acceptance criteria
- [ ] Use cases cover main and alternative flows
- [ ] Technical considerations address security, performance
- [ ] Dependencies are identified

### 4. Create GitHub Issue (if requested)

Use `mcp_github_create_issue` to track the feature.

## Quality Standards

- User stories follow "As a... I want... So that..." format
- Acceptance criteria are testable and specific
- Use cases include preconditions and postconditions
- Code examples use proper syntax highlighting

## Examples

See `.github/skills/markdown-formatting/examples/feature-spec-example.md`

````

### Ejemplo 3: README.md Template

```markdown
# Project Name

Brief one-liner description of the project.

![Build Status](https://img.shields.io/badge/build-passing-brightgreen)
![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Overview

2-3 paragraph description of:
- What the project does
- Why it exists
- Key features

## Features

- ✅ Feature 1 with brief description
- ✅ Feature 2 with brief description
- ✅ Feature 3 with brief description

## Installation

```bash
# Clone the repository
git clone https://github.com/user/repo.git

# Install dependencies
npm install

# Run the project
npm start
````

## Usage

### Basic Example

```javascript
import { Library } from 'library-name';

const instance = new Library();
instance.doSomething();
```

### Advanced Example

```javascript
// More complex usage with configuration
const instance = new Library({
  option1: 'value1',
  option2: true,
});

const result = await instance.advancedFeature();
```

## Configuration

| Option    | Type      | Default     | Description        |
| --------- | --------- | ----------- | ------------------ |
| `option1` | `string`  | `'default'` | Controls feature X |
| `option2` | `boolean` | `false`     | Enables feature Y  |

## Development

### Prerequisites

- Node.js >= 18.x
- npm >= 9.x

### Setup

```bash
# Install dev dependencies
npm install --dev

# Run tests
npm test

# Build
npm run build
```

### Project Structure

```
project/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
└── dist/          # Build output
```

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm test -- --coverage

# Run specific test
npm test -- auth.test.ts
```

## License

[MIT](LICENSE) © [Author Name]

## Acknowledgments

- [Dependency 1](https://example.com) - Purpose
- [Dependency 2](https://example.com) - Purpose

## Support

- 📧 Email: support@example.com
- 💬 Discussions: [GitHub Discussions](https://github.com/user/repo/discussions)
- 🐛 Issues: [GitHub Issues](https://github.com/user/repo/issues)

---

**Maintained by:** [Team/Person Name]
**Last Updated:** 2026-02-13

```

## Criterios de Calidad

Al usar este skill, verifica que el documento cumpla:

- [ ] Un solo H1 (título principal) al inicio del documento
- [ ] Jerarquía de headings correcta (no saltar niveles)
- [ ] Todos los code blocks tienen lenguaje especificado
- [ ] Listas tienen líneas en blanco antes/después
- [ ] No hay trailing whitespace
- [ ] Tables tienen header row y alineación correcta
- [ ] Links tienen texto descriptivo (no "click here")
- [ ] Imágenes tienen alt text
- [ ] Frontmatter YAML válido (si aplica)
- [ ] Documento termina con newline
- [ ] Pasa validación markdownlint

## Integración con AURORA

### Fase INCEPTION

**Documentos comunes:**
- `memory/constitution.md` - Project DNA
- `README.md` - Project overview
- `docs/vision.md` - Vision document

**Formato crítico:**
- Usar H1 para título del proyecto
- Sección de tech stack con tabla
- Code examples con lenguaje

### Fase DISCOVERY

**Documentos comunes:**
- `specs/XXX-feature-name/feature.md` - Feature specs
- `specs/XXX-feature-name/requirements/*.md` - Requirements
- ADRs (Architecture Decision Records)

**Formato crítico:**
- Frontmatter con metadata
- User stories estructuradas
- Tables para comparaciones
- Code blocks para ejemplos técnicos

### Fase CONSTRUCTION

**Documentos comunes:**
- `specs/XXX-feature-name/planning/*.md` - Implementation plans
- `.github/agents/*.agent.md` - Agent definitions
- `.github/prompts/*.prompt.md` - Prompts
- API documentation

**Formato crítico:**
- Code blocks con syntax highlighting
- Task lists para planificación
- Tables para endpoints/schemas
- Proper linking entre documentos

### Fase TRANSITION

**Documentos comunes:**
- `CHANGELOG.md` - Version history
- `docs/deployment.md` - Deployment guides
- Release notes

**Formato crítico:**
- Ordered lists para procedimientos
- Code blocks para comandos
- Tables para configuration options

### Fase PRODUCTION

**Documentos comunes:**
- `docs/troubleshooting.md` - Problem solving
- `docs/monitoring.md` - Observability guides
- Runbooks

**Formato crítico:**
- Blockquotes para warnings
- Code blocks para logs/output
- Tables para metrics

## Referencias

### Especificaciones y Estándares

- [CommonMark Specification](https://spec.commonmark.org/) - Definitive Markdown spec
- [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/) - GitHub extensions
- [Markdown Guide](https://www.markdownguide.org/) - Comprehensive guide

### Herramientas

- [markdownlint](https://github.com/DavidAnson/markdownlint) - Linter
- [markdown-it](https://markdown-it.github.io/) - Parser following CommonMark
- [Prettier](https://prettier.io/) - Code formatter (supports Markdown)
- [remark](https://remark.js.org/) - Markdown processor

### VS Code Extensions

- `DavidAnson.vscode-markdownlint` - Linting
- `yzhang.markdown-all-in-one` - All-in-one Markdown support
- `bierner.markdown-mermaid` - Mermaid diagram support

### Skills Relacionados

- Skill: `new-skill` - Cómo crear skills (usa Markdown)
- Skill: `bolt-framework` - AURORA methodology (documentación en Markdown)

### Archivos del Proyecto AURORA

- [Constitution Template](../../templates/constitution.md)
- [Feature Spec Template](../../templates/feature-spec.md)
- [ADR Template](../../templates/adr.md)

## Notas Adicionales

### Consideraciones de Accesibilidad

- Usar headings para estructura semántica (no solo para tamaño)
- Texto alternativo descriptivo en imágenes
- Link text descriptivo (no "click here")
- Tables con headers claros
- Evitar solo color para transmitir información

### Consideraciones de Internacionalización

- Usar Reference-style links para facilitar traducción
- Evitar texto en imágenes (dificulta traducción)
- Usar palabras completas, no abreviaciones ambiguas
- Considerar RTL (right-to-left) languages en tables

### Mantenimiento

- Revisar links rotos periódicamente
- Actualizar ejemplos de código cuando cambie tech stack
- Mantener consistencia cuando evoluciona el estándar
- Re-validar con markdownlint después de cambios grandes

## Changelog

- **2026-02-13** - v1.0.0 - Versión inicial
  - CommonMark specification compliance
  - AURORA-specific conventions
  - Markdownlint integration
  - Examples for all document types

---

**Autor**: AURORA AI Development Team
**Versión**: 1.0.0
**Última actualización**: 2026-02-13
**Revisado por**: GitHub Copilot + new-skill skill
```
