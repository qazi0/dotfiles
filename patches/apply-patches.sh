#!/usr/bin/env bash
# Apply post-plugin-install patches for nvim compatibility
# Run this after lazy.nvim syncs plugins

set -e

LAZY_DIR="${HOME}/.local/share/nvim/lazy"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Applying nvim compatibility patches..."

# 1. Treesitter shims (newer treesitter removed modules that older plugins depend on)
TS_DIR="${LAZY_DIR}/nvim-treesitter/lua/nvim-treesitter"
if [ -d "$TS_DIR" ]; then
    cp "${SCRIPT_DIR}/nvim-treesitter/configs.lua" "$TS_DIR/configs.lua"
    cp "${SCRIPT_DIR}/nvim-treesitter/ts_utils.lua" "$TS_DIR/ts_utils.lua"
    cp "${SCRIPT_DIR}/nvim-treesitter/locals.lua" "$TS_DIR/locals.lua"
    cp "${SCRIPT_DIR}/nvim-treesitter/query.lua" "$TS_DIR/query.lua"
    echo "  -> treesitter shims applied"
else
    echo "  -> treesitter not found, skipping shims"
fi

# 2. Suppress lspconfig deprecation warning (nvim 0.11+)
LSPCONFIG="${LAZY_DIR}/nvim-lspconfig/lua/lspconfig.lua"
if [ -f "$LSPCONFIG" ]; then
    if grep -q "if vim.fn.has('nvim-0.11') == 1 then" "$LSPCONFIG"; then
        sed -i.bak "s/if vim.fn.has('nvim-0.11') == 1 then/if false then/" "$LSPCONFIG"
        rm -f "${LSPCONFIG}.bak"
        echo "  -> lspconfig deprecation warning suppressed"
    else
        echo "  -> lspconfig already patched or different version"
    fi
else
    echo "  -> lspconfig not found, skipping"
fi

echo "Patches applied."
