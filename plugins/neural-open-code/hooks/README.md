# Hooks

Neural OpenCode registers these handlers through the OpenCode 1.18.31 plugin API. There is no `hooks.json`; the plugin entry at `../index.js` returns hook functions.

| Handler | OpenCode event | Behavior |
|---|---|---|
| `dangerous-actions.js` | `tool.execute.before` (`bash`) | Blocks high-confidence destructive shell and protected-branch force-push patterns. |
| `sensitive-files.js` | `tool.execute.before` (`write`, `edit`, `apply_patch`) | Blocks writes to common secret-bearing files. |
| `prompt-injection.js` | `tool.execute.before` | Blocks obvious instruction-injection text in executable inputs while allowing documentation discussion. |
| `output-scanner.js` | `tool.execute.after` | Warns when tool output resembles credentials without repeating the detected value. |
| `pre-compact.js` | `experimental.session.compacting` | Writes `.opencode/compact-context.md` and appends a recovery pointer to the compaction context. |

Handlers use Node's standard library only. Blocking is done by throwing from `tool.execute.before`. OpenCode 1.18.31 has no `/hooks` trust UI: review this folder before adding the plugin to `opencode.json`.

## Trust limits

These hooks are guardrails, not a sandbox. They do not replace OpenCode permissions, filesystem policy, branch protection, CI secret scanning, or human review. They inspect the mapped tool arguments only; they cannot see every read, search, or external request.
