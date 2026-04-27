#!/usr/bin/env bash
# Neovim setup script for Ubuntu/Debian Linux
# Usage: ./setup-linux.sh [--quiet|-q]

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"

# Parse flags
QUIET=0
for arg in "$@"; do
    case "$arg" in
        --quiet|-q) QUIET=1 ;;
    esac
done

# Helper: run a command, suppressing output only if --quiet
run() {
    if [ "$QUIET" -eq 1 ]; then
        "$@" > /dev/null 2>&1
    else
        "$@"
    fi
}

# Apt wrapper that respects --quiet
apt_run() {
    if [ "$QUIET" -eq 1 ]; then
        sudo apt-get -qq "$@" > /dev/null 2>&1
    else
        sudo apt-get "$@"
    fi
}

echo "=== Neovim Setup (Linux) ==="

# 1. Install dependencies
echo "[1/7] Installing dependencies..."
apt_run update
apt_run install -y ripgrep gcc build-essential git curl pipx
echo "  -> ripgrep, gcc, build-essential, git, pipx installed"

# 2. Install neovim via unstable PPA (ships current releases)
echo "[2/7] Installing neovim..."
if ! command -v nvim &> /dev/null || [[ "$(nvim --version | head -1)" < "NVIM v0.10" ]]; then
    if [ "$QUIET" -eq 1 ]; then
        sudo add-apt-repository -y ppa:neovim-ppa/unstable > /dev/null 2>&1
    else
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
    fi
    apt_run update
    apt_run install -y neovim
    echo "  -> neovim $(nvim --version | head -1) installed"
else
    echo "  -> neovim already installed: $(nvim --version | head -1)"
fi

# 3. Install language servers (pyright for Python)
echo "[3/7] Installing language servers..."
pipx ensurepath > /dev/null 2>&1 || true
export PATH="$HOME/.local/bin:$PATH"
if ! command -v pyright-langserver &> /dev/null; then
    run pipx install pyright
    echo "  -> pyright installed"
else
    echo "  -> pyright already installed"
fi

# 4. Clean old config and data
echo "[4/7] Cleaning old nvim config..."
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim
mkdir -p ~/.config/nvim

# 5. Copy config
echo "[5/7] Copying nvim config..."
cp -r "${DOTFILES_DIR}/nvim/"* "${DOTFILES_DIR}/nvim/".* ~/.config/nvim/ 2>/dev/null || true
echo "  -> config copied to ~/.config/nvim/"

# 6. Install plugins via lazy.nvim
echo "[6/7] Installing plugins (this may take a minute)..."
nvim --headless -c 'quitall' 2>/dev/null || true
sleep 2
if [ "$QUIET" -eq 1 ]; then
    nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' > /dev/null 2>&1 || true
else
    nvim --headless -c 'lua require("lazy").sync()' -c 'sleep 30' -c 'quitall' || true
fi
echo "  -> plugins installed"

# 7. Apply compatibility patches
echo "[7/7] Applying patches..."
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
