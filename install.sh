#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/.dotfiles-backups/$TIMESTAMP}"
ROS_DISTRO="${ROS_DISTRO:-humble}"
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

INSTALL_ROS2="${INSTALL_ROS2:-1}"
INSTALL_NERD_FONT="${INSTALL_NERD_FONT:-1}"
RUN_NVIM_SYNC="${RUN_NVIM_SYNC:-1}"
BACKUP_NVIM_STATE="${BACKUP_NVIM_STATE:-0}"

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

require_linux() {
  [[ "$(uname -s)" == "Linux" ]] || die "This installer currently supports Linux only."
}

require_apt() {
  has_cmd apt-get || die "This installer currently supports Debian/Ubuntu systems with apt-get."
}

require_sudo() {
  sudo -v
}

os_codename() {
  . /etc/os-release
  printf '%s' "${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
}

is_ubuntu_like() {
  . /etc/os-release
  [[ "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *"ubuntu"* ]]
}

download() {
  local url="$1"
  local output="$2"
  curl -fL --retry 3 --connect-timeout 20 "$url" -o "$output"
}

backup_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0

  local rel
  if [[ "$path" == "$HOME/"* ]]; then
    rel="${path#$HOME/}"
  else
    rel="${path#/}"
  fi

  local backup="$BACKUP_ROOT/$rel"
  mkdir -p "$(dirname "$backup")"

  if [[ -e "$backup" || -L "$backup" ]]; then
    backup="${backup}.$TIMESTAMP"
  fi

  mv "$path" "$backup"
  log "Backed up $path -> $backup"
}

backup_system_path() {
  local path="$1"
  [[ -e "$path" || -L "$path" ]] || return 0

  local backup="${path}.bak.${TIMESTAMP}"
  sudo mv "$path" "$backup"
  log "Backed up $path -> $backup"
}

same_path() {
  local src="$1"
  local dest="$2"

  [[ -L "$dest" ]] && return 1

  if [[ -d "$src" && -d "$dest" ]]; then
    diff -qr "$src" "$dest" >/dev/null
  elif [[ -f "$src" && -f "$dest" ]]; then
    cmp -s "$src" "$dest"
  else
    return 1
  fi
}

copy_config() {
  local src="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -e "$dest" || -L "$dest" ]]; then
    if same_path "$src" "$dest"; then
      log "Config up to date: $dest"
      return 0
    fi
    backup_path "$dest"
  fi

  cp -a "$src" "$dest"
  log "Copied $src -> $dest"
}

copy_file_with_backup() {
  local content="$1"
  local dest="$2"
  local tmp
  tmp="$(mktemp)"
  printf '%s\n' "$content" >"$tmp"

  mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ ! -L "$dest" && -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
      rm -f "$tmp"
      log "File up to date: $dest"
      return 0
    fi
    backup_path "$dest"
  fi

  mv "$tmp" "$dest"
  log "Wrote $dest"
}

apt_update() {
  sudo apt-get update
}

apt_install() {
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

apt_has_package() {
  apt-cache show "$1" >/dev/null 2>&1
}

apt_install_available() {
  local available=()
  local missing=()
  local pkg

  for pkg in "$@"; do
    if apt_has_package "$pkg"; then
      available+=("$pkg")
    else
      missing+=("$pkg")
    fi
  done

  if ((${#available[@]})); then
    apt_install "${available[@]}"
  fi

  for pkg in "${missing[@]}"; do
    warn "apt package not available on this system: $pkg"
  done
}

enable_ubuntu_universe() {
  if is_ubuntu_like && has_cmd add-apt-repository; then
    sudo add-apt-repository -y universe
  fi
}

setup_eza_repo() {
  log "Configuring eza apt repository"
  sudo install -d -m 0755 /etc/apt/keyrings
  curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc |
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
  printf '%s\n' 'deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main' |
    sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
  sudo chmod 0644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
}

setup_ros2_repo() {
  [[ "$INSTALL_ROS2" == "1" ]] || return 0

  if ! is_ubuntu_like; then
    warn "Skipping ROS 2 apt repository setup: not an Ubuntu-like OS."
    return 0
  fi

  local codename version tmp deb
  codename="$(os_codename)"
  [[ -n "$codename" ]] || {
    warn "Skipping ROS 2 apt repository setup: could not detect Ubuntu codename."
    return 0
  }

  log "Configuring ROS 2 apt repository for $codename"
  version="$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p' |
    head -n 1 || true)"

  [[ -n "$version" ]] || {
    warn "Skipping ROS 2 apt repository setup: could not detect latest ros-apt-source release."
    return 0
  }

  tmp="$(mktemp -d)"
  deb="$tmp/ros2-apt-source.deb"
  if ! download "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${version}/ros2-apt-source_${version}.${codename}_all.deb" "$deb"; then
    warn "Could not download ros2-apt-source for $codename."
    rm -rf "$tmp"
    return 0
  fi

  if ! sudo dpkg -i "$deb"; then
    warn "Could not install ros2-apt-source for $codename."
    rm -rf "$tmp"
    return 0
  fi

  rm -rf "$tmp"
}

install_system_packages() {
  log "Installing apt dependencies"
  apt_update
  apt_install ca-certificates curl git gpg software-properties-common sudo

  enable_ubuntu_universe
  setup_eza_repo
  setup_ros2_repo
  apt_update

  local packages=(
    bat
    build-essential
    clangd
    cmake
    eza
    fd-find
    fontconfig
    fzf
    git
    jq
    locales
    nodejs
    npm
    pkg-config
    python3
    python3-argcomplete
    python3-colcon-common-extensions
    python3-pip
    python3-rosdep
    python3-venv
    python3-vcstool
    ripgrep
    ros-dev-tools
    timg
    unzip
    wget
    xz-utils
    zsh
  )

  if [[ "$INSTALL_ROS2" == "1" ]]; then
    packages+=("ros-${ROS_DISTRO}-ros-base")
  fi

  apt_install_available "${packages[@]}"
}

install_local_shims() {
  mkdir -p "$HOME/.local/bin"

  if ! has_cmd bat && has_cmd batcat; then
    ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if ! has_cmd fd && has_cmd fdfind; then
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_bat_latest() {
  local arch deb_arch url tmp deb
  arch="$(uname -m)"

  case "$arch" in
    x86_64) deb_arch="amd64" ;;
    aarch64 | arm64) deb_arch="arm64" ;;
    *)
      warn "Skipping latest bat .deb: unsupported architecture $arch."
      return 0
      ;;
  esac

  log "Installing latest bat release"
  url="$(curl -fsSL https://api.github.com/repos/sharkdp/bat/releases/latest |
    grep -Eo "https://[^\"]+bat_[^\"]+_${deb_arch}\.deb" |
    head -n 1 || true)"

  [[ -n "$url" ]] || {
    warn "Could not find latest bat .deb for $deb_arch; keeping apt package."
    return 0
  }

  tmp="$(mktemp -d)"
  deb="$tmp/bat.deb"
  download "$url" "$deb"
  sudo apt-get install -y "$deb"
  rm -rf "$tmp"
}

install_starship_latest() {
  log "Installing latest Starship"
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
}

install_direnv_latest() {
  log "Installing latest direnv"
  mkdir -p "$HOME/.local/bin"
  curl -fsSL https://direnv.net/install.sh | bash
}

install_zoxide_latest() {
  log "Installing latest zoxide"
  mkdir -p "$HOME/.local/bin"
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_or_update_git_repo() {
  local repo="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [[ -d "$dest/.git" ]]; then
    log "Updating $dest"
    git -C "$dest" pull --ff-only
  else
    backup_path "$dest"
    log "Cloning $repo -> $dest"
    git clone --depth 1 "$repo" "$dest"
  fi
}

install_fzf_latest() {
  local dest="$HOME/.local/share/fzf"
  install_or_update_git_repo "https://github.com/junegunn/fzf.git" "$dest"
  "$dest/install" --bin --no-update-rc
  ln -sfn "$dest/bin/fzf" "$HOME/.local/bin/fzf"
}

install_zsh_plugins() {
  install_or_update_git_repo "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$HOME/.zsh/plugins/zsh-autosuggestions"
  install_or_update_git_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$HOME/.zsh/plugins/zsh-syntax-highlighting"
}

install_kitty_latest() {
  log "Installing latest kitty"
  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications" "$HOME/.config"
  curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n

  ln -sfn "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
  ln -sfn "$HOME/.local/kitty.app/bin/kitten" "$HOME/.local/bin/kitten"

  cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/"
  cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/"

  sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
    "$HOME"/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" \
    "$HOME"/.local/share/applications/kitty*.desktop

  copy_file_with_backup "kitty.desktop" "$HOME/.config/xdg-terminals.list"
}

install_neovim_latest() {
  local arch nvim_arch asset asset_dir url tmp tarball dest
  arch="$(uname -m)"

  case "$arch" in
    x86_64) nvim_arch="x86_64" ;;
    aarch64 | arm64) nvim_arch="arm64" ;;
    *)
      warn "Skipping latest Neovim tarball: unsupported architecture $arch."
      return 0
      ;;
  esac

  asset="nvim-linux-${nvim_arch}.tar.gz"
  asset_dir="nvim-linux-${nvim_arch}"
  url="https://github.com/neovim/neovim/releases/latest/download/${asset}"
  dest="/opt/${asset_dir}"

  log "Installing latest Neovim"
  tmp="$(mktemp -d)"
  tarball="$tmp/$asset"
  download "$url" "$tarball"
  tar -C "$tmp" -xzf "$tarball"

  backup_system_path "$dest"
  sudo mv "$tmp/$asset_dir" "$dest"

  if [[ -e /usr/local/bin/nvim || -L /usr/local/bin/nvim ]]; then
    if [[ "$(readlink /usr/local/bin/nvim 2>/dev/null || true)" != "$dest/bin/nvim" ]]; then
      backup_system_path /usr/local/bin/nvim
    fi
  fi
  sudo ln -sfn "$dest/bin/nvim" /usr/local/bin/nvim
  rm -rf "$tmp"
}

