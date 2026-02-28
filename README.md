# dotclaude

My [Claude Code](https://claude.com/code) configuration — agents, skills, hooks, and settings.

## Structure

```
~/.claude/
├── CLAUDE.md              # Global rules (loaded in every session)
├── settings.json          # Preferences, hooks, plugins
├── agents/
│   ├── reviewer.md        # Adversarial code review (read-only)
│   ├── architect.md       # Architecture planning (read-only)
│   ├── simplifier.md      # Post-work code cleanup
│   └── ux-auditor.md      # UX, accessibility (WCAG), SEO audit
├── commands/
│   ├── commit.md          # Standardized commit workflow
│   ├── review.md          # Code review orchestrating the reviewer agent
│   ├── g-audit-feature.md # E2E Playwright testing → UX report → Linear issues
│   ├── g-create-issue.md  # Structured Linear issue from a description
│   └── g-generate-skill.md # Meta-skill: generate new skills from a session
└── hooks/
    ├── guard-destructive.sh # PreToolUse: blocks dangerous commands
    └── auto-format.sh       # PostToolUse: auto-format after writes
```

## Agents

| Agent | Role | Tools | Writes code? |
|---|---|---|---|
| **reviewer** | Adversarial code review — finds bugs, security issues, missing tests | Read, Glob, Grep, WebSearch | No |
| **architect** | Architecture planning — proposes approaches with trade-offs | Read, Glob, Grep, WebSearch, WebFetch | No |
| **simplifier** | Post-work cleanup — removes dead code, simplifies logic | Read, Glob, Grep, Edit, Bash | Yes (behavior-preserving only) |
| **ux-auditor** | UX, accessibility (WCAG 2.2 AA), SEO audit via Playwright | Read, Glob, Grep, Playwright (navigate, snapshot, screenshot, resize) | No |

## Skills (slash commands)

| Command | Description |
|---|---|
| `/feature` | Full feature workflow: clarify → plan (+ optional architect analysis) → implement → review → tests → Playwright → commit → optional Linear issue |
| `/feature-linear` | Same as `/feature` but starts from an existing Linear issue and updates it to Done at the end |
| `/commit` | Follows the project's existing commit style |
| `/review` | Adversarial code review → fix loop → re-review |
| `/g-audit-feature` | Playwright E2E test → UX audit report → Linear issues |
| `/g-create-issue` | Explore codebase → structured Linear issue |
| `/g-generate-skill` | Turn a session workflow into a reusable skill |

## Hooks

| Event | Script | What it does |
|---|---|---|
| `PreToolUse(Bash)` | `guard-destructive.sh` | Blocks `rm -rf /`, `git push --force main`, `git reset --hard`, `DROP TABLE`, `chmod 777` |
| `PostToolUse(Write\|Edit)` | `auto-format.sh` | Auto-formats with the project's local formatter (prettier, pint, black, gofmt, rustfmt) |
| `Stop` | inline (settings.json) | Desktop notification when Claude finishes |
| `Notification` | inline (settings.json) | Desktop notification when Claude needs input |

## Setup

### New install (recommended)

Claude hasn't created `~/.claude` yet — clone directly, nothing to lose:

```bash
git clone git@github.com:louistamanini/dotclaude.git ~/.claude
```

### Existing install

`~/.claude` already exists with credentials, cache, and history. No need to move anything — initialize git in place and pull the repo over it:

```bash
cd ~/.claude
git init
git remote add origin git@github.com:louistamanini/dotclaude.git
git fetch origin
git reset origin/main    # set index to main without touching existing files
git checkout .           # restore tracked files from the repo
git branch -M main       # rename branch to main
git branch -u origin/main
```

The `.gitignore` excludes all local files (`.credentials.json`, `settings.json`, `cache/`, `projects/`, etc.), so nothing is overwritten.

### Update

```bash
cd ~/.claude && git pull
```

## Design principles

- **Compound engineering** — Every mistake feeds back into CLAUDE.md and skills via self-improvement rules
- **Verification loops** — The `/review` skill re-reviews after every fix; the simplifier runs tests after changes
- **Restricted tools** — Read-only agents are more reliable (reviewer and architect can't modify code)
- **Hooks as guardrails** — PreToolUse blocks destructive commands before they run; PostToolUse handles formatting
- **DRY rules** — Shared rules live in `CLAUDE.md`, skills reference them instead of duplicating

## License

MIT
