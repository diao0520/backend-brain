# {{project_name}}

> Generated: Backend Brain Phase 2 | {{date}}

## Project Overview

> ⚡ Run Backend Brain at the start of every session to check project status (say "continue" or "start").
> 
> **🔴 SVG RULE (OVERRIDES ALL SKILLS):** ALL frontend icons MUST be SVG. No PNG/JPEG/GIF/WebP.

{{description}}

## Tech Stack

| Layer | Technology | Version |
|-------|-----------|---------|
{{#each tech_stack}}
| {{layer}} | {{name}} | {{version}} |
{{/each}}

## Project Structure

```
{{structure}}
```

## Database

| Setting | Value |
|---------|-------|
| Type | {{db_type}} |
| ORM | {{orm}} |
| Migration | {{migration_tool}} |
| Pool Size | {{pool_size}} |
| Charset | UTF-8 |

> ⚠️ Migrations first. Never modify tables directly.

## API Conventions

| Rule | Value |
|------|-------|
| Prefix | `/api/v1/` |
| Format | `{ "code": 0, "data": ..., "msg": "ok" }` |
| Error Codes | Business 4xxx / System 5xxx |
| Pagination | `page`(1-based) `pageSize`(default 20, max 100) |
| Auth | JWT Bearer |
| Validation | All inputs must be validated |
| Docs | OpenAPI 3.0 |

## Middleware Chain

```
{{middleware_chain}}
```

## Environment Variables

> All env-specific config in `.env.*`. Never hardcode.

| Variable | Description | Example |
|----------|-------------|---------|
| `DB_HOST` | DB host | `127.0.0.1` |
| `DB_PORT` | DB port | `5432` |
| `DB_NAME` | DB name | `app` |
| `DB_USER` | DB user | `app` |
| `DB_PASS` | DB password | `***` |
| `REDIS_URL` | Redis | `redis://127.0.0.1:6379` |
| `JWT_SECRET` | JWT secret | `***` |
| `LOG_LEVEL` | Log level | `INFO` |
{{#each extra_env}}
| `{{key}}` | {{desc}} | `{{example}}` |
{{/each}}

## Logging

- Levels: DEBUG < INFO < WARN < ERROR < FATAL
- Format: JSON (production) / multiline (development)
- Required: `timestamp` `level` `trace_id` `message`
- Redact: passwords/tokens/PII → `***`

## Development Principles

### 1. Layered Architecture

```
Controller → validation + routing only
Service    → business logic
Repository → data access
No business logic in Controllers. No silent exceptions.
```

### 2. Code Standards

- Methods ≤ 50 lines / Classes ≤ 500 lines / Params ≤ 4 → use DTOs
- All public methods documented
- No N+1 queries / no `SELECT *` / no raw SQL concatenation
- Batch size ≤ 1000 / Transaction timeout ≤ 30s / Indexes need EXPLAIN

### 3. Testing

- Coverage ≥ 80%
- Unit: Service + Repository layers
- Integration: API endpoints + DB + Cache
- Every migration has rollback test

{{#if special_constraints}}
### 4. Special Constraints

{{special_constraints}}
{{/if}}

## Running

```bash
# Install dependencies
{{install_command}}

# Start infrastructure
{{db_start_command}}

# Run migrations
{{migrate_command}}

# Start dev server
{{start_command}}

# Run tests
{{test_command}}
```

## Prohibited

- ❌ Hardcoded passwords/keys/tokens
- ❌ DB dumps with real data committed
- ❌ SQL in Controllers
- ❌ Silent exception swallowing
- ❌ Direct production DB changes
- ❌ Vague completion status
