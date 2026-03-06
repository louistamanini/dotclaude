Fix a bug from diagnosis to commit. Argument: bug description, error message, or stack trace.

## Process

### Step 1 — Source the bug

Detect the input type from the argument:

**If the argument is an error message or stack trace:**
- Parse the error: extract the error type, message, file paths, and line numbers
- Display a summary of what went wrong and where
- Ask: "Is this the right bug? Anything to add before I dig in?"

**If the argument is a text description:**
- If the description is vague, ask targeted questions:
  - What is the expected vs actual behavior?
  - How to reproduce?
  - When did it start happening (recent change, always broken)?
- If the description is clear enough, confirm understanding and move on

**If no argument:** ask the user what bug they want to fix.

Do NOT start diagnosing until the bug is confirmed.

### Step 2 — Diagnose

- Follow the clues from Step 1 (file paths, error messages, stack trace) to locate the root cause
- Read the relevant code and understand the logic around the bug
- Identify WHY the bug happens, not just WHERE
- Present the root cause to the user in 2-3 sentences and ask for confirmation before fixing

Do NOT start fixing until the diagnosis is confirmed.

### Step 3 — Fix

Implement the minimal fix that addresses the root cause. Follow existing conventions (naming, structure, imports). If the fix reveals unexpected complexity, stop and inform the user.

### Step 4 — Scan for similar occurrences

Search the codebase for the same pattern that caused the bug:
- Look for similar code paths, copy-pasted logic, or shared utilities that could have the same issue
- If similar occurrences are found, list them and ask: "These locations have a similar pattern — should I fix them too?"
- If the user says yes, fix them. If no, move on.

### Step 5 — Regression test [ask here]

Ask: "Do you want a regression test covering this bug?"

If yes:
- Write a focused test that reproduces the original bug scenario and verifies the fix
- The test should fail without the fix and pass with it
- Follow the project's existing test conventions (framework, file location, naming)

### Step 6 — Verify

Read and follow `~/.claude/commands/verify.md` to run all available checks and fix failures.

### Step 7 — Commit

Read and follow `~/.claude/commands/commit.md`.

## Rules

- Never fix before the diagnosis is confirmed (Step 2)
- Keep fixes minimal — do not refactor surrounding code or "improve while you're at it"
- If the root cause is unclear after exploration, say so — do not guess
- If similar occurrences are found (Step 4), always present them before fixing — never silently fix code the user didn't ask about

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
