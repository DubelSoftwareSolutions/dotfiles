unsetopt BEEP

# ==========================================
# 1. PATH & ENVIRONMENT VARIABLES
# ==========================================
export PATH="$HOME/.local/bin:$PATH"

# Force ROS2 to use colorized output even when piped through other tools
export RCUTILS_COLORIZED_OUTPUT=1

# Prevent ROS2 traffic leakage on shared networks (Change this per robot)
export ROS_DOMAIN_ID=21

# Add ROS_WS directory env variable
export ROS_WS="$HOME/workspaces/ros_ws"

# ==========================================
# 2. MODERN TOOL REPLACEMENTS
# ==========================================
# Replace 'ls' with 'eza' (tree-view, colors, git integration)
alias ls='eza --icons --git --group-directories-first'
alias ll='eza -al --icons --git --group-directories-first'
alias tree='eza --tree --icons'

# Replace 'cat' with 'bat' (syntax highlighting)
alias cat='bat --paging=never'

# Replace 'cd' with 'zoxide'
eval "$(zoxide init zsh)"
alias cd='z'

# Replace 'ssh' with 'kitten ssh'
alias ssh='kitten ssh'

alias icat='kitty +kitten icat'
alias 'tpdf'='timg --grid=1x1 --title'
alias 'tvid'='timg --loops=1'

# ==========================================
# 3. ZSH BEHAVIOR & HISTORY
# ==========================================
# Keep massive history for FZF to search through
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY       # Share history across all Kitty tabs instantly
setopt HIST_IGNORE_DUPS    # Do not record an event that was just recorded again

# ==========================================
# 4. INITIALIZE RUST TOOLS
# ==========================================
eval "$(direnv hook zsh)"
eval "$(starship init zsh)"

# Source FZF (adjust path if installed via git rather than apt)
--- FZF Bindings ---
if [ -f "$HOME/.zsh/fzf/key-bindings.zsh" ]; then
    source "$HOME/.zsh/fzf/key-bindings.zsh"
    source "$HOME/.zsh/fzf/completion.zsh"
fi

# ==========================================
# 5. ROS2 & COLCON ALIASES
# ==========================================
# Colcon Build: The daily driver (Release mode with debug symbols, symlinked)
alias ccb='colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'

# Colcon Build Single Package
alias ccbp='colcon build --symlink-install --packages-select'

# Nuke the workspace
alias ccclean='rm -rf build/ install/ log/'

# Fast ROS2 Introspection
alias r2tl='ros2 topic list'
alias r2ti='ros2 topic info'
alias r2te='ros2 topic echo'
alias r2th='ros2 topic hz'
alias r2td='ros2 topic delay'
alias r2sl='ros2 service list'
alias r2si='ros2 service list'
alias r2sc='ros2 service call'
alias r2al='ros2 action list'
alias r2ai='ros2 action info'
alias r2ag='ros2 action send_goal'
alias r2nl='ros2 node list'
alias r2ni='ros2 node info'

# Source the underlay manually if needed outside a specific workspace
alias ros2source='source /opt/ros/humble/setup.zsh'
alias r2s='ros2source'

# ==========================================
# 6. ZSH PLUGINS
# ==========================================
# --- Zsh Plugins ---
if [ -f "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [ -f "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Make autosuggestions use a subtle gray color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=60'

# ==========================================
# ZSH AUTOCOMPLETION ENGINE
# ==========================================
# 1. Turn on the Zsh completion system
autoload -Uz compinit
compinit

# 2. Enable Bash compatibility mode (Python's argcomplete requires this)
autoload -Uz bashcompinit
bashcompinit

# 3. Hook ROS2 and Colcon into the engine
eval "$(register-python-argcomplete ros2)"
eval "$(register-python-argcomplete colcon)"

bindkey -v

# ==========================================
# ZSH MENU COMPLETION BEHAVIOR
# ==========================================
# Enable a navigable menu for autocompletions (use arrow keys or Tab)
zstyle ':completion:*' menu select

# Map Shift+Tab to cycle backward through the completion menu
bindkey '^[[Z' reverse-menu-complete

# ==========================================
# PREFIX HISTORY SEARCH
# ==========================================
# Map Up/Down arrows to search history based on what you've already typed
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# Map Kitty's alternative arrow key codes (just to be safe)
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward

# Map Vim normal mode 'k' and 'j' keys to do the same thing
bindkey -M vicmd 'k' history-beginning-search-backward
bindkey -M vicmd 'j' history-beginning-search-forward

# Restore Ctrl+Left and Ctrl+Right word jumping in Vi insert mode
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Delete previous word (Ctrl+Backspace) / next word (Ctrl+Delete)
bindkey '^H' backward-kill-word
bindkey '^[[3;5~' kill-word

# ==========================================
# 9. ROS2 REAL-TIME PLOTTING
# ==========================================
# Usage: r2plot /topic_name field_name
# Example: r2plot /odom twist.twist.linear.x
r2plot() {
  if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: r2plot <topic> <field_path>"
    return 1
  fi
  echo "Plotting $1 -> $2... (Press Ctrl+C to stop)"
  # Echo the topic, grep the specific field, extract the number, and pipe to ttyplot
  ros2 topic echo "$1" | stdbuf -oL grep "^$2:" | stdbuf -oL awk '{print $2}' | ttyplot -s 100 -t "$1 ($2)"
}

# ==========================================
# 10. DOCKER / DEVCONTAINER INTEGRATION
# ==========================================
# Fuzzy find a running container and attach a Kitty shell to it
djump() {
  local container
  # Pop up an FZF menu of currently running Docker containers
  container=$(docker ps --format "{{.Names}} ({{.Image}})" | fzf --prompt="Jump to Container> " --height=40% --layout=reverse | awk '{print $1}')
  
  if [[ -n "$container" ]]; then
    echo "Attaching Kitty to $container..."
    # Fallback to xterm-256color just in case kitty-terminfo isn't installed in the container
    docker exec -it -e TERM=xterm-256color "$container" /bin/zsh || docker exec -it -e TERM=xterm-256color "$container" /bin/bash
  fi
}

alias gcloud_vpn='gcloud compute ssh instance-20260308-201926 --zone=europe-central2-c --project=gd-gcp-rnd-robotics'
alias tailscale_up='sudo tailscale up --login-server http://127.0.0.1:18080'
