Commit current changes, optionally push. Argument: optional — append "push" to also push after committing (e.g., `/commit push`). Default: commit only, no push.

## Process

### Step 1 — Analyze commit style
- Run `git log --oneline -20` to see the existing commit style
- Analyze the pattern: language, format, prefixes, casing, with or without scope
- Follow the exact same style for your commit

If no clear pattern is detectable:
- Use conventional commits WITHOUT scope parentheses
- `feat:` description
- `fix:` description
- `refactor:` description
- `chore:` description
- `docs:` description

### Step 2 — Commit
- `git add` relevant files + `git commit -m "message"`

### Step 3 — Push [CONDITIONAL]
If the argument contains "push":
- Run `git push`
- Report the result (success or error)

If no "push" argument: do NOT push. Stop after committing.

## Rules
- ONE single line, never a description/body after
- NEVER Co-Authored-By
- NEVER "Generated with Claude Code"
- NEVER a footer
- NEVER push unless the user explicitly passes "push" as argument

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
