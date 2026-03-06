# dotclaude

My [Claude Code](https://claude.com/code) configuration — agents, skills, hooks, and settings.

## Structure

```
~/.claude/
├── CLAUDE.md              # Global rules (loaded in every session)
├── settings.json          # Preferences, hooks, plugins
├── agents/
│   ├── architect.md       # Architecture planning (read-only)
│   ├── reviewer.md        # Adversarial code review (read-only)
│   ├── explorer.md        # Codebase research and investigation (read-only)
│   ├── simplifier.md      # Post-work code cleanup (worktree-isolated)
│   └── ux-auditor.md      # UX, accessibility (WCAG), SEO audit
├── commands/
│   ├── feature.md         # Full feature pipeline (accepts description or Linear issue)
│   ├── commit.md          # Standardized commit workflow
│   ├── review.md          # Code review orchestrating the reviewer agent
│   ├── verify.md          # Universal verification (lint, types, tests, build)
│   ├── wrap-up.md         # End-of-session compound learning ritual
│   ├── audit-feature.md   # E2E Playwright testing → UX report → Linear issues
│   ├── launch.md          # Project kickoff: idea → stack → architecture → Linear plan
│   ├── create-issue.md    # Structured Linear issue from a description
│   └── generate-skill.md  # Meta-skill: generate new skills from a session
├── rules/
│   ├── compound-learning.md   # Auto-detect and propose learnings after every skill
│   └── execution-discipline.md # Step ordering and failure handling
└── hooks/
    ├── guard-destructive.sh # PreToolUse: blocks dangerous commands + commit reminder
    └── auto-format.sh       # PostToolUse: auto-format after writes
```

## Agents

| Agent | Role | Tools | Writes code? |
|---|---|---|---|
| **architect** | Architecture planning — proposes approaches with trade-offs | Read, Glob, Grep, WebSearch, WebFetch | No |
| **reviewer** | Adversarial code review — finds bugs, security issues, missing tests | Read, Glob, Grep, WebSearch | No |
| **explorer** | Codebase research — traces flows, maps dependencies, answers questions | Read, Glob, Grep, WebSearch, WebFetch | No |
| **simplifier** | Post-work cleanup — removes dead code, simplifies logic (worktree-isolated) | Read, Glob, Grep, Edit, Bash | Yes (behavior-preserving only) |
| **ux-auditor** | UX, accessibility (WCAG 2.2 AA), SEO audit via Playwright | Read, Glob, Grep, Playwright | No |

All agents have a `description` field enabling automatic delegation — Claude routes tasks to the right agent without explicit invocation.

## Skills (slash commands)

| Command | Description |
|---|---|
| `/launch` | Project kickoff: interview idea → research stack (architect agent + web) → design architecture → create Linear milestones & tasks (senior dev briefs) → self-review tasks → optional bootstrap |
| `/feature` | Full feature pipeline: accepts a description **or** a Linear issue ID/URL. Clarify (with interview) → plan (+ optional architect) → implement → simplify → review → verify → Playwright → commit → Linear (update or create) |
| `/commit` | Follows the project's existing commit style |
| `/review` | Adversarial code review → fix loop → re-review → verify |
| `/verify` | Detects and runs all available checks (lint, types, tests, build) with auto-fix loop (max 3 iterations) |
| `/wrap-up` | End-of-session compound ritual: synthesize learnings into durable CLAUDE.md and skill rules |
| `/audit-feature` | Playwright E2E test → UX audit report → Linear issues |
| `/create-issue` | Explore codebase → structured Linear issue |
| `/generate-skill` | Turn a session workflow into a reusable skill |

## Hooks

| Event | Script | What it does |
|---|---|---|
| `PreToolUse(Bash)` | `guard-destructive.sh` | Blocks `rm -rf /`, `git push --force main`, `git reset --hard`, `DROP TABLE`, `chmod 777`. Warns before `git commit` if `/verify` hasn't been run. |
| `PostToolUse(Write\|Edit)` | `auto-format.sh` | Auto-formats with the project's local formatter (biome, prettier, pint, black, gofmt, rustfmt) |
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

- **Compound engineering** — Micro-compound after every skill (auto-detect learnings → propose CLAUDE.md updates) + `/wrap-up` for end-of-session synthesis
- **Context preservation** — Read-only agents (architect, reviewer, explorer) report back summaries without polluting the main context window
- **Worktree isolation** — The simplifier agent runs in its own git worktree, preventing accidental corruption of in-progress work
- **Auto-delegation** — All agents have descriptive `description` fields, enabling Claude to route tasks automatically without explicit invocation
- **Verification loops** — `/verify` is the single source of truth for all checks; referenced by `/feature`, `/review`, and the simplifier agent
- **Hooks as guardrails** — PreToolUse blocks destructive commands before they run; PostToolUse handles formatting
- **DRY rules** — Shared rules live in `CLAUDE.md` with `@import` for detailed sub-rules; skills reference them instead of duplicating
- **Single feature pipeline** — `/feature` handles both free-text descriptions and Linear issues, eliminating duplication

## License

MIT
