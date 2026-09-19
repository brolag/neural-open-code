# Model and prompting guidance

Neural OpenCode does not install or edit OpenCode configuration except for the
two project keys you add yourself (`plugin` and `skills.paths`). Review every
example against your own account, client version, permission, and cost policy.

## Model availability comes first

Do not copy a vendor model ID into `opencode.json` solely because a provider
guide discusses that model. Availability differs by product, account, and
client version.

Prefer the OpenCode default or a model your client explicitly lists. Provider
access in one product does not imply OpenCode client access.

## Balanced OpenCode policy

This example intentionally leaves `model` unset and shows only the Neural
OpenCode install keys:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["./plugins/neural-open-code"],
  "skills": {
    "paths": ["./plugins/neural-open-code/skills"]
  }
}
```

Permission, sandbox, MCP, and agent fields stay under your control. The plugin
must not write them.

To reverse installation, delete those two keys and restart OpenCode.

## Optional compact rules

OpenCode loads project `AGENTS.md` as always-on instructions. A short snippet
lives at `plugins/neural-open-code/rules/AGENTS.snippet.md`. Copy it only if
you want that overhead. The plugin does not inject rules into the system
prompt.

## Task-based adjustments

| Work | Notes |
|---|---|
| Mechanical, well-specified edit | Keep acceptance narrow and run tests. |
| Normal feature or refactor | Recommended general starting point. |
| Architecture, security, difficult debugging | Pair with explicit invariants and independent review. |

Model strength is not permission. Approval and isolation boundaries should be
chosen independently of model capability.

## Prompting principles

Prefer:

1. a concrete outcome and scope;
2. repository evidence and current constraints;
3. explicit authority and forbidden side effects;
4. executable acceptance criteria;
5. a clear stopping condition.

The five Neural OpenCode skills encode this structure in durable artifacts.
Avoid duplicating the full plan in every message; point OpenCode at the
source-of-truth artifact and record material amendments there.

Verify current behavior against the official
[OpenCode config](https://opencode.ai/docs/config),
[plugins](https://opencode.ai/docs/plugins), and
[skills](https://opencode.ai/docs/skills) docs before adopting a model ID in a
managed environment.
