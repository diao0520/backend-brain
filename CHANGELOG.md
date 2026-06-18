# Changelog

All notable changes to Backend Brain are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/) · [Semantic Versioning](https://semver.org/)

---

## [1.0.2] — 2026-06-18

### Added

- **Output compression** (R9): caveman-style `output_style` system — `normal`/`compact`/`ultra` modes with progressive compression rules in SKILL.MD
- **output_style signal** in `learn-preferences.sh`: Accepts `{"signal":"output_style","value":"compact|ultra"}` signal to set output mode
- **Tests**: 2 new tests for output_style compact/ultra signals (43→50 total)
- **Fixed**: `learn-preferences.sh` value parser now correctly extracts string values without JSON quoting

## [1.0.1] — 2026-06-18

### Added

- **PowerShell preflight** (`scripts/preflight.ps1`): Native Windows environment check (G14)
- **Preferences v2 learning loop** (`scripts/learn-preferences.sh`): Signal→preference update cycle with confidence scaling (G15)
- **Tests**: 6 new tests covering preflight.ps1 and learn-preferences.sh

### Performance

- `audit-tracker.sh`: **32.8× faster** (13,465ms → 410ms) — nested while-read + grep → arrays + bash built-in matching
- `skill-matcher.sh`: **3.6× faster** (7,470ms → 2,070ms) — `echo|grep` subprocesses → bash `[[ ==* ]]` built-ins
- `benchmark.sh`: Fixed `$PROJECT` absolute path to prevent `cd` crash on deleted temp dir

## [1.0.0] — 2026-06-18

### Added

- **8-phase architecture**: Phase 0 (Briefing) → 1 (Analysis) → 2 (Onboarding) → 3 (Memory Recovery) → 4 (Pre-flight) → 5 (Search) → 6 (Quality Gate) → 7 (Archive)
- **Skill matching engine** (`scripts/skill-matcher.sh`): keyword→registry→TF-IDF scoring
- **Tracking table auto-audit** (`scripts/audit-tracker.sh`): git diff→tracking table matching
- **4 AI tool adapters** (`adapters/`): Cursor, Gemini CLI, GitHub Copilot, Windsurf
- **HARD RULES (R1–R8)** system with conflict resolution
- **6-section tracking table** specification
- **Idempotent SQL templates**

### Enhanced

- Multi-word fuzzy memory search with scoring (`search-memory.sh`)
- Input sanitization and injection protection
- Cross-platform HOME detection
- Performance benchmark suite (`scripts/benchmark.sh`): 13 scenarios, median-of-3 timing, baseline comparison with `--compare`

### Changed

- SKILL.MD 292→65 lines (73% token reduction via progressive disclosure)
- Test suite 11→43 tests (behavioral + boundary + JSON validation)
- install.sh: 11→25 files

### Fixed

- Bootstrap URL: `diao0520/-backend-brain` → `diao0520/backend-brain`
- `grep -P` → `sed` for portability, pipefail removed from grep scripts
- Redis check uses `timeout 2`, `os.makedirs` before index.json write
- Phase references no longer truncated

### Security

- Input validation on all scripts, env vars instead of string interpolation
- Session archive names validated against `^[a-zA-Z0-9_.-]+$`
