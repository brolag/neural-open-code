# Configuration

Neural OpenCode does not install or edit `~/.config/opencode/opencode.json` for you. Review every example against your own providers, cost, and permission policy.

## Project config

`opencode.json` in this repository declares:

- `$schema`: `https://opencode.ai/config.json`
- `instructions`: `AGENTS.md`
- `compaction` defaults
- deny rules for destructive bash and `.env` edits

Do not hardcode a model ID. Use the model your OpenCode client already has configured.

## Optional env

```bash
export OPENCODE_CONFIG_DIR="/path/to/neural-open-code/.opencode"
```

This loads agents, commands, plugins, and skills from that directory without copying files into `$HOME`.

## Restart

Config, skills, commands, and plugins load at startup. Restart OpenCode after changing them.
