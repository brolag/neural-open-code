# Tutorial 1: Installation

Get Neural OpenCode running on your machine.

---

## Prerequisites

- [OpenCode CLI](https://opencode.ai/download) installed
- Git
- macOS, Linux, or WSL

## Option A: One-Line Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/brolag/neural-open-code/main/install.sh | bash
```

This will:
1. Clone the repository to `~/Sites/neural-open-code`
2. Configure your shell (`~/.zshrc` or `~/.bashrc`)
3. Register all commands to `~/.config/opencode/commands/`
4. Set up hooks (TTS, session tracking)
5. Offer to install recommended skills

Then start the guided tour:

```bash
/onboard
```

## Option B: Manual Installation

### Step 1: Clone the Plugin

```bash
git clone https://github.com/brolag/neural-open-code ~/Sites/neural-open-code
```

### Step 2: Run Setup

```bash
cd ~/Sites/neural-open-code
chmod +x scripts/setup-hooks.sh
./scripts/setup-hooks.sh
```

This configures:
- Session hooks (start/stop tracking)
- TTS integration (optional)

### Step 3: Add Environment Variable

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export OPENCODE_PLUGIN_ROOT="$HOME/Sites/neural-open-code"
```

Then reload:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

### Step 4: Register Commands

```bash
cp ~/Sites/neural-open-code/.opencode/commands/*.md ~/.config/opencode/commands/
```

### Step 5: Install Skills

```bash
/install-skills
```

Or install the recommended bundle:

```bash
bash ~/Sites/neural-open-code/scripts/install-skills.sh
```

## Post-Install: Onboarding

Run the interactive guided tour:

```bash
/onboard
```

This will:
- Check your system
- Show available features
- Help you pick skills
- Configure TTS preferences
- Give you a quick command reference

## Verify Installation

```bash
opencode --version    # Should be v2.1.x or later
/help               # Should list all plugin commands
```

---

## Managing Your Setup

After installation, use these commands to manage the plugin:

| Command | What it does |
|---------|--------------|
| `/install-skills` | Add new skills (interactive) |
| `/manage-skills` | Enable/disable/update skills |
| `/tts` | Toggle voice and text summaries |
| `/onboard` | Re-run the guided tour |

---

## What's Next?

**[Tutorial 2: Your First Expertise File ->](02-first-expertise.md)**

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `opencode: command not found` | Install OpenCode CLI first |
| Setup script fails | Check you have `jq` installed: `brew install jq` |
| Hooks don't fire | Verify `OPENCODE_PLUGIN_ROOT` is set correctly |
| `/onboard` not found | Copy commands: `cp $OPENCODE_PLUGIN_ROOT/.opencode/commands/*.md ~/.config/opencode/commands/` |
| Skills not available | Run `/install-skills` to install them |

Need more help? [Open an issue](https://github.com/brolag/neural-open-code/issues)
