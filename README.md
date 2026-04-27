# dotfiles

NvChad neovim config + zsh setup with oh-my-zsh, shell tools, and aliases.

## What's included

- **nvim/** - NvChad config with catppuccin theme, LSP, telescope, nvim-tree, gitsigns, autocomplete
- **zsh/** - Shell aliases (common + macOS-specific)
- **patches/** - Compatibility fixes for newer nvim/treesitter versions
- **setup-zsh.sh** - Installs oh-my-zsh, plugins (autosuggestions, syntax highlighting), and shell tools (eza, fzf, ripgrep, bat, zoxide, yazi)
- **setup-linux.sh** - Installs neovim + config on Ubuntu/Debian
- **setup-mac.sh** - Installs neovim + config on macOS

## Usage

```bash
git clone https://github.com/qazi0/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup-zsh.sh        # zsh + plugins + shell tools
./setup-linux.sh      # neovim (Ubuntu/Debian)
# or
./setup-mac.sh        # neovim (macOS)
```

Pass `--quiet` (or `-q`) to suppress install output:

```bash
./setup-zsh.sh --quiet
./setup-linux.sh -q
```

## Shell tools installed by setup-zsh.sh

| Tool | Purpose |
|------|---------|
| eza | Modern ls replacement with icons and git status |
| fzf | Fuzzy finder for files and text |
| ripgrep | Fast grep alternative |
| bat | cat with syntax highlighting |
| zoxide | Smarter cd that learns your habits |
| yazi | Terminal file manager |
