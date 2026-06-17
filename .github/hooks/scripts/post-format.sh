#!/bin/bash

allow() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Format a single file. Always succeeds (post-hook never blocks).
format_file() {
  local file="$1"
  local ext="${file##*.}"

  [ ! -f "$file" ] && return 0

  # --- TypeScript ---
  if [[ "$ext" =~ ^(ts|tsx)$ ]]; then
    if ! ESLINT_OUT=$(npx eslint "$file" --fix 2>&1); then
      echo "⚠️ eslint --fix had issues on $file: $ESLINT_OUT" >&2
    fi
    return 0
  fi

  # --- Markdown / YAML / JSON ---
  if [[ "$ext" =~ ^(md|yaml|yml|json)$ ]]; then
    if ! PRETTIER_OUT=$(npx prettier "$file" --write 2>&1); then
      echo "⚠️ prettier had issues on $file: $PRETTIER_OUT" >&2
    fi
    return 0
  fi
}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only for writing tools
[[ "$TOOL_NAME" =~ ^(replace_string_in_file|multi_replace_string_in_file|create_file)$ ]] \
  || allow "⏭️ Read-only tool"

# Build the list of files to format.
# multi_replace_string_in_file carries an array — iterate over all unique paths.
if [ "$TOOL_NAME" = "multi_replace_string_in_file" ]; then
  mapfile -t FILES < <(echo "$INPUT" | jq -r '.tool_input.replacements[].filePath // empty' | sort -u)
else
  SINGLE_FILE=$(echo "$INPUT" | jq -r '.tool_input.filePath // empty')
  [ -z "$SINGLE_FILE" ] && allow "⏭️ No filePath"
  FILES=("$SINGLE_FILE")
fi

[ "${#FILES[@]}" -eq 0 ] && allow "⏭️ No filePaths"

for FILE in "${FILES[@]}"; do
  [ -z "$FILE" ] && continue
  format_file "$FILE"
done

allow "✨ Post-format complete"
