Test a feature end-to-end with Playwright browser automation, produce a UX audit report, then create Linear issues for each finding. Argument: description of the feature/flow to test (e.g., "test the wiki page editor flow from login to save").

## Process

### Step 1 — Understand the feature to test
- Read the user's description of the feature/flow to test
- Identify the entry point (URL or navigation path)
- Identify the key interactions to perform (click, type, navigate)
- If the description is too vague, ask ONE clarifying question

### Step 2 — Prepare the browser session
- Use Playwright MCP `browser_navigate` to open the application
- If authentication is required, ask the user for credentials or check if already logged in
- Navigate to the starting point of the feature

### Step 3 — Execute the test flow
- Follow the feature flow step by step using Playwright tools:
  - `browser_snapshot` to understand current page state
  - `browser_click` to interact with elements
  - `browser_type` / `browser_fill_form` to input data
  - `browser_take_screenshot` to capture visual state at key moments
  - `browser_navigate` for direct URL navigation
  - `browser_wait_for` when async operations are expected
  - `browser_console_messages` to check for JS errors
- At each step, evaluate:
  - Does the UI respond as expected?
  - Is there visual feedback for actions?
  - Are there layout issues, misalignment, or missing elements?
  - Are there console errors or warnings?
  - Is the flow intuitive?

### Step 4 — Produce the UX audit report
Compile findings into a structured report with this format:

```
# UX Audit Report — [Feature Name]

## Test Flow
1. [Step performed] — [result observed]
2. [Step performed] — [result observed]
...

## Findings

### [Severity] — [Short title]
- **What**: Description of the issue
- **Where**: Page/component where it occurs
- **Expected**: What should happen
- **Actual**: What actually happens
- **Screenshot**: [if captured]

(repeat for each finding)

## Summary
- Critical: X
- Important: X
- Minor: X
- Cosmetic: X
```

Severity levels:
- **Critical**: Blocks the user or causes data loss
- **Important**: Degrades experience significantly
- **Minor**: Noticeable but not blocking
- **Cosmetic**: Visual polish issues

Present the report to the user and ask for validation before creating issues.

### Step 5 — Create Linear issues
- For each finding validated by the user:
  - Explore the codebase to find relevant files (Grep/Glob/Read)
  - Build the structured issue description (same format as create-issue):
    - Problem, Context (with real file paths), Suggested solution, Questions
  - Detect the Linear team (list_teams, ask if multiple)
  - Find or create the appropriate label (Bug, UX, Improvement, Feature)
  - Create the issue via Linear MCP `create_issue`
  - Do NOT use accented characters in title/description sent to Linear
- Create issues in batch — do not ask for confirmation between each one

### Step 6 — Final report
Display a summary table of all created issues:

```
| ID     | Title                        | Severity  | Label |
|--------|------------------------------|-----------|-------|
| FLO-1  | Add save feedback indicator  | Important | UX    |
| FLO-2  | Fix layout shift on load     | Minor     | Bug   |
```

## Rules

### Testing discipline
- Take screenshots at KEY moments only (start, after main action, end) — not at every click
- Always check console messages for JS errors — they are findings too
- Test the HAPPY PATH first, then edge cases if time permits
- If a step fails (element not found, timeout), note it as a finding and continue

### Issue quality
- Every issue must have all 4 sections (Problem, Context, Suggested solution, Questions)
- Never create an issue without exploring the codebase first
- Never invent file paths — only reference files you actually found and read
- Keep titles short and actionable

### Linear API safety
- Do NOT use accented characters (e, a, u instead of e, a, u) in title and description sent to Linear
- If creation fails with validation error, sanitize the content and retry once

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
