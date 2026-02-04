# Reference: Project Structure

Directory layout for Neural OpenCode projects.

---

## Overview

```
your-project/
├── .opencode/                    # Neural OpenCode root
│   ├── expertise/              # Domain knowledge
│   ├── memory/                 # Persistent storage
│   ├── config/                 # Configuration files
│   ├── agents/                 # Custom agents
│   ├── skills/                 # Custom skills
│   ├── commands/               # Custom commands
│   ├── scripts/                # Hooks and utilities
│   ├── loop/                   # Loop state files
│   ├── templates/              # Workflow templates
│   ├── settings.json           # Project settings
│   ├── settings.local.json     # Local settings (gitignored)
│   └── AGENTS.md               # Project instructions
│
└── ... (your project files)
```

---

## Directory Details

### `expertise/`

Domain knowledge files:

```
expertise/
├── manifest.yaml       # Load order & config
├── project.yaml        # Main project expertise
├── frontend.yaml       # Frontend-specific
├── backend.yaml        # Backend-specific
└── shared.yaml         # Cross-domain patterns
```

### `memory/`

Persistent memory storage:

```
memory/
├── events/             # Daily event logs (JSONL)
│   └── 2026-01-12.jsonl
├── facts/              # Stored facts (JSON)
│   └── fact-abc123.json
├── session_logs/       # Session history
└── pattern-index.json  # Detected patterns
```

### `config/`

Configuration files:

```
config/
└── bash-permissions.yaml   # Auto-approve patterns
```

### `agents/`

Custom agents (markdown):

```
agents/
├── security-checker.md
└── generated/          # Auto-generated agents
```

### `skills/`

Custom skills (directories):

```
skills/
└── api-testing/
    ├── SKILL.md        # Skill definition
    └── tests.json      # Test cases
```

### `commands/`

Custom slash commands:

```
commands/
├── deploy.md
└── daily-standup.md
```

### `scripts/`

Hooks and utilities:

```
scripts/
├── session-start.sh        # SessionStart hook
├── session-stop.sh         # Stop hook
├── expertise-watcher.sh    # Live expertise updates
├── expertise-streamer.sh   # Real-time streaming
├── deep-research-hook.sh   # Research hook
└── neural-loop/            # Loop scripts
    ├── start.sh
    ├── cancel.sh
    └── test-on-stop.sh
```

### `loop/`

Loop state files:

```
loop/
├── state.json          # Current loop state
├── progress.txt        # Progress tracking
├── features.json       # Feature tracking
├── research-queue.txt  # Research tasks
└── research-results.md # Research output
```

### `templates/`

Workflow templates:

```
templates/
└── todo-workflow.md    # Todo template
```

---

## Root Files

### `settings.json`

Project-level settings (committed):

```json
{
  "hooks": {
    "SessionStart": [".opencode/scripts/session-start.sh"]
  }
}
```

### `settings.local.json`

Local overrides (gitignored):

```json
{
  "hookTimeouts": {
    "deep-research": 600000
  }
}
```

### `AGENTS.md`

Project instructions loaded into every session.

---

## Global Structure

User-level configuration in `~/.config/opencode/`:

```
~/.config/opencode/
├── AGENTS.md           # Global instructions
├── memory/             # Global memory
│   └── facts/          # Cross-project facts
├── skills/             # Global skills
├── rules/              # Safety rules
└── tts-voices.json     # Voice assignments
```

---

## Creating Structure

Initialize automatically:

```bash
/setup
```

Or manually:

```bash
mkdir -p .opencode/{expertise,memory/events,memory/facts,scripts,config}
```
