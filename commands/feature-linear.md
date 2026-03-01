Implement a feature from A to Z starting from an existing Linear issue: fetch the spec, plan, implement, simplify, review, optionally test and Playwright-audit, commit, then update the Linear issue. Argument: Linear issue ID (e.g. FLO-42) or URL.

## Process

### Step 1 — Fetch the Linear issue

- Extract the issue ID from the argument
- Use Linear MCP `get_issue` to fetch the full issue: title, description, comments, labels, assignee, status
- Display a summary to the user:
  - ID and title
  - Current status
  - Description (condensed)
  - Any relevant comments
- Ask for confirmation: "Is this the right issue? Anything to clarify or add before we start?"
- If the user adds clarifications, incorporate them into the working spec

### Step 2 — Options checkpoint

Ask upfront, all at once, which optional steps the user wants:

- **Architect analysis**: Should the `architect` agent (Opus) analyze the codebase and propose 2-3 approaches with trade-offs before planning? Recommended for complex features, new systems, or when an external library is involved.
- **Tests**: Should tests be written alongside the implementation?

(No Linear option — the issue already exists and will be updated at the end.)

### Step 3 — Explore and plan

Enter plan mode (EnterPlanMode). In plan mode:

**If the user requested architect analysis:**
- Spawn the `architect` agent with the full spec from the Linear issue
- The agent will explore the codebase and propose 2-3 approaches with trade-offs, a recommendation, and a detailed implementation plan for the chosen approach
- Present the agent's output and ask the user to pick an approach
- Use the chosen approach as the basis for the execution plan

**In all cases:**
- Identify all files to create or modify with exact paths and line numbers
- Produce a clear, step-by-step execution plan

Do not exit plan mode until the user explicitly approves the plan. If the user requests changes, revise and re-present. Only exit plan mode (ExitPlanMode) once the plan is approved.

Once the plan is approved, update the Linear issue status to **In Progress**.

### Step 4 — Implement

Execute the approved plan step by step, following existing conventions (naming, structure, imports). If a step reveals unexpected complexity or a blocker, stop and inform the user before continuing.

### Step 5 — Simplify

Spawn the `code-simplifier` agent on all files modified during this feature. The agent will refine the code for clarity, consistency, and maintainability while preserving exact functionality. Let it complete its full pass without interruption.

This step is not optional — it runs on every feature to ensure the code going into review is already clean and readable.

### Step 6 — Review

Read and follow `~/.claude/commands/review.md`. The scope is all files modified during this feature.

### Step 7 — Tests [CONDITIONAL]

If the user requested tests in Step 2:
- Detect the test runner (package.json scripts, Makefile, pytest, etc.) and run existing tests
- If tests fail, fix them before continuing — do not leave broken tests
- If the feature has no test coverage, write tests for the core logic
- Re-run to confirm all tests pass

### Step 8 — Playwright audit [ask here]

After the code is solid, ask:

> "Do you want a Playwright E2E audit on this feature?"

If yes, read and follow `~/.claude/commands/g-audit-feature.md` with the feature flow as the test description.

### Step 9 — Commit

Read and follow `~/.claude/commands/commit.md`.

Include the Linear issue ID in the commit message if the project's commit style supports it (e.g. `feat: add X [FLO-42]` or `feat(FLO-42): add X`). If the style has no issue reference pattern, omit it.

### Step 10 — Update the Linear issue

- Use Linear MCP `save_issue` to update the issue status to **Done** (or the equivalent closing status in the team's workflow)
- Add a comment on the issue summarizing:
  - What was implemented
  - Key files modified (with paths)
  - Commit hash

## Rules

- Never start implementing before the plan is approved (Step 3)
- Never commit while review blockers remain unresolved (Step 6)
- Never skip the simplify or review steps — they are not optional
- If tests are requested and fail, fix before committing — never commit with failing tests
- Always update the Linear issue at the end (Step 10) — this is not optional for this skill
- If the Linear issue cannot be fetched (wrong ID, permission error), stop and ask the user

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
