#!/bin/bash
# Neural OpenCode Plugin - Hook Setup Script
# Adds TTS and session hooks to OpenCode settings
# Auto-installs dependencies when possible

set -e

SETTINGS_FILE="$HOME/.config/opencode/settings.json"
PLUGIN_ROOT="${OPENCODE_PLUGIN_ROOT:-$HOME/Sites/neural-open-code}"

echo "🔧 Neural OpenCode - Setup"
echo "=============================="
echo ""

# Detect OS
detect_os() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -q Microsoft /proc/version 2>/dev/null; then
      echo "wsl"
    else
      echo "linux"
    fi
  else
    echo "unknown"
  fi
}

OS=$(detect_os)
echo "📍 Detected OS: $OS"
echo ""

# Function to install jq
install_jq() {
  echo "📦 Installing jq..."
  case "$OS" in
    macos)
      if command -v brew &>/dev/null; then
        brew install jq
      else
        echo "❌ Homebrew not found. Install it first:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "Then run this script again."
        exit 1
      fi
      ;;
    linux|wsl)
      if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y jq
      elif command -v yum &>/dev/null; then
        sudo yum install -y jq
      elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm jq
      else
        echo "❌ Could not detect package manager. Install jq manually."
        exit 1
      fi
      ;;
    *)
      echo "❌ Unknown OS. Install jq manually."
      exit 1
      ;;
  esac
  echo "✅ jq installed successfully"
  echo ""
}

# Check and install jq
if ! command -v jq &>/dev/null; then
  echo "⚠️  jq is required but not installed."
  echo ""
  read -p "Install jq automatically? [Y/n] " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    install_jq
  else
    echo "❌ jq is required. Install manually:"
    echo "   macOS:  brew install jq"
    echo "   Ubuntu: sudo apt-get install jq"
    exit 1
  fi
else
  echo "✅ jq is installed"
fi

# Check plugin exists
if [ ! -d "$PLUGIN_ROOT" ]; then
  echo "❌ Plugin not found at: $PLUGIN_ROOT"
  echo ""
  echo "Set OPENCODE_PLUGIN_ROOT or clone the plugin first:"
  echo "  git clone https://github.com/brolag/neural-open-code.git"
  echo "  export OPENCODE_PLUGIN_ROOT=\"\$HOME/Sites/neural-open-code\""
  exit 1
fi
echo "✅ Plugin found at: $PLUGIN_ROOT"

# Create settings directory if needed
mkdir -p "$HOME/.config/opencode"

# Create default settings if file doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
  echo '{}' > "$SETTINGS_FILE"
  echo "📝 Created new settings file"
fi

# Backup existing settings
cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
echo "💾 Backed up settings to $SETTINGS_FILE.backup"

# Define hooks to add (OpenCode 2.0 format)
HOOKS_JSON=$(cat <<EOF
{
  "Stop": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "bash $PLUGIN_ROOT/scripts/hooks/stop-tts.sh",
          "timeout": 15000
        }
      ]
    }
  ],
  "SessionStart": [
    {
      "matcher": "",
      "hooks": [
        {
          "type": "command",
          "command": "bash $PLUGIN_ROOT/scripts/hooks/session-start.sh",
          "timeout": 5000
        }
      ]
    }
  ]
}
EOF
)

# Merge hooks into settings
UPDATED=$(jq --argjson hooks "$HOOKS_JSON" '
  .hooks = (.hooks // {}) * $hooks
' "$SETTINGS_FILE")

echo "$UPDATED" > "$SETTINGS_FILE"

echo ""
echo "✅ Hooks installed successfully!"
echo ""
echo "Hooks added:"
echo "  • SessionStart → Generates agent name (Luna, Nova, etc.) and initializes session"
echo "  • Stop → TTS with agent voice (\"Luna reporting. Task completed.\")"
echo ""
echo "Features enabled:"
echo "  • Unique feminine agent names per session"
echo "  • Auto-assigned unique voice per agent"
echo "  • Agent announces itself in TTS"
echo ""

# Check optional dependencies
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Optional Dependencies"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check ElevenLabs
if [ -n "$ELEVENLABS_API_KEY" ]; then
  echo "✅ ElevenLabs API key is set"
else
  echo "⚪ ElevenLabs API key not set (TTS will use macOS voice)"
  echo "   Get a key at: https://elevenlabs.io"
  echo "   Add to ~/.zshrc: export ELEVENLABS_API_KEY=\"your-key\""
fi

# Check Ollama
if command -v ollama &>/dev/null; then
  if ollama list 2>/dev/null | grep -q "llama"; then
    echo "✅ Ollama is installed with models"
  else
    echo "⚪ Ollama installed but no models. Run: ollama pull llama3.2:1b"
  fi
else
  echo "⚪ Ollama not installed (agent names will use fallback)"
  echo "   Install: brew install ollama (macOS) or curl -fsSL https://ollama.com/install.sh | sh"
fi

# Check curl (usually present but just in case)
if command -v curl &>/dev/null; then
  echo "✅ curl is installed"
else
  echo "❌ curl is required for TTS API calls"
fi

# Check afplay (macOS audio)
if [[ "$OS" == "macos" ]]; then
  if command -v afplay &>/dev/null; then
    echo "✅ afplay is available (audio playback)"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  Restart OpenCode for changes to take effect"
echo ""
echo "Done! Run '/doctor' in OpenCode to verify."
