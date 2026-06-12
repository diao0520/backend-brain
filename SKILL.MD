---
name: backend-brain
description: Auto-trigger backend skill for Claude Code/Cursor/Gemini CLI/Windsurf/Copilot. Session continuity for backend projects. Auto-detects framework/database/config/AI-tool on open, restores last session memory. Pure Bash+Markdown, 1000+ auditable lines.
---

# Backend Brain — Session Memory for Backend Projects

> **LANGUAGE RULE (CRITICAL — OVERRIDES ALL OTHER RULES):**
> - User message in Chinese → ALL output in Chinese
> - User message in any other language → ALL output in that language
> - **NEVER** respond in Chinese to a non-Chinese user message, and vice versa.
> - Match the user's language exactly. This rule is hardcoded.

```
New project → 3 questions → CLAUDE.md + 11-column tracking table in 10 seconds
Returning → "👋 Last: E01 LTR, stuck on NPE. 3 TODOs | env OK. Continue?"
/recall <keyword> → grep session history (zero-dependency)
Session end → auto-archive + git HEAD snapshot
```

---

## Phase 0: Auto Briefing (every session)

### Step 1: Parallel Detection

```
[1] Extract project name → query .claude/memory/index.json
[2] Bash <skill-dir>/scripts/preflight.sh   → env JSON
[3] Bash <skill-dir>/scripts/git-summary.sh  → git change JSON
[4] Glob ~/.claude/skills/*/SKILL.MD         → third-party skill registry
[5] Glob .claude/skills/*/SKILL.MD           → project skills
```

### Step 2: One-Line Briefing

```
Case A: New project + no CLAUDE.md → Phase 2 (Onboarding)
Case B: New project + has CLAUDE.md → silent register
Case C: Returning + ≤24h → quiet mode (1 line)
Case D: Returning + >24h → full briefing
  "👋 [N] days since last. Last: [summary]. Stuck on: [issue].
   +[N] commits | env OK. Continue?"
```

### Zero-Interaction Principle

```
Detectable → don't ask. Inferrable → don't ask. Defaultable → don't ask.
Only ask when user decision is truly required.
```

---

## Phase 2: Onboarding — Generate Project Brain (first time only)

```
Parallel:
  A. Auto-detect (silent):
     - pom.xml → Spring Boot | requirements.txt + fastapi → FastAPI | go.mod → Go
     - application.yml/.env DB_HOST → infer database
     - Glob **/*.sql (read-only) + Bash git-summary.sh

  B. Ask only what can't be detected (≤3 questions):
     Q1: Project description?
     Q2: Current stage? (from-scratch / building / polishing / maintenance)
     Q3: This week's goal?
     (Framework/DB skipped if auto-detected)

  C. CLAUDE.md strategy:
     - Exists → Read → append Backend Brain trigger line → Write (merge, not overwrite)
     - None → fill claude-md-boilerplate.md → Write

Output:
  ✅ Tracking table with 11-column format:
     header (blockquote style):
     > **Document Version**: V1.0
     > **Creation Date**: YYYY-MM-DD
     > **Last Scan**: YYYY-MM-DD (summary of changes)
     > **Tool**: Backend Brain Phase 2
     > **Tech Stack**: [framework] + [database]
     > **Current Stage**: [from-scratch / building / polishing / maintenance]

  ✅ Table per Phase, 11 fixed columns:
     | ID | Feature | Description | Acceptance Criteria | Implementation Path | Extensible To | Priority | Status | Progress | Last Scan | Notes |

     Status: ⬜ not started  🔵 in-progress  🟡 partial  🟠 half  🟢 mostly  ✅ done  ⏸️ paused  ❌ blocked
     Progress: 0% / 1-30% / 31-50% / 51-80% / 81-99% / 100%

  ✅ SQL rules: create sql/ dir per module (user.sql / student.sql). Idempotent: CREATE IF NOT EXISTS + INSERT IGNORE. Split at ~200 lines.
  ✅ CLAUDE.md: merge if exists / generate if not (template includes auto-trigger hint)
  ✅ Q3 → 5-10 milestones (`- [ ] milestone [P0/P1/P2]`)
  ✅ preferences-default.json → replace {{date}} → Write .claude/memory/preferences.json
  ✅ Bash session-archive.sh → register project + git snapshot

Auto-audit each session:
  - Read tracking table → match modified files to "Implementation Path" column
  - Hit → update Status/Progress/Last Scan/Notes
  - Update header "Last Scan" + overview stats
  - Append change log entry

Session-end change log:
  | YYYY-MM-DD | IDs | Summary |
  Like git commits: ID + what changed + status transition. No vague entries.
  Prohibited: "fixed stuff" / "bug fix" / "updated code"
```

