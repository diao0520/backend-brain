# Changelog

All notable changes to Backend Brain are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/) · [Semantic Versioning](https://semver.org/)

---

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
