Create a well-structured Linear issue from a problem description. Argument: free-text description of the bug, improvement, or feature request.

## Process

### Step 1 — Understand the problem
- Read the user's description provided as argument
- Identify the type: Bug, Feature, Improvement, or UX
- If the description is too vague to explore the codebase, ask ONE clarifying question before proceeding

### Step 2 — Explore the codebase
- Use Grep, Glob, and Read to find the files directly related to the problem
- Identify 2-5 key files with exact paths and relevant line numbers
- Understand the current implementation to formulate a meaningful solution
- Do NOT spend more than ~5 searches — focus on the most relevant files

### Step 3 — Formulate the structured description
Build the issue description in this exact markdown format:

```
## Problem
[Clear description of the bug or improvement, in the user's language]

## Context
- `path/to/file.ext:line` — what this file does and why it's relevant
- `path/to/file2.ext:line` — what this file does and why it's relevant

## Suggested solution
1. Step 1
2. Step 2
3. Step 3

## Questions before implementation
- Question 1?
- Question 2?
- Question 3?
```

Rules for the description:
- Write in the same language as the user's description
- Keep the Problem section to 2-3 sentences max
- Context must have real file paths found in Step 2 (not invented)
- Suggested solution should be actionable steps, not vague directions
- Questions should be things that would change the implementation approach
- Do NOT use accented characters in the markdown sent to Linear (Linear API can reject them) — use ASCII equivalents. Mapping: é/è/ê/ë → e, à/â → a, ù/û/ü → u, î/ï → i, ô → o, ç → c, ñ → n, œ → oe, æ → ae. Apply to both lowercase and uppercase.

### Step 4 — Detect the Linear team
- Use Linear MCP `list_teams` to get available teams
- If there is only one team, use it automatically
- If there are multiple teams, ask the user which one to use
- Remember the team ID for issue creation

### Step 5 — Find or create the label
- Use Linear MCP `list_issue_labels` to check existing labels
- Match the issue type from Step 1 to a label: Bug, Feature, Improvement, or UX
- If the label does not exist, create it with `create_issue_label`
- If multiple labels could apply, pick the most specific one

### Step 6 — Create the issue on Linear
- Use Linear MCP `create_issue` with:
  - `title`: concise summary (under 80 chars, no accented characters)
  - `description`: the structured markdown from Step 3
  - `team_id`: from Step 4
  - `label_ids`: from Step 5
- Show the user the issue identifier (e.g., FLO-12) and confirm creation

### Step 7 — Report
- Display the issue ID and title
- If creation failed, show the error and offer to retry with adjusted content

## Rules

### Issue quality
- Every issue must have all 4 sections (Problem, Context, Suggested solution, Questions)
- Never create an issue without exploring the codebase first
- Never invent file paths — only reference files you actually found and read
- Keep titles short and actionable (verb + noun pattern preferred)

### Linear API safety
- Do NOT use accented characters (e, a, u instead of e, a, u) in title and description sent to Linear
- If creation fails with validation error, sanitize the content and retry once

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
