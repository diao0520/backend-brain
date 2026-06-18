#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — Skill Matching Engine
# 用法: bash skill-matcher.sh <query> [top-n]
# 输出: JSON — 匹配到的技能列表 + 置信度 + 推荐动作
# ═══════════════════════════════════════════════════════════
set -eu

QUERY="${1:-}"
TOP_N="${2:-3}"

if [ -z "$QUERY" ]; then
  echo '{"error":"no query","matches":[],"best_match":"none","best_score":0,"recommendation":"none"}'
  exit 0
fi

# ── 1. Build skill registry from SKILL.MD files ──
TMP_REG=$(mktemp 2>/dev/null || echo "/tmp/bb-registry-$$.tmp")
trap "rm -f '$TMP_REG'" EXIT

# Collect all skill names + descriptions
{
  for md in "${HOME:-$USERPROFILE}/.claude/skills/"*/SKILL.MD .claude/skills/*/SKILL.MD; do
    [ -f "$md" ] || continue
    name=$(grep -m1 '^name:' "$md" 2>/dev/null | sed 's/^name:\s*//' | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    desc=$(grep -m1 '^description:' "$md" 2>/dev/null | sed 's/^description:\s*//' | tr -d '\r\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    [ -z "$name" ] && continue
    echo "${name}|||${desc}"
  done
} > "$TMP_REG"

if [ ! -s "$TMP_REG" ]; then
  echo '{"query":"'"$QUERY"'","matches":[],"best_match":"none","best_score":0,"recommendation":"none"}'
  exit 0
fi

# ── 2. Scoring function ──
score_skill() {
  local q="$1" name="$2" desc="$3"
  local score=0
  local q_lower n_lower d_lower
  q_lower=$(echo "$q" | tr '[:upper:]' '[:lower:]')
  n_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
  d_lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

  # Direct name contains query or query contains name
  echo "$n_lower" | grep -qwF "$q_lower" 2>/dev/null && score=$((score + 100))
  echo "$q_lower" | grep -qwF "$n_lower" 2>/dev/null && score=$((score + 80))

  # Hyphenated word match in name
  for word in $(echo "$n_lower" | tr '-' ' '); do
    [ ${#word} -lt 3 ] && continue
    echo "$q_lower" | grep -qwF "$word" 2>/dev/null && score=$((score + 50))
  done

  # Description keyword match
  for kw in $q_lower; do
    [ ${#kw} -lt 3 ] && continue
    echo "$d_lower" | grep -qwF "$kw" 2>/dev/null && score=$((score + 30))
    echo "$d_lower" | grep -qF "$kw" 2>/dev/null && score=$((score + 10))
  done

  # Domain keyword bonus
  case "$q_lower" in
    *test*|*tdd*|*spec*)           echo "$n_lower" | grep -qE 'tdd|test' 2>/dev/null && score=$((score + 40)) ;;
    *security*|*audit*|*vuln*)     echo "$n_lower" | grep -qE 'security|audit' 2>/dev/null && score=$((score + 40)) ;;
    *build*|*compile*|*error*)     echo "$n_lower" | grep -qE 'build|error|resolver' 2>/dev/null && score=$((score + 40)) ;;
    *review*|*lint*|*quality*)     echo "$n_lower" | grep -qE 'review|lint|quality' 2>/dev/null && score=$((score + 40)) ;;
    *database*|*sql*|*query*)      echo "$n_lower" | grep -qE 'database|sql|postgres' 2>/dev/null && score=$((score + 40)) ;;
    *refactor*|*clean*|*dead*)     echo "$n_lower" | grep -qE 'refactor|clean' 2>/dev/null && score=$((score + 40)) ;;
    *deploy*|*docker*|*k8s*|*ci*)  echo "$n_lower" | grep -qE 'deploy|docker|ci|cd' 2>/dev/null && score=$((score + 40)) ;;
    *doc*|*document*|*readme*)     echo "$n_lower" | grep -qE 'doc|readme' 2>/dev/null && score=$((score + 40)) ;;
    *e2e*|*playwright*|*browser*)  echo "$n_lower" | grep -qE 'e2e|playwright|browser' 2>/dev/null && score=$((score + 40)) ;;
    *frontend*|*ui*|*css*|*design*) echo "$n_lower" | grep -qE 'frontend|design|ui|css' 2>/dev/null && score=$((score + 40)) ;;
    *perf*|*slow*|*optimize*)      echo "$n_lower" | grep -qE 'perf|performance|optimize' 2>/dev/null && score=$((score + 40)) ;;
  esac

  echo "$score"
}

# ── 3. Score + rank ──
RANKED=""
while IFS='|||' read -r name desc; do
  [ -z "$name" ] && continue
  s=$(score_skill "$QUERY" "$name" "$desc")
  [ "$s" -eq 0 ] 2>/dev/null && continue
  RANKED="${RANKED}${s}|${name}|${desc}
"
done < "$TMP_REG"

if [ -z "$RANKED" ]; then
  echo '{"query":"'"$QUERY"'","matches":[],"best_match":"none","best_score":0,"recommendation":"none"}'
  exit 0
fi

# Sort and take top N
TOP_MATCHES=$(echo "$RANKED" | sort -t'|' -k1 -rn | head -"$TOP_N")

# ── 4. Build JSON output ──
MATCHES_JSON="["
FIRST=true
BEST_NAME="none"
BEST_SCORE=0

while IFS='|' read -r score name desc; do
  [ -z "$name" ] && continue
  if [ "$FIRST" = true ]; then
    BEST_NAME="$name"
    BEST_SCORE="$score"
    FIRST=false
  else
    MATCHES_JSON="${MATCHES_JSON},"
  fi
  safe_desc=$(echo "$desc" | sed 's/"/\\"/g')
  MATCHES_JSON="${MATCHES_JSON}{\"skill\":\"$name\",\"score\":$score,\"desc\":\"$safe_desc\"}"
done <<EOF
$TOP_MATCHES
EOF
MATCHES_JSON="${MATCHES_JSON}]"

# Recommendation logic
if [ "$BEST_SCORE" -ge 120 ] 2>/dev/null; then
  RECO="invoke"
elif [ "$BEST_SCORE" -ge 60 ] 2>/dev/null; then
  RECO="suggest"
else
  RECO="none"
fi

cat <<EOF
{
  "query": "$QUERY",
  "best_match": "$BEST_NAME",
  "best_score": $BEST_SCORE,
  "matches": $MATCHES_JSON,
  "recommendation": "$RECO"
}
EOF
