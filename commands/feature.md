Implement a feature from A to Z: clarify, plan, implement, review, optionally test and Playwright-audit, commit, and optionally create a Linear issue. Argument: feature description.

## Process

### Step 1 — Clarify the feature

- Read the user's description from the argument
- If the description is missing, ask for it
- Ask all questions needed to have an unambiguous spec before touching any code:
  - What is the expected behavior and user-facing result?
  - What are the edge cases and error states?
  - Any constraints (stack, performance, design system, existing patterns)?
  - Is there a reference (mockup, existing similar feature, PR)?
- Do NOT start planning until every open question is answered

### Step 2 — Options checkpoint

Ask upfront, all at once, which optional steps the user wants:

- **Architect analysis**: Should the `architect` agent (Opus) analyze the codebase and propose 2-3 approaches with trade-offs before planning? Recommended for complex features, new systems, or when an external library is involved.
- **Tests**: Should tests be written alongside the implementation?
- **Linear**: Should a Linear issue be created at the end to document this feature?

Collect all answers before moving on.

### Step 3 — Explore and plan

Enter plan mode (EnterPlanMode). In plan mode:

**If the user requested architect analysis:**
- Spawn the `architect` agent with the full feature spec
- The agent will explore the codebase and propose 2-3 approaches with trade-offs, a recommendation, and a detailed implementation plan for the chosen approach
- Present the agent's output and ask the user to pick an approach
- Use the chosen approach as the basis for the execution plan

**In all cases:**
- Identify all files to create or modify with exact paths and line numbers
- Produce a clear, step-by-step execution plan

Do not exit plan mode until the user explicitly approves the plan. If the user requests changes, revise and re-present. Only exit plan mode (ExitPlanMode) once the plan is approved.

### Step 4 — Implement

Execute the approved plan step by step, following existing conventions (naming, structure, imports). If a step reveals unexpected complexity or a blocker, stop and inform the user before continuing.

### Step 5 — Review

Read and follow `~/.claude/commands/review.md`. The scope is all files modified during this feature.

### Step 6 — Tests [CONDITIONAL]

If the user requested tests in Step 2:
- Detect the test runner (package.json scripts, Makefile, pytest, etc.) and run existing tests
- If tests fail, fix them before continuing — do not leave broken tests
- If the feature has no test coverage, write tests for the core logic
- Re-run to confirm all tests pass

### Step 7 — Playwright audit [ask here]

After the code is solid, ask:

> "Do you want a Playwright E2E audit on this feature?"

If yes, read and follow `~/.claude/commands/g-audit-feature.md` with the feature flow as the test description.

### Step 8 — Commit

Read and follow `~/.claude/commands/commit.md`.

### Step 9 — Linear issue [CONDITIONAL]

If the user requested a Linear issue in Step 2, read and follow `~/.claude/commands/g-create-issue.md` using the feature description and implementation context as input.

## Rules

- Never start implementing before the plan is approved (Step 3)
- Never commit while review blockers remain unresolved (Step 5)
- Never skip the review loop — it is not optional
- If tests are requested and fail, fix before committing — never commit with failing tests
- At each conditional step, honour exactly what the user answered in Step 2 — do not re-ask

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
