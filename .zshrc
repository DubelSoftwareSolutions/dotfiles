unsetopt BEEP
bindkey -v

# Environment
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
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

eval "$(register-python-argcomplete ros2)"
eval "$(register-python-argcomplete colcon)"

zstyle ':completion:*' menu select

# Tool initialization
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

if [[ -f "$HOME/.zsh/fzf/key-bindings.zsh" ]]; then
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

# Devcontainer helpers
function dcup() {
    local target_path="${DEVCONTAINER_PATH:-.}"
    local dotfiles_repo="https://github.com/DubelSoftwareSolutions/dotfiles.git"
    local dotfiles_target="~/dotfiles"
    local dotfiles_install="install-container-development.sh"

    echo "🚀 Booting Devcontainer in $target_path (Injecting Dotfiles)..."

    devcontainer up \
        --workspace-folder "$target_path" \
        --dotfiles-repository "$dotfiles_repo" \
        --dotfiles-target-path "$dotfiles_target" \
        --dotfiles-install-command "$dotfiles_install" \
        "$@"
}

alias dcre='dcup --remove-existing-container'

function dcin() {
    local target_path="${DEVCONTAINER_PATH:-.}"
    local quoted_cmd
    if [ $# -eq 0 ]; then
        echo "💻 Dropping into container shell..."
        devcontainer exec --workspace-folder "$target_path" zsh -ic 'direnv allow 2>/dev/null; eval "$(direnv export zsh)"; exec zsh -i'
    else
        echo "💻 Executing inside container: $*"
        quoted_cmd="${(j: :)${(q)@}}"
        devcontainer exec --workspace-folder "$target_path" zsh -ic "direnv allow 2>/dev/null; eval \"\$(direnv export zsh)\"; ${quoted_cmd}; exec zsh -i"
    fi
}

function dcinw() {
    local target_path="${DEVCONTAINER_PATH:-.}"
    echo "⏳ Waiting for Devcontainer to be ready..."
    until devcontainer exec --workspace-folder "$target_path" echo "ready" > /dev/null 2>&1; do
        sleep 2
    done
    echo "✅ Container is up!"
    dcin "$@"
}

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

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

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
