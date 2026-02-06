#!/bin/bash
#
# Neural OpenCode - One-Line Installer
# Usage: curl -fsSL https://raw.githubusercontent.com/brolag/neural-open-code/main/install.sh | bash
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}║  Neural OpenCode - One-Line Installer              ║${RESET}"
echo -e "${BOLD}║  v1.4.0                                                ║${RESET}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Default installation directory
INSTALL_DIR="${OPENCODE_PLUGIN_ROOT:-$HOME/Sites/neural-open-code}"
REPO_URL="https://github.com/brolag/neural-open-code.git"

echo -e "${BLUE}→${RESET} Installation directory: ${BOLD}$INSTALL_DIR${RESET}"
echo ""

# Check prerequisites
echo -e "${BLUE}→${RESET} Checking prerequisites..."

missing=()

if ! command -v git &> /dev/null; then
    missing+=("git")
fi

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠${RESET} jq not found (required for interactive installer)"
    missing+=("jq")
fi

if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${RED}✗${RESET} Missing: ${missing[*]}"
    echo -e "${BLUE}ℹ${RESET} Install with: ${BOLD}brew install ${missing[*]}${RESET}"
    exit 1
fi

echo -e "${GREEN}✓${RESET} Prerequisites met"
echo ""

# Clone or update repository
if [ -d "$INSTALL_DIR/.git" ]; then
    echo -e "${BLUE}→${RESET} Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
    echo -e "${GREEN}✓${RESET} Updated to latest version"
else
    echo -e "${BLUE}→${RESET} Cloning repository..."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone "$REPO_URL" "$INSTALL_DIR"
    echo -e "${GREEN}✓${RESET} Repository cloned"
fi

cd "$INSTALL_DIR"
echo ""

# Detect shell
SHELL_RC=""
SHELL_NAME=$(basename "$SHELL")

case "$SHELL_NAME" in
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    bash)
        SHELL_RC="$HOME/.bashrc"
        if [ ! -f "$SHELL_RC" ]; then
            SHELL_RC="$HOME/.bash_profile"
        fi
        ;;
    *)
        SHELL_RC="$HOME/.profile"
        ;;
esac

echo -e "${BLUE}→${RESET} Detected shell: ${BOLD}$SHELL_NAME${RESET} (config: $SHELL_RC)"
echo ""

# Add to shell config
if ! grep -q "OPENCODE_PLUGIN_ROOT" "$SHELL_RC" 2>/dev/null; then
    echo -e "${BLUE}→${RESET} Adding to shell configuration..."
    cat >> "$SHELL_RC" << EOF

# Neural OpenCode Plugin
export OPENCODE_PLUGIN_ROOT="$INSTALL_DIR"
EOF
    echo -e "${GREEN}✓${RESET} Added to $SHELL_RC"

    # Source it immediately
    export OPENCODE_PLUGIN_ROOT="$INSTALL_DIR"
else
    echo -e "${YELLOW}⚠${RESET} Already configured in $SHELL_RC"
fi

echo ""

