# Hooks

Neural OpenCode packages lifecycle hooks in
`plugins/neural-open-code/index.js`. OpenCode 1.18.31 loads that module from
the project's `plugin` array and calls the returned `Hooks` object.

## Included handlers

| Handler | Event | Behavior |
|---|---|---|
| `dangerous-actions.js` | `tool.execute.before` | Blocks high-confidence destructive `bash` commands and protected-branch force-push patterns. |
| `sensitive-files.js` | `tool.execute.before` | Blocks `write` / `edit` / `apply_patch` changes to common secret-bearing files. |
| `prompt-injection.js` | `tool.execute.before` | Blocks obvious instruction-injection text in executable inputs while allowing documentation discussion. |
| `output-scanner.js` | `tool.execute.after` | Warns when tool output resembles credentials without repeating the detected value. |
| `pre-compact.js` | `experimental.session.compacting` | Writes `.opencode/compact-context.md` and adds a recovery pointer to compaction context. |

Handlers use only the Node standard library. A thrown error from
`tool.execute.before` is the block signal. Non-blocking deletion warnings from
the Codex port have no first-class OpenCode hook channel, so they are omitted
rather than faked.

## Trust

Installing or enabling the plugin does not trust its hooks. OpenCode 1.18.31
has no `/hooks` trust dialog. Read `plugins/neural-open-code/hooks/`, then keep
or remove the `plugin` entry in your project `opencode.json`. A changed hook
file should be reviewed again.

## Boundaries

Hooks reduce mistakes but do not replace:

- OpenCode permission policy;
- filesystem and network isolation you configure yourself;
- repository branch protection;
- secret scanning in CI;
- human review for destructive or external side effects.

The sensitive-file guard covers write/edit/apply_patch paths; it is not a
universal filesystem access control. The prompt-injection detector
intentionally targets obvious signals and cannot establish that arbitrary
external content is trustworthy.

The plugin does not register a `config` hook and does not change model,
approval, MCP, or sandbox settings.

## Validate

```bash
node --test tests/hooks.test.js
python3 -m pytest -q tests/test_hooks.py
```
