# Global rules

## Skill execution

These rules apply to ALL skills (slash commands) without exception.

### Compound learning

After every skill execution, before returning control to the user, run this micro-compound pass:

1. **Detect learnings** — scan what happened during this skill for:
   - User interruptions: the user changed, corrected, or redirected something mid-execution
   - Self-corrections: Claude detected and fixed its own mistake without user intervention
   - Discovered conventions: code style, naming, structure, or patterns specific to the project
   - Workflow preferences: how the user likes to work (e.g., "always run tests first", "prefers small commits")
2. **Filter** — keep only what is a reusable PATTERN, discard what is specific to this one instance
3. **Classify each pattern** by where it belongs:
   - **Skill improvement** → the skill file itself should be updated (new step, modified step, conditional branch)
   - **Project rule** → the project's CLAUDE.md should gain a convention or guard-rail
   - **Global rule** → the global ~/.claude/CLAUDE.md should gain a preference or convention
4. **Propose** — show a compact summary: "Compound: X learnings detected — [list]. Apply?"
   - If nothing was detected, skip silently — no noise
   - If the user approves, apply changes immediately
   - If the user declines, move on without insisting
5. **For skill improvements specifically**, ask targeted questions:
   - Should this be a new step, a modified step, or a conditional branch?
   - Is this change always applicable or only in certain situations?
   - Where in the process should it go?
   - Then update the skill file in place

### Execution discipline
- Follow the steps IN ORDER — do not skip or reorder unless the user explicitly asks
- If a step fails or is blocked, STOP and ask the user — do not silently skip
- If unsure about a decision within a step, ask rather than guess

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
