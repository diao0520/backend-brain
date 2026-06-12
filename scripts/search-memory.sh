#!/usr/bin/env bash
# Backend Brain: 记忆搜索 — 全文检索历史会话
# 用法: bash search-memory.sh <project> <keyword> [limit]
set -eu  # no pipefail: grep empty is normal
P="$1"; K="${2:-}"; L="${3:-5}"
R="${HOME:-${USERPROFILE}}/.claude/memory/projects/${P}/sessions"
[ ! -d "$R" ] && echo '{"results":[],"total":0}' && exit 0
LINES=$(grep -rli "$K" "$R" 2>/dev/null || true | head -"$L" | while read f; do
  D=$(basename "$f" .md | sed 's/session-//')
  S=$(grep -i "$K" "$f" | head -3 | sed 's/"/\\"/g' | tr '\n' ' ' | cut -c1-200)
  echo "{\"date\":\"$D\",\"file\":\"$(basename $f)\",\"snippet\":\"$S\"}"
done | tr '\n' ',' | sed 's/,$//')
T=$(grep -rl "$K" "$R" 2>/dev/null | wc -l | tr -d ' ')
echo "{\"results\":[${LINES}],\"total\":${T:-0},\"query\":\"${K}\"}"
