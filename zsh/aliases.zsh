# General
alias ls='eza --icons -F -H --group-directories-first --git -1'
alias cl='clear'
alias vi=nvim
alias sz='source ~/.zshrc'
alias viz='vi ~/.zshrc'
alias skl="sudo kill -9"

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gunc='git reset HEAD~'
alias guna='git checkout --'

# Python / Dev
alias jn='jupyter notebook'
alias jpl='jupyter lab'
alias dev='conda activate dev'
alias uvp="uv pip install"

# OpenCommit
alias oco='NODE_NO_WARNINGS=1 oco'
alias xcx='oco'

# Google Cloud
alias gal="gcloud auth login"

# Claude
alias c-dsp='claude --dangerously-skip-permissions'

# FZF helpers (requires rg, fzf, bat)
fzf-search-files() {
  rg --files "${1:-.}" | fzf --preview 'bat --color=always {}' --preview-window=right
}

fzf-search-text() {
  rg --color=always --line-number '' "${1:-.}" | fzf --ansi --delimiter=: \
    --preview 'bat --color=always --highlight-line {2} --line-range {2}: {1}' \
    --preview-window=right:50%
}

alias fzfind=fzf-search-files
alias fzs=fzf-search-text

# Yazi file manager (cd into directory on exit)
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# --- macOS only ---
# alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
# alias binst="HOMEBREW_NO_AUTO_UPDATE=1 brew install"