install_tree_sitter_cli() {
  if has_cmd npm; then
    log "Installing latest tree-sitter CLI"
    mkdir -p "$HOME/.local"
    npm_config_prefix="$HOME/.local" npm install -g tree-sitter-cli
  else
    warn "Skipping tree-sitter CLI: npm is not installed."
  fi
}

install_nerd_font() {
  [[ "$INSTALL_NERD_FONT" == "1" ]] || return 0

  local font="${NERD_FONT:-JetBrainsMono}"
  local url tmp zip dest

  log "Installing latest ${font} Nerd Font"
  url="$(curl -fsSL https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest |
    grep -Eo "https://[^\"]+/${font}\.zip" |
    head -n 1 || true)"

  [[ -n "$url" ]] || {
    warn "Could not find ${font}.zip in latest Nerd Fonts release."
    return 0
  }

  tmp="$(mktemp -d)"
  zip="$tmp/${font}.zip"
  dest="$HOME/.local/share/fonts/NerdFonts/$font"

  download "$url" "$zip"
  mkdir -p "$dest"
  unzip -oq "$zip" -d "$dest"
  fc-cache -f "$HOME/.local/share/fonts" || true
  rm -rf "$tmp"
}

setup_rosdep() {
  [[ "$INSTALL_ROS2" == "1" ]] || return 0
  has_cmd rosdep || return 0

  if [[ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]]; then
    sudo rosdep init || warn "rosdep init failed; it may already be initialized."
  fi

  rosdep update || warn "rosdep update failed."
}

