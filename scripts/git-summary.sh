#!/usr/bin/env bash
# backend-brain: Git 变更摘要
# 用法: bash git-summary.sh [project_path] [since]
# 输出: JSON

set -u  # no -e: grep -c returning 1 is normal; no pipefail: same reason
PROJECT_PATH="${1:-.}"
SINCE="${2:-HEAD~5}"
cd "$PROJECT_PATH"

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo '{"error":"not a git repo"}'
  exit 0
fi

DIFF_STAT=$(git diff --stat "$SINCE" 2>/dev/null || echo "")
INS=$(echo "$DIFF_STAT" | tail -1 | sed -n 's/.*\([0-9]\+\) insertion.*/\1/p' | head -1)
DEL=$(echo "$DIFF_STAT" | tail -1 | sed -n 's/.*\([0-9]\+\) deletion.*/\1/p' | head -1)
FILES=$(echo "$DIFF_STAT" | wc -l | tr -d ' ')
[ "$FILES" -gt 0 ] && FILES=$((FILES - 1))

COMMITS=$(git log --oneline "$SINCE"..HEAD 2>/dev/null | wc -l | tr -d ' ')
FIXES=$(git log --oneline "$SINCE"..HEAD 2>/dev/null | grep -ciE 'fix|bug' 2>/dev/null)
FEATS=$(git log --oneline "$SINCE"..HEAD 2>/dev/null | grep -ciE 'feat|feature' 2>/dev/null)
FIXES=${FIXES:-0}
FEATS=${FEATS:-0}

cat <<EOF
{
  "insertions": ${INS:-0},
  "deletions": ${DEL:-0},
  "file_count": ${FILES:-0},
  "commits": ${COMMITS:-0},
  "fixes": ${FIXES:-0},
  "feats": ${FEATS:-0}
}
EOF
