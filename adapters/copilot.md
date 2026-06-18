# Backend Brain → GitHub Copilot Adapter

> 将此内容追加到 `.github/copilot-instructions.md`。
> Copilot Chat 会自动读取该文件作为系统指令。

---

## Backend Brain Integration

This project uses Backend Brain for session continuity. Follow these conventions:

### Project State

Before suggesting code, check:
- `docs/<project>-TRACKING.md` — current feature status and progress
- `.claude/memory/index.json` — last session context
- Run `bash .claude/skills/backend-brain/scripts/preflight.sh` for environment status

### Tracking Table Conventions

The tracking table at `docs/<project>-TRACKING.md` uses:
- 11 columns: ID | Feature | Description | Acceptance Criteria | Implementation Path | Extensible To | Priority | Status | Progress | Last Scan | Notes
- Status: ⬜not_started 🔵in-progress 🟡partial 🟠half 🟢mostly ✅done ⏸️paused ❌blocked
- Priority: P0(critical) P1(high) P2(medium) P3(low)

When implementing a feature:
1. Find its row in the tracking table
2. Update status from ⬜ to 🔵 when starting
3. Update progress percentage as you work
4. Mark ✅ when complete with acceptance criteria met

### SQL Idempotency (CRITICAL)

All SQL output must be re-runnable without errors:
- `CREATE TABLE IF NOT EXISTS` (never bare `CREATE TABLE`)
- `INSERT IGNORE INTO` (MySQL) or `ON CONFLICT DO NOTHING` (PostgreSQL)
- `DROP TABLE IF EXISTS` (never bare `DROP TABLE`)
- Never: `DELETE` without `WHERE`, `TRUNCATE`, hardcoded auto-increment IDs

### SVG Only (HARD)

All frontend icons, logos, and graphics MUST be SVG format. Never suggest PNG, JPEG, GIF, or WebP for icons.

### Status Updates

Never use vague completion terms ("80% done", "basically finished", "almost there"). Use the 8-level emoji system from the tracking table.
