# Phase 1: Project Analysis — Deep Codebase Scan

> Phase 0 之后、Phase 2(新项目)或Phase 3(回归)之前执行。
> 只读扫描，零副作用。输出项目健康报告卡。

---

## When This Runs

```
Phase 0 → Case A (new) → Phase 2 onboarding → THEN Phase 1 analysis
Phase 0 → Case C/D (returning) → Phase 3 memory → THEN Phase 1 (if >7 days stale)
User says: "analyze" "scan" "audit" "health check" "what's the state"
```

---

## Scan Dimensions (5 parallel)

### 1. Codebase Metrics

```
- File count by language: *.py / *.ts / *.java / *.go / *.rs / *.js
- Total lines of code (sloccount or wc -l fallback)
- Largest files (>500 lines): paths + line counts
- Deepest directories: nesting level
- Test file ratio: *test* / *spec* files vs total source files
```

### 2. Architecture Detection

```
- Layered? (controller/ service/ repository/ model/ dirs)
- Monolith vs microservices? (single entry point vs multiple)
- API style? (REST controllers / GraphQL schema / gRPC proto files)
- Event-driven? (message queue consumers / Kafka / RabbitMQ)
- CQRS? (separate read/write models)
```

### 3. Quality Indicators

```
- TODO/FIXME/HACK density: count per 1000 lines
- Comment ratio: comment lines / total lines
- Doc coverage: README / CONTRIBUTING / API docs / CHANGELOG
- Linter config: .eslintrc / .pylintrc / .golangci.yml / checkstyle
- CI config: .github/workflows/ / .gitlab-ci.yml / Jenkinsfile
- Test framework detection: pytest / jest / JUnit / Go testing / cargo test
```

### 4. Dependency Health

```
- Outdated packages: npm outdated / pip list --outdated / cargo outdated
- Known vulnerabilities: npm audit / pip-audit / cargo audit (if available, timeout 5s)
- Direct vs transitive dependency count
- License mix: scan package.json / requirements.txt / Cargo.toml
```

### 5. Git Health

```
- Branch count (local + remote)
- Stale branches (>30 days no commit)
- Merge conflict residue: grep <<<<<<< in source files
- Commit frequency: commits per week (last 4 weeks)
- Contributor count: git shortlog -sn
```

---

## Output: Project Health Report Card

```
📊 Project Health: [A/B/C/D/F]

A. Codebase
   Files: 247 | Languages: TS(180) Python(45) SQL(22)
   Lines: 32,450 | Tests: 12,100 (37%) | Large files: 3 (>500 lines)

B. Architecture
   Pattern: Layered REST API
   Layers: controller→service→repository→model ✅
   Concerns: No event layer. Direct DB from 2 controllers ⚠️

C. Quality
   TODOs: 34 (1.0/1K lines) | Comments: 8% | Docs: README only ⚠️
   Linter: ESLint ✅ | CI: GitHub Actions ✅ | Tests: Jest ✅

D. Dependencies
   Outdated: 12 packages | Vulnerabilities: 0 (npm audit clean) ✅
   License: MIT(180) Apache(15) Unknown(3) ⚠️

E. Git
   Branches: 14 | Stale: 4 (>30 days) | Commits: 8/week
   Contributors: 3 | Merge conflicts: 0 ✅

Overall: B+ (78/100)
→ Recommendations: Add API docs, clean stale branches, review unknown licenses
```

---

## Phase 1 Exit

```
→ Updates .claude/memory/index.json with health snapshot + timestamp
→ Feeds recommendations into Phase 2 tracking table (if new project)
→ Feeds warnings into Phase 3 briefing (if returning user)
→ Health score <60 → suggest Phase 2 re-onboarding
```
