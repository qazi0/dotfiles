#!/usr/bin/env bash
# Neovim setup script for macOS
# Usage: curl -fsSL <raw-url>/setup-mac.sh | bash

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

echo "=== Neovim Setup (macOS) ==="

# 1. Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Install dependencies
echo "[1/5] Installing dependencies..."
HOMEBREW_NO_AUTO_UPDATE=1 brew install neovim ripgrep 2>/dev/null || true
echo "  -> neovim $(nvim --version | head -1), ripgrep installed"

# 3. Clean old config and data
echo "[2/5] Cleaning old nvim config..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
mkdir -p ~/.config/nvim

# 4. Copy config
echo "[3/5] Copying nvim config..."
cp -r "${DOTFILES_DIR}/nvim/"* "${DOTFILES_DIR}/nvim/".* ~/.config/nvim/ 2>/dev/null || true
echo "  -> config copied to ~/.config/nvim/"

# 5. Install plugins via lazy.nvim
echo "[4/5] Installing plugins (this may take a minute)..."
nvim --headless -c 'quitall' 2>/dev/null || true
sleep 2
nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' 2>/dev/null || true
echo "  -> plugins installed"

# 6. Apply compatibility patches
echo "[5/5] Applying patches..."
bash "${DOTFILES_DIR}/patches/apply-patches.sh"

echo ""
echo "=== Setup complete! ==="
echo "Run 'nvim' to start. Leader key is Space."
echo "Press Space+ch for the NvChad cheatsheet."
