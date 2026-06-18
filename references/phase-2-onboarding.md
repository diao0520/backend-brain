# Phase 2: Onboarding — Generate Project Brain

> 仅首次运行。自动检测 + ≤3个问题 → 生成CLAUDE.md + 跟踪表 + SQL模板。

---

## Step 1: Auto-Detect (silent, 5 checks)

```
A. Framework detection:
   - pom.xml → Spring Boot (Maven) / build.gradle → Spring Boot (Gradle)
   - requirements.txt + "fastapi" → FastAPI | + "django" → Django | + "flask" → Flask
   - package.json + "express" → Express | + "nestjs" → NestJS | + "koa" → Koa
   - go.mod → Go (check for gin/fiber/echo imports)
   - composer.json → Laravel
   - Gemfile → Rails
   - Cargo.toml → Rust (Actix/Axum)

B. Database detection:
   - application.yml: spring.datasource.url → MySQL/PostgreSQL
   - .env: DATABASE_URL / DB_HOST / DB_TYPE
   - application.properties: quarkus.datasource.db-kind
   - build.gradle/pom.xml: postgresql/mysql driver dependency

C. Migration tool detection:
   - db/migration/ → Flyway (Java)
   - alembic/ → Alembic (Python)
   - migrations/ → Django / Laravel / general
   - prisma/ → Prisma

D. AI tool detection:
   - .claude/ → Claude Code
   - .cursorrules / .cursor/ → Cursor
   - .gemini/ → Gemini CLI
   - .github/copilot-instructions.md → GitHub Copilot
   - .windsurfrules → Windsurf

E. Git snapshot:
   Bash git-summary.sh → insertions/deletions/commits

Anything detected → skip the question. Only ask what can't be detected.
```

---

## Step 2: Ask Only What's Undetectable (≤3 questions)

```
Q1: "Briefly describe this project?" (if no README or description found)
Q2: "Current stage?" → from-scratch / building / polishing / maintenance
Q3: "This week's goal?" → generates milestone row in tracking table

Framework/DB/AI-tool skipped if auto-detected in Step 1.
If user gives short answer, don't probe further — use defaults.
```

---

## Step 3: CLAUDE.md Strategy

```
Existing CLAUDE.md → Read → append Backend Brain trigger hint → Write (MERGE, never replace)

  Append to end of existing file:
  ```
  > ⚡ Run Backend Brain at the start of every session to check project status.
  > Say "continue" or "start".
  ```

No CLAUDE.md → Fill boilerplate template with detected values → Write

  Template: assets/templates/claude-md-boilerplate.md
  Filled with: project name, tech stack, DB info, API conventions, middleware chain
```

---

## Step 4: Generate Tracking Table

### Path: `PROJECT_ROOT/docs/<project>-TRACKING.md` (R3)

### 6 Mandatory Sections (R6):

```
1. Header blockquote:
   > **Document Version**: V1.0
   > **Creation Date**: YYYY-MM-DD
   > **Last Scan**: YYYY-MM-DD
   > **Tool**: Backend Brain Phase 2
   > **Tech Stack**: [framework] + [database]
   > **Current Stage**: [from-scratch / building / polishing / maintenance]

2. 使用说明 (Usage Guide):
   - Status marker legend: ⬜🔵🟡🟠🟢✅⏸️❌
   - Priority legend: P0(紧急) P1(高) P2(中) P3(低)
   - "Last Scan 列记录最后一次自动审计的时间"

3. 总览统计 (Overview):
   - Phase × Status matrix table
   - Total items / Completed / In Progress / Blocked counts

4. Phase Tables (11 columns each):
   | 编号 | 功能子项 | 需求描述 | 验收标准 | 实现路径/文件 | 可扩展功能 | 优先级 | 状态 | 完成度 | 最近扫描 | 备注 |

5. 里程碑 (Milestones):
   | 编号 | 里程碑 | 关联ID | 预计日期 | 状态 |
   M0-MN entries derived from Q3 answer

6. 变更日志 (Change Log):
   | 日期 | 涉及ID | 变更摘要 |
   (Empty initially, appended per session)
```

### 11-Column Format (headers follow LANGUAGE RULE):

```
Chinese:  | 编号 | 功能子项 | 需求描述 | 验收标准 | 实现路径/文件 | 可扩展功能 | 优先级 | 状态 | 完成度 | 最近扫描 | 备注 |
English:  | ID | Feature | Description | Acceptance Criteria | Implementation Path | Extensible To | Priority | Status | Progress | Last Scan | Notes |

Status: ⬜未开始 🔵进行中 🟡小部分 🟠半完成 🟢大部分 ✅完成 ⏸️暂停 ❌阻塞
Progress: 0% / 1-30% / 31-50% / 51-80% / 81-99% / 100%
Priority: P0(紧急) P1(高) P2(中) P3(低)
```

---

## Step 5: SQL Templates (Idempotent)

### Path: `PROJECT_ROOT/sql/<module>.sql` (R4)
### Rule R5: `CREATE IF NOT EXISTS` + `INSERT IGNORE`

```
Each SQL file MUST start with:
-- @idempotent
-- Module: <name>
-- Generated: Backend Brain Phase 2 | YYYY-MM-DD

DDL: CREATE TABLE IF NOT EXISTS / ADD COLUMN IF NOT EXISTS
DML: INSERT IGNORE INTO (MySQL) / ON CONFLICT DO NOTHING (PostgreSQL)
DROP: DROP TABLE IF EXISTS / DROP INDEX IF EXISTS

NEVER: DELETE without WHERE | TRUNCATE | raw DROP | hardcoded IDs
```

---

## Phase 2 Output Summary

```
✅ CLAUDE.md — created/merged
✅ docs/<project>-TRACKING.md — 6 sections, initial items
✅ sql/<module>.sql — idempotent templates
✅ .claude/memory/preferences.json — defaults
✅ .claude/memory/index.json — project registered
✅ Bash session-archive.sh — initial snapshot

Next: "The project brain is ready. Say 'continue' to start working."
```
