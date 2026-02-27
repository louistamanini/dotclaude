#!/bin/bash
# Guard hook — blocks destructive commands BEFORE execution
# Used by the PreToolUse hook on Bash
#
# Exit 0 = command allowed
# Exit 2 + STDERR message = command blocked (Claude sees the message)

# Get the command from the tool input
COMMAND=$(echo "$CLAUDE_TOOL_INPUT" | jq -r '.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

# --- Blocked destructive patterns ---

# rm -rf on root/home/current directory
if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|\.|~|\$HOME)\s*$'; then
  echo "BLOCKED: rm -rf on a root/home/current path. Specify a precise path." >&2
  exit 2
fi

# git push --force/--force-with-lease on main/master (composed detection)
if echo "$COMMAND" | grep -qE 'git\s+push' && \
   echo "$COMMAND" | grep -qE '\-\-force|\-\-force-with-lease' && \
   echo "$COMMAND" | grep -qE '\b(main|master)\b'; then
  echo "BLOCKED: Force push on main/master. Use a branch." >&2
  exit 2
fi

# git reset --hard
if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: git reset --hard can destroy uncommitted work. Commit first or use git stash." >&2
  exit 2
fi

# git clean -f (deletes untracked files) — allow --dry-run / -n
if echo "$COMMAND" | grep -qE 'git\s+clean\s+-[a-zA-Z]*f' && \
   ! echo "$COMMAND" | grep -qE '\-\-dry-run|-n'; then
  echo "BLOCKED: git clean -f deletes untracked files. Check with git clean -n first." >&2
  exit 2
fi

# git branch -D main/master (force-delete protected branches)
if echo "$COMMAND" | grep -qE 'git\s+branch\s+-D\s+(main|master)\b'; then
  echo "BLOCKED: Force-deleting main/master branch. Use a feature branch." >&2
  exit 2
fi

# DROP TABLE / TRUNCATE in SQL
if echo "$COMMAND" | grep -qiE '(drop\s+table|drop\s+database|truncate\s+table)'; then
  echo "BLOCKED: Destructive SQL operation detected. Back up first." >&2
  exit 2
fi

# chmod 777 (overly permissive)
if echo "$COMMAND" | grep -qE 'chmod\s+777'; then
  echo "BLOCKED: chmod 777 gives full access to everyone. Use more restrictive permissions." >&2
  exit 2
fi

# Writing to /etc or system files
if echo "$COMMAND" | grep -qE '>\s*/etc/'; then
  echo "BLOCKED: Write to /etc detected. System file modification not allowed." >&2
  exit 2
fi

# Command allowed
exit 0
