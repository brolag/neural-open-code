# Hooks

OpenCode loads `.opencode/plugin/neural-hooks.js` automatically.

## Handlers

| Hook | Behavior |
|---|---|
| `tool.execute.before` (bash) | Blocks high-confidence destructive shell and force-push patterns. |
| `tool.execute.before` (edit/write) | Blocks writes to `.env` and `.env.*` except `.env.example`. |
| `experimental.session.compacting` | Injects a compact recovery note. |

`opencode.json` `permission` is the complementary policy layer.

## Boundaries

Hooks reduce mistakes. They do not replace:

- OpenCode permission prompts;
- branch protection;
- secret scanning in CI;
- human review for destructive or external side effects.

## Validate

```bash
node --check .opencode/plugin/neural-hooks.js
python3 -m pytest -q tests/test_plugin_structure.py
```
