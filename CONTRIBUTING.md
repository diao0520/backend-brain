# Contributing

## Setup

```bash
git clone https://github.com/diao0520/backend-brain.git
cd backend-brain
bash scripts/test.sh .
```

## Style

- **Bash**: `set -eu`, no `jq`, no `grep -P`
- **Markdown**: Semantic line breaks
- **JSON**: Pure Bash construction, parsed with grep/sed

## Adding a Script

1. Place in `scripts/`, chmod +x
2. Add JSON output support
3. Add test to `scripts/test.sh`
4. Register in `scripts/install.sh`
5. Update `SKILL.MD` Files section + `CHANGELOG.md`

## Before Submitting

```bash
bash scripts/test.sh .        # Must pass all
bash scripts/install.sh --check  # Dry-run
```

## Commits

```
type: description
```
Types: `feat` `fix` `refactor` `test` `docs` `chore` `security`

## PR Process

1. Branch from `main`
2. Tests passing
3. Update `CHANGELOG.md`
4. Open PR
