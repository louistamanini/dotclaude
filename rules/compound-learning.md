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
