#!/usr/bin/env bash
# backend-brain Phase 7: 会话存档
# 用法: bash session-archive.sh <project> [date]
# 创建记忆目录 + 保存 git HEAD + 更新 index.json

set -euo pipefail
PROJECT="$1"
DATE="${2:-$(date +%Y-%m-%d)}"
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
  $PY -c "
import json, os
os.makedirs(os.path.dirname('$INDEX'), exist_ok=True)
data = {'active': '$PROJECT', 'last_checked': '$NOW', 'projects': {}}
if os.path.exists('$INDEX'):
    with open('$INDEX') as f:
        data = json.load(f)
data['active'] = '$PROJECT'
data['last_checked'] = '$NOW'
if '$PROJECT' not in data.get('projects', {}):
    data['projects']['$PROJECT'] = {'name': '$PROJECT', 'last_session': '$DATE', 'session_count': 0}
data['projects']['$PROJECT']['last_session'] = '$DATE'
data['projects']['$PROJECT']['session_count'] += 1
with open('$INDEX', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
"
fi

echo "✅ Session archive ready: ${PROJ_DIR}/sessions/session-${DATE}.md"
echo "📊 Index updated"
