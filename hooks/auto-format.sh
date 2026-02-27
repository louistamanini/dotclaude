#!/bin/bash
# Auto-format hook — formats the file after each Write/Edit
# Used by the PostToolUse hook on Write and Edit
#
# Detects file type and applies the appropriate formatter
# Does nothing if the formatter is not installed

# Get the file path from the tool input
FILE=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.file_path // empty')

if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Find the project root (walk up until package.json or composer.json)
PROJECT_DIR="$FILE"
while [ "$PROJECT_DIR" != "/" ]; do
  PROJECT_DIR=$(dirname "$PROJECT_DIR")
  if [ -f "$PROJECT_DIR/package.json" ] || [ -f "$PROJECT_DIR/composer.json" ]; then
    break
  fi
done

if [ "$PROJECT_DIR" = "/" ]; then
  exit 0
fi

# Determine the file extension
EXT="${FILE##*.}"

case "$EXT" in
  # JavaScript / TypeScript / JSX / TSX / CSS / JSON / HTML / Vue / Svelte
  js|jsx|ts|tsx|css|scss|json|html|vue|svelte)
    if [ -f "$PROJECT_DIR/node_modules/.bin/biome" ]; then
      "$PROJECT_DIR/node_modules/.bin/biome" format --write "$FILE" 2>/dev/null
    elif command -v biome &>/dev/null && [ -f "$PROJECT_DIR/biome.json" -o -f "$PROJECT_DIR/biome.jsonc" ]; then
      biome format --write "$FILE" 2>/dev/null
    elif [ -f "$PROJECT_DIR/node_modules/.bin/prettier" ]; then
      "$PROJECT_DIR/node_modules/.bin/prettier" --write "$FILE" 2>/dev/null
    elif command -v prettier &>/dev/null; then
      prettier --write "$FILE" 2>/dev/null
    fi
    ;;

  # PHP
  php)
    if [ -f "$PROJECT_DIR/vendor/bin/pint" ]; then
      "$PROJECT_DIR/vendor/bin/pint" "$FILE" 2>/dev/null
    elif [ -f "$PROJECT_DIR/vendor/bin/php-cs-fixer" ]; then
      "$PROJECT_DIR/vendor/bin/php-cs-fixer" fix "$FILE" --quiet 2>/dev/null
    fi
    ;;

  # Blade templates
  blade.php)
    if [ -f "$PROJECT_DIR/node_modules/.bin/blade-formatter" ]; then
      "$PROJECT_DIR/node_modules/.bin/blade-formatter" --write "$FILE" 2>/dev/null
    fi
    ;;

  # Python
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$FILE" 2>/dev/null
    elif command -v black &>/dev/null; then
      black --quiet "$FILE" 2>/dev/null
    fi
    ;;

  # Go
  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE" 2>/dev/null
    fi
    ;;

  # Rust
  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE" 2>/dev/null
    fi
    ;;
esac

# Always exit 0 — formatting must never block the workflow
exit 0
