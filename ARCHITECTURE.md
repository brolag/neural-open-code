# Neural OpenCode architecture

Neural OpenCode has two layers: one plugin package and documented project
config keys. This mirrors OpenCode 1.18.31's distribution model (npm/file
plugins + disk skills) and keeps authoring, installation, and runtime paths
unambiguous.

```text
repository
├── opencode.json
├── opencode.example.json
└── plugins/neural-open-code
    ├── package.json
    ├── index.js
    ├── skills
    │   ├── discover
    │   ├── spec
    │   ├── craft
    │   ├── vet
    │   └── exercise
    └── hooks
        └── *.js
```

## Why this is not a Codex marketplace

OpenCode 1.18.31 has no plugin marketplace, no `plugin.json` skill manifest,
and no `hooks.json`. Plugins are TypeScript/JavaScript modules that return a
`Hooks` object. Skills are `SKILL.md` trees discovered from `.opencode/skills`
or `skills.paths`. Neural OpenCode therefore ships one package and asks the
user to add two explicit keys.

## Plugin boundary

`package.json` identifies the package (`name`, `exports["./server"]`,
`engines.opencode`). The entry registers only lifecycle hooks. It does not
declare MCP servers, models, permissions, or agents.

## Workflow boundary

The five skills have intentionally different authority:

1. `/discover` gathers unknowns and stops.
2. `/spec` writes an approvable contract and stops.
3. `/craft` implements only an approved contract.
4. `/vet` evaluates in fresh context and returns `SHIP` or `HOLD`.
5. `/exercise` runs tests and drives observable user behavior.

No skill silently collapses planning, implementation, review, and exercise into
one self-certifying step.

## Hook boundary

Hooks implement OpenCode events:

- `tool.execute.before` — inspect `bash`, `write`, `edit`, and `apply_patch`
- `tool.execute.after` — scan tool output
- `experimental.session.compacting` — write a recovery note

They throw to block. They do not call the `config` hook. They complement
OpenCode permission policy; they do not replace it.

## Configuration boundary

The plugin never changes model, approval, sandbox, network, MCP, or global
configuration. `docs/CONFIGURATION.md` contains examples only, which keeps
installation reversible and policy-neutral.
