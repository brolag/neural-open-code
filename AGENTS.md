# Neural OpenCode

Supported surface: five skills (`discover`, `spec`, `craft`, `vet`, `exercise`), matching slash commands, and `.opencode/plugin/neural-hooks.js`.

Do not add skill bundles, personas, autonomous loops, or an installer that copies files into a user's home directory.

## Paths

- Skills: `.opencode/skills/<name>/SKILL.md`
- Commands: `.opencode/commands/<name>.md`
- Plugin: `.opencode/plugin/neural-hooks.js`
- Config: `opencode.json`
- Docs: `docs/`
- Plans: `plans/`

## Workflow

`/discover` → `/spec` → approval → `/craft` → `/vet` + `/exercise` → ship.

Planning does not implement. Implementation does not self-approve. Green tests do not replace `/exercise`.

Quality gates are part of every material change, not extra skills: OWASP ASVS + CWE, ISO/IEC 25010, WCAG 2.2 AA (or explicit `n/a`). `/spec` writes them, `/craft` must not drop them, `/vet` judges them, `/exercise` drives what a user can observe.

## Validation

```bash
python3 -m pytest -q
./scripts/doc-lint.sh
```

Restart OpenCode after changing config, skills, commands, or the plugin.
