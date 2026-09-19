# Neural OpenCode architecture

One OpenCode project plugin. Five gated skills plus reviewed hooks.

```text
repository
├── opencode.json
├── AGENTS.md
└── .opencode
    ├── skills/{discover,spec,craft,vet,exercise}/SKILL.md
    ├── commands/{discover,spec,craft,vet,exercise}.md
    └── plugin/neural-hooks.js
```

## Skill authority

1. `/discover` gathers unknowns and stops.
2. `/spec` writes an approvable contract and stops.
3. `/craft` implements only an approved contract.
4. `/vet` evaluates in fresh context and returns `SHIP` or `HOLD`.
5. `/exercise` drives observable user behavior and returns `PASS` or `FAIL`.

No skill collapses planning, implementation, review, and exercise into one self-certifying step.

Quality gates ride that same pipeline: OWASP ASVS + CWE (security), ISO/IEC 25010 (simplicity), WCAG 2.2 AA (accessibility). They are contract fields, not a sixth skill.

## Hook boundary

`neural-hooks.js` blocks high-confidence destructive shell, writes to `.env*`, and injects a compact recovery note. Hooks complement OpenCode `permission`; they do not replace it.

## Configuration boundary

The plugin does not set model, provider, MCP servers, or global `~/.config/opencode` files. Installation is the repository itself (or `OPENCODE_CONFIG_DIR` pointing at `.opencode/`).
