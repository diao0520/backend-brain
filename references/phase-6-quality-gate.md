# Phase 6: Quality Gate — Pre-Commit Validation

> 代码提交前自动执行。检查→修复→验证→更新跟踪表。
> 用户说: "commit" "push" "PR" "merge" 时触发，或在会话结束前自动执行。

---

## Gate Pipeline (顺序执行，任一步失败=BLOCK)

### Gate 1: Build Check

```
Language-specific build verification:
- TypeScript: npx tsc --noEmit
- Java: ./mvnw compile -q / ./gradlew compileJava
- Go: go build ./...
- Python: python -m compileall . (syntax only)
- Rust: cargo check

Fail → suggest build-error-resolver agent
Timeout: 30s. Skip if no build tool detected.
```

### Gate 2: Lint Check

```
- ESLint (JS/TS): npx eslint --quiet .
- Pylint/Flake8/Ruff (Python): ruff check .
- golangci-lint (Go): golangci-lint run
- checkstyle (Java): ./mvnw checkstyle:check
- Clippy (Rust): cargo clippy --no-deps

Fail → list top 5 errors. Suggest auto-fix if available.
```

### Gate 3: Test Suite

```
Run project test suite:
- npm test / pytest / go test ./... / cargo test / ./mvnw test

Minimum: tests pass. Ideal: coverage ≥80%.

Coverage check (if tool available):
- Jest: --coverage
- pytest-cov: --cov
- go test -coverprofile
- JaCoCo (Java)

Fail → suggest tdd-guide agent
```

### Gate 4: Security Scan

```
Quick security checks (read-only, no network):
- grep for hardcoded keys: (password|secret|token|api_key)\s*=\s*['\"][^$]
- grep for unsafe SQL: (execute|query)\s*\(\s*['\"`].*\$
- Check .gitignore for: .env *.log *.pem credentials.json
- Detect committed secrets: git secrets --scan (if installed)

CRITICAL finding → BLOCK commit. Suggest security-reviewer agent.
```

### Gate 5: Tracking Table Sync

```
Match git diff files → tracking table "实现路径/文件" column:
- Hit found → auto-update Status + Progress + Last Scan
- New file not in any path → suggest adding tracking item
- File deleted → mark related items for review

Update:
- Header "Last Scan" date
- Overview stats (recalculate)
- Change Log append: | YYYY-MM-DD | IDs | Summary |
```

---

## Gate Result

```
PASS ✅ → All gates green → proceed to commit/archive
WARN ⚠️ → Non-blocking issues (lint warnings, coverage slightly below 80%)
BLOCK 🔴 → Critical issue → stop, suggest fix, do not archive

PASS + WARN:
  "✅ Quality gate passed (3 warnings)
   → Ready to commit. Session archive → Phase 7"

BLOCK:
  "🔴 Quality gate BLOCKED: [N] critical issues
   1. [issue description + suggested agent]
   2. [issue description + suggested agent]
   → Fix before commit or use --no-verify to skip"
```

---

## Integration with Phase 7

```
Phase 6 PASS → auto-trigger Phase 7 (Archive)
Phase 6 BLOCK → mark session as "blocked" in archive
Phase 6 skipped → Phase 7 runs with "quality_gate_skipped" flag
```

---

## Configurable Thresholds

| Parameter | Default | Description |
|-----------|---------|-------------|
| `min_test_coverage` | 80 | Percentage |
| `max_lint_errors` | 0 | Block if exceeded |
| `max_todo_density` | 5 per 1000 lines | Warn if exceeded |
| `security_scan` | true | Always run |
| `auto_fix_lint` | false | Auto-apply fix suggestions |
