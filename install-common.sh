#!/bin/zsh

if [[ -z "${DOTFILES_DIR:-}" ]]; then
  DOTFILES_DIR="${0:A:h}"
fi

require_sudo_apt() {
  if ! command -v sudo >/dev/null 2>&1; then
    print -u2 "sudo is required to install apt packages."
    return 1
  fi

  if ! command -v apt >/dev/null 2>&1; then
    print -u2 "apt is required; only Debian/Ubuntu containers are supported."
    return 1
  fi
}

apt_install_packages() {
  require_sudo_apt
  sudo apt update
  sudo apt install -y "$@"
}

install_host_packages() {
  apt_install_packages \
    bat \
    btop \
    bubblewrap \
    curl \
    direnv \
    eza \
    fd-find \
    fzf \
    inotify-tools \
    pandoc \
    poppler-utils \
    python3-argcomplete \
    python3-colcon-common-extensions \
    ripgrep \
    timg \
    tree \
    ttyplot \
    xclip \
    zathura \
    zathura-pdf-poppler \
    zoxide \
    zsh
}

require_pacman() {
  if ! command -v sudo >/dev/null 2>&1; then
    print -u2 "sudo is required to install pacman packages."
    return 1
  fi

  if ! command -v pacman >/dev/null 2>&1; then
    print -u2 "pacman is required; only Arch/CachyOS hosts are supported."
    return 1
  fi
}

pacman_install_packages() {
  require_pacman
  sudo pacman -Syu --needed --noconfirm "$@"
}

require_paru() {
  if command -v paru >/dev/null 2>&1; then
    return 0
  fi

  echo "Bootstrapping paru (AUR helper)..."
  require_pacman
  sudo pacman -S --needed --noconfirm base-devel git

  local paru_build_dir="/tmp/paru-build"
  rm -rf "$paru_build_dir"
  git clone https://aur.archlinux.org/paru.git "$paru_build_dir"
  (cd "$paru_build_dir" && makepkg -si --noconfirm)
  rm -rf "$paru_build_dir"

  if ! command -v paru >/dev/null 2>&1; then
    print -u2 "paru installation failed."
    return 1
  fi
}

aur_install_packages() {
  require_paru
  paru -Syu --needed --noconfirm "$@"
}

install_host_packages_cachyos() {
  pacman_install_packages \
    bat \
    btop \
    bubblewrap \
    curl \
    direnv \
    eza \
    fd \
    fzf \
    inotify-tools \
    pandoc \
    poppler \
    glow \
    mdfried \
    python-argcomplete \
    ripgrep \
    typst \
    xclip \
    zathura \
    zathura-pdf-mupdf \
    zoxide \
    zsh

  aur_install_packages \
    timg \
    ttyplot
}

install_container_production_packages() {
  apt_install_packages \
    zsh \
    curl \
    git \
    fzf \
    ripgrep \
    fd-find \
    bat \
    eza \
    kitty-terminfo \
    xclip \
    zoxide \
    direnv
}

setup_config_dir() {
  mkdir -p ~/.config
}

install_zsh_config() {
  local zshrc_source="$1"
  echo "Configuting Zsh..."
  rm -rf ~/.zshrc
  cp "$zshrc_source" ~/.zshrc
}

install_zsh_plugins() {
  rm -rf ~/.zsh
  mkdir -p ~/.zsh/plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
}

install_fzf_shell_files() {
  mkdir -p ~/.zsh/fzf
  curl -sS -o ~/.zsh/fzf/key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh
  curl -sS -o ~/.zsh/fzf/completion.zsh https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh
}

configure_git_aliases() {
  git config --global alias.commig commit
}

configure_git_kitty_difftool() {
  echo "Configuring Kitty Git difftool..."
  git config --global diff.tool kitten
  git config --global difftool.kitten.cmd 'kitten diff "$LOCAL" "$REMOTE"'
  git config --global difftool.prompt false
  git config --global alias.kdiff 'difftool --dir-diff --no-prompt'
  git config --global alias.kdiff-file 'difftool --no-prompt'
}

setup_host_zsh() {
  install_zsh_config "$DOTFILES_DIR/.zshrc" required
  install_zsh_plugins
  install_fzf_shell_files
}

setup_container_zsh() {
  install_zsh_config "$DOTFILES_DIR/.zshrc.container"
  install_zsh_plugins
  install_fzf_shell_files
}

setup_container_ssh() {
  mkdir -p ~/.ssh
  chmod 700 ~/.ssh
  ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
  chmod 644 ~/.ssh/known_hosts
  ssh-add -L | grep 'kdubel@griddynamics.com' > ~/.ssh/id_rsa.pub
  chmod 644 ~/.ssh/id_rsa.pub
}

install_starship_config() {
  echo "Configuring Starship..."
  mkdir -p "$HOME/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  eval "$("$HOME/.local/bin/starship" init zsh)"

  rm -rf ~/.config/starship.toml
  cp "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
}

