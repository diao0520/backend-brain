#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — One-Click Install
# Usage: bash install.sh [project-path]
# ═══════════════════════════════════════════════════════════
set -euo pipefail

CHECK=false; PROJECT=""
for a in "$@"; do case "$a" in --check) CHECK=true ;; *) PROJECT="$a" ;; esac; done
PROJECT="${PROJECT:-$(pwd)}"
NAME="backend-brain"
SKILL_DIR="${PROJECT}/.claude/skills/${NAME}"
SETTINGS="${PROJECT}/.claude/settings.local.json"
SRC="$(cd "$(dirname "$0")/.." && pwd)"

G='\033[0;32m'; B='\033[0;34m'; Y='\033[1;33m'; R='\033[0;31m'; N='\033[0m'
say() { echo -e "$1"; }

echo ""
say "${B}⚡ Backend Brain — Session memory for AI${N}"
say ""

# 1. Check
say "${B}→${N} Checking environment..."
[ -d "$PROJECT" ] || { say "  ${R}❌ Project directory not found: $PROJECT${N}"; exit 1; }
say "  ${G}✅${N} Project: $(basename "$PROJECT")"

# Auto-detect framework
FW=""; [ -f "$PROJECT/pom.xml" ] && FW="Spring Boot"
[ -f "$PROJECT/requirements.txt" ] && grep -q "fastapi\|django\|flask" "$PROJECT/requirements.txt" 2>/dev/null && FW="Python"
[ -f "$PROJECT/package.json" ] && grep -q "express\|nestjs\|koa" "$PROJECT/package.json" 2>/dev/null && FW="Node.js"
[ -f "$PROJECT/go.mod" ] && FW="Go"
[ -n "$FW" ] && say "  ${G}✅${N} Framework: ${FW}" || say "  ${Y} ?${N} Framework: not detected"

# Auto-detect AI tool
TOOL=""; [ -d "$PROJECT/.claude" ] && TOOL="Claude Code"
[ -f "$PROJECT/.cursorrules" ] || [ -d "$PROJECT/.cursor" ] && TOOL="${TOOL:+$TOOL + }Cursor"
[ -d "$PROJECT/.gemini" ] && TOOL="${TOOL:+$TOOL + }Gemini CLI"
[ -f "$PROJECT/.github/copilot-instructions.md" ] && TOOL="${TOOL:+$TOOL + }Copilot"
[ -f "$PROJECT/.windsurfrules" ] && TOOL="${TOOL:+$TOOL + }Windsurf"
[ -n "$TOOL" ] && say "  ${G}✅${N} AI Tool: ${TOOL}" || say "  ${Y} ?${N} AI Tool: Claude Code (default)"

# Check CLAUDE.md
[ -f "$PROJECT/CLAUDE.md" ] && say "  ${Y}⚠${N} CLAUDE.md exists — will append trigger line, not overwrite" || say "  ${G}✅${N} CLAUDE.md: will create"

# Check Redis
command -v redis-cli >/dev/null 2>&1 && timeout 1 redis-cli ping >/dev/null 2>&1 && say "  ${G}✅${N} Redis: connected" || say "  ${Y} ?${N} Redis: not detected (跳过)"

# --check mode: stop here
if $CHECK; then
    say ""
    say "${B}── DRY RUN ──${N}"
    say "  Will install 28 files to: ${SKILL_DIR}"
    say "  Will add Stop Hook to: ${SETTINGS}"
    say "  No source files will be modified"
    say ""
    say "  ${G}Run install? Execute: bash install.sh${N}"
    exit 0
fi

# 2. Dirs
say "${B}→${N} Creating directories..."
mkdir -p "${SKILL_DIR}/assets/templates" "${SKILL_DIR}/scripts" "${SKILL_DIR}/references" "${SKILL_DIR}/adapters" "${PROJECT}/.claude/memory/projects"
say "  ${G}✅${N} .claude/skills/${NAME}/"

# 3. Copy
say "${B}→${N} Installing files..."
for f in SKILL.MD README.md \
         references/phase-0-briefing.md references/phase-1-analysis.md \
         references/phase-2-onboarding.md references/phase-3-memory.md \
         references/phase-4-preflight.md references/phase-5-search.md \
         references/phase-6-quality-gate.md references/phase-7-archive.md \
         references/preferences-system.md references/skill-orchestration.md \
         adapters/cursor.md adapters/gemini.md adapters/copilot.md adapters/windsurf.md \
         assets/templates/claude-md-boilerplate.md \
         assets/templates/session-summary.md \
         assets/templates/preferences-default.json \
         scripts/preflight.sh scripts/git-summary.sh \
         scripts/session-archive.sh scripts/search-memory.sh \
         scripts/skill-matcher.sh scripts/audit-tracker.sh \
         scripts/benchmark.sh scripts/preflight.ps1 scripts/learn-preferences.sh; do
    cp "${SRC}/${f}" "${SKILL_DIR}/${f}"
done
say "  ${G}✅${N} 28 files"

# 4. Permissions
chmod +x "${SKILL_DIR}/scripts/"*.sh "${SKILL_DIR}/scripts/"*.ps1 2>/dev/null || true
say "  ${G}✅${N} Script permissions"

# 5. Hook
say "${B}→${N} Configuring Hook..."
HOOK_CMD='bash .claude/skills/backend-brain/scripts/session-archive.sh "${PWD##*/}" "$(date +%Y-%m-%d)"'

PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")
if [ -n "$PY" ]; then
    $PY -c "
import json, os
p='$SETTINGS'
os.makedirs(os.path.dirname(p), exist_ok=True)
d=json.load(open(p)) if os.path.exists(p) else {}
d.setdefault('hooks',{}).setdefault('Stop',[])
desc='Backend Brain: auto-archive + update index'
if not any(h.get('description')==desc for h in d['hooks']['Stop']):
    d['hooks']['Stop'].append({'type':'command','command':'$HOOK_CMD','description':desc})
json.dump(d,open(p,'w'),indent=2,ensure_ascii=False)
"
    say "  ${G}✅${N} Hook configured"
    else
        mkdir -p "$(dirname "$SETTINGS")"
        if [ ! -f "$SETTINGS" ]; then
            printf '{
  "hooks": {
    "Stop": [
      {"type":"command","command":"%s","description":"Backend Brain: auto-archive"}
    ]
  }
}
' "$HOOK_CMD" > "$SETTINGS"
            say "  ${G}✅${N} Hook (no Python)"
        elif grep -q "Backend Brain" "$SETTINGS" 2>/dev/null; then
            say "  ${G}✅${N} Hook exists"
        else
            say "  ${Y}WARN${N} Settings exists. Manually add Stop Hook:"
        fi
fi

# 6. Done
say ""
say "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
say "${G}  ✅ Backend Brain Installation complete!${N}"
say "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
say ""
say "  📁 ${B}${SKILL_DIR}${N}"
say "  🪝 ${B}Auto-archive on every session end${N}"
say ""
say "  ${B}下次打开项目，说一句 '继续' 。${N}"
say ""
