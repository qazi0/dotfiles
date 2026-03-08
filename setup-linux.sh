#!/usr/bin/env bash
# Neovim setup script for Ubuntu/Debian Linux
# Usage: curl -fsSL <raw-url>/setup-linux.sh | bash

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

echo "=== Neovim Setup (Linux) ==="

# 1. Install dependencies
echo "[1/6] Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq ripgrep gcc build-essential git curl > /dev/null 2>&1
echo "  -> ripgrep, gcc, build-essential, git installed"

# 2. Install neovim via unstable PPA (ships current releases)
echo "[2/6] Installing neovim..."
if ! command -v nvim &> /dev/null || [[ "$(nvim --version | head -1)" < "NVIM v0.10" ]]; then
    sudo add-apt-repository -y ppa:neovim-ppa/unstable > /dev/null 2>&1
    sudo apt-get update -qq
    sudo apt-get install -y -qq neovim > /dev/null 2>&1
    echo "  -> neovim $(nvim --version | head -1) installed"
else
    echo "  -> neovim already installed: $(nvim --version | head -1)"
fi

# 3. Clean old config and data
echo "[3/6] Cleaning old nvim config..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
mkdir -p ~/.config/nvim

# 4. Copy config
echo "[4/6] Copying nvim config..."
cp -r "${DOTFILES_DIR}/nvim/"* "${DOTFILES_DIR}/nvim/".* ~/.config/nvim/ 2>/dev/null || true
echo "  -> config copied to ~/.config/nvim/"

# 5. Install plugins via lazy.nvim
echo "[5/6] Installing plugins (this may take a minute)..."
# First launch bootstraps lazy.nvim, second syncs plugins
nvim --headless -c 'quitall' 2>/dev/null || true
sleep 2
nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' 2>/dev/null || true
echo "  -> plugins installed"

# 6. Apply compatibility patches
echo "[6/6] Applying patches..."
bash "${DOTFILES_DIR}/patches/apply-patches.sh"

# Disable WiFi power management if on WiFi (headless server optimization)
WIFI_IFACE=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -1)
if [ -n "$WIFI_IFACE" ]; then
    echo ""
    echo "=== WiFi Optimization ==="
    echo "Detected WiFi interface: $WIFI_IFACE"
    echo "To disable WiFi power management (reduces SSH latency):"
    echo "  sudo iwconfig $WIFI_IFACE power off"
    echo "  echo -e '[connection]\nwifi.powersave=2' | sudo tee /etc/NetworkManager/conf.d/no-powersave.conf"
    echo "  sudo systemctl restart NetworkManager"
fi

echo ""
echo "=== Setup complete! ==="
echo "Run 'nvim' to start. Leader key is Space."
echo "Press Space+ch for the NvChad cheatsheet."