---

## Phase 3: Memory Recovery (returning user)

```
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
  ✅ Cache: Redis connectivity (if detected)
  ⚠️ [N] TODOs | 💡 [N] files >500 lines
```

---

## Phase 5: Memory Search (lightweight grep, zero-dependency)

```
User: "/recall <keyword>" or "/search <keyword>"

Bash <skill-dir>/scripts/search-memory.sh <project> <keyword> → JSON

Output:
  🔍 Found [N] results:

  📅 2026-06-10  session-2026-06-10.md
     "...JWT signature failed on Kylin env..."

  📅 2026-06-08  session-2026-06-08.md
     "...switched to /dev/urandom..."

  Expand which? Or "expand all"
```

> Unlike competitors: no SQLite, no vector DB, no MCP server. Pure grep — zero token overhead, zero install dependencies.

---

## Phase 7: Session Archive (on session end)

```
Claude proactively:
  1. Summarize: git diff --stat + decisions + blockers + next steps
  2. Fill session-summary.md template → Write sessions/session-YYYY-MM-DD.md
  3. Bash session-archive.sh → git HEAD snapshot + index.json
  4. "📝 Session archived."

Hook safety net (Stop):
  → session-archive.sh independently updates index
  → Even if Claude forgets Phase 7, index stays updated
```

---

## Team Sharing (optional)

```
git add .claude/memory/ && git commit -m "chore: update dev memory"
git push

Teammates see on clone:
  "👋 Team memory: @alice refactored auth yesterday, @bob fixing search.
   No conflicts detected."
```

> Inspired by Agent-Mem: git is the simplest sync mechanism.

---

## Skill Orchestration — Dynamic Third-Party Skill Discovery

→ **Read `<skill-dir>/references/skill-orchestration.md`** for full orchestration rules.

Core: Phase 0 scans global + project skills → builds registry. Any user intent → keyword-match skills → auto-invoke. Session-end recommends skill chain.

---

## Commands

| User says | Triggers |
|-----------|----------|
| "continue" / "start" / "init" | Phase 0 (auto briefing) |
| "env" / "check" / "preflight" | Phase 4 |
| "archive" / "save" | Phase 7 |
| **"/recall <keyword>"** | **Phase 5 (memory search)** |
| **"/search <keyword>"** | **Phase 5 (same)** |
| "team mode" / "share memory" | git add .claude/memory/ |

---

## File Structure

```
<skill-dir>/                          ← .claude/skills/backend-brain
├── SKILL.MD                          ← orchestrator (272 lines)
├── README.md                         ← human-readable + positioning
├── references/
│   ├── preferences-system.md         ← Preferences Schema + Signal Map
│   └── skill-orchestration.md        ← Third-party skill orchestration
├── assets/templates/
│   ├── claude-md-boilerplate.md      ← Onboarding: CLAUDE.md template
│   ├── session-summary.md            ← Archive: session summary template
│   └── preferences-default.json      ← Onboarding: initial preferences
└── scripts/
    ├── install.sh                    ← One-click install
    ├── preflight.sh                  ← Pre-flight: env check → JSON
    ├── git-summary.sh                ← Git change summary → JSON
    ├── session-archive.sh            ← Archive: snapshot + index
    ├── search-memory.sh              ← Lightweight memory search → JSON
    └── test.sh                       ← Regression test suite

Runtime output:
.claude/memory/                       ← git track for team sharing
├── index.json                        ← Multi-project index
├── preferences.json                  ← User preferences
└── projects/<name>/
    ├── sessions/session-*.md         ← Session archives
    └── last-session-hash             ← Git snapshot

sql/                                  ← Skill output, per-module idempotent
├── user.sql                          ← User module
├── student.sql                       ← Student module
└── ...                               ← Split at ~200 lines
```
