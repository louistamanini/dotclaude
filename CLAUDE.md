# Global rules

## Skill execution

These rules apply to ALL skills (slash commands) without exception.

### Self-improvement
- During skill execution, if the user interrupts the process to change, correct, or redirect something (e.g., "actually do X instead", "wait, skip that", "add this step"), flag it at the END of the skill execution
- At the end, ask: "During this run, I noticed you [describe the deviation]. Want me to update the skill to account for this? If yes, I'll ask a few questions to clarify the change."
- If the user agrees, ask targeted questions to determine:
  - Should this be a new step, a modified step, or a conditional branch?
  - Is this change always applicable or only in certain situations?
  - Where in the process should it go?
- Then update the skill file in place

### Execution discipline
- Follow the steps IN ORDER — do not skip or reorder unless the user explicitly asks
- If a step fails or is blocked, STOP and ask the user — do not silently skip
- If unsure about a decision within a step, ask rather than guess

## Verification

- After modifying code, run existing tests if a test runner is available (detect via package.json scripts, Makefile, etc.)
- If a test fails, fix the issue before moving on — do not leave broken tests behind
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
