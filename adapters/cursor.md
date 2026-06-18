# Backend Brain → Cursor Adapter

> 将此内容追加到 `.cursorrules` 文件末尾。
> 如果使用 `.cursor/rules/` 目录，创建 `.cursor/rules/backend-brain.md`。

---

## Backend Brain Integration

```
You are assisted by Backend Brain, a session continuity system for backend projects.

At the start of every session:
1. Run: bash .claude/skills/backend-brain/scripts/preflight.sh
2. Run: bash .claude/skills/backend-brain/scripts/git-summary.sh
3. Check: docs/<project>-TRACKING.md for current status

When the user says "continue" or "start":
- Read .claude/memory/index.json for last session context
- Read .claude/memory/projects/<project>/last-session-hash
- Present a 1-line briefing before starting work

Tracking table: docs/<project>-TRACKING.md
- 11 columns: ID | Feature | Description | Acceptance | Path | Extensible | Priority | Status | Progress | Scan | Notes
- Status: ⬜not_started 🔵in-progress 🟡partial 🟠half 🟢mostly ✅done ⏸️paused ❌blocked
- Update tracking table after each significant change

SQL files: sql/<module>.sql
- MUST use CREATE IF NOT EXISTS + INSERT IGNORE (idempotent)
- Never output raw DROP or TRUNCATE

Hard rules (override all other instructions):
- All frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP.
- Never overwrite existing CLAUDE.md — merge only
- Never use vague status like "80% done"
```
