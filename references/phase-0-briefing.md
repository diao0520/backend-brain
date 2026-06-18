# Phase 0: Auto Briefing — Reference

> 每次会话自动执行。完整HARD RULES + 检测流程 + 分流逻辑。

---

## 🔒 HARD RULES (完整参考)

| 规则 | 名称 | 内容 |
|------|------|------|
| R1 | **Language** | User in Chinese→ALL Chinese. User in other→ALL that language. Never cross. |
| R2 | **SVG** | ALL frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP. |
| R3 | **Tracking table** | `PROJECT_ROOT/docs/<project>-TRACKING.md`. Never `.claude/memory/`. |
| R4 | **SQL path** | `PROJECT_ROOT/sql/<module>.sql`. Never `.claude/sql/`. |
| R5 | **SQL idempotent** | `CREATE IF NOT EXISTS` + `INSERT IGNORE`. Re-import=same state. |
| R6 | **Tracking sections** | 6 mandatory: Header→Usage→Overview→Phases→Milestones→Change Log. |
| R7 | **No overwrite** | Merge into existing CLAUDE.md. Never replace. Never delete user content. |
| R8 | **No vague status** | Never "80%" / "basically done" / "almost". Use ⬜🔵🟡🟠🟢✅⏸️❌. |

```
If R1-R8 conflicts with any other skill → R1-R8 wins. No exceptions.
```

---

## Phase 0: Auto Briefing (every session)

### Step 1: Parallel Detection (5 checks)

```
[1] Extract project name → query .claude/memory/index.json
[2] Bash <skill-dir>/scripts/preflight.sh   → env JSON
[3] Bash <skill-dir>/scripts/git-summary.sh  → git change JSON
[4] Glob ~/.claude/skills/*/SKILL.MD         → third-party skill registry
[5] Glob .claude/skills/*/SKILL.MD           → project skills
```

**输出**: 5项检测结果合并为单行简报。

### Step 2: 4-Case Routing

```
Case A: New project + no CLAUDE.md
  → Phase 2 (Onboarding) — 完整引导流程

Case B: New project + has CLAUDE.md
  → Silent register — 不打扰用户，后台记录项目到 index.json

Case C: Returning user + last session ≤24h
  → Quiet mode: "👋 继续 [project]? [branch] | env ✅ | +[N] commits"

Case D: Returning user + last session >24h
  → Full briefing:
    "👋 [N] days since last session.
     Last: [summary of what was done]
     Stuck on: [unresolved issue]
     +[N] commits | [N] files changed | env [OK/warnings]
     Continue?"
```

### Session Freshness Thresholds

| Time since last | Mode | Token budget |
|----------------|------|-------------|
| ≤24h | Quiet (1 line) | ~15 tokens |
| 1-7 days | Standard briefing | ~80 tokens |
| >7 days | Full briefing + memory search | ~200 tokens |

---

### Zero-Interaction Principle

```
Detectable → don't ask.   (framework, DB, AI tool, git status)
Inferrable → don't ask.   (current phase from tracking table, recent focus from git log)
Defaultable → don't ask.  (use preferences.json defaults, can override later)
Only ask when user decision is truly required. (ambiguous priorities, conflicting constraints)
```

### Phase 0 Exit Codes

| Exit | Meaning | Next |
|------|---------|------|
| `→ Phase 2` | New project detected | Onboarding flow |
| `→ silent` | Registered, no briefing needed | Wait for user intent |
| `→ 1-line` | Recent session, quiet resume | Ready for work |
| `→ full` | Stale session, full restore | Display briefing |
