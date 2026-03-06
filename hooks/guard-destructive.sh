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

# --- Check each segment of chained commands (;, &&, ||) ---
while IFS= read -r segment; do
  # Trim whitespace
  segment=$(echo "$segment" | sed 's/^\s*//;s/\s*//')
  [ -z "$segment" ] && continue

  # Strip sudo prefix for pattern matching
  stripped=$(echo "$segment" | sed 's/^sudo\s\+//')

  # rm with both -r and -f flags on dangerous paths (/, /*, ., .., ~, $HOME)
  if echo "$stripped" | grep -qE '^rm\s'; then
    flags=$(echo "$stripped" | grep -oE ' -[a-zA-Z]+' | tr -d ' \n-')
    if [[ "$flags" == *r* && "$flags" == *f* ]]; then
      if echo "$stripped" | grep -qE '\s(\/\*?|\.\.?|~|\$HOME)\s*$'; then
        echo "BLOCKED: rm -rf on a root/home/current path. Specify a precise path." >&2
        exit 2
      fi
    fi
  fi

  # git reset --hard
  if echo "$stripped" | grep -qE '^git\s+reset\s+--hard'; then
    echo "BLOCKED: git reset --hard can destroy uncommitted work. Commit first or use git stash." >&2
    exit 2
  fi

  # git clean -f (allow --dry-run or -n flag)
  if echo "$stripped" | grep -qE '^git\s+clean\s+-[a-zA-Z]*f' && \
     ! echo "$stripped" | grep -qE '(--dry-run|\s-[a-zA-Z]*n)'; then
    echo "BLOCKED: git clean -f deletes untracked files. Check with git clean -n first." >&2
    exit 2
  fi

  # git branch -D main/master (force-delete protected branches)
  if echo "$stripped" | grep -qE '^git\s+branch\s+-D\s+(main|master)\b'; then
    echo "BLOCKED: Force-deleting main/master branch. Use a feature branch." >&2
    exit 2
  fi

  # DROP TABLE / TRUNCATE in SQL
  if echo "$stripped" | grep -qiE '(drop\s+table|drop\s+database|truncate\s+table)'; then
    echo "BLOCKED: Destructive SQL operation detected. Back up first." >&2
    exit 2
  fi

  # chmod 777 (overly permissive)
  if echo "$stripped" | grep -qE 'chmod\s+777'; then
    echo "BLOCKED: chmod 777 gives full access to everyone. Use more restrictive permissions." >&2
    exit 2
  fi

  # Writing to /etc or system files
  if echo "$stripped" | grep -qE '>\s*/etc/'; then
    echo "BLOCKED: Write to /etc detected. System file modification not allowed." >&2
    exit 2
  fi

done < <(echo "$COMMAND" | sed 's/\s*&&\s*/\n/g;s/\s*||\s*/\n/g;s/\s*;\s*/\n/g')

# Reminder: verify before committing (warning only — does not block)
if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  echo "REMINDER: Have you run /verify before committing?" >&2
fi

# Command allowed
exit 0
