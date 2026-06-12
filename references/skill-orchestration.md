# Skill 编排 — 动态发现第三方skills

> Backend Brain 负责"知道做什么"，其他skills负责"做"。

## Phase 0 Skill Discovery

```
并行:
  [4] Glob ~/.claude/skills/*/SKILL.MD          → 全局skills
  [5] Glob .claude/skills/*/SKILL.MD            → 项目skills
提取每个 Skill 的 name + description → 构建注册表
```

## Task→Skill Matching

| 任务特征 | 关键词 | 示例 |
|----------|--------|------|
| 写测试、新功能 | `tdd` `test` | tdd-guide |
| 代码审查 | `review` `lint` | code-reviewer |
| 构建错误 | `build` `compile` | build-error-resolver |
| 安全审计 | `security` `audit` | security-reviewer |
| API 文档 | `doc` `swagger` | doc-updater |
| 数据库/SQL | `database` `sql` | database-reviewer |
| 性能优化 | `perf` `benchmark` | performance-optimizer |
| 重构清理 | `refactor` `clean` | refactor-cleaner |
| E2E 测试 | `e2e` `playwright` | e2e-runner |
| 部署 CI/CD | `deploy` `docker` `k8s` | deploy-scripts |

## Trigger→Match→Invoke

```
用户: "优化前端登录页样式"
  → Searchskills → frontend-design (95%) → 自动调用 → 更新追踪表

用户: "审计认证模块安全性"
  → Searchskills → security-reviewer (98%) → 自动调用 → 更新追踪表

用户: "数据库慢了，看看 SQL"
  → Searchskills → database-reviewer (93%) → 自动调用 → 更新追踪表
```

## Skill Registry Cache

Phase 0 构建 → `.claude/memory/skill-registry.json` → 24h 有效 → 过期重新Search。

## Session-End Recommendation

```
This session: A04 JWT → ✅ | Next: B02 登录
Search 12 skills → Match: tdd-guide + security-reviewer + code-reviewer
💡 "用 tdd-guide 开始 B02" 或 "全部执行"
```
