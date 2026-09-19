# Neural OpenCode project instructions

## Product boundary

Neural OpenCode is one installable OpenCode plugin. Its supported surface is
exactly five skills: `discover`, `spec`, `craft`, `vet`, and `exercise`, plus
the reviewed hooks under `plugins/neural-open-code/hooks/`.

Do not add a second skill root, a silent config writer, or an installer that
copies files into a user's home directory. The plugin package plus documented
`opencode.json` keys are the distribution contract.

OpenCode 1.18.31 has no marketplace API and no `hooks.json`. Do not invent
Codex `.codex-plugin` paths or Claude `settings.json` merges.

## Canonical paths

- Plugin package: `plugins/neural-open-code/package.json`
- Plugin entry: `plugins/neural-open-code/index.js`
- Skills: `plugins/neural-open-code/skills/<name>/SKILL.md`
- Hooks: `plugins/neural-open-code/hooks/`
- Example config: `opencode.example.json`
- Public docs: `docs/`
- Plans and evidence: `plans/`
- Unsupported 1.9.0 surface: `archived/v1.9.0/`

## Change workflow

Use `/discover` for material ambiguity, `/spec` before non-trivial
implementation, `/craft` for an approved plan, and independent `/vet` plus
`/exercise` gates before shipping. Keep generated evidence beside its plan.

Never auto-trust hooks or mutate a user's global OpenCode configuration. Never
commit credentials or read/write `.env` contents as part of validation.

## Required validation

```bash
python3 -m pytest -q
node --test tests/hooks.test.js
./scripts/doc-lint.sh
```

A valid directory shape is necessary but not sufficient: tests must also reject
stale claims and unsupported inventory.

## Documentation map

- Architecture: `ARCHITECTURE.md`
- Harness contract: `docs/AGENT-HARNESS.md`
- Workflow: `docs/WORKFLOW.md`
- Hooks and trust: `docs/HOOKS.md`
- Model availability and prompting: `docs/CONFIGURATION.md`
- Verification: `docs/VERIFICATION.md`
