#!/usr/bin/env bash
# backend-brain Phase 7: 会话存档
# 用法: bash session-archive.sh <project> [date]
# 创建记忆目录 + 保存 git HEAD + 更新 index.json

set -euo pipefail
PROJECT="$1"
DATE="${2:-$(date +%Y-%m-%d)}"

# Input sanitization: only allow alphanumeric, hyphen, underscore, dot
if ! echo "$PROJECT" | grep -qE '^[a-zA-Z0-9_.-]+$'; then
  echo '{"error":"Invalid project name. Use only a-z, 0-9, hyphens, underscores, dots."}'
  exit 1
fi

# Cross-platform home directory detection
if [ -n "$HOME" ]; then
  ROOT="${HOME}/.claude/memory"
elif [ -n "$USERPROFILE" ]; then
  ROOT="${USERPROFILE}/.claude/memory"
else
  echo '{"error":"Cannot determine home directory"}' && exit 1
fi
PROJ_DIR="${ROOT}/projects/${PROJECT}"

mkdir -p "${PROJ_DIR}/sessions" "${PROJ_DIR}/pitfalls"

# Git snapshot
if git rev-parse --git-dir > /dev/null 2>&1; then
  git rev-parse HEAD > "${PROJ_DIR}/last-session-hash"
  echo "📸 Git HEAD saved"
fi

# Update index.json
INDEX="${ROOT}/index.json"
NOW=$(date -Iseconds)

PY=$(command -v python3 2>/dev/null || command -v python 2>/dev/null || echo "")
if [ -n "$PY" ]; then
  export BB_PROJECT="$PROJECT"
  export BB_DATE="$DATE"
  export BB_NOW="$NOW"
  export BB_INDEX="$INDEX"
  $PY -c "
import json, os
p = os.environ['BB_INDEX']
proj = os.environ['BB_PROJECT']
date = os.environ['BB_DATE']
now = os.environ['BB_NOW']
os.makedirs(os.path.dirname(p), exist_ok=True)
data = {'active': proj, 'last_checked': now, 'projects': {}}
if os.path.exists(p):
    with open(p) as f:
        data = json.load(f)
data['active'] = proj
data['last_checked'] = now
if proj not in data.get('projects', {}):
    data['projects'][proj] = {'name': proj, 'last_session': date, 'session_count': 0}
data['projects'][proj]['last_session'] = date
data['projects'][proj]['session_count'] += 1
with open(p, 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
fi

echo "✅ Session archive ready: ${PROJ_DIR}/sessions/session-${DATE}.md"
echo "📊 Index updated"
