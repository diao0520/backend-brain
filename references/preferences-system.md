# Preferences System Reference

> v1 only uses `interaction_style.verbosity`。Rest reserved for v2。

## v1

| 字段 | 默认 | Phase | 用途 |
|------|------|-------|------|
| `interaction_style.verbosity` | `"normal"` | Phase 3 | compact=1行 / normal=标准 / verbose=详细 |

## v2 预留

完整 Schema → `assets/templates/preferences-default.json`

### 信号→字段

| Behavior | Threshold | Update |
|------|------|------|
| Reply <5字 | ×3 | `verbosity="compact"` |
| 回答>50字 | ×3 | `verbosity="verbose"` |
| Consecutive `--fix` | ×3 | `code_first=true` |
| Reverts AI changes | ×3 | `show_diff_before_apply=true` |
| Skips recommendation | ×3 | `skipped[agent]=999` |

### Trust Level

`0.0-0.3` ask more → `0.6-0.8` infer freely → `0.8-1.0` full auto

> v1→v2: Phase 7 按信号Update preferences.json → confidence>0.8 后自动模式
