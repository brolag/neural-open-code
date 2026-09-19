# Neural OpenCode

Neural OpenCode is a small, evidence-gated workflow for [OpenCode](https://opencode.ai) **1.18.31+**:

```text
discover -> spec -> craft -> vet -> exercise
```

It is distributed as one OpenCode plugin. The repository intentionally ships
only those five skills and the reviewed lifecycle hooks that support them.

## Install

Requires [OpenCode](https://opencode.ai) **v1.18.31** or later (`opencode --version`).

Clone this repository, then add the plugin and skill path to **your project's**
`opencode.json`. The plugin does not edit global OpenCode config, model
selection, approval policy, sandbox settings, or MCP servers.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["./plugins/neural-open-code"],
  "skills": {
    "paths": ["./plugins/neural-open-code/skills"]
  }
}
```

If this repository lives outside the project, use an absolute path or a
`file://` URL instead of `./plugins/neural-open-code`. A copy-paste example is
in [`opencode.example.json`](opencode.example.json).

Restart OpenCode after changing project config. Confirm the plugin loaded and
review the hook source before trusting it in a session:

```bash
opencode --version
ls plugins/neural-open-code/hooks
```

Installing or enabling the plugin does not trust hooks automatically. OpenCode
1.18.31 has no `/hooks` trust UI; read `plugins/neural-open-code/hooks/` and
keep the plugin entry only if it matches your policy. Remove those two
`opencode.json` keys to uninstall.

## Workflow

| Skill | Purpose | Artifact or verdict |
|---|---|---|
| `/discover` | Surface architectural unknowns before planning | `unknowns-map.md` |
| `/spec` | Lock interfaces, invariants, dependencies, and acceptance | `plan.md` |
| `/craft` | Build an approved plan and capture before/after evidence | implemented change |
| `/vet` | Review the change independently and adversarially | `SHIP` or `HOLD` |
| `/exercise` | Drive the result as a user after automated tests | `PASS` or `FAIL` |

Small, obvious edits can skip `/discover` and sometimes `/spec`. Material work
should preserve the gates: planning does not implement, implementation does not
self-approve, and green tests do not replace behavioral verification.

See [the workflow guide](docs/WORKFLOW.md) for artifact contracts and examples.

## Hooks

The plugin includes dependency-free Node hooks for:

- blocking high-confidence destructive shell commands;
- guarding common secret-bearing files from writes;
- detecting obvious instruction injection in executable content;
- warning when tool output resembles credentials;
- preserving a compact recovery note before context compaction.

Hooks are guardrails, not a sandbox. Review their limits and trust model in
[docs/HOOKS.md](docs/HOOKS.md).

## Model and prompting guidance

Neural OpenCode does not change `opencode.json` model, agent, permission, MCP,
or sandbox fields beyond the two install keys you add. Model availability
differs by provider and account, so do not hardcode a model ID only because it
appears in a vendor guide. Safe copyable settings are separated in
[docs/CONFIGURATION.md](docs/CONFIGURATION.md).

## Repository structure

```text
opencode.json                              # this repo's local plugin + skills paths
plugins/neural-open-code/
  package.json                             # OpenCode 1.18.31 plugin package
  index.js                                 # hook registration
  skills/                                  # exactly five workflow skills
  hooks/                                   # tool.execute.* and compacting handlers
docs/                                      # focused guides and GitHub Page
tests/                                     # plugin, workflow, hook, and docs contracts
archived/v1.9.0/                           # unsupported 1.9.0 kitchen sink
```

The 2.0 plugin is a deliberate breaking cleanup. Previous command bundles,
personas, autonomous loops, courses, squads, TTS, multi-AI mesh, KPI/CA/cost
trackers, profiles, templates, and custom installers are not part of the
supported product. See [`archived/v1.9.0/UNSUPPORTED.md`](archived/v1.9.0/UNSUPPORTED.md).

## Develop and validate

Requirements: Python 3.11+, `pytest`, and Node.js 20+ (OpenCode's plugin
runtime is Bun; the hook units run on Node).

```bash
python3 -m pytest -q
node --test tests/hooks.test.js
./scripts/doc-lint.sh
```

The full verification and behavioral expectations are in
[docs/VERIFICATION.md](docs/VERIFICATION.md).

## Documentation

- [Architecture](ARCHITECTURE.md)
- [Agent harness](docs/AGENT-HARNESS.md)
- [Workflow](docs/WORKFLOW.md)
- [Hooks](docs/HOOKS.md)
- [Configuration](docs/CONFIGURATION.md)
- [Verification](docs/VERIFICATION.md)
- [GitHub Page](https://brolag.github.io/neural-open-code/)

## License

MIT — see [LICENSE](LICENSE)
