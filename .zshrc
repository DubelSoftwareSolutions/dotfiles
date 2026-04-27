unsetopt BEEP
bindkey -v

# Environment
export PATH="$HOME/.local/bin:$PATH"
export RCUTILS_COLORIZED_OUTPUT=1
export ROS_DOMAIN_ID=21

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Completion
autoload -Uz compinit
compinit

autoload -Uz bashcompinit
bashcompinit

if command -v register-python-argcomplete >/dev/null 2>&1; then
    if command -v ros2 >/dev/null 2>&1; then
        eval "$(register-python-argcomplete ros2)"
    fi
    if command -v colcon >/dev/null 2>&1; then
        eval "$(register-python-argcomplete colcon)"
    fi
fi

zstyle ':completion:*' menu select

# Tool initialization
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v direnv >/dev/null 2>&1; then
    eval "$(direnv hook zsh)"
fi

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v fzf >/dev/null 2>&1 && fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
elif [[ -f "$HOME/.zsh/fzf/shell/key-bindings.zsh" ]]; then
    source "$HOME/.zsh/fzf/shell/key-bindings.zsh"
    source "$HOME/.zsh/fzf/shell/completion.zsh"
elif [[ -f "$HOME/.zsh/fzf/key-bindings.zsh" ]]; then
    source "$HOME/.zsh/fzf/key-bindings.zsh"
    source "$HOME/.zsh/fzf/completion.zsh"
fi

# Modern tool aliases
alias ls='eza --icons --git --group-directories-first'
alias ll='eza -al --icons --git --group-directories-first'
alias tree='eza --tree --icons'
alias cat='bat --paging=never'
alias cd='z'
alias ssh='kitten ssh'

# Kitty and media aliases
alias icat='kitty +kitten icat'
alias tpdf='timg --grid=1x1 --title'
alias tvid='timg --loops=1'
alias rp='kitty --session ~/.config/kitty/rp_session.conf'

# Colcon aliases
alias ccb='colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
alias ccbp='colcon build --symlink-install --packages-select'
alias ccclean='rm -rf build/ install/ log/'

# ROS2 aliases
alias ros2source='source /opt/ros/humble/setup.zsh'
alias r2s='ros2source'
alias r2tl='ros2 topic list'
alias r2ti='ros2 topic info'
alias r2te='ros2 topic echo'
alias r2th='ros2 topic hz'
alias r2td='ros2 topic delay'
alias r2sl='ros2 service list'
alias r2sc='ros2 service call'
alias r2al='ros2 action list'
alias r2ai='ros2 action info'
alias r2ag='ros2 action send_goal'
alias r2nl='ros2 node list'
alias r2ni='ros2 node info'

# Autosuggestions
if [[ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# Key bindings
bindkey '^[[Z' reverse-menu-complete

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# Syntax highlighting stays last
if [[ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
