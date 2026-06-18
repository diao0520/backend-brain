# Backend Brain → Windsurf Adapter

> 将此内容追加到 `.windsurfrules` 文件。
> Windsurf 在每次对话中自动加载该规则文件。

---

## Backend Brain — Session Memory for Backend Projects

You are augmented by Backend Brain, a backend-focused session continuity system. Follow these rules in addition to your default behavior.

### Session Start Protocol

At the beginning of each conversation:

1. **Check project state** (run in parallel):
   ```bash
   bash .claude/skills/backend-brain/scripts/preflight.sh
   bash .claude/skills/backend-brain/scripts/git-summary.sh
   ```

2. **Read last session context**:
   - Check `.claude/memory/index.json` for active project and last session date
   - If recent (≤24h): give a 1-line status, don't re-explain
   - If stale (>24h): give a full briefing with what was done, what's blocked, and changed files

3. **Locate tracking table** at `docs/<project>-TRACKING.md`

### Development Workflow

When working on features:

```
1. Find the feature in the tracking table (11-column format)
2. Mark 🔵 when you start working
3. Implement following the "Implementation Path" column
4. Verify against "Acceptance Criteria"
5. Mark ✅ when all criteria are met
6. Update "Last Scan" to today's date
7. Add a concise note in "Notes" about what changed
```

### Hard Constraints (override all other rules)

| Rule | Description |
|------|-------------|
| **SVG Only** | ALL frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP. |
| **Idempotent SQL** | `CREATE IF NOT EXISTS` + `INSERT IGNORE`. Never TRUNCATE or raw DROP. |
| **No Overwrite** | Merge into existing files. Never delete user content. |
| **No Vague Status** | Never "80% done" — use the 8-level emoji system. |
| **Tracking in docs/** | Tracking tables live in `docs/`, never in `.claude/memory/`. |
| **SQL in sql/** | SQL files live in `sql/` at project root, never in `.claude/sql/`. |

### Memory Search

When asked to find past work or decisions:
```bash
bash .claude/skills/backend-brain/scripts/search-memory.sh <project> <keyword>
```

### Session End

Before the conversation ends:
- Update the tracking table with progress
- Run: `bash .claude/skills/backend-brain/scripts/session-archive.sh <project>`
- Note any unresolved issues for the next session
