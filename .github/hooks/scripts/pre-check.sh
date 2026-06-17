#!/bin/bash

allow() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

deny() {
  jq -n --arg reason "$1" --arg context "$2" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason,
      additionalContext: $context
    }
  }'
  exit 1
}

# Check a single file. Sets DENY_REASON/DENY_CONTEXT and returns 1 on failure.
DENY_REASON=""
DENY_CONTEXT=""
check_file() {
  local file="$1"
  local ext="${file##*.}"

  # --- C# ---
  if [[ "$ext" =~ ^(cs)$ ]]; then
    [[ "$TOOL_NAME" == "create_file" ]] && return 0
    [ ! -f "$file" ] && { DENY_REASON="⚠️ File not found: $file"; DENY_CONTEXT=""; return 1; }

    local proj
    proj=$(find "$(dirname "$file")" -maxdepth 6 -name "*.csproj" 2>/dev/null | head -1)
    [ -z "$proj" ] && return 0

    if dotnet format "$proj" --include "$file" --verify-no-changes > /dev/null 2>&1; then
      return 0
    else
      DENY_REASON="❌ Format issues detected in $file"
      DENY_CONTEXT="Run: dotnet format $(basename "$proj") --include $file"
      return 1
    fi
  fi

  # --- TypeScript ---
  if [[ "$ext" =~ ^(ts|tsx)$ ]]; then
    [ ! -f "$file" ] && return 0

    if npx eslint "$file" --max-warnings 0 > /dev/null 2>&1; then
      return 0
    else
      DENY_REASON="❌ ESLint issues detected in $file"
      DENY_CONTEXT="Run: npx eslint $file --fix"
      return 1
    fi
  fi

  # --- Markdown / YAML / JSON ---
  if [[ "$ext" =~ ^(md|yaml|yml|json)$ ]]; then
    [[ "$TOOL_NAME" == "create_file" ]] && return 0
    [ ! -f "$file" ] && return 0

    if npx prettier "$file" --check > /dev/null 2>&1; then
      return 0
    else
      DENY_REASON="❌ Prettier issues detected in $file"
      DENY_CONTEXT="Run: npx prettier $file --write"
      return 1
    fi
  fi

  return 0  # Not a linted file type
}

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

# Only for writing tools
[[ "$TOOL_NAME" =~ ^(replace_string_in_file|multi_replace_string_in_file|create_file)$ ]] \
  || allow "⏭️ Read-only tool"

# Build the list of files to check.
# multi_replace_string_in_file carries an array — iterate over all unique paths.
if [ "$TOOL_NAME" = "multi_replace_string_in_file" ]; then
  mapfile -t FILES < <(echo "$INPUT" | jq -r '.tool_input.replacements[].filePath // empty' | sort -u)
else
  SINGLE_FILE=$(echo "$INPUT" | jq -r '.tool_input.filePath // empty')
  [ -z "$SINGLE_FILE" ] && allow "⏭️ No filePath"
  FILES=("$SINGLE_FILE")
fi

[ "${#FILES[@]}" -eq 0 ] && allow "⏭️ No filePaths"

# Check every file — deny on first failure
for FILE in "${FILES[@]}"; do
  [ -z "$FILE" ] && continue
  if ! check_file "$FILE"; then
    deny "$DENY_REASON" "$DENY_CONTEXT"
  fi
done

allow "✅ All files passed"
