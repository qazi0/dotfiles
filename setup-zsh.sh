#!/usr/bin/env bash
# Oh-My-Zsh + plugins + shell tools setup script
# Works on both macOS and Linux
# Usage: ./setup-zsh.sh

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "$0")" && pwd)}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
OS="$(uname)"

echo "=== Zsh Setup ($OS) ==="

# 1. Ensure zsh is installed
echo "[1/7] Checking zsh..."
if ! command -v zsh &> /dev/null; then
    echo "  -> Installing zsh..."
    if [[ "$OS" == "Darwin" ]]; then
        brew install zsh
    else
        sudo apt-get update -qq && sudo apt-get install -y -qq zsh
    fi
fi
echo "  -> $(zsh --version | head -1)"

# 2. Install shell tools: eza, fzf, ripgrep, bat, zoxide, yazi
echo "[2/7] Installing shell tools..."
if [[ "$OS" == "Darwin" ]]; then
    HOMEBREW_NO_AUTO_UPDATE=1 brew install eza fzf ripgrep bat zoxide yazi 2>/dev/null || true
else
    # eza
    if ! command -v eza &> /dev/null; then
        if [[ "$(uname -m)" == "x86_64" ]]; then
            sudo apt-get install -y -qq gpg wget 2>/dev/null
            sudo mkdir -p /etc/apt/keyrings
            wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --batch --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
            echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
            sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
            sudo apt-get update -qq
            sudo apt-get install -y -qq eza 2>/dev/null
        else
            echo "  -> eza: no ARM deb package available, skipping (use 'ls' instead)"
        fi
    fi

    # fzf (from git for latest version + keybindings)
    if ! command -v fzf &> /dev/null; then
        [ -d ~/.fzf ] || git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi

    # ripgrep, bat, zoxide (bat is batcat on Ubuntu)
    sudo apt-get install -y -qq ripgrep bat zoxide 2>/dev/null || true
    # Ubuntu names bat as batcat - create symlink
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        sudo ln -sf "$(which batcat)" /usr/local/bin/bat
    fi

    # zoxide fallback (if apt didn't have it on older distros)
    if ! command -v zoxide &> /dev/null; then
        export PATH="$HOME/.local/bin:$PATH"
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # yazi
    if ! command -v yazi &> /dev/null; then
        YAZI_VERSION=$(curl -sSf https://api.github.com/repos/sxyazi/yazi/releases/latest | grep tag_name | cut -d'"' -f4)
        ARCH="$(uname -m)"
        if [[ "$ARCH" == "x86_64" ]]; then
            YAZI_ARCH="x86_64-unknown-linux-gnu"
        elif [[ "$ARCH" == "aarch64" ]]; then
            YAZI_ARCH="aarch64-unknown-linux-gnu"
        fi
        if [[ -n "$YAZI_ARCH" ]]; then
            curl -sSfL "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-${YAZI_ARCH}.zip" -o /tmp/yazi.zip
            unzip -oq /tmp/yazi.zip -d /tmp/yazi
            sudo mv "/tmp/yazi/yazi-${YAZI_ARCH}/yazi" /usr/local/bin/yazi
            rm -rf /tmp/yazi /tmp/yazi.zip
        else
            echo "  -> yazi: unsupported arch $ARCH, skipping"
        fi
    fi
fi

echo "  -> eza:    $(command -v eza &>/dev/null && echo 'ok' || echo 'MISSING')"
echo "  -> fzf:    $(command -v fzf &>/dev/null && echo 'ok' || echo 'MISSING')"
echo "  -> rg:     $(command -v rg &>/dev/null && echo 'ok' || echo 'MISSING')"
echo "  -> bat:    $(command -v bat &>/dev/null && echo 'ok' || echo 'MISSING')"
echo "  -> zoxide: $(command -v zoxide &>/dev/null && echo 'ok' || echo 'MISSING')"
echo "  -> yazi:   $(command -v yazi &>/dev/null && echo 'ok' || echo 'MISSING')"

# 3. Install Oh-My-Zsh (skip if already installed)
echo "[3/7] Installing Oh-My-Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "  -> already installed, skipping"
else
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "  -> installed"
fi

# 4. Install zsh plugins
echo "[4/7] Installing zsh plugins..."

if [ -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ]; then
    echo "  -> zsh-autosuggestions already installed"
else
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM}/plugins/zsh-autosuggestions"
    echo "  -> zsh-autosuggestions installed"
fi

if [ -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ]; then
    echo "  -> zsh-syntax-highlighting already installed"
else
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting"
    echo "  -> zsh-syntax-highlighting installed"
fi

if [ -d "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting" ]; then
    echo "  -> fast-syntax-highlighting already installed"
else
    git clone --depth=1 https://github.com/zdharma-continuum/fast-syntax-highlighting "${ZSH_CUSTOM}/plugins/fast-syntax-highlighting"
    echo "  -> fast-syntax-highlighting installed"
fi

# 5. Copy aliases
echo "[5/7] Installing aliases..."
mkdir -p "${ZSH_CUSTOM}"
cp "${DOTFILES_DIR}/zsh/aliases.zsh" "${ZSH_CUSTOM}/aliases.zsh"
if [[ "$OS" == "Darwin" ]]; then
    cp "${DOTFILES_DIR}/zsh/aliases-mac.zsh" "${ZSH_CUSTOM}/aliases-mac.zsh"
    echo "  -> common + macOS aliases installed"
else
    echo "  -> common aliases installed"
fi

# 6. Set up fzf keybindings
echo "[6/7] Setting up fzf..."
if [[ "$OS" == "Darwin" ]]; then
    # Homebrew fzf install script
    "$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true
else
    # fzf keybindings on Linux (git install already sets up ~/.fzf.zsh)
    if [ -f ~/.fzf.zsh ]; then
        echo "  -> fzf keybindings already configured"
    elif [ -f ~/.fzf/install ]; then
        ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    fi
fi
echo "  -> fzf configured"

# 7. Configure .zshrc
echo "[7/7] Configuring .zshrc..."

if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
    echo "  -> backed up existing .zshrc"
fi

cat > "$HOME/.zshrc" << 'ZSHRC'
# Local binaries
export PATH="$HOME/.local/bin:$PATH"

# Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# Aliases & functions
[ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh" ] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases.zsh"

# macOS-specific aliases
[[ "$(uname)" == "Darwin" ]] && [ -f "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases-mac.zsh" ] && source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/aliases-mac.zsh"

# Zoxide (if installed)
command -v zoxide &> /dev/null && eval "$(zoxide init --cmd cd zsh)"

# FZF (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
ZSHRC

echo "  -> .zshrc written"

# Set zsh as default shell if it isn't already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo ""
    echo "To set zsh as your default shell, run:"
    echo "  chsh -s \$(which zsh)"
fi

echo ""
echo "=== Zsh setup complete! ==="
echo "Run 'source ~/.zshrc' or start a new terminal session."
