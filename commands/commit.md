Before committing:
- Run `git log --oneline -20` to see the existing commit style
- Analyze the pattern: language, format, prefixes, casing, with or without scope
- Follow the exact same style for your commit

If no clear pattern is detectable:
- Use conventional commits WITHOUT scope parentheses
- `feat:` description
- `fix:` description
- `refactor:` description
- `chore:` description
- `docs:` description

Absolute rules:
- ONE single line, never a description/body after
- NEVER Co-Authored-By
- NEVER "Generated with Claude Code"
- NEVER a footer
- `git add` relevant files + `git commit -m "message"`
