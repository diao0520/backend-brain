#!/usr/bin/env bash
# Backend Brain — 回归测试套件
# 用法: bash test.sh [project-path]
set -u

P="${1:-.}"
PASS=0; FAIL=0
G='\033[0;32m'; R='\033[0;31m'; N='\033[0m'

ok()   { PASS=$((PASS+1)); echo -e "  ${G}PASS${N} $1"; }
fail() { FAIL=$((FAIL+1)); echo -e "  ${R}FAIL${N} $1 — $2"; }

echo "Backend Brain Test Suite"
echo "========================"
echo ""

# ── 1. preflight.sh ──
echo "1. preflight.sh"
OUT=$(bash "$(dirname "$0")/preflight.sh" "$P" 2>&1) || { fail "exit code" "$OUT"; }
echo "$OUT" | grep -q '"git"'    && ok "git block"    || fail "git block" "missing"
echo "$OUT" | grep -q '"deps"'   && ok "deps block"   || fail "deps block" "missing"
echo "$OUT" | grep -q '"config"' && ok "config block" || fail "config block" "missing"
echo "$OUT" | grep -q '"code"'   && ok "code block"   || fail "code block" "missing"
python3 -c "import json; json.loads('''$OUT''')" 2>/dev/null && ok "valid JSON" || fail "valid JSON" "$(echo "$OUT" | head -1)"
echo ""

# ── 2. git-summary.sh ──
echo "2. git-summary.sh"
OUT=$(bash "$(dirname "$0")/git-summary.sh" "$P" "HEAD~1" 2>&1) || { fail "exit code" "$OUT"; }
echo "$OUT" | grep -q '"insertions"' && ok "insertions" || fail "insertions" "missing"
echo "$OUT" | grep -q '"commits"'    && ok "commits"    || fail "commits" "missing"
python3 -c "import json; json.loads('''$OUT''')" 2>/dev/null && ok "valid JSON" || fail "valid JSON" "$(echo "$OUT" | head -1)"
echo ""

# ── 3. session-archive.sh ──
echo "3. session-archive.sh"
OUT=$(bash "$(dirname "$0")/session-archive.sh" "test-project" "2026-01-01" 2>&1) || { fail "exit code" "$OUT"; }
echo "$OUT" | grep -qE "ready|saved|updated" && ok "produces output" || fail "produces output" "$OUT"
echo ""

# ── 4. search-memory.sh ──
echo "4. search-memory.sh"
OUT=$(bash "$(dirname "$0")/search-memory.sh" "test-project" "nonexistent" 2>&1) || { fail "exit code" "$OUT"; }
echo "$OUT" | grep -q '"results"' && ok "results" || fail "results" "missing"
python3 -c "import json; json.loads('''$OUT''')" 2>/dev/null && ok "valid JSON" || fail "valid JSON" "$(echo "$OUT" | head -1)"
echo ""

# ── Summary ──
TOTAL=$((PASS+FAIL))
echo "========================"
echo -e "${G}${PASS} passed${N}, ${R}${FAIL} failed${N}, ${TOTAL} total"
[ "$FAIL" -eq 0 ] && echo -e "${G}ALL TESTS PASSED${N}" && exit 0
exit 1
