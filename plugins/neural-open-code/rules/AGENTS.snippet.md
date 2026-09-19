# Neural OpenCode compact rules

Optional low-token project instructions. Copy into a project's `AGENTS.md` only if you want them always on. The plugin does not inject them.

- Verify state, tools, and docs before implementing. Local files first, then official docs.
- Stay on the requested scope. Do not expand into adjacent cleanup.
- Run tests, types, and lint that apply before calling work done.
- No dead code, vague TODOs, or unsupported claims.
- Use a branch and conventional commits. Never force-push `main` or `master`.
- Material work uses `/discover` → `/spec` → `/craft` → `/vet` + `/exercise`.
