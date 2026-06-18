# Backend Brain → Gemini CLI Adapter

> 将此内容添加到 `.gemini/rules/backend-brain.md`。
> Gemini CLI 会自动加载 `.gemini/rules/` 目录下的所有规则文件。

---

# Backend Brain — Session Continuity for Backend Projects

## Auto-Detection (run at session start)

When a session begins, run these checks in parallel:

```bash
# 1. Environment check
bash .claude/skills/backend-brain/scripts/preflight.sh

# 2. Git change summary
bash .claude/skills/backend-brain/scripts/git-summary.sh

# 3. Last session context
cat .claude/memory/index.json 2>/dev/null || echo '{"active":null}'
```

## Session Briefing

Based on check results, present:

```
Case: New project (no CLAUDE.md)
  → Run Phase 2 onboarding: ask 3 questions, generate CLAUDE.md + tracking table

Case: Returning ≤24h
  → Quiet: "👋 Continue [project]? [branch] | env ✅ | +[N] commits"

Case: Returning >24h
  → Full: "👋 [N] days. Last: [summary]. Stuck: [issue]. Continue?"
```

## Tracking Table

Path: `docs/<project>-TRACKING.md` (never `.claude/memory/`)

11 columns:
| ID | Feature | Description | Acceptance Criteria | Implementation Path | Extensible To | Priority | Status | Progress | Last Scan | Notes |

Status markers: ⬜🔵🟡🟠🟢✅⏸️❌

## SQL Rules (HARD)

- Path: `sql/<module>.sql` (project root, never `.claude/sql/`)
- All SQL MUST be idempotent: CREATE IF NOT EXISTS + INSERT IGNORE
- Never: DELETE without WHERE | TRUNCATE | raw DROP | hardcoded IDs

## SVG Rule (HARD)

ALL frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP. This overrides all other design instructions.

## Memory Search

When user asks to recall past work:
```bash
bash .claude/skills/backend-brain/scripts/search-memory.sh <project> <keyword>
```
