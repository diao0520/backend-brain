#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain: 增强记忆搜索 — 模糊匹配 + 相关性排序
# 用法: bash search-memory.sh <project> <keyword> [limit]
# 输出: JSON — 按相关性排序的结果
# ═══════════════════════════════════════════════════════════
set -eu

P="$1"
K="${2:-}"
L="${3:-5}"

# Cross-platform home
ROOT="${HOME:-${USERPROFILE}}/.claude/memory/projects/${P}/sessions"

if [ ! -d "$ROOT" ]; then
  echo '{"results":[],"total":0,"query":"'"$K"'","method":"none"}'
  exit 0
fi

if [ -z "$K" ]; then
  echo '{"results":[],"total":0,"query":"","method":"none"}'
  exit 0
fi

# ── 1. Multi-word tokenization ──
KEYWORDS=$(echo "$K" | tr '[:upper:]' '[:lower:]' | tr ' ' '\n' | awk 'length($0)>=2' | sort -u)

# ── 2. Score each session file ──
SCORED=""
for f in "$ROOT"/session-*.md; do
  [ -f "$f" ] || continue
  score=0
  matched_kws=""

  for kw in $KEYWORDS; do
    count=$(grep -ci "$kw" "$f" 2>/dev/null || echo 0)
    if [ "$count" -gt 0 ] 2>/dev/null; then
      score=$((score + count * 10))
      matched_kws="${matched_kws:+$matched_kws,}$kw"
    fi
  done

  if [ "$score" -gt 0 ] 2>/dev/null; then
    SCORED="${SCORED}${score}|${f}|${matched_kws}
"
  fi
done

if [ -z "$SCORED" ]; then
  echo '{"results":[],"total":0,"query":"'"$K"'"}'
  exit 0
fi

# ── 3. Rank by score, take top N ──
RANKED=$(echo "$SCORED" | sort -t'|' -k1 -rn)
TOTAL=$(echo "$RANKED" | grep -c '|' 2>/dev/null || echo 0)
TOP=$(echo "$RANKED" | head -"$L")

# ── 4. Build results JSON ──
RESULTS="["
FIRST=true

while IFS='|' read -r score file matched_kws; do
  [ -z "$file" ] && continue

  date_str=$(basename "$file" .md | sed 's/session-//')
  fname=$(basename "$file")

  # Extract best snippet: first matching line with context
  first_kw=$(echo "$matched_kws" | cut -d',' -f1)
  snippet=$(grep -i "$first_kw" "$file" 2>/dev/null | head -3 | sed 's/"/\\"/g' | tr '\n' ' ' | cut -c1-250)

  safe_score=${score:-0}
  safe_date=$(echo "$date_str" | xargs)
  safe_kws=$(echo "$matched_kws" | sed 's/"/\\"/g')

  if [ "$FIRST" = false ]; then RESULTS="${RESULTS},"; fi
  RESULTS="${RESULTS}{\"date\":\"$safe_date\",\"file\":\"$fname\",\"score\":$safe_score,\"matched\":\"$safe_kws\",\"snippet\":\"$snippet\"}"
  FIRST=false
done <<< "$TOP"
RESULTS="${RESULTS}]"

SAFE_QUERY=$(echo "$K" | sed 's/"/\\"/g')

cat <<EOF
{
  "results": $RESULTS,
  "total": ${TOTAL:-0},
  "query": "$SAFE_QUERY",
  "keywords": "$(echo "$KEYWORDS" | tr '\n' ' ' | xargs)",
  "method": "fuzzy_multiword"
}
EOF
