autoload -U +X compinit && compinit

# Remove duplicates from history
setopt HIST_IGNORE_ALL_DUPS

# Devbox
DEVBOX_NO_PROMPT=true

# Git
LANG=en_US.UTF-8

# Completions
source <(docker completion zsh)
source <(kubectl completion zsh)

(cd ~/enhanced-shell && devbox shell)
cd ~
clear
