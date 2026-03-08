# macOS-specific aliases (sourced only on Darwin)
alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
alias binst="HOMEBREW_NO_AUTO_UPDATE=1 brew install"
