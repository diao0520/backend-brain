# ⚡ Backend Brain — Session Memory for Backend Projects

# ⚡ Backend Brain — 后端项目会话记忆系统

<p align="center">
  <b>Open your project. AI remembers where you left off.</b><br>
  <b>打开项目，AI 自动记住你上次做到哪里。</b><br>
  <sub>Pure Bash + Markdown · 1000+ auditable lines · Zero dependencies · No data uploads</sub><br>
  <sub>纯 Bash + Markdown · 1000+ 行可审计代码 · 零依赖 · 不上传任何数据</sub>
</p>

<p align="center">
  <a href="#install"><img src="https://img.shields.io/badge/install-bash%20install.sh-green"></a>
  <a href="#supported-tools"><img src="https://img.shields.io/badge/tools-Claude%20Code%20%7C%20Cursor%20%7C%20Gemini%20%7C%204%2B-blue"></a>
  <a href="#"><img src="https://img.shields.io/badge/focus-backend-orange"></a>
  <a href="#"><img src="https://img.shields.io/badge/audit-1000%2B%20lines-lightgrey"></a>
</p>

---

## Before vs After · 使用前后对比

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
You: *重新解释 5 分钟的背景*                你: "继续" → 立刻开始工作
```

---

## Install · 安装

```bash
# One-line remote install (recommended) · 一行远程安装（推荐）
curl -fsSL https://raw.githubusercontent.com/diao0520/-backend-brain/main/scripts/bootstrap.sh | bash

# Or local install · 或本地安装
bash .claude/skills/backend-brain/scripts/install.sh

# Pre-flight check (dry-run, no changes) · 预检（试运行，不做任何更改）
bash .claude/skills/backend-brain/scripts/install.sh --check
```

> Zero dependencies. Python optional (only improves JSON merging). No data ever uploaded.
> 零依赖。Python 可选（仅用于优化 JSON 合并）。绝不上传任何数据。

---

## What It Does · 功能一览

| Capability · 能力 | Description · 描述 |
|------------|-------------|
| **Session Memory** · 会话记忆 | Open project → what you did last, what's blocked, environment status · 打开项目 → 上次做了什么、卡在哪里、环境状态 |
| **Framework Detection** · 框架检测 | Spring Boot / FastAPI / Express / Gin / Django ... |
| **DB Checks** · 数据库检查 | Flyway / Liquibase / Alembic migration detection + Redis connectivity · 迁移检测 + Redis 连通性 |
| **CLAUDE.md Generation** · CLAUDE.md 生成 | API conventions, DB rules, layered architecture, middleware chain · API 规范、数据库规则、分层架构、中间件链 |
| **Tracking Table** · 跟踪表 | 11 columns: ID/Feature/Description/Acceptance/Path/Priority/Status/Progress/Scan/Notes · 11 列 |
| **Auto-Audit** · 自动审计 | Match git changes to tracking items → auto-update status · Git 变更匹配跟踪项 → 自动更新状态 |
| **Memory Search** · 记忆搜索 | `/recall <keyword>` → grep session history (zero-dependency) · `/recall <关键词>` → 搜索会话历史（零依赖） |
| **Change Log** · 变更日志 | One entry per session, like git commits · 每次会话一条记录，类似 Git 提交 |
| **Idempotent SQL** · 幂等 SQL | sql/ dir per module, `CREATE IF NOT EXISTS` + `INSERT IGNORE` |

---

## Skill Orchestration — Auto-Discover & Dispatch · 技能编排 — 自动发现与调度

Backend Brain is your **entry skill**. Any development intent gets intercepted, available skills are scanned, and the best match is invoked.
Backend Brain 是你的**入口技能**。任何开发意图都会被拦截，扫描可用技能，然后调用最佳匹配。

```
You: "Audit the auth module for security issues"
你: "审计认证模块的安全问题"
  → Backend Brain scans global + project skills
  → Backend Brain 扫描全局 + 项目技能
  → Found: security-reviewer (98% match) · 找到: security-reviewer（98% 匹配）
  → Auto-invokes security-reviewer → finds JWT key hardcoded ⚠️
  → 自动调用 security-reviewer → 发现 JWT 密钥硬编码 ⚠️
  → Updates tracking table A04 notes: "Security audit: 2 critical items"
  → 更新跟踪表 A04 备注："安全审计：2 个严重问题"

You: "The login page UI looks terrible" · 你: "登录页 UI 太丑了"
  → Found: frontend-design (95% match) · 找到: frontend-design（95% 匹配）
  → Auto-invokes frontend-design → generates new UI
  → 自动调用 frontend-design → 生成新 UI

You: "Database queries are slow" · 你: "数据库查询太慢了"
  → Found: database-reviewer (93% match) · 找到: database-reviewer（93% 匹配）
  → Auto-invokes → analyzes slow queries → suggests indexes
  → 自动调用 → 分析慢查询 → 建议索引
