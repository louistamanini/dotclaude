Generate a reusable skill (slash command) from the current session's workflow. Argument: none (uses conversation context).

## Process

### Step 1 — Analyze the session
- Review the full conversation history
- Identify the distinct phases/steps that were followed
- Identify any interruptions, course corrections, or modifications made mid-process
- Note what worked and what was adjusted

### Step 2 — Ask clarifying questions
Ask the user ALL of the following before generating anything:

1. **Scope**: "This skill should be global (available in all projects) or local to this project?"
   - If global → save to `~/.claude/commands/`
   - If local → save to `.claude/commands/` in project root

2. **Specificity check**: For each identified step, ask:
   - "I identified these steps: [list]. Are any of these too specific to this session and should be generalized or removed?"
   - "Are there steps I missed that should be included?"

3. **Parameters**: "What arguments should this skill accept? (e.g., component names, phase number, file paths)"

4. **Name**: Propose a name that precisely describes what the skill does. Ask for confirmation. The name should be a verb or verb-phrase (e.g., `port-components`, `review-migration`, `scaffold-module`).

### Step 3 — Generate the skill
Write the skill file with this structure:

```
[One-line description of what the skill does. Argument: description of expected args.]

## Process

[Numbered steps, each with clear sub-bullets]

## Rules

[Skill-specific rules]

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
```

Do NOT copy universal rules (self-improvement, execution discipline) into generated skills — they are inherited from ~/.claude/CLAUDE.md.

### Step 4 — Confirm and save
- Show the full skill content to the user
- Ask for approval before writing the file
- Save to the correct location based on scope decision

## Rules

- Never generate a skill without showing its full content to the user first (Step 4)
- Never duplicate an existing skill — check `~/.claude/commands/` and `.claude/commands/` before creating
- The template format in Step 3 is mandatory — do not improvise a different structure
- Never add universal rules (self-improvement, execution discipline) into the generated skill body — only include the standard footer line
- Skill names must be verb or verb-phrases in kebab-case (e.g., `scaffold-module`, not `module-scaffold` or `scaffoldModule`)

_Self-improvement and Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
