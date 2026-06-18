#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
# Backend Brain — 偏好系统 v2 学习循环
# 用法: learn-preferences.sh <project> <signal-json>
# 信号格式: {"signal":"verbosity","value":"compact"}
#           {"signal":"skip_agent","value":"code-reviewer"}
#           {"signal":"session_duration","value":45}
#           {"signal":"code_first","value":true}
# 输出: JSON — 更新后的偏好 + 推荐动作
# ═══════════════════════════════════════════════════════════
set -eu

PROJECT="${1:-}"
SIGNAL_JSON="${2:-}"

if [ -z "$PROJECT" ] || [ -z "$SIGNAL_JSON" ]; then
  echo '{"error":"usage: learn-preferences.sh <project> <signal-json>","preferences":null,"recommendation":"usage"}'
  exit 1
fi

ROOT="${HOME:-${USERPROFILE}}"
PREFS_DIR="$ROOT/.claude/memory/projects/$PROJECT"
PREFS_FILE="$PREFS_DIR/preferences.json"
TEMPLATE="$ROOT/.claude/skills/backend-brain/assets/templates/preferences-default.json"
mkdir -p "$PREFS_DIR"

# ── 1. Load or init preferences ──
if [ -f "$PREFS_FILE" ]; then
  PREFS=$(cat "$PREFS_FILE")
else
  [ -f "$TEMPLATE" ] && PREFS=$(cat "$TEMPLATE") || PREFS='{"_meta":{"version":2,"session_count":0,"confidence":0.3},"interaction_style":{"verbosity":"normal","code_first":false},"agent_affinity":{"favorites":{},"skipped":{}},"temporal_patterns":{"avg_session_minutes":0},"communication":{"language":"zh-CN"}}'
fi

# ── 2. Parse signal ──
_signal=$(echo "$SIGNAL_JSON" | python3 -c "
import json,sys
try: d=json.load(sys.stdin)
except: d={}
print(d.get('signal',''))
" 2>/dev/null || echo "")

_value=$(echo "$SIGNAL_JSON" | python3 -c "
import json,sys
try: d=json.load(sys.stdin)
except: d={}
v=d.get('value','')
print(json.dumps(v) if not isinstance(v, str) else v)
" 2>/dev/null || echo "")

[ -z "$_signal" ] && echo '{"error":"invalid signal","preferences":'$PREFS',"recommendation":"noop"}' && exit 0

# ── 3. Apply signal → preference update ──
UPDATED=$(python3 -c "
import json, sys

prefs = json.loads('''$PREFS''')
meta = prefs.setdefault('_meta', {})
meta['session_count'] = meta.get('session_count', 0) + 1
meta['updated'] = '$(date +%Y-%m-%d)'
changed = False
rec = None

signal = '$_signal'
value = '$_value'

if signal == 'verbosity':
    prefs.setdefault('interaction_style', {})['verbosity'] = value
    changed = True

elif signal == 'code_first':
    prefs.setdefault('interaction_style', {})['code_first'] = (value == 'true')
    changed = True

elif signal == 'skip_agent':
    aff = prefs.setdefault('agent_affinity', {})
    skipped = aff.setdefault('skipped', {})
    skipped[value] = skipped.get(value, 0) + 1
    aff['skipped'] = skipped
    if skipped[value] >= 3:
        rec = {'type':'mute','agent':value,'reason':'skipped 3 times'}
    changed = True

elif signal == 'session_duration':
    try: mins = int(float(value))
    except: mins = 0
    tp = prefs.setdefault('temporal_patterns', {})
    prev = tp.get('avg_session_minutes', 0) or 0
    cnt = meta.get('session_count', 1)
    tp['avg_session_minutes'] = int((prev * (cnt - 1) + mins) / cnt)
    changed = True

elif signal == 'explanation_depth':
    prefs.setdefault('interaction_style', {})['explanation_depth'] = value
    changed = True

elif signal == 'output_style':
    allowed = ['normal','compact','ultra']
    if value in allowed:
        prefs.setdefault('interaction_style', {})['output_style'] = value
        changed = True
        if value == 'ultra':
            rec = {'type':'max_compression','reason':'output_style=ultra'}
        elif value == 'compact':
            rec = {'type':'compact','reason':'output_style=compact'}

# Confidence adjustment
cnt = meta.get('session_count', 1)
meta['confidence'] = round(min(0.3 + cnt * 0.03, 0.95), 2)
if meta['confidence'] >= 0.8 and not rec:
    rec = {'type':'auto_mode','reason':'confidence >= 0.8'}
elif meta['confidence'] >= 0.6 and not rec:
    rec = {'type':'infer_allowed','reason':'confidence >= 0.6'}

print(json.dumps({'preferences':prefs, 'changed':changed, 'recommendation':rec}))
")

echo "$UPDATED"

# ── 4. Save ──
echo "$UPDATED" | python3 -c "
import json,sys
d=json.load(sys.stdin)
json.dump(d['preferences'], open('$PREFS_FILE','w'), indent=2, ensure_ascii=False)
" 2>/dev/null && echo \"  [saved] $PREFS_FILE\" >&2 || true
