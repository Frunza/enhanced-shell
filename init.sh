#!/bin/zsh

# Starship
eval "$(starship init zsh)" || handle_error

# Zoxide
eval "$(zoxide init --cmd cd zsh)" || handle_error

# Source Zsh plugins
source $(find /nix/store -name zsh-syntax-highlighting.zsh | grep 'share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh')
source $(find /nix/store -name zsh-history-substring-search.zsh | grep 'share/zsh-history-substring-search/zsh-history-substring-search.zsh')

# Aliases
alias clear="tput reset && printf '\033[3J'"
alias ls='eza --long --all --no-permissions --no-filesize --no-user --no-time --git'
alias lst='eza --long --all --no-permissions --no-filesize --no-user --git --sort modified'
alias lsp='find . -maxdepth 1 -type f | fzf --preview "bat --style numbers --color always {}"'
alias cat='bat --paging never'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
