#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — 性能基线基准测试
# 用法: bash benchmark.sh [project-path] [runs]
#       bash benchmark.sh --compare  对比上次基线
# 输出: JSON 基线报告 + 场景耗时表
# ═══════════════════════════════════════════════════════════
set -eu

PROJECT="$(cd "${1:-.}" && pwd)"
RUNS="${2:-3}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATE=$(date +%Y-%m-%d)
BASELINE_DIR="$PROJECT/.claude/memory"
COMPARE=false

for a in "$@"; do [ "$a" = "--compare" ] && COMPARE=true; done

# ── timer (毫秒) ──
timer_ms() {
  local start end
  start=$(date +%s%N 2>/dev/null || echo 0)
  "$@" >/dev/null 2>&1 || true
  end=$(date +%s%N 2>/dev/null || echo 0)
  echo $(( (end - start) / 1000000 ))
}

median_time() {
  local cmd="$1" n="$2" times="" t i
  for i in $(seq 1 "$n"); do
    t=$(timer_ms bash -c "$cmd")
    times="${times}${t}"$'\n'
  done
  echo "$times" | grep -v '^$' | sort -n | sed -n "$(( (n+1)/2 ))p"
}

gen_file() { local p="$1" l="$2"; for i in $(seq 1 "$l"); do echo "Line $i: const x = $i; // TODO refactor" >> "$p"; done; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Backend Brain — 性能基线            ║"
echo "╚══════════════════════════════════════╝"
echo "  项目: $PROJECT | 采样: ${RUNS}次/项"
echo ""

RESULTS="["

# 1. preflight
echo "┌─ 1. preflight.sh"
for label in empty medium large; do
  T=$(mktemp -d)
  cd "$T"
  case "$label" in
    medium) git init -q; gen_file "a.py" 200 ;;
    large)  git init -q; gen_file "a.py" 2000; gen_file "b.ts" 1500; gen_file "c.go" 300 ;;
  esac
  t=$(median_time "bash '$SCRIPT_DIR/preflight.sh' '$T'" "$RUNS")
  rm -rf "$T"; cd "$PROJECT"
  echo "   ${label}: ${t}ms"
  [ "$RESULTS" != "[" ] && RESULTS="${RESULTS},"
  RESULTS="${RESULTS}{\"script\":\"preflight\",\"scenario\":\"$label\",\"median_ms\":$t}"
done

# 2. git-summary
echo "┌─ 2. git-summary.sh"
for count in 1 10 50; do
  T=$(mktemp -d); cd "$T"
  git init -q; git config user.name "b"; git config user.email "b@b"
  for i in $(seq 1 "$count"); do echo "$i">"f$i.txt"; git add "f$i.txt" 2>/dev/null; git commit -m "c$i" --no-gpg-sign -q 2>/dev/null; done
  t=$(median_time "bash '$SCRIPT_DIR/git-summary.sh' '$T' 'HEAD~$(( count>5?5:count ))'" "$RUNS")
  rm -rf "$T"; cd "$PROJECT"
  echo "   ${count}c: ${t}ms"
  RESULTS="${RESULTS},{\"script\":\"git-summary\",\"scenario\":\"${count}_commits\",\"median_ms\":$t}"
done

# 3. search-memory
echo "┌─ 3. search-memory.sh"
t=$(median_time "bash '$SCRIPT_DIR/search-memory.sh' 'bench-nonexistent' 'test'" "$RUNS")
echo "   none: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"search-memory\",\"scenario\":\"no_data\",\"median_ms\":$t}"
T=$(mktemp -d); export HOME="$T"
mkdir -p "$T/.claude/memory/projects/bench-p/sessions"
for i in $(seq 1 10); do echo "# Session $i" > "$T/.claude/memory/projects/bench-p/sessions/session-2026-06-$i.md"; done
t=$(median_time "bash '$SCRIPT_DIR/search-memory.sh' 'bench-p' 'session'" "$RUNS")
rm -rf "$T"
echo "   10ses: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"search-memory\",\"scenario\":\"10_sessions\",\"median_ms\":$t}"

# 4. skill-matcher
echo "┌─ 4. skill-matcher.sh"
t=$(median_time "bash '$SCRIPT_DIR/skill-matcher.sh' 'security audit'" "$RUNS")
echo "   empty: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"skill-matcher\",\"scenario\":\"empty\",\"median_ms\":$t}"
T=$(mktemp -d); HOME="$T"
for sk in reviewer builder docer security perf e2e db lint deploy; do
  mkdir -p "$T/.claude/skills/$sk"
  echo -e "---\nname: $sk\ndescription: $sk tasks\n---" > "$T/.claude/skills/$sk/SKILL.MD"
