#!/usr/bin/env bash
# Neovim setup script for macOS
# Usage: ./setup-mac.sh [--quiet|-q]

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# Parse flags
QUIET=0
for arg in "$@"; do
    case "$arg" in
        --quiet|-q) QUIET=1 ;;
    esac
done

run() {
    if [ "$QUIET" -eq 1 ]; then
        "$@" > /dev/null 2>&1
    else
        "$@"
    fi
}

brew_run() {
    if [ "$QUIET" -eq 1 ]; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew "$@" > /dev/null 2>&1 || true
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew "$@" || true
    fi
}

echo "=== Neovim Setup (macOS) ==="

# 1. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Install dependencies
echo "[1/6] Installing dependencies..."
brew_run install neovim ripgrep pipx
echo "  -> neovim $(nvim --version | head -1), ripgrep, pipx installed"

# 3. Install language servers (pyright for Python)
echo "[2/6] Installing language servers..."
pipx ensurepath > /dev/null 2>&1 || true
export PATH="$HOME/.local/bin:$PATH"
if ! command -v pyright-langserver &> /dev/null; then
    run pipx install pyright
    echo "  -> pyright installed"
else
    echo "  -> pyright already installed"
fi

# 4. Clean old config and data
echo "[3/6] Cleaning old nvim config..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
mkdir -p ~/.config/nvim

# 5. Copy config
echo "[4/6] Copying nvim config..."
cp -r "${DOTFILES_DIR}/nvim/"* "${DOTFILES_DIR}/nvim/".* ~/.config/nvim/ 2>/dev/null || true
echo "  -> config copied to ~/.config/nvim/"

# 6. Install plugins via lazy.nvim
echo "[5/6] Installing plugins (this may take a minute)..."
nvim --headless -c 'quitall' 2>/dev/null || true
sleep 2
if [ "$QUIET" -eq 1 ]; then
    nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' > /dev/null 2>&1 || true
else
    nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' || true
fi
echo "  -> plugins installed"

# 7. Apply compatibility patches
echo "[6/6] Applying patches..."
bash "${DOTFILES_DIR}/patches/apply-patches.sh"

echo ""
echo "=== Setup complete! ==="
echo "Run 'nvim' to start. Leader key is Space."
echo "Press Space+ch for the NvChad cheatsheet."
