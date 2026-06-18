#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — 增强回归测试套件 v2.0
# 用法: bash test.sh [project-path]
# 覆盖: 行为验证 + 边界测试 + JSON结构校验 (0 python依赖)
# ═══════════════════════════════════════════════════════════
set -u

P="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PASS=0; FAIL=0; TOTAL=0
G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; N='\033[0m'

ok()   { PASS=$((PASS+1)); TOTAL=$((TOTAL+1)); echo -e "  ${G}PASS${N} $1"; }
fail() { FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); echo -e "  ${R}FAIL${N} $1 — $2"; }
warn() { echo -e "  ${Y}SKIP${N} $1 — $2"; }

# JSON structural validator (multi-line safe)
json_valid() {
  local s="$1"
  echo "$s" | grep -q '^{' && echo "$s" | grep -q '}$' && return 0
  return 1
}
# JSON key checker: search for "key" in output (no extra quotes in arg)
json_has_key() { local s="$1" k="$2"; echo "$s" | grep -q "\"$k\""; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║  Backend Brain — Test Suite v2.0    ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ─ 1. preflight.sh ─
echo "┌─ 1. preflight.sh"
OUT=$(bash "$SCRIPT_DIR/preflight.sh" "$P" 2>&1) || { fail "preflight:exit_code" "$OUT"; }
json_valid "$OUT"                  && ok "preflight:valid_json"            || fail "preflight:valid_json" "not JSON"
json_has_key "$OUT" "git"          && ok "preflight:git_block"             || fail "preflight:git_block" "missing"
json_has_key "$OUT" "deps"         && ok "preflight:deps_block"            || fail "preflight:deps_block" "missing"
json_has_key "$OUT" "config"       && ok "preflight:config_block"          || fail "preflight:config_block" "missing"
json_has_key "$OUT" "code"         && ok "preflight:code_block"            || fail "preflight:code_block" "missing"
json_has_key "$OUT" "branch"     && ok "preflight:git_branch_field"      || fail "preflight:git_branch_field" "missing"
json_has_key "$OUT" "dirty"      && ok "preflight:git_dirty_field"       || fail "preflight:git_dirty_field" "missing"
json_has_key "$OUT" "outdated"   && ok "preflight:deps_outdated_field"   || fail "preflight:deps_outdated_field" "missing"
json_has_key "$OUT" "todo_count" && ok "preflight:todo_count_field"      || fail "preflight:todo_count_field" "missing"
echo "$OUT" | grep -q '"dirty": \(true\|false\)' && ok "preflight:dirty_is_boolean" || fail "preflight:dirty_is_boolean" "not bool"
echo ""

# ─ 2. git-summary.sh ─
echo "┌─ 2. git-summary.sh"
OUT=$(bash "$SCRIPT_DIR/git-summary.sh" "$P" "HEAD~1" 2>&1) || { fail "git-summary:exit_code" "$OUT"; }
json_valid "$OUT"                     && ok "git-summary:valid_json"        || fail "git-summary:valid_json" "not JSON"
json_has_key "$OUT" "insertions"      && ok "git-summary:insertions_field"  || fail "git-summary:insertions_field" "missing"
json_has_key "$OUT" "deletions"       && ok "git-summary:deletions_field"   || fail "git-summary:deletions_field" "missing"
json_has_key "$OUT" "file_count"      && ok "git-summary:file_count_field"  || fail "git-summary:file_count_field" "missing"
json_has_key "$OUT" "commits"         && ok "git-summary:commits_field"     || fail "git-summary:commits_field" "missing"
json_has_key "$OUT" "fixes"           && ok "git-summary:fixes_field"       || fail "git-summary:fixes_field" "missing"
json_has_key "$OUT" "feats"           && ok "git-summary:feats_field"       || fail "git-summary:feats_field" "missing"
echo "$OUT" | grep -q '"insertions": [0-9]' && ok "git-summary:insertions_numeric" || fail "git-summary:insertions_numeric" "not numeric"
echo "$OUT" | grep -q '"commits": [0-9]'    && ok "git-summary:commits_numeric"    || fail "git-summary:commits_numeric" "not numeric"
NONGIT_OUT=$(cd /tmp && bash "$SCRIPT_DIR/git-summary.sh" "/tmp" "HEAD~1" 2>&1) || true
json_has_key "$NONGIT_OUT" "error" && ok "git-summary:non_git_repo_handled" || fail "git-summary:non_git_repo_handled" "no error key"
echo ""

# ─ 3. session-archive.sh ─
echo "┌─ 3. session-archive.sh"
OUT=$(bash "$SCRIPT_DIR/session-archive.sh" "test-project" "2026-06-18" 2>&1) || { fail "session-archive:exit_code" "$OUT"; }
echo "$OUT" | grep -qE "ready|saved|updated|Archive" && ok "session-archive:produces_output" || fail "session-archive:produces_output" "$OUT"
INJ_OUT=$(bash "$SCRIPT_DIR/session-archive.sh" "bad';rm -rf /\$(whoami)" "2026-06-18" 2>&1) || true
echo "$INJ_OUT" | grep -q "Invalid" && ok "session-archive:rejects_injection" || fail "session-archive:rejects_injection" "accepted injection"
echo ""

# ─ 4. search-memory.sh ─
echo "┌─ 4. search-memory.sh"
OUT=$(bash "$SCRIPT_DIR/search-memory.sh" "nonexistent-project-xyz" "test" 2>&1) || { fail "search-memory:exit_code" "$OUT"; }
json_valid "$OUT"                  && ok "search-memory:valid_json"          || fail "search-memory:valid_json" "not JSON"
json_has_key "$OUT" "results"      && ok "search-memory:results_field"       || fail "search-memory:results_field" "missing"
json_has_key "$OUT" "total"        && ok "search-memory:total_field"         || fail "search-memory:total_field" "missing"
json_has_key "$OUT" "query"        && ok "search-memory:query_field"         || fail "search-memory:query_field" "missing"
json_has_key "$OUT" "method"       && ok "search-memory:method_field"        || fail "search-memory:method_field" "missing"
EMPTY_OUT=$(bash "$SCRIPT_DIR/search-memory.sh" "test-project" "" 2>&1) || true
json_has_key "$EMPTY_OUT" "results" && ok "search-memory:empty_query_handled" || fail "search-memory:empty_query_handled" "crashed"
echo "$OUT" | grep -q '"total":0' && ok "search-memory:empty_results_for_missing" || fail "search-memory:empty_results_for_missing" "unexpected results"
echo ""

# ─ 5. skill-matcher.sh ─
echo "┌─ 5. skill-matcher.sh"
OUT=$(bash "$SCRIPT_DIR/skill-matcher.sh" "" 2>&1) || true
json_valid "$OUT"                  && ok "skill-matcher:valid_json_empty"    || fail "skill-matcher:valid_json_empty" "not JSON"
json_has_key "$OUT" "matches"      && ok "skill-matcher:matches_field"       || fail "skill-matcher:matches_field" "missing"
json_has_key "$OUT" "best_match"   && ok "skill-matcher:best_match_field"    || fail "skill-matcher:best_match_field" "missing"
json_has_key "$OUT" "recommendation" && ok "skill-matcher:recommendation_field" || fail "skill-matcher:recommendation_field" "missing"
OUT2=$(bash "$SCRIPT_DIR/skill-matcher.sh" "security audit auth" 3 2>&1) || true
json_valid "$OUT2"                 && ok "skill-matcher:valid_json_query"    || fail "skill-matcher:valid_json_query" "not JSON"
json_has_key "$OUT2" "best_score"  && ok "skill-matcher:best_score_field"    || fail "skill-matcher:best_score_field" "missing"
echo "$OUT2" | grep -q '"recommendation"' && ok "skill-matcher:recommendation_present" || fail "skill-matcher:recommendation_present" "missing"
echo "$OUT2" | grep -o '"skill"' | wc -l | xargs | grep -qE '^[0-3]$' && ok "skill-matcher:top_n_respected" || fail "skill-matcher:top_n_respected" "too many results"
echo ""

# ─ 6. audit-tracker.sh ─
echo "┌─ 6. audit-tracker.sh"
OUT=$(bash "$SCRIPT_DIR/audit-tracker.sh" "$P" 2>&1) || true
json_valid "$OUT"                  && ok "audit-tracker:valid_json"          || fail "audit-tracker:valid_json" "not JSON"
json_has_key "$OUT" "files_scanned" && ok "audit-tracker:files_scanned_field" || fail "audit-tracker:files_scanned_field" "missing"
json_has_key "$OUT" "matches"      && ok "audit-tracker:matches_field"       || fail "audit-tracker:matches_field" "missing"
json_has_key "$OUT" "recommendation" && ok "audit-tracker:recommendation_field" || fail "audit-tracker:recommendation_field" "missing"
OUT2=$(bash "$SCRIPT_DIR/audit-tracker.sh" "$P" "/nonexistent/path/TRACKING.md" 2>&1) || true
json_has_key "$OUT2" "error"       && ok "audit-tracker:missing_table_handled" || fail "audit-tracker:missing_table_handled" "no error"
echo ""

# ─ 7. install.sh --check ─
echo "┌─ 7. install.sh --check"
DRY_OUT=$(bash "$SCRIPT_DIR/install.sh" --check 2>&1) || true
echo "$DRY_OUT" | grep -q "DRY RUN\|Will install" && ok "install:dry_run_works" || fail "install:dry_run_works" "no dry run message"
echo ""

# ─ Summary ─
echo "═══════════════════════════════════════"
echo -e "  ${G}${PASS} passed${N}  ${R}${FAIL} failed${N}  ${TOTAL} total"
echo "═══════════════════════════════════════"
[ "$FAIL" -eq 0 ] && echo -e "  ${G}✅ ALL TESTS PASSED${N}\n" && exit 0
echo -e "  ${R}❌ ${FAIL} TEST(S) FAILED${N}\n" && exit 1
