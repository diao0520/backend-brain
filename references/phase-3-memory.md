     - NEVER: DELETE without WHERE | TRUNCATE | raw DROP | hardcoded IDs
  ✅ Tracking table MANDATORY sections (in order):
     1. Header blockquote (version, date, scan, tool, stack, stage)
     2. 使用说明 (Usage Guide): status marker legend + priority legend
     3. 总览统计 (Overview): Phase × status matrix
     4. Phase tables (11 columns, one per Phase)
     5. 里程碑 (Milestones): M0-MN with IDs + estimated + status
     6. 变更日志 (Change Log): per-session append-only entries
     (ALL SIX sections are mandatory. Never skip any.)

  ✅ CLAUDE.md: merge if exists / generate if not (template includes auto-trigger hint)
  ✅ Q3 → milestones table (included in section 5 above)
  ✅ preferences-default.json → replace {{date}} → Write .claude/memory/preferences.json
  ✅ Bash session-archive.sh → register project + git snapshot

