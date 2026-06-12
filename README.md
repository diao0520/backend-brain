# ⚡ Backend Brain — Session Memory for Backend Projects

<p align="center">
  <b>Open your project. AI remembers where you left off.</b><br>
  <sub>Pure Bash + Markdown · 1000+ auditable lines · Zero dependencies · No data uploads</sub>
</p>

<p align="center">
  <a href="#install"><img src="https://img.shields.io/badge/install-bash%20install.sh-green"></a>
  <a href="#supported-tools"><img src="https://img.shields.io/badge/tools-Claude%20Code%20%7C%20Cursor%20%7C%20Gemini%20%7C%204%2B-blue"></a>
  <a href="#"><img src="https://img.shields.io/badge/focus-backend-orange"></a>
  <a href="#"><img src="https://img.shields.io/badge/audit-1000%2B%20lines-lightgrey"></a>
</p>

---

## Before vs After

```
Before (without Backend Brain):            After (with Backend Brain):
─────────────────────────────────────    ─────────────────────────────────────
$ cd my-api-project                       $ cd my-api-project

Claude: "How can I help?"                  👋 user-service | feature/rate-limit
                                          ✅ DB migration | Redis ✅ | .env ✅
You: "I'm building a rate limiter,         📌 Last: RateLimiter — Lua atomicity
     stuck on Redis Lua scripts..."        🆕 +3 commits | 28/28 tests passing
                                          Continue?
You: *re-explain 5 min of context*
                                          You: "continue" → start immediately
```

---

## Install

```bash
# One-line remote install (recommended)
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/backend-brain/main/scripts/bootstrap.sh | bash

# Or local install
bash .claude/skills/backend-brain/scripts/install.sh

# Pre-flight check (dry-run, no changes)
bash .claude/skills/backend-brain/scripts/install.sh --check
```

> Zero dependencies. Python optional (only improves JSON merging). No data ever uploaded.

---

## What It Does

| Capability | Description |
|------------|-------------|
| **Session Memory** | Open project → what you did last, what's blocked, environment status |
| **Framework Detection** | Spring Boot / FastAPI / Express / Gin / Django ... |
| **DB Checks** | Flyway / Liquibase / Alembic migration detection + Redis connectivity |
| **CLAUDE.md Generation** | API conventions, DB rules, layered architecture, middleware chain |
| **Tracking Table** | 11 columns: ID/Feature/Description/Acceptance/Path/Priority/Status/Progress/Scan/Notes |
| **Auto-Audit** | Match git changes to tracking items → auto-update status |
| **Memory Search** | `/recall <keyword>` → grep session history (zero-dependency) |
| **Change Log** | One entry per session, like git commits |
| **Idempotent SQL** | sql/ dir per module, `CREATE IF NOT EXISTS` + `INSERT IGNORE` |

---

## Skill Orchestration — Auto-Discover & Dispatch

Backend Brain is your **entry skill**. Any development intent gets intercepted, available skills are scanned, and the best match is invoked.

```
You: "Audit the auth module for security issues"
  → Backend Brain scans global + project skills
  → Found: security-reviewer (98% match)
  → Auto-invokes security-reviewer → finds JWT key hardcoded ⚠️
  → Updates tracking table A04 notes: "Security audit: 2 critical items"

You: "The login page UI looks terrible"
  → Found: frontend-design (95% match)
  → Auto-invokes frontend-design → generates new UI
  → Updates tracking table F01 → 🟢

You: "Database queries are slow"
  → Found: database-reviewer (93% match)
  → Auto-invokes → analyzes slow queries → suggests indexes
```

**Any third-party skill is auto-discovered and dispatched.** No manual configuration needed.

---

## The Backend Brain Method

> More than a skill — a **tracking-table-driven AI development methodology**.

```
1. Phase 2 Onboarding → 3 questions → generates CLAUDE.md + 11-column tracking table
2. Every session → auto briefing + match git changes → update tracking table
3. Every session end → change log + Stop Hook archive → seamless next session
4. Team sharing → git add .claude/memory/ → git push → everyone synced
```

**Competitors are memory libraries. Backend Brain is your daily standup. Only the 3 things that matter.**

---

## vs Competitors

| | Backend Brain | memsearch | AgentKits |
|---|---|---|---|
| **Approach** | Backend butler | Search engine | Memory DB |
| **On open** | Proactive briefing | Passive search | Passive search |
| **Backend native** | ✅ framework/DB | ❌ | ❌ |
| **Tracking table** | ✅ 11-col + audit | ❌ | ❌ |
| **Runtime** | No process | watch daemon | MCP server |
| **Dependencies** | Bash | Haiku API | Node.js |
| **Auditable** | ✅ 1000+ lines | ❌ | ❌ |

---

## Supported Tools

| Tool | Status | Integration |
|------|:--:|------|
| **Claude Code** | ✅ Recommended | `.claude/skills/backend-brain/` — full Phase 0-7 |
| **Cursor** | ✅ | `.cursorrules` — preflight + tracking table |
| **Gemini CLI** | ✅ | `.gemini/rules/` — preflight + session memory |
| **GitHub Copilot** | ✅ | `.github/copilot-instructions.md` — tracking table context |
| **Windsurf** | ✅ | `.windsurfrules` — preflight + memory |
| **Antigravity** | ✅ | Project rules — preflight + tracking |
| **OpenCode** | ✅ | `.opencode/rules/` — preflight + session memory |
| **Kiro IDE** | ✅ | IDE rules — preflight + tracking |

> Core scripts (`preflight.sh`, `git-summary.sh`, tracking table) are tool-agnostic Bash. Adapters config snippets in `adapters/`. Install auto-detects your tool.

## Supported Frameworks

Spring Boot · FastAPI · Express · Gin · Django · Flask · Laravel · Rails · Go-Zero · Ktor · NestJS · Fiber

## Verified

| Test | Status |
|------|:--:|
| Script regression suite | 11/11 ✅ |
| Spring Boot + MySQL (simulated) | 36-item tracking table ✅ |
| Memory search (empty DB) | Graceful degradation ✅ |
| install --check dry-run | ✅ |
| Existing CLAUDE.md merge | No overwrite ✅ |

---

## Share This

```
# Reddit / Hacker News
Title: Show HN: Backend Brain — Claude Code skill that remembers where you left off
Tags: #ClaudeCode #backend #devtools #ai

# Twitter
"Built a Claude Code skill for backend devs.
 Opens your project → tells you what you did last session.
 Pure Bash. 1000+ lines. No data leaves your machine."

# Team recommendation
"You need this. Install → say 'continue' next session.
 It remembers what you were stuck on."
```

---

**Backend Brain — AI that remembers your backend project.**
