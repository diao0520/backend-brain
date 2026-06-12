#!/usr/bin/env bash
# backend-brain Phase 4: Pre-flight 环境检查
# 用法: bash preflight.sh [project_path]
# 输出: JSON

set -eu  # no pipefail: grep/find returning empty is normal in preflight
PROJECT_PATH="${1:-.}"
cd "$PROJECT_PATH"

bool() { [ "$1" -eq 0 ] && echo "true" || echo "false"; }

# Git
GIT_DIRTY=0; GIT_BEHIND=0; GIT_BRANCH=""; GIT_UNTRACKED=0
if git rev-parse --git-dir > /dev/null 2>&1; then
  GIT_BRANCH=$(git branch --show-current)
  [ -n "$(git status --porcelain)" ] && GIT_DIRTY=1
  git fetch --dry-run 2>/dev/null && \
    [ -n "$(git log HEAD..origin/"$GIT_BRANCH" --oneline 2>/dev/null)" ] && GIT_BEHIND=1
  GIT_UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
fi

# Deps
DEPS_OUTDATED=0
if [ -f "package.json" ]; then
  npm outdated --json 2>/dev/null | grep -q . && DEPS_OUTDATED=1 || true
elif [ -f "requirements.txt" ]; then
  pip list --outdated --format=json 2>/dev/null | grep -q . && DEPS_OUTDATED=1 || true
fi

# TODOs
TODO_COUNT=$(grep -r "TODO\|FIXME" --include="*.py" --include="*.ts" --include="*.js" --include="*.java" --include="*.go" --include="*.rs" . 2>/dev/null | wc -l | tr -d ' ')

# Config & infra (backend)
CFG=0
for f in .env .env.local application.yml application.properties application.yaml; do
  [ -f "$f" ] && CFG=1 && break
done
MIG="none"
[ -d "migrations" ] || [ -d "alembic" ] && MIG="detected"
[ -d "db/migration" ] || [ -d "src/main/resources/db/migration" ] && MIG="detected"
REDIS="unknown"
command -v redis-cli >/dev/null 2>&1 && timeout 2 redis-cli ping >/dev/null 2>&1 && REDIS="true" || REDIS="false"

# Large files
LARGE=$(find . -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.java" -o -name "*.go" -o -name "*.rs" 2>/dev/null | xargs wc -l 2>/dev/null | awk '$1 > 500 {print $2":"$1}' | tr '\n' ',' | sed 's/,$//')

cat <<EOF
{
  "git": {
    "branch": "$GIT_BRANCH",
    "dirty": $(bool $GIT_DIRTY),
    "behind": $(bool $GIT_BEHIND),
    "untracked": $GIT_UNTRACKED
  },
  "deps": { "outdated": $(bool $DEPS_OUTDATED) },
  "config": { "found": $(bool $CFG), "migration": "$MIG", "redis": "$REDIS" },
  "code": {
    "todo_count": ${TODO_COUNT:-0},
    "large_files": "${LARGE:-none}"
  }
}
EOF
