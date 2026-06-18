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

# ── 1. Get changed files into array ──
FILES=()
if git rev-parse --git-dir > /dev/null 2>&1; then
  while IFS= read -r f; do
    [ -n "$f" ] && FILES+=("$f")
  done < <( { git diff --name-only HEAD 2>/dev/null; git diff --name-only --cached 2>/dev/null; } | sort -u | grep -v '^$' || true)
fi

FILE_COUNT=${#FILES[@]}
if [ "$FILE_COUNT" -eq 0 ]; then
  echo '{"source":"git diff","files_scanned":0,"matches":[],"suggestions":[],"recommendation":"no_changes"}'
  exit 0
fi

# ── 2. Parse tracking table rows into array ──
ROWS=()
while IFS= read -r row; do
  [ -n "$row" ] && ROWS+=("$row")
done < <(grep -E '^\|' "$TABLE" 2>/dev/null | grep -vE '^\|[- ]*\|' | grep -vE '编号|ID|Feature|功能' || true)

# ── 3. Match: single pass using arrays + bash built-ins ──
MATCH_IDS="["
SUGGESTIONS="["
M_FIRST=true; S_FIRST=true
# Track which files have been matched (associative array)
declare -A FILE_MATCHED

for row in "${ROWS[@]}"; do
  # Parse fields
  IFS='|' read -r _ id feature desc acceptance impl_path _status _progress _scan _notes <<< "$row"

  # trim
  id="${id## }"; id="${id%% }"
  impl_path="${impl_path## }"; impl_path="${impl_path%% }"
  _status="${_status## }"; _status="${_status%% }"

  [ -z "$id" ] && continue
  [ -z "$impl_path" ] && continue
  [[ "$id" =~ ^[A-Za-z]{1,2}[0-9]{1,3}$ ]] || continue

  # Match changed files using bash built-ins
  MATCHED_FILES=""
  for cf in "${FILES[@]}"; do
    fb="${cf##*/}"
    matched=false
    [[ "$impl_path" == *"$cf"* ]] && matched=true
    [[ "$impl_path" == *"$fb"* ]] && matched=true
    [[ "$cf" == *"$impl_path"* ]] && matched=true
    if [ "$matched" = true ]; then
      MATCHED_FILES="${MATCHED_FILES:+$MATCHED_FILES, }$cf"
      FILE_MATCHED["$cf"]=1
    fi
  done

  if [ -n "$MATCHED_FILES" ]; then
    # Status transition (bash built-in pattern matching)
    NEW_STATUS=""
    case "$_status" in
      *"⬜"*|*"not_started"*) NEW_STATUS="🔵 in-progress" ;;
      *"🔵"*|*"in-progress"*) NEW_STATUS="🟢 mostly" ;;
      *"🟡"*|*"partial"*)     NEW_STATUS="🟠 half" ;;
      *"🟠"*|*"half"*)        NEW_STATUS="🟢 mostly" ;;
      *"🟢"*|*"mostly"*)      NEW_STATUS="✅ done" ;;
    esac

    safe_feat="${feature//\"/\\\"}"
    safe_files="${MATCHED_FILES//\"/\\\"}"
    safe_new="${NEW_STATUS//\"/\\\"}"

    [ "$M_FIRST" = false ] && MATCH_IDS="$MATCH_IDS,"
    MATCH_IDS="${MATCH_IDS}{\"id\":\"$id\",\"feature\":\"$safe_feat\",\"files\":\"$safe_files\"}"
    M_FIRST=false

    if [ -n "$NEW_STATUS" ]; then
      [ "$S_FIRST" = false ] && SUGGESTIONS="$SUGGESTIONS,"
      SUGGESTIONS="${SUGGESTIONS}{\"id\":\"$id\",\"action\":\"update_status\",\"from\":\"$_status\",\"to\":\"$safe_new\"}"
      S_FIRST=false
    fi
  fi
done

MATCH_IDS="${MATCH_IDS}]"
SUGGESTIONS="${SUGGESTIONS}]"

# ── 4. Untracked: files not matched in any row ──
UNTRACKED="["
U_FIRST=true
for cf in "${FILES[@]}"; do
  if [ -z "${FILE_MATCHED[$cf]:-}" ]; then
    safe_f="${cf//\"/\\\"}"
    [ "$U_FIRST" = false ] && UNTRACKED="$UNTRACKED,"
    UNTRACKED="${UNTRACKED}\"$safe_f\""
    U_FIRST=false
  fi
done
UNTRACKED="${UNTRACKED}]"

# ── 5. Counts ──
M_COUNT="${M_FIRST:+0}"; [ "$M_FIRST" = false ] && M_COUNT=$(echo "$MATCH_IDS" | grep -o '"id"' | wc -l | tr -d ' ')
S_COUNT="${S_FIRST:+0}"; [ "$S_FIRST" = false ] && S_COUNT=$(echo "$SUGGESTIONS" | grep -o '"id"' | wc -l | tr -d ' ')
U_COUNT="${U_FIRST:+0}"; [ "$U_FIRST" = false ] && U_COUNT=${#UNTRACKED//[^,]}; U_COUNT=$((U_COUNT + 1))

RECO="no_changes"
[ "${M_COUNT:-0}" -gt 0 ] && RECO="update_tracking_table"
[ "${U_COUNT:-0}" -gt 0 ] && [ "$RECO" = "update_tracking_table" ] && RECO="${RECO}_and_review_untracked"
[ "${U_COUNT:-0}" -gt 0 ] && [ "$RECO" = "no_changes" ] && RECO="review_untracked"

cat <<EOF
{
  "source": "git diff",
  "files_scanned": $FILE_COUNT,
  "matches": $MATCH_IDS,
  "match_count": $M_COUNT,
  "suggestions": $SUGGESTIONS,
  "suggestion_count": $S_COUNT,
  "untracked": $UNTRACKED,
  "untracked_count": $U_COUNT,
  "recommendation": "$RECO"
}
EOF
