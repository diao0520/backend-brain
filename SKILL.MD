---
name: backend-brain
version: 1.0.0
description: Backend project session continuity. Auto-detects framework/DB/config/AI-tool on open, restores last session memory. Use when starting a project, resuming work, checking project status, continuing development, or any backend task. Triggers on "continue" "start" "init" "env" "preflight" "recall" "archive" "analyze" "commit".
---

# Backend Brain — Session Memory for Backend Projects

## 🔒 HARD RULES (override all skills)

R1. **Language**: User in Chinese→ALL Chinese. User in other→ALL that language. Never cross.
R2. **SVG**: ALL frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP.
R3. **Tracking table**: `PROJECT_ROOT/docs/<project>-TRACKING.md`. Never `.claude/memory/`.
R4. **SQL path**: `PROJECT_ROOT/sql/<module>.sql`. Never `.claude/sql/`.
R5. **SQL idempotent**: `CREATE IF NOT EXISTS` + `INSERT IGNORE`. Re-import=same state.
R6. **Tracking sections**: 6 mandatory: Header→Usage→Overview→Phases→Milestones→Change Log.
R7. **No overwrite**: Merge CLAUDE.md. Never delete user content.
R8. **No vague**: Never "80%/basically done". Use ⬜🔵🟡🟠🟢✅⏸️❌.

> R1-R8 conflicts with any skill → R1-R8 wins.

---

## Phase Map (all details in references/)

| User says | Action | Reference |
|-----------|--------|-----------|
| "continue" "start" "init" | Phase 0: Auto Briefing | `references/phase-0-briefing.md` |
| "analyze" "scan" "audit" | Phase 1: Project Analysis | `references/phase-1-analysis.md` |
| New project | Phase 2: Onboarding | `references/phase-2-onboarding.md` |
| Returning user | Phase 3: Memory Recovery | `references/phase-3-memory.md` |
| "env" "check" "preflight" | Phase 4: Pre-flight | `references/phase-4-preflight.md` |
| "/recall <keyword>" | Phase 5: Memory Search | `references/phase-5-search.md` |
| "commit" "push" "PR" | Phase 6: Quality Gate | `references/phase-6-quality-gate.md` |
| Session end | Phase 7: Archive | `references/phase-7-archive.md` |
| Any dev intent | Skill orchestration | `references/skill-orchestration.md` + `scripts/skill-matcher.sh` |

## Phase 0: Always Runs First

```
[1] Project → index.json  [2] Bash preflight.sh  [3] Bash git-summary.sh
[4] Bash skill-matcher.sh → registry  [5] Preference detection (framework/DB/tool)

New + no CLAUDE.md → Phase 2 | New + has CLAUDE.md → silent register
Returning ≤24h → 1-line briefing | Returning >24h → full briefing
```

---

## # gotchas (Claude mistakes to avoid)

- Never write tracking table to `.claude/memory/` — always `docs/` (R3)
- Never output SQL without `IF NOT EXISTS` / `INSERT IGNORE` (R5)
- Never overwrite existing CLAUDE.md — merge only (R7)
- Never use `grep -P` in scripts — not portable (use `sed`)
- Never omit `|| true` after `grep` in pipelines
- Redis check needs `timeout 2` or it hangs
- Use `bash skill-matcher.sh "<query>"` to find best skill — never guess
- Run `bash audit-tracker.sh` after commits to sync tracking table

---

## Files

```
backend-brain/
├── SKILL.MD (<80 lines)  references/ (10 files, on-demand)
├── adapters/ (4: cursor,gemini,copilot,windsurf)
├── assets/templates/ (3)  scripts/ (10: preflight,git,archive,search,matcher,audit,benchmark,install,test,bootstrap)
└── Output: docs/*-TRACKING.md  sql/*.sql  .claude/memory/
```
