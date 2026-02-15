# Scopes packaging

Este directorio define qué artefactos se pueden copiar al proyecto destino por scope.

## Tipos de elementos soportados

- `templates`
- `agents`
- `prompts`
- `instructions`
- `skills`

## Archivo de configuración

Cada scope debe incluir un `scope.yaml` con entradas en `items`.

Campos recomendados por item:

- `id`: identificador único dentro del scope.
- `kind`: uno de `templates|agents|prompts|instructions|skills`.
- `enabled`: `true|false`.
- `source`: definición de origen.
  - `type`: `local_file|local_folder|web|git_repo|context7|awesome_copilot`
  - según `type`, usar:
    - `path` (local)
    - `url` (web)
    - `repo` y opcional `ref`/`subpath` (git)
    - `library` + `query` (context7)
    - `collection` + `item_path` (awesome_copilot)
  - opcional:
    - `title` (nombre humano del recurso)
    - `notes` (contexto de por qué incluirlo)
- `destination`: destino en el proyecto generado.
  - `folder`: ruta de carpeta destino (ej. `.github/instructions`)
  - `name`: nombre final de fichero/carpeta en destino.

## Reglas

- No copiar skills de `.aurora/available-skills` salvo decisión de inicialización o del agente Bolt Framework.
- Las rutas locales se resuelven relativas a `.aurora/`.
- Un item puede quedar `enabled: false` para dejarlo documentado sin aplicarlo.
