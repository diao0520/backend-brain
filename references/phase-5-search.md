Parallel:
  A. Read sessions/ last 2 files
  B. Bash git-summary.sh . $(cat last-session-hash)
  C. Read .claude/memory/preferences.json (interaction_style.verbosity)
     → unknown fields? Read <skill-dir>/references/preferences-system.md

Output (adapts to verbosity):
  "👋 [N] days since last session.
   Last: [summary] | Stuck: [issue]
   +[N] commits | [N] files changed
   Continue?"
```

---

## Phase 4: Pre-flight — Environment Check

```
Bash preflight.sh → JSON:
  ✅ Git: [branch] [clean/dirty]
  ✅ Dependencies: [current/outdated]
  ✅ Config: .env / application.yml present
  ✅ DB: migration status (if migration tool detected)
  ✅ SQL: sql/ dir exists + source SQL file count (read-only)