copy_configs() {
  log "Copying configs with backups"
  copy_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  copy_config "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
  copy_config "$DOTFILES_DIR/kitty" "$HOME/.config/kitty"
  copy_config "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

  if [[ "$BACKUP_NVIM_STATE" == "1" ]]; then
    backup_path "$HOME/.local/share/nvim"
    backup_path "$HOME/.local/state/nvim"
    backup_path "$HOME/.cache/nvim"
  fi
}

sync_neovim_plugins() {
  [[ "$RUN_NVIM_SYNC" == "1" ]] || return 0

  if has_cmd nvim; then
    log "Syncing Neovim plugins"
    nvim --headless "+Lazy! sync" +qa || warn "Neovim plugin sync failed; run ':Lazy sync' manually."
  else
    warn "Skipping Neovim plugin sync: nvim is not installed."
  fi
}

check_expected_commands() {
  local required=(
    zsh
    git
    curl
    nvim
    kitty
    kitten
    starship
    zoxide
    direnv
    fzf
    eza
    bat
    timg
    rg
    fd
    colcon
    register-python-argcomplete
  )

  if [[ "$INSTALL_ROS2" == "1" ]]; then
    required+=(ros2)
  fi

  local optional=(code codex claude dcup dcinw)
  local cmd

  log "Checking expected commands"
  for cmd in "${required[@]}"; do
    has_cmd "$cmd" || warn "Missing required command after install: $cmd"
  done

  for cmd in "${optional[@]}"; do
    has_cmd "$cmd" || warn "Optional command used by session config is missing: $cmd"
  done
}

main() {
  require_linux
  require_apt
  require_sudo

  mkdir -p "$HOME/.config" "$HOME/.local/bin"

  install_system_packages
  install_local_shims
  install_bat_latest
  install_starship_latest
  install_direnv_latest
  install_zoxide_latest
  install_fzf_latest
  install_zsh_plugins
  install_kitty_latest
  install_neovim_latest
  install_tree_sitter_cli
  install_nerd_font
  setup_rosdep
  copy_configs
  sync_neovim_plugins
  check_expected_commands

  log "Install complete. Backups, if any, are under $BACKUP_ROOT"
}

main "$@"
