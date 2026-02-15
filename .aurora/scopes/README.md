# Scopes packaging

Este directorio define qué artefactos se pueden copiar al proyecto destino por scope.

## Tipos de elementos soportados

- `templates`
- `agents`
- `prompts`
- `instructions`
- `skills`

## Convención `mcp-tools`

Cada scope puede incluir una carpeta `mcp-tools/` con uno o varios JSON de configuración MCP.

Para aplicar uno de estos JSON al proyecto destino, añade un `item` en `scope.yaml` con:

- `source.type: local_file`
- `source.path: scopes/<scope>/mcp-tools/<archivo>.json`
- `destination.folder: .vscode`
- `destination.name: settings.json`

Esto permite versionar presets MCP por scope y proyectarlos en `.vscode/settings.json` del proyecto generado.

## Archivo de configuración

Cada scope debe incluir un `scope.yaml` con entradas en `items`.

Campos recomendados por item:

- `id`: identificador único dentro del scope.
- `kind`: uno de `templates|agents|prompts|instructions|skills`.
- `enabled`: `true|false`.
- `tags`: array opcional de etiquetas para búsqueda (`0..3` elementos).
  - Recomendación: usar `1..3` etiquetas concretas por item.
  - Evitar etiquetas redundantes con el scope (ej.: en `backend` no hace falta `backend`).
  - Si el item es de `csharp/.net/aspnet`, incluir etiqueta `csharp`.
  - Si el item es de `node/nodejs/nestjs/express/fastify`, incluir etiqueta `nodejs`.
- `source`: definición de origen.
  - `type`: `local_file|local_folder|web|git_repo|context7|awesome_copilot|awesome_skills`
  - según `type`, usar:
    - `path` (local)
    - `url` (web)
    - `repo` y opcional `ref`/`subpath` (git)
    - `library` + `query` (context7)
    - `collection` + `item_path` (awesome_copilot)
    - `catalog_url` + `repository` y opcional `skill_path|plugin|listing_url` (awesome_skills)
  - opcional:
    - `title` (nombre humano del recurso)
    - `notes` (contexto de por qué incluirlo)
  - para fuentes externas (`web|git_repo|context7|awesome_copilot|awesome_skills`) se recomienda incluir metadatos de resolución:
    - `resolved_url`: URL final resuelta usada para descarga.
    - `resolved_ref`: versión/ref concreta (tag/commit/doc-version).
    - `resolved_doc_id`: identificador estable de documento (especialmente útil en `context7`).
    - `content_hash`: hash del contenido descargado (por ejemplo, `sha256:<hex>`).
    - `fetched_at`: fecha/hora de resolución en formato ISO-8601 UTC.
    - `license`: licencia o referencia corta de uso del recurso.
- `destination`: destino en el proyecto generado.
  - `folder`: ruta de carpeta destino (ej. `.github/instructions`)
  - `name`: nombre final de fichero/carpeta en destino.

## Reglas

- No copiar skills de `.aurora/available-skills` salvo decisión de inicialización o del agente Bolt Framework.
- Las rutas locales se resuelven relativas a `.aurora/`.
- Un item puede quedar `enabled: false` para dejarlo documentado sin aplicarlo.

## Reglas mínimas de validación recomendadas

- `source.type=awesome_skills` requiere `catalog_url` y `repository`.
- `tags`, si existe, debe ser array de máximo 3 elementos.
- Items relacionados con C# o Node.js deben incluir `csharp` o `nodejs` respectivamente.
