#!/bin/bash
# Status Line v1 - Simple: model, cwd, git branch
# Usage: Add to .opencode/settings.json: "statusLine": "bash ~/Sites/neural-open-code-plugin/status-lines/v1.sh"

# Get model from env or default
MODEL="${OPENCODE_MODEL:-opus}"

# Model emoji
case "$MODEL" in
  opus) MODEL_ICON="🟣" ;;
  sonnet) MODEL_ICON="🔵" ;;
  haiku) MODEL_ICON="🟢" ;;
  *) MODEL_ICON="⚪" ;;
esac

# Current directory (shortened)
CWD=$(basename "$PWD")

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

# Output status line
echo "$MODEL_ICON $MODEL │ $CWD │ $GIT_INFO"
