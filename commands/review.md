Adversarial code review on current changes. Optional argument: comparison branch or specific file(s).

## Process

### Step 1 — Determine the review scope

In priority order:
1. If an argument is provided (branch, file, or commit range), use it as scope
2. Otherwise, check for staged changes (`git diff --staged --stat`)
3. Otherwise, check for unstaged changes (`git diff --stat`)
4. Otherwise, compare the last commit with its parent (`git diff HEAD~1 --stat`)
5. If none of the above, ask which scope to analyze

**Mixed state warning**: If both staged and unstaged changes exist and no argument was provided, inform the user: "You have both staged and unstaged changes. Reviewing staged only. Run `/review` with no staged changes to review everything, or pass a specific scope."

Display the detected scope and number of files involved before continuing.

### Step 2 — Quick pre-analysis

Before launching the full review:
- List modified files with `git diff --stat` (on the chosen scope)
- Identify the types of changes: new file, modification, deletion, rename
- If more than 15 files are modified:
  - Group files by top-level directory (e.g., `src/auth/`, `src/api/`, `tests/`)
  - Show the breakdown: "15+ files detected — split by folder? [auth (4 files), api (6 files), tests (5 files)]"
  - If the user accepts, run one reviewer agent per group sequentially
  - If the user declines, proceed with a single review but warn about potential quality loss on large diffs

### Step 3 — Launch the reviewer agent

Spawn the `reviewer` agent with instructions including:
- The exact scope to analyze (the git diff command to use)
- The project context if a CLAUDE.md exists (conventions, patterns)
- A mandatory security pass covering at minimum:
  - Injection vectors (SQL, command, XSS, template injection)
  - Authentication and authorization flaws (missing auth checks, IDOR)
  - Secrets and credentials hardcoded in source
  - Unsafe deserialization or file operations
  - Exposed sensitive data in logs, errors, or API responses

Let the agent complete its full analysis without interruption.

### Step 4 — Sanity-check before presenting

Before relaying the agent's verdict, apply these filters on each IMPORTANT/CRITICAL finding:

- **Intentional degradation vs bug**: error-handling paths (`failed()`, `catch`, fallback) are often designed to degrade gracefully on purpose. If the reviewer flags such a path, check the calling code to verify whether the behavior is intentional before presenting it as a bug.
- **Frequency/volume dependency**: if an issue is only serious under repeated calls (accumulation, loops, performance), ask the user about real-world usage frequency before declaring a blocker. Do not assume worst case.

Downgrade or dismiss findings that do not survive these filters. Mention dismissed findings as non-blocking observations if relevant.

### Step 5 — Synthesis and actions

Based on the reviewer agent's report **after sanity-check**, propose concrete actions:

If **SHIP IT**:
- "Code is solid. Want me to run /commit?"

If **NEEDS WORK**:
- For each CRITICAL or IMPORTANT issue, propose: "Want me to fix [issue] in `file:line`?"
- Group fixes by file for efficient application
- After fixes, offer to re-run the review to verify

If **BLOCK**:
- Clearly explain why it is blocked
- Propose a correction plan ordered by priority
- Do NOT offer to commit while blockers remain unresolved

### Step 6 — Correction loop (if applicable)

If the user accepts corrections:
1. Apply corrections one by one
2. After all corrections, re-run the reviewer agent on the modified files
3. Repeat until SHIP IT or the user decides to stop

## Rules

### Review quality
- NEVER launch the review without showing the scope to the user first. No surprises.
- The reviewer agent is read-only — YOU (the skill) apply corrections if requested, not the agent.
- Never fix an issue without the user's explicit agreement. Show first, fix second.
- If the reviewer agent flags an obvious false positive, mention it as such rather than silently discarding it.

### Verification loop
- After corrections, ALWAYS re-run a review. This is the feedback loop — a correction can introduce a new issue.
- Do NOT run verify inside the review loop — the caller (e.g., /feature Step 7) handles verification separately to avoid double runs.

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
