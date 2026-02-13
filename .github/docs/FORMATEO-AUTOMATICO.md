# Configuración de Formateo Automático - AURORA

Configuración completada el 2026-02-13 para formateo automático de Markdown y otros archivos.

## ✅ Extensiones Instaladas

- **Prettier** (`esbenp.prettier-vscode`) - Formateo automático
- **Markdownlint** (`davidanson.vscode-markdownlint`) - Validación y linting
- **Markdown All in One** (`yzhang.markdown-all-in-one`) - Suite completa
- **Markdown Mermaid** (`bierner.markdown-mermaid`) - Diagramas

## 🎯 Uso Diario

### Formateo Automático al Guardar

**Ya está configurado** ✅ - Solo guarda el archivo con `Ctrl+S` y se formateará automáticamente.

### Formateo Manual

| Acción                       | Atajo                      |
| ---------------------------- | -------------------------- |
| Formatear documento completo | `Shift+Alt+F`              |
| Formatear selección          | `Ctrl+K Ctrl+F`            |
| Fix markdownlint issues      | `Ctrl+Shift+P` → "Fix all" |
| Preview Markdown             | `Ctrl+Shift+V`             |
| Preview lado a lado          | `Ctrl+K V`                 |

### Comandos de Terminal

```powershell
# Formatear archivo específico
npx prettier --write archivo.md

# Formatear todos los markdown
npx prettier --write "**/*.md"

# Validar sin modificar
npx prettier --check "**/*.md"

# Markdownlint fix
npx markdownlint --fix "**/*.md"
```

## ⚙️ Configuración Aplicada

### `.vscode/settings.json`

- ✅ Formateo automático al guardar (solo Markdown)
- ✅ Word wrap activado
- ✅ Rulers en columnas 80 y 100
- ✅ Trim trailing whitespace
- ✅ Insert final newline
- ✅ Markdownlint con reglas AURORA

### `.prettierrc.json`

- ✅ Print width: 100 caracteres
- ✅ 2 espacios de indentación
- ✅ LF line endings
- ✅ Configuración específica por tipo de archivo

## 🔧 Personalización

### Cambiar Ancho de Línea

Edita `.prettierrc.json`:

```json
{
  "printWidth": 100 // Cambiar de 80 a 100
}
```

### Deshabilitar Format-on-Save

Edita `.vscode/settings.json`:

```json
"[markdown]": {
  "editor.formatOnSave": false  // Cambiar a false
}
```

### Usar Markdownlint en lugar de Prettier

```json
"[markdown]": {
  "editor.defaultFormatter": "DavidAnson.vscode-markdownlint"
}
```

## 📋 Reglas Markdownlint Activas

Ver configuración completa en:
`.github/skills/markdown-formatting/.markdownlint.json`

Principales reglas:

- ✅ Un solo H1 por documento
- ✅ ATX headings style (`#`)
- ✅ Fenced code blocks con lenguaje
- ✅ Sin trailing whitespace
- ✅ Listas con blank lines
- ❌ Line length (deshabilitado para flexibilidad)

## 🚀 Probarlo

1. Abre cualquier archivo `.md`
2. Escribe contenido sin formato correcto
3. Guarda con `Ctrl+S`
4. ¡Debería formatearse automáticamente!

## 🐛 Troubleshooting

### "El formateo no funciona"

1. Verifica que Prettier esté instalado: `code --list-extensions | grep prettier`
2. Verifica que sea el formatter por defecto: Check status bar (bottom right)
3. Recarga VS Code: `Ctrl+Shift+P` → "Reload Window"

### "Conflictos entre Prettier y Markdownlint"

Prettier formatea, Markdownlint valida. No deberían entrar en conflicto si usas la configuración de este proyecto.

### "Format on save no funciona"

Verifica en `.vscode/settings.json`:

```json
"[markdown]": {
  "editor.formatOnSave": true
}
```

## 📚 Referencias

- [Prettier Documentation](https://prettier.io/docs/en/)
- [Markdownlint Rules](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

---

**Configurado por**: AURORA AI Assistant
**Fecha**: 2026-02-13
**Skill**: [markdown-formatting](.github/skills/markdown-formatting/)
