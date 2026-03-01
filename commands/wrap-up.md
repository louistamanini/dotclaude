End-of-session compound ritual: synthesize all learnings from the session into durable project and global rules. Run this before closing a work session.

## Process

### Step 1 — Gather session activity

Collect everything that happened in this session:
- Run `git log --oneline` and identify all commits made during this session (today's date, current branch)
- Run `git diff` on those commits to see the full scope of changes
- Mentally replay the conversation: what was asked, what was corrected, what was pivoted

### Step 2 — Identify patterns

Look for reusable learnings across the session. Specifically:

- **Repeated corrections**: the same type of fix applied more than once (e.g., "forgot to handle null", "wrong import path pattern")
- **User preferences expressed**: explicit or implicit choices the user made consistently (e.g., always chose Option A over B, preferred a certain naming style)
- **Conventions discovered**: project patterns that were not documented but became clear during work (e.g., "all API routes use kebab-case", "components are co-located with their tests")
- **Pitfalls encountered**: things that broke unexpectedly or took multiple attempts to get right
- **Tool/workflow patterns**: specific tools, commands, or approaches that worked well or poorly

### Step 3 — Deduplicate against existing rules

For each pattern found:
1. Read the project's CLAUDE.md (if it exists)
2. Read the global ~/.claude/CLAUDE.md
3. Check if this pattern is already documented — if yes, skip it
4. Check if it contradicts an existing rule — if yes, flag the conflict for the user to resolve

### Step 4 — Propose updates

Present all proposed changes grouped by target:

**Project CLAUDE.md** (conventions specific to this codebase):
- List each proposed rule with a one-line rationale

**Global CLAUDE.md** (preferences that apply everywhere):
- List each proposed rule with a one-line rationale

**Skill files** (workflow improvements):
- List each proposed change with the target skill file

Format each proposal as:
```
[target] + "rule text" — because [rationale from this session]
```

### Step 5 — Apply with approval

- Ask the user to approve, modify, or reject each group
- Apply approved changes immediately using Edit
- For CLAUDE.md additions, follow the existing structure and section organization — do not create new sections unless necessary
- For skill file changes, follow the skill's existing format

### Step 6 — Summary

Display a compact summary:
```
Session compound complete:
- X rules added to project CLAUDE.md
- Y rules added to global CLAUDE.md
- Z skill improvements applied
```

## Rules

- Never add a rule that duplicates an existing one — always check first
- Never add vague or overly broad rules (e.g., "write good code") — rules must be specific and actionable
- Never modify CLAUDE.md or skill files without explicit user approval
- If no learnings were found, say so honestly — do not invent rules to justify the ritual
- Keep rules concise: one line per rule, imperative form, no fluff
- Prefer updating an existing rule over adding a new one when the intent overlaps

_Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
