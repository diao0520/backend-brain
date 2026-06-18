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

# ── 2. Scoring function (all bash built-ins, zero subprocess) ──
score_skill() {
  local q="$1" name="$2" desc="$3"
  local score=0
  local q_lower n_lower d_lower word kw

  q_lower="${q,,}"; n_lower="${name,,}"; d_lower="${desc,,}"

  # Direct name contains query or query contains name
  [[ "$n_lower" == *"$q_lower"* ]] && score=$((score + 100))
  [[ "$q_lower" == *"$n_lower"* ]] && score=$((score + 80))

  # Hyphenated word match in name
  for word in ${n_lower//-/ }; do
    [ ${#word} -lt 3 ] && continue
    [[ "$q_lower" == *"$word"* ]] && score=$((score + 50))
  done

  # Description keyword match
  for kw in $q_lower; do
    [ ${#kw} -lt 3 ] && continue
    [[ "$d_lower" == *"$kw"* ]] && score=$((score + 30))
  done

  # Domain keyword bonus (all bash built-ins, no grep)
  [[ "$q_lower" == *test* || "$q_lower" == *tdd* ]] && [[ "$n_lower" == *tdd* || "$n_lower" == *test* ]] && score=$((score + 40))
  [[ "$q_lower" == *security* || "$q_lower" == *audit* || "$q_lower" == *vuln* ]] && [[ "$n_lower" == *security* || "$n_lower" == *audit* ]] && score=$((score + 40))
  [[ "$q_lower" == *build* || "$q_lower" == *compile* || "$q_lower" == *error* ]] && [[ "$n_lower" == *build* || "$n_lower" == *error* || "$n_lower" == *resolver* ]] && score=$((score + 40))
  [[ "$q_lower" == *review* || "$q_lower" == *lint* || "$q_lower" == *quality* ]] && [[ "$n_lower" == *review* || "$n_lower" == *lint* || "$n_lower" == *quality* ]] && score=$((score + 40))
  [[ "$q_lower" == *database* || "$q_lower" == *sql* || "$q_lower" == *query* ]] && [[ "$n_lower" == *database* || "$n_lower" == *sql* || "$n_lower" == *postgres* ]] && score=$((score + 40))
  [[ "$q_lower" == *refactor* || "$q_lower" == *clean* ]] && [[ "$n_lower" == *refactor* || "$n_lower" == *clean* ]] && score=$((score + 40))
  [[ "$q_lower" == *deploy* || "$q_lower" == *docker* || "$q_lower" == *k8s* || "$q_lower" == *ci* ]] && [[ "$n_lower" == *deploy* || "$n_lower" == *docker* || "$n_lower" == *ci* || "$n_lower" == *cd* ]] && score=$((score + 40))
  [[ "$q_lower" == *doc* || "$q_lower" == *document* || "$q_lower" == *readme* ]] && [[ "$n_lower" == *doc* || "$n_lower" == *readme* ]] && score=$((score + 40))
  [[ "$q_lower" == *e2e* || "$q_lower" == *playwright* || "$q_lower" == *browser* ]] && [[ "$n_lower" == *e2e* || "$n_lower" == *playwright* || "$n_lower" == *browser* ]] && score=$((score + 40))
  [[ "$q_lower" == *frontend* || "$q_lower" == *ui* || "$q_lower" == *css* || "$q_lower" == *design* ]] && [[ "$n_lower" == *frontend* || "$n_lower" == *design* || "$n_lower" == *ui* || "$n_lower" == *css* ]] && score=$((score + 40))
  [[ "$q_lower" == *perf* || "$q_lower" == *slow* || "$q_lower" == *optimize* ]] && [[ "$n_lower" == *perf* || "$n_lower" == *performance* || "$n_lower" == *optimize* ]] && score=$((score + 40))

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