install_noto_colrv1_emoji_font() {
  echo "Installing Noto COLRv1 emoji font..."
  local font_dir="$HOME/.local/share/fonts/noto-emoji"

  mkdir -p "$font_dir"
  curl -fL -o "$font_dir/Noto-COLRv1.ttf" \
    https://raw.githubusercontent.com/googlefonts/noto-emoji/main/fonts/Noto-COLRv1.ttf
  fc-cache -f "$font_dir"
}

install_kitty_host() {
  echo "Configuring Kitty..."
  install_noto_colrv1_emoji_font
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/.local/bin/
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/
  sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" ~/.local/share/applications/kitty*.desktop
  echo 'kitty.desktop' > ~/.config/xdg-terminals.list
  rm -rf ~/.config/kitty
  cp -r "$DOTFILES_DIR/kitty" ~/.config/kitty
}

install_zathura_config() {
  echo "Configuring Zathura..."
  rm -rf ~/.config/zathura
  cp -r "$DOTFILES_DIR/zathura" ~/.config/zathura
}

install_github_deb() {
  local repo="$1" name="$2"
  echo "Installing ${name}..."
  require_sudo_apt

  local deb_arch release_api deb_url deb_path
  case "$(uname -m)" in
    x86_64|amd64)
      deb_arch="amd64"
      ;;
    aarch64|arm64)
      deb_arch="arm64"
      ;;
    *)
      print -u2 "${name} install is only configured for amd64 and arm64."
      return 1
      ;;
  esac

  release_api="https://api.github.com/repos/${repo}/releases/latest"
  deb_url="$(
    curl -fsSL "$release_api" |
      grep -o 'https://[^"]*\.deb' |
      grep "${deb_arch}\.deb$" |
      head -n 1
  )"

  if [[ -z "$deb_url" ]]; then
    print -u2 "Failed to find a ${deb_arch} ${name} .deb in the latest GitHub release."
    return 1
  fi

  deb_path="/tmp/${name}_${deb_arch}.deb"
  curl -fL -o "$deb_path" "$deb_url"
  sudo apt install -y "$deb_path"
}

install_mdfried() {
  install_github_deb benjajaja/mdfried mdfried
}

install_glow() {
  install_github_deb charmbracelet/glow glow
}

configure_fzf_current_shell() {
  echo "Configuring FZF..."
  source <(fzf --zsh)
}

install_node() {
  echo "Configuring NodeJS..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
  \. "$HOME/.nvm/nvm.sh"
  nvm install 24
}

install_ai_cli_tools() {
  echo "Installing AI CLI tools..."
  npm i -g @openai/codex@latest
  curl -fsSL https://claude.ai/install.sh | bash
  claude plugin marketplace add griddynamics/rosetta
  claude plugin install rosetta@rosetta
}

install_aider() {
  echo "Installing Aider..."
  curl -LsSf https://aider.chat/install.sh | sh
  cp "$DOTFILES_DIR/.aider.conf.yml" "$HOME/.aider.conf.yml"
}

install_uv_pynvim() {
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
  if [[ -f "$HOME/.local/bin/env" ]]; then
    source "$HOME/.local/bin/env"
  fi
  "$HOME/.local/bin/uv" tool install --upgrade pynvim
}

sync_neovim_plugins() {
  local nvim_bin="/opt/nvim-linux-x86_64/bin/nvim"

  NVIM_DOTFILES_BOOTSTRAP=1 "$nvim_bin" --headless "+Lazy! sync" +qa
  NVIM_DOTFILES_BOOTSTRAP=1 "$nvim_bin" --headless \
    "+lua require('lazy').load({ plugins = { 'mason.nvim' } })" \
    "+MasonInstall stylua shfmt clang-format clangd cmake-language-server pyright ruff" \
    +qa
}

install_neovim_host() {
  echo "Linking Neovim..."
  install_uv_pynvim
  curl -fL -o /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  tar -tzf /tmp/nvim-linux-x86_64.tar.gz >/dev/null
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
  source $HOME/.local/bin/env
  rm -rf ~/.config/nvim
  cp -r "$DOTFILES_DIR/nvim" ~/.config/nvim
  sync_neovim_plugins
}

install_neovim_container() {
  echo "Linking Neovim..."
  install_uv_pynvim
  curl -fL -o /tmp/nvim-linux-x86_64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  tar -tzf /tmp/nvim-linux-x86_64.tar.gz >/dev/null
  sudo rm -rf /opt/nvim-linux-x86_64
  sudo tar -C /opt -xzf /tmp/nvim-linux-x86_64.tar.gz
  rm -rf ~/.config/nvim
  cp -r "$DOTFILES_DIR/nvim" ~/.config/nvim
  sync_neovim_plugins
}

setup_production_container() {
  install_container_production_packages
  setup_config_dir
  setup_container_zsh
  setup_container_ssh
  install_starship_config
  configure_git_aliases
  install_mdfried
}

setup_development_container() {
  setup_production_container
  install_glow
  install_node
  install_ai_cli_tools
  install_neovim_container
}
