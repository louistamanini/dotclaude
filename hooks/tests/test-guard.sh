#!/bin/bash
# Unit tests for guard-destructive.sh
# Run: bash ~/.claude/hooks/tests/test-guard.sh

HOOK="$(dirname "$0")/../guard-destructive.sh"
PASS=0
FAIL=0
TOTAL=0

# --- Test helper ---
run_guard() {
  export CLAUDE_TOOL_INPUT=$(jq -n --arg cmd "$1" '{command: $cmd}')
  bash "$HOOK" 2>/dev/null
  return $?
}

expect_blocked() {
  TOTAL=$((TOTAL + 1))
  run_guard "$1"
  if [ $? -eq 2 ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: expected BLOCKED: $1"
  fi
}

expect_allowed() {
  TOTAL=$((TOTAL + 1))
  run_guard "$1"
  if [ $? -eq 0 ]; then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
    echo "  FAIL: expected ALLOWED: $1"
  fi
}

# ============================================================
echo "--- rm -rf ---"
# ============================================================

expect_blocked "rm -rf /"
expect_blocked "rm -rf ."
expect_blocked "rm -rf .."
expect_blocked "rm -rf ~"
expect_blocked 'rm -rf $HOME'
expect_blocked "rm -rf /*"
expect_blocked "rm -fr /"
expect_blocked "rm -r -f /"
expect_blocked "rm -f -r /"
expect_blocked "rm -rfi /"

# sudo prefix
expect_blocked "sudo rm -rf /"
expect_blocked "sudo rm -rf ."
expect_blocked "sudo rm -rf ~"

# chained commands
expect_blocked "echo hello && rm -rf /"
expect_blocked "cd /tmp ; rm -rf /"
expect_blocked "test -f x || rm -rf ~"
expect_blocked "echo ok && sudo rm -rf ."

# safe rm operations
expect_allowed "rm -rf ./src"
expect_allowed "rm -rf /tmp/test"
expect_allowed "rm file.txt"
expect_allowed "rm -r directory/"
expect_allowed "rm -f file.txt"
expect_allowed "rm -rf node_modules"

# ============================================================
echo "--- git reset --hard ---"
# ============================================================

expect_blocked "git reset --hard"
expect_blocked "git reset --hard HEAD~1"
expect_blocked "sudo git reset --hard"
expect_blocked "echo x && git reset --hard"

expect_allowed "git reset --soft HEAD~1"
expect_allowed "git reset HEAD file.txt"

# ============================================================
echo "--- git push --force (ALLOWED) ---"
# ============================================================

expect_allowed "git push --force"
expect_allowed "git push origin main --force"
expect_allowed "git push --force-with-lease"
expect_allowed "git push origin main --force-with-lease"

# ============================================================
echo "--- git clean ---"
# ============================================================

expect_blocked "git clean -f"
expect_blocked "git clean -fd"
expect_blocked "git clean -fdx"
expect_blocked "sudo git clean -f"

expect_allowed "git clean -f --dry-run"
expect_allowed "git clean -fn"
expect_allowed "git clean -fdn"
expect_allowed "git clean -nf"
expect_allowed "git clean -f -n"

# ============================================================
echo "--- git branch -D ---"
# ============================================================

expect_blocked "git branch -D main"
expect_blocked "git branch -D master"

expect_allowed "git branch -D feature-branch"
expect_allowed "git branch -d main"

# ============================================================
echo "--- SQL ---"
# ============================================================

expect_blocked "mysql -e 'DROP TABLE users'"
expect_blocked "psql -c 'drop database mydb'"
expect_blocked "psql -c 'TRUNCATE TABLE orders'"

expect_allowed "mysql -e 'SELECT * FROM users'"

# ============================================================
echo "--- chmod 777 ---"
# ============================================================

expect_blocked "chmod 777 /var/www"
expect_blocked "sudo chmod 777 file"

expect_allowed "chmod 755 /var/www"
expect_allowed "chmod 644 file.txt"

# ============================================================
echo "--- /etc writes ---"
# ============================================================

expect_blocked "echo 'test' > /etc/passwd"
expect_blocked "cat file > /etc/hosts"

expect_allowed "cat /etc/hosts"
expect_allowed "grep root /etc/passwd"

# ============================================================
echo "--- safe commands ---"
# ============================================================

expect_allowed "ls -la"
expect_allowed "git status"
expect_allowed "npm install"
expect_allowed "git commit -m 'test'"
expect_allowed "python script.py"
expect_allowed ""

# ============================================================
# Results
# ============================================================
echo ""
echo "==============================="
echo "Results: $PASS/$TOTAL passed, $FAIL failed"
echo "==============================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
