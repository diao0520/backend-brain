#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — Tracking Table Auto-Audit
# 用法: bash audit-tracker.sh <project-path> [tracking-table]
# 输出: JSON — diff→tracking匹配 + 状态更新建议 + 未跟踪文件
# ═══════════════════════════════════════════════════════════
set -eu

PROJECT="${1:-.}"
TABLE="${2:-}"

# Find tracking table if not specified
if [ -z "$TABLE" ]; then
  TABLE=$(ls "$PROJECT/docs/"*-TRACKING.md 2>/dev/null | head -1)
fi

if [ -z "$TABLE" ] || [ ! -f "$TABLE" ]; then
  echo '{"error":"no tracking table found","files_scanned":0,"matches":[],"suggestions":[],"recommendation":"no_tracking_table"}'
  exit 0
fi

cd "$PROJECT"

# ── 1. Get changed files ──
CHANGED_FILES=""
if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGED_FILES=$( {
    git diff --name-only HEAD 2>/dev/null
    git diff --name-only --cached 2>/dev/null
  } | sort -u | grep -v '^$' || true)
fi

if [ -z "$CHANGED_FILES" ]; then
  echo '{"source":"git diff","files_scanned":0,"matches":[],"suggestions":[],"recommendation":"no_changes"}'
  exit 0
fi

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

# ── 2. Parse tracking table for rows with implementation paths ──
ROWS=$(grep -E '^\|' "$TABLE" 2>/dev/null | grep -vE '^\|[- ]*\|' | grep -vE '编号|ID|Feature|功能' || true)

# ── 3. Match loop ──
MATCHES="["
SUGGESTIONS="["
M_FIRST=true
S_FIRST=true

while IFS= read -r row; do
  [ -z "$row" ] && continue

  IFS='|' read -r _ id feature desc acceptance impl_path extensible priority status progress scan notes <<< "$row"

  id=$(echo "$id" | xargs)
  impl_path=$(echo "$impl_path" | xargs)
  status=$(echo "$status" | xargs)

  [ -z "$id" ] && continue
  [ -z "$impl_path" ] && continue
  echo "$id" | grep -qE '^[A-Za-z]{1,2}[0-9]{1,3}$' || continue

  # Match changed files against implementation path
  MATCHED=""
  while IFS= read -r cf; do
    [ -z "$cf" ] && continue
    fb=$(basename "$cf")
    matched=false
    echo "$impl_path" | grep -qF "$cf" 2>/dev/null && matched=true
    echo "$impl_path" | grep -qF "$fb" 2>/dev/null && matched=true
    echo "$cf" | grep -qF "$impl_path" 2>/dev/null && matched=true
    if [ "$matched" = true ]; then
      MATCHED="${MATCHED:+$MATCHED, }$cf"
    fi
  done <<< "$CHANGED_FILES"

  if [ -n "$MATCHED" ]; then
    # Status transition logic
    NEW_STATUS=""
    case "$status" in
      *"⬜"*|*"not_started"*) NEW_STATUS="🔵 in-progress" ;;
      *"🔵"*|*"in-progress"*) NEW_STATUS="🟢 mostly" ;;
      *"🟡"*|*"partial"*)     NEW_STATUS="🟠 half" ;;
      *"🟠"*|*"half"*)        NEW_STATUS="🟢 mostly" ;;
      *"🟢"*|*"mostly"*)      NEW_STATUS="✅ done" ;;
    esac

    safe_id=$(echo "$id" | xargs)
    safe_feat=$(echo "$feature" | tr -d '\r' | xargs | sed 's/"/\\"/g')
    safe_files=$(echo "$MATCHED" | sed 's/"/\\"/g')

    if [ "$M_FIRST" = false ]; then MATCHES="${MATCHES},"; fi
    MATCHES="${MATCHES}{\"id\":\"$safe_id\",\"feature\":\"$safe_feat\",\"files\":\"$safe_files\"}"
    M_FIRST=false

    if [ -n "$NEW_STATUS" ]; then
      safe_new=$(echo "$NEW_STATUS" | sed 's/"/\\"/g')
      if [ "$S_FIRST" = false ]; then SUGGESTIONS="${SUGGESTIONS},"; fi
      SUGGESTIONS="${SUGGESTIONS}{\"id\":\"$safe_id\",\"action\":\"update_status\",\"from\":\"$status\",\"to\":\"$safe_new\"}"
      S_FIRST=false
    fi
  fi
done <<< "$ROWS"

MATCHES="${MATCHES}]"
SUGGESTIONS="${SUGGESTIONS}]"

# ── 4. Untracked files ──
UNTRACKED="["
U_FIRST=true
while IFS= read -r cf; do
  [ -z "$cf" ] && continue
  if ! echo "$MATCHES" | grep -qF "$cf" 2>/dev/null; then
    if [ "$U_FIRST" = false ]; then UNTRACKED="${UNTRACKED},"; fi
    safe_f=$(echo "$cf" | sed 's/"/\\"/g')
    UNTRACKED="${UNTRACKED}\"$safe_f\""
    U_FIRST=false
  fi
done <<< "$CHANGED_FILES"
UNTRACKED="${UNTRACKED}]"

# ── 5. Counts ──
M_COUNT=$(echo "$MATCHES" | grep -o '"id"' | wc -l | tr -d ' ')
S_COUNT=$(echo "$SUGGESTIONS" | grep -o '"id"' | wc -l | tr -d ' ')
U_COUNT=0
[ "$UNTRACKED" != "[]" ] && U_COUNT=$(echo "$UNTRACKED" | tr ',' '\n' | wc -l | tr -d ' ')

RECO="no_changes"
[ "$M_COUNT" -gt 0 ] 2>/dev/null && RECO="update_tracking_table"
[ "$U_COUNT" -gt 0 ] 2>/dev/null && RECO="${RECO}_and_review_untracked"

cat <<EOF
{
  "source": "git diff",
  "files_scanned": $FILE_COUNT,
  "matches": $MATCHES,
  "match_count": $M_COUNT,
  "suggestions": $SUGGESTIONS,
  "suggestion_count": $S_COUNT,
  "untracked": $UNTRACKED,
  "untracked_count": $U_COUNT,
  "recommendation": "$RECO"
}
EOF
