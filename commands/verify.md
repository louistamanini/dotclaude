Run all available verification tools on the project and fix failures. Argument: optional scope (file path, directory, or "all" — defaults to modified files).

## Process

### Step 1 — Detect the project stack

Read the project root for configuration files and detect available verification tools:

| Check for | Tool detected |
|-----------|--------------|
| `package.json` scripts containing "test" | Test runner (npm/bun/yarn test) |
| `package.json` scripts containing "lint" | Linter (npm/bun/yarn run lint) |
| `package.json` scripts containing "typecheck" or `tsconfig.json` | TypeScript (tsc --noEmit) |
| `package.json` scripts containing "build" | Build (npm/bun/yarn run build) |
| `pyproject.toml` or `setup.py` | pytest, ruff/black, mypy |
| `composer.json` | phpunit, phpstan, pint |
| `Makefile` with test/lint/check targets | Make targets |
| `Cargo.toml` | cargo test, cargo clippy, cargo build |
| `go.mod` | go test, go vet, go build |

Display what was detected:
```
Verification tools detected:
- Tests: npm test
- Types: tsc --noEmit
- Lint: npm run lint
- Build: npm run build
```

If nothing was detected, inform the user and stop — do not guess or invent commands.

### Step 2 — Determine scope

In priority order:
1. If an argument is provided, use it as scope
2. Otherwise, verify the full project (all detected tools run on their default scope)

### Step 3 — Run all checks

Run each detected tool and collect results. Run them sequentially (some depend on others — e.g., type errors may cause build failures):

1. **Lint** (fastest feedback)
2. **Types** (catches structural issues)
3. **Tests** (catches behavioral issues)
4. **Build** (catches integration issues)

For each tool, capture:
- Exit code (pass/fail)
- Error output (first 50 lines if verbose)
- Number of errors/warnings

### Step 4 — Fix and re-verify (if failures)

If any check failed:
1. Analyze the errors and fix them — prioritize in order: lint → types → tests → build
2. Re-run ONLY the tools that failed
3. Repeat up to **3 iterations** total
4. If still failing after 3 iterations, stop and report remaining issues — do not loop forever

### Step 5 — Report

```
Verification results:
- Lint:   ✅ pass | ❌ X errors (fixed Y)
- Types:  ✅ pass | ❌ X errors (fixed Y)
- Tests:  ✅ pass (N passed) | ❌ X failed / N total (fixed Y)
- Build:  ✅ pass | ❌ failed

Iterations: N/3
```

If all pass: "All checks pass."
If some remain after 3 iterations: list the unresolved errors clearly so the user can decide.

## Rules

- Never invent or guess verification commands — only use what is detected from config files
- Never install new tools or dependencies to make verification work
- Never modify test files to make tests pass (e.g., deleting a failing test) — fix the source code instead
- Never skip a detected tool — run everything available
- If a tool produces only warnings (exit 0), report them but count it as pass
- The 3-iteration cap is strict — if stuck in a fix loop, stop and report honestly

_Execution discipline rules are defined in ~/.claude/CLAUDE.md and apply automatically._
