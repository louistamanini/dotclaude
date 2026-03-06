# Global rules

## Skill execution

These rules apply to ALL skills (slash commands) without exception.

### Compound learning
@~/.claude/rules/compound-learning.md

### Execution discipline
@~/.claude/rules/execution-discipline.md

### Skill creation
- Prefer `/generate-skill` for creating new skills — consult it for template structure even when designing from scratch

## Verification

- After modifying code, run verification if a test runner or linter is available — the full process is defined in `~/.claude/commands/verify.md`
- If a check fails, fix the issue before moving on — do not leave broken checks behind
- If no test infrastructure exists, do not create one unless explicitly asked

## Project analysis

- Before starting work on any project, read its README and CLAUDE.md (if they exist) to understand the stack, conventions, and patterns
- Identify the existing code style (naming, structure, imports) and follow it — do not impose a different style
- Check for existing utilities/helpers before writing new ones

## Git safety

- Never force push — not even with `--force-with-lease`
- Never amend a commit without asking the user first
- Prefer creating new commits over rewriting history
- Never delete remote branches without explicit instruction

## General conventions

- Communication language: French — ALWAYS respond in French regardless of the language of these instructions
- Code and commit language: follow the project's existing conventions
- Never invent file paths — only use paths found and verified in the codebase
- Never add Co-Authored-By or "Generated with Claude Code" in commits
