# Complete Setup Guide

This guide walks you through setting up the Neural OpenCode Plugin from scratch.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Plugin Installation](#plugin-installation)
3. [Hook Setup](#hook-setup)
4. [Project Setup](#project-setup)
5. [Optional: ElevenLabs TTS](#optional-elevenlabs-tts)
6. [Optional: Ollama Agent Names](#optional-ollama-agent-names)
7. [Optional: Multi-AI Setup](#optional-multi-ai-setup)
8. [Verification](#verification)

---

## Prerequisites

### Required: OpenCode CLI

You need the OpenCode CLI installed. If you don't have it, install from:

https://opencode.ai/download

Verify installation:
```bash
opencode --version
```

### Required: jq

`jq` is used for JSON processing in hooks and status lines.

**macOS:**
```bash
brew install jq
```

**Ubuntu/Debian:**
```bash
sudo apt-get install jq
```

**Windows (WSL):**
```bash
sudo apt-get install jq
```

Verify installation:
```bash
jq --version
# Should output: jq-1.7 or similar
```

---

## Plugin Installation

### Step 1: Clone the Plugin

```bash
git clone https://github.com/brolag/neural-open-code-plugin ~/Sites/neural-open-code-plugin
```

### Step 2: Run the Installer

```bash
cd ~/Sites/neural-open-code-plugin
./install.sh
```

This will:
- Configure your shell with `OPENCODE_PLUGIN_ROOT`
- Register commands to `~/.config/opencode/commands/`
- Set up hooks for TTS and session tracking

---

## Hook Setup

Hooks enable TTS audio summaries and session tracking. This is a **one-time setup** that applies globally.

### Option A: Automated Setup (Recommended)

Run the setup script:

```bash
# Set the plugin location (adjust path if different)
export OPENCODE_PLUGIN_ROOT="$HOME/Sites/neural-open-code-plugin"

# Run setup
bash "$OPENCODE_PLUGIN_ROOT/scripts/setup-hooks.sh"
```

The script will:
- Back up your existing settings
- Add TTS hooks to `~/.config/opencode/settings.json`
- Verify your configuration

### Option B: Manual Setup

Edit `~/.config/opencode/settings.json` and add the hooks section:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": {},
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/neural-open-code-plugin/scripts/hooks/stop-tts.sh",
            "timeout": 15000
          }
        ]
      }
    ]
  }
}
```

Replace `/path/to/neural-open-code-plugin` with your actual plugin path.

### Verify Hook Setup

After setup, run in OpenCode:

```
/doctor
```

You should see no errors under "Invalid Settings". If you see hook-related errors, ensure:
- The hook format uses `matcher` and `hooks` arrays (OpenCode 2.0+ format)
- The script path is correct and executable

### Restart Required

**Important:** Restart OpenCode after setting up hooks for changes to take effect.

---

## Project Setup

After installing the plugin, you need to initialize it in each project you want to use it with.

### Step 1: Navigate to Your Project

```bash
cd /path/to/your/project
```

### Step 2: Initialize OpenCode Structure

In OpenCode, run:
```
setup opencode
```

Or:
```
init project
```

This creates the following structure:

```
your-project/
├── .opencode/
│   ├── data/                    # Session state (gitignored)
│   │   └── current-session.json
│   ├── expertise/               # Agent learning files
│   │   └── project.yaml
│   ├── memory/                  # Project memory
│   │   ├── facts/
│   │   └── events/
│   └── settings.local.json      # Local settings (gitignored)
```

### Step 3: Configure Status Line (Optional)

To enable status lines, create or edit `.opencode/settings.local.json`:

```json
{
  "statusLine": "v3"
}
```

Available versions:
- `v1` - Basic: model, directory, git branch
- `v2` - + Last prompt with emoji
- `v3` - + Agent name (recommended)

---

## Optional: ElevenLabs TTS

Enable text-to-speech summaries when tasks complete.

### Step 1: Get API Key

1. Go to [ElevenLabs](https://elevenlabs.io/)
2. Create an account or sign in
3. Go to Profile Settings > API Keys
4. Create a new API key with **only** "Text to Speech: Access" permission

### Step 2: Set Environment Variable

**macOS/Linux - Add to `~/.zshrc` or `~/.bashrc`:**
```bash
export ELEVENLABS_API_KEY="your-api-key-here"
```

Then reload:
```bash
source ~/.zshrc  # or source ~/.bashrc
```

**Verify:**
```bash
echo $ELEVENLABS_API_KEY
# Should show your key
```

### Step 3: Test TTS

In OpenCode:
```
/output-style tts
```

Then ask OpenCode to do something. At the end of the response, you should hear an audio summary.

### Custom Voice (Optional)

By default, the plugin uses the "Rachel" voice. To use a different voice:

```bash
export ELEVENLABS_VOICE_ID="your-voice-id"
```

Find voice IDs at [ElevenLabs Voices](https://elevenlabs.io/voice-library).

---

## Optional: Ollama Agent Names

Generate creative agent names for identifying multiple OpenCode instances.

### Step 1: Install Ollama

**macOS:**
```bash
brew install ollama
```

**Linux:**
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**Windows:**
Download from [ollama.com](https://ollama.com/download)

### Step 2: Start Ollama

```bash
ollama serve
```

Or on macOS, Ollama runs automatically as a service.

### Step 3: Pull the Model

```bash
ollama pull llama3.2:1b
```

This downloads a ~1.3GB model optimized for quick responses.

### Step 4: Verify

```bash
ollama run llama3.2:1b "Say hello"
```

**Note:** If Ollama isn't available, the plugin falls back to random names from a preset list (Nova, Cipher, Echo, etc.).

---

## Optional: Multi-AI Setup

Enable collaboration between Claude, Codex, and Gemini.

### Codex (OpenAI)

```bash
# Install Codex CLI
npm install -g @openai/codex

# Set API key
export OPENAI_API_KEY="your-openai-key"
```

### Gemini (Google)

```bash
# Install Gemini CLI
npm install -g @google/gemini-cli

# Set API key
export GOOGLE_API_KEY="your-google-key"
```

### Using Multi-AI

In OpenCode:
```
/ai-collab How should I structure the authentication system?
```

This queries all three AIs and synthesizes their responses.

---

## Verification

Run these checks to verify your setup:

### 1. Check Plugin Installation

```bash
ls ~/.config/opencode/commands | head -n 5
# Should list commands like: onboard.md, course.md, loop.md
```

### 2. Check Required Tools

```bash
jq --version
# Should output version
```

### 3. Check Optional Tools

```bash
# ElevenLabs
echo $ELEVENLABS_API_KEY
# Should show key (or empty if not configured)

# Ollama
ollama list
# Should show llama3.2:1b (or empty if not configured)
```

### 4. Test in a Project

```bash
cd /path/to/your/project
opencode
```

In OpenCode:
```
> /meta/brain
```

This shows system health and what's configured.

---

## Troubleshooting

### Commands Not Found

If `/onboard` is missing, re-register commands:
```bash
cp "$OPENCODE_PLUGIN_ROOT/.opencode/commands"/*.md ~/.config/opencode/commands/
```

### Invalid Settings / Hook Errors

```
Invalid Settings
└ hooks: Expected array, but received undefined
```

**Fix:** OpenCode 2.0+ requires a new hook format with `matcher` and `hooks` arrays:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": {},
        "hooks": [
          {
            "type": "command",
            "command": "bash /path/to/script.sh"
          }
        ]
      }
    ]
  }
}
```

Run the setup script to fix automatically:
```bash
bash "$OPENCODE_PLUGIN_ROOT/scripts/setup-hooks.sh"
```

### TTS Not Working

1. **Check hooks are set up:** Run `/doctor` - no errors should appear
2. **Check API key is set:** `echo $ELEVENLABS_API_KEY`
3. **Check script is executable:** `ls -la $OPENCODE_PLUGIN_ROOT/scripts/hooks/stop-tts.sh`
4. **Check audio output:** Ensure your system audio is working
5. **Restart OpenCode:** Hooks require a restart to take effect

### Agent Names Not Generating

1. Check Ollama is running: `ollama list`
2. Check model is installed: `ollama pull llama3.2:1b`
3. If Ollama fails, fallback names are used automatically

### Status Line Not Showing

1. Verify `.opencode/settings.local.json` exists with `"statusLine": "v3"`
2. Restart OpenCode session

---

## Next Steps

- See [Fullstack App Example](../examples/fullstack-app-setup.md) for a real-world setup walkthrough
- Check the [README](../README.md) for feature documentation
- Run `/meta/brain` to see system status
