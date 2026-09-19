#!/bin/bash
# Status Line v3 - Full: model, last prompt, agent name, trailing prompts, git
# Usage: Add to .opencode/settings.json: "statusLine": "bash ~/Sites/neural-open-code/status-lines/v3.sh"

PLUGIN_ROOT="${OPENCODE_PLUGIN_ROOT:-$HOME/Sites/neural-open-code}"
DATA_DIR="$PWD/.opencode/data"
SESSION_FILE="$DATA_DIR/current-session.json"

# Get model from env or default
MODEL="${OPENCODE_MODEL:-opus}"

# Model emoji
case "$MODEL" in
  opus) MODEL_ICON="🟣" ;;
  sonnet) MODEL_ICON="🔵" ;;
  haiku) MODEL_ICON="🟢" ;;
  *) MODEL_ICON="⚪" ;;
esac

# Get session data
AGENT_NAME=""
LAST_PROMPT="no recent prompt"
PROMPT_ICON="💬"

if [ -f "$SESSION_FILE" ]; then
  AGENT_NAME=$(jq -r '.agent_name // ""' "$SESSION_FILE" 2>/dev/null)
  LAST_PROMPT=$(jq -r '.prompts[-1] // "no recent prompt"' "$SESSION_FILE" 2>/dev/null | head -c 35)

  # Determine prompt type emoji
  if [[ "$LAST_PROMPT" == *"?"* ]]; then
    PROMPT_ICON="❓"
  elif [[ "$LAST_PROMPT" =~ ^(create|add|write|make|build|generate) ]]; then
    PROMPT_ICON="💡"
  elif [[ "$LAST_PROMPT" =~ ^(fix|debug|solve|repair) ]]; then
    PROMPT_ICON="🔧"
  elif [[ "$LAST_PROMPT" =~ ^(delete|remove|clean) ]]; then
    PROMPT_ICON="🗑️"
  elif [[ "$LAST_PROMPT" =~ ^(test|check|verify) ]]; then
    PROMPT_ICON="✅"
  fi
fi

# Git branch and changes
GIT_INFO=""
if git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  if [ "$CHANGES" -gt 0 ]; then
    GIT_INFO="$BRANCH +$CHANGES"
  else
    GIT_INFO="$BRANCH"
  fi
fi

# Build status line
STATUS="$MODEL_ICON $MODEL"

if [ -n "$AGENT_NAME" ]; then
  STATUS="$STATUS │ $AGENT_NAME"
fi

STATUS="$STATUS │ $PROMPT_ICON $LAST_PROMPT"

if [ -n "$GIT_INFO" ]; then
  STATUS="$STATUS │ $GIT_INFO"
fi

echo "$STATUS"