done
t=$(median_time "bash '$SCRIPT_DIR/skill-matcher.sh' 'build error fix'" "$RUNS")
rm -rf "$T"
echo "   8sk: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"skill-matcher\",\"scenario\":\"8_skills\",\"median_ms\":$t}"

# 5. audit-tracker
echo "┌─ 5. audit-tracker.sh"
t=$(median_time "bash '$SCRIPT_DIR/audit-tracker.sh' /tmp" "$RUNS")
echo "   no_tbl: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"audit-tracker\",\"scenario\":\"no_table\",\"median_ms\":$t}"
T=$(mktemp -d); cd "$T"
git init -q; git config user.name "b"; git config user.email "b@b"
mkdir -p docs src
echo "# TRACKING" > docs/bench-TRACKING.md
for i in $(seq 1 30); do echo "| A$i | F$i | src/f$i.py | P$((i%4)) | ⬜ |" >> docs/bench-TRACKING.md; done
echo "init" > src/main.py; git add -A 2>/dev/null; git commit -m "init" --no-gpg-sign -q 2>/dev/null
echo "changed" > src/main.py
t=$(median_time "bash '$SCRIPT_DIR/audit-tracker.sh' '$T'" "$RUNS")
rm -rf "$T"; cd "$PROJECT"
echo "   30r: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"audit-tracker\",\"scenario\":\"30_rows\",\"median_ms\":$t}"

# 6. session-archive
echo "┌─ 6. session-archive.sh"
T=$(mktemp -d); export HOME="$T"
mkdir -p "$T/.claude/memory/projects"
t=$(median_time "bash '$SCRIPT_DIR/session-archive.sh' 'bench-p' '2026-06-18'" "$RUNS")
rm -rf "$T"
echo "   run: ${t}ms"
RESULTS="${RESULTS},{\"script\":\"session-archive\",\"scenario\":\"first\",\"median_ms\":$t}"
echo ""
RESULTS="${RESULTS}]"

# Save
mkdir -p "$BASELINE_DIR"
echo "$RESULTS" > "$BASELINE_DIR/benchmark-baseline.json"

# Report
echo "═══════════════════════════════════════"
echo "  📊 性能基线报告"
echo "═══════════════════════════════════════"
echo "$RESULTS" | grep -o '"script":"[^"]*","scenario":"[^"]*","median_ms":[0-9]*' | while IFS= read -r line; do
  s=$(echo "$line" | sed 's/.*"script":"\([^"]*\)".*/\1/')
  sc=$(echo "$line" | sed 's/.*"scenario":"\([^"]*\)".*/\1/')
  m=$(echo "$line" | sed 's/.*"median_ms":\([0-9]*\).*/\1/')
  printf "  %-22s %-18s %4sms\n" "$s:$sc" "" "$m"
done

echo ""
echo "  ⚡ 项: $(echo "$RESULTS" | grep -o 'median_ms' | wc -l) | 基线: $BASELINE_DIR/benchmark-baseline.json"
echo ""

# Compare mode
if [ "$COMPARE" = true ] && [ -f "$BASELINE_DIR/benchmark-baseline.json.prev" ]; then
  echo "═══════════════════════════════════════"
  echo "  📉 vs 上次基线"
  echo "═══════════════════════════════════════"
  PREV="$BASELINE_DIR/benchmark-baseline.json.prev"
  echo "$RESULTS" | grep -o '"script":"[^"]*","scenario":"[^"]*","median_ms":[0-9]*' | while IFS= read -r line; do
    s=$(echo "$line" | sed 's/.*"script":"\([^"]*\)".*/\1/')
    sc=$(echo "$line" | sed 's/.*"scenario":"\([^"]*\)".*/\1/')
    cur=$(echo "$line" | sed 's/.*"median_ms":\([0-9]*\).*/\1/')
    prev=$(grep -o "\"script\":\"$s\",\"scenario\":\"$sc\",\"median_ms\":[0-9]*" "$PREV" 2>/dev/null | sed 's/.*"median_ms":\([0-9]*\).*/\1/')
    if [ -n "$prev" ]; then
      d=$((cur - prev))
      tag=""; [ "$d" -gt 10 ] && tag="⚠️ "; [ "$d" -lt -10 ] && tag="✅ "
      printf "  %-22s %4sms (vs %4sms %+d%s) %s\n" "$s:$sc" "$cur" "$prev" "$d" "ms" "$tag"
    fi
  done
  echo ""
fi

if [ "$COMPARE" = false ]; then
  cp "$BASELINE_DIR/benchmark-baseline.json" "$BASELINE_DIR/benchmark-baseline.json.prev" 2>/dev/null || true
fi
