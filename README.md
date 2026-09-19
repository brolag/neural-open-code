# Neural OpenCode

Evidence-gated workflow for OpenCode:

```text
discover -> spec -> craft -> vet -> exercise
```

The repository ships only those five skills, matching slash commands, and the reviewed plugin hooks.

## Install

Clone this repository and open it with OpenCode, or point config at it:

```bash
git clone https://github.com/brolag/neural-open-code
export OPENCODE_CONFIG_DIR="$PWD/neural-open-code/.opencode"
```

Restart OpenCode. Confirm `/discover`, `/spec`, `/craft`, `/vet`, and `/exercise` are available.

Do not copy files into `~/.config/opencode` unless you choose to. The plugin never mutates global config.

## Workflow

| Command | Purpose | Artifact or verdict |
|---|---|---|
| `/discover` | Surface architectural unknowns before planning | `unknowns-map.md` |
| `/spec` | Lock interfaces, invariants, dependencies, acceptance | `plan.md` |
| `/craft` | Build an approved plan with before/after evidence | implemented change |
| `/vet` | Independent adversarial review | `SHIP` or `HOLD` |
| `/exercise` | Drive the result as a user after tests | `PASS` or `FAIL` |

Small edits can skip `/discover` and sometimes `/spec`. Material work keeps the gates. Security (OWASP ASVS), simplicity (ISO/IEC 25010), and accessibility (WCAG 2.2 AA) are locked in `/spec` and judged in `/vet`.

See [docs/WORKFLOW.md](docs/WORKFLOW.md).

## Hooks

The plugin:

- blocks high-confidence destructive shell commands;
- refuses writes to `.env` files;
- preserves a compact recovery note before compaction.

Hooks are guardrails, not a sandbox. See [docs/HOOKS.md](docs/HOOKS.md).

## Repository structure

```text
.opencode/skills/     # exactly five workflow skills
.opencode/commands/   # /discover /spec /craft /vet /exercise
.opencode/plugin/     # neural-hooks.js
docs/                 # focused guides
tests/                # inventory and docs contracts
plans/                # generated evidence
```

This is a breaking cleanup. Previous command bundles, personas, loops, TTS, templates, and custom installers are not part of the product.

## Validate

```bash
python3 -m pytest -q
./scripts/doc-lint.sh
```