```

**Any third-party skill is auto-discovered and dispatched.** No manual configuration needed.
**任何第三方技能都会被自动发现并调用。** 无需手动配置。

---

## The Backend Brain Method · Backend Brain 方法论

> More than a skill — a **tracking-table-driven AI development methodology**.
> 不只是一个技能 — 是一套**跟踪表驱动的 AI 开发方法论**。

```
1. Phase 2 Onboarding → 3 questions → generates CLAUDE.md + 11-column tracking table
   第二阶段引导 → 3 个问题 → 生成 CLAUDE.md + 11 列跟踪表
2. Every session → auto briefing + match git changes → update tracking table
   每次会话 → 自动简报 + 匹配 Git 变更 → 更新跟踪表
3. Every session end → change log + Stop Hook archive → seamless next session
   每次会话结束 → 变更日志 + Stop Hook 存档 → 下次会话无缝衔接
4. Team sharing → git add .claude/memory/ → git push → everyone synced
   团队共享 → git add .claude/memory/ → git push → 全员同步
```

**Competitors are memory libraries. Backend Brain is your daily standup. Only the 3 things that matter.**
**竞争对手是记忆库。Backend Brain 是你的每日站会。只告诉你最重要的 3 件事。**

---

## vs Competitors · 竞品对比

| | Backend Brain | memsearch | AgentKits |
|---|---|---|---|
| **Approach** · 方式 | Backend butler · 后端管家 | Search engine · 搜索引擎 | Memory DB · 记忆数据库 |
| **On open** · 启动时 | Proactive briefing · 主动简报 | Passive search · 被动搜索 | Passive search · 被动搜索 |
| **Backend native** · 后端原生 | ✅ framework/DB | ❌ | ❌ |
| **Tracking table** · 跟踪表 | ✅ 11-col + audit · 11列+审计 | ❌ | ❌ |
| **Runtime** · 运行时 | No process · 无进程 | watch daemon · 监听守护 | MCP server · MCP 服务器 |
| **Dependencies** · 依赖 | Bash | Haiku API | Node.js |
| **Auditable** · 可审计 | ✅ 1000+ lines · 行 | ❌ | ❌ |

---

## Supported Tools · 支持的工具

| Tool · 工具 | Status · 状态 | Integration · 集成方式 |
|------|:--:|------|
| **Claude Code** | ✅ Recommended · 推荐 | `.claude/skills/backend-brain/` — full Phase 0-7 · 完整 Phase 0-7 |
| **Cursor** | ✅ | `.cursorrules` — preflight + tracking table · 预检 + 跟踪表 |
| **Gemini CLI** | ✅ | `.gemini/rules/` — preflight + session memory · 预检 + 会话记忆 |
| **GitHub Copilot** | ✅ | `.github/copilot-instructions.md` — tracking table context · 跟踪表上下文 |
| **Windsurf** | ✅ | `.windsurfrules` — preflight + memory · 预检 + 记忆 |
| **Antigravity** | ✅ | Project rules — preflight + tracking · 项目规则 |
| **OpenCode** | ✅ | `.opencode/rules/` — preflight + session memory · 预检 + 会话记忆 |
| **Kiro IDE** | ✅ | IDE rules — preflight + tracking · IDE 规则 |

> Core scripts (`preflight.sh`, `git-summary.sh`, tracking table) are tool-agnostic Bash. Adapters config snippets in `adapters/`. Install auto-detects your tool.
> 核心脚本（`preflight.sh`、`git-summary.sh`、跟踪表）是与工具无关的 Bash。适配器配置片段在 `adapters/` 中。安装时自动检测你的工具。

## Supported Frameworks · 支持的框架

Spring Boot · FastAPI · Express · Gin · Django · Flask · Laravel · Rails · Go-Zero · Ktor · NestJS · Fiber

## Verified · 已验证

| Test · 测试 | Status · 状态 |
|------|:--:|
| Script regression suite · 脚本回归测试 | 11/11 ✅ |
| Spring Boot + MySQL (simulated) · 模拟 | 36-item tracking table · 36项跟踪表 ✅ |
| Memory search (empty DB) · 空库记忆搜索 | Graceful degradation · 优雅降级 ✅ |
| install --check dry-run · 安装预检 | ✅ |
| Existing CLAUDE.md merge · 现有文件合并 | No overwrite · 不覆盖 ✅ |

---

## Share This · 分享

```
# Reddit / Hacker News
Title: Show HN: Backend Brain — Claude Code skill that remembers where you left off
标题: Show HN: Backend Brain — 能记住你上次做到哪的 Claude Code 技能
Tags: #ClaudeCode #backend #devtools #ai

# Twitter
"Built a Claude Code skill for backend devs.
 Opens your project → tells you what you did last session.
 Pure Bash. 1000+ lines. No data leaves your machine."
 
"做了一个给后端开发者用的 Claude Code 技能。
 打开项目 → 告诉你上次会话做了什么。
 纯 Bash。1000+ 行代码。数据不出本机。"

# Team recommendation · 团队推荐
"You need this. Install → say 'continue' next session.
 It remembers what you were stuck on."

"装上它。下次会话直接说'继续'。
 它会记住你上次卡在哪里。"
```

---

**Backend Brain — AI that remembers your backend project.**
**Backend Brain — 能记住你后端项目的 AI。**