# Register commands
echo -e "${BLUE}→${RESET} Registering commands..."
mkdir -p "$HOME/.config/opencode/commands"
for cmd_file in "$INSTALL_DIR"/.opencode/commands/*.md; do
    if [ -f "$cmd_file" ]; then
        cp "$cmd_file" "$HOME/.config/opencode/commands/"
    fi
done
success "Commands registered"

# Run setup hooks
if [ -f "$INSTALL_DIR/scripts/setup-hooks.sh" ]; then
    echo -e "${BLUE}→${RESET} Setting up hooks..."
    bash "$INSTALL_DIR/scripts/setup-hooks.sh"
    echo -e "${GREEN}✓${RESET} Hooks configured"
else
    echo -e "${YELLOW}⚠${RESET} Setup script not found, skipping hooks"
fi

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}✓ Installation complete!${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════${RESET}"
echo ""

# Offer to install skills
echo -e "${BOLD}Next step: Install skills${RESET}"
echo ""

# Check if interactive installer will work (needs bash 4+)
BASH_MAJOR_VERSION="${BASH_VERSINFO[0]:-3}"
INTERACTIVE_AVAILABLE=true

if [ "$BASH_MAJOR_VERSION" -lt 4 ]; then
    INTERACTIVE_AVAILABLE=false
fi

echo "Would you like to install recommended skills now?"

if [ "$INTERACTIVE_AVAILABLE" = true ]; then
    echo "  1) Yes, install now (interactive)"
    echo "  2) Install recommended bundle (auto) ⭐ Recommended"
    echo "  3) Skip (install later with /install-skills)"
else
    echo "  1) Install recommended bundle (auto) ⭐ Recommended"
    echo "  2) Skip (install later with /install-skills)"
    echo ""
    echo -e "${YELLOW}ℹ${RESET} Interactive mode requires bash 4+. Install with: ${BOLD}brew install bash${RESET}"
fi

echo ""
read -p "Select: " choice

if [ "$INTERACTIVE_AVAILABLE" = true ]; then
    # Menu with interactive option
    case "$choice" in
        1)
            echo ""
            echo -e "${BLUE}→${RESET} Launching interactive installer..."
            bash "$INSTALL_DIR/scripts/install-skills.sh"
            ;;
        2)
            echo ""
            echo -e "${BLUE}→${RESET} Installing recommended bundle..."

            # Install to global by default
            TARGET_DIR="$HOME/.config/opencode/skills"
            mkdir -p "$TARGET_DIR"

            # Copy recommended skills
            recommended=(
                "debugging"
                "tdd"
                "deep-research"
                "slop-scan"
                "slop-fix"
                "overseer"
            )

            for skill in "${recommended[@]}"; do
                if [ -d "$INSTALL_DIR/.opencode/skills/$skill" ]; then
                    echo -e "${BLUE}→${RESET} Installing $skill..."
                    mkdir -p "$TARGET_DIR/$skill"
                    cp -r "$INSTALL_DIR/.opencode/skills/$skill/"* "$TARGET_DIR/$skill/"
                    echo -e "${GREEN}✓${RESET} $skill"
                fi
            done

            echo ""
            echo -e "${GREEN}✓${RESET} Installed ${#recommended[@]} skills to $TARGET_DIR"
            ;;
        3)
            echo ""
            echo -e "${YELLOW}⚠${RESET} Skipped skill installation"
            ;;
    esac
else
    # Menu without interactive option (bash 3.2)
    case "$choice" in
        1)
            echo ""
            echo -e "${BLUE}→${RESET} Installing recommended bundle..."

            # Install to global by default
            TARGET_DIR="$HOME/.config/opencode/skills"
            mkdir -p "$TARGET_DIR"

            # Copy recommended skills
            recommended=(
                "debugging"
                "tdd"
                "deep-research"
                "slop-scan"
                "slop-fix"
                "overseer"
            )

            for skill in "${recommended[@]}"; do
                if [ -d "$INSTALL_DIR/.opencode/skills/$skill" ]; then
                    echo -e "${BLUE}→${RESET} Installing $skill..."
                    mkdir -p "$TARGET_DIR/$skill"
                    cp -r "$INSTALL_DIR/.opencode/skills/$skill/"* "$TARGET_DIR/$skill/"
                    echo -e "${GREEN}✓${RESET} $skill"
                fi
            done

            echo ""
            echo -e "${GREEN}✓${RESET} Installed ${#recommended[@]} skills to $TARGET_DIR"
            ;;
        2)
            echo ""
            echo -e "${YELLOW}⚠${RESET} Skipped skill installation"
            ;;
    esac
fi

echo ""
echo -e "${BOLD}Quick Start:${RESET}"
echo ""
echo "  # Reload shell"
echo "  source $SHELL_RC"
echo ""
echo "  # In any OpenCode session:"
echo "  /install-skills          # Install more skills"
echo "  /slop-scan               # Detect technical debt"
echo "  /debug                   # Systematic debugging"
echo "  /tdd                     # Test-driven development"
echo ""
echo -e "${BOLD}Documentation:${RESET}"
echo "  https://github.com/brolag/neural-open-code"
echo ""
echo -e "${GREEN}Happy coding! 🚀${RESET}"
