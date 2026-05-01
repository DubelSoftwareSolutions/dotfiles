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
    python3-argcomplete \
    python3-colcon-common-extensions \
    ripgrep \
    timg \
    ttyplot \
    xclip \
    zoxide \
    zsh
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

install_starship_config() {
  echo "Configuring Starship..."
  mkdir -p "$HOME/.local/bin"
  curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
  eval "$("$HOME/.local/bin/starship" init zsh)"

  rm -rf ~/.config/starship.toml
  cp "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml
}

install_kitty_host() {
  echo "Configuring Kitty..."
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

install_mdfried() {
  echo "Installing mdfried..."
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
      print -u2 "mdfried install is only configured for amd64 and arm64."
      return 1
      ;;
  esac

  release_api="https://api.github.com/repos/benjajaja/mdfried/releases/latest"
  deb_url="$(
    curl -fsSL "$release_api" |
      grep -o 'https://[^"]*\.deb' |
      grep "${deb_arch}\.deb$" |
      head -n 1
  )"

  if [[ -z "$deb_url" ]]; then
    print -u2 "Failed to find a ${deb_arch} mdfried .deb in the latest GitHub release."
    return 1
  fi

  deb_path="/tmp/mdfried_${deb_arch}.deb"
  curl -fL -o "$deb_path" "$deb_url"
  sudo apt install -y "$deb_path"
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
    "+MasonInstall stylua shfmt clangd cmake-language-server pyright ruff" \
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
  install_starship_config
  configure_git_aliases
  install_mdfried
}

setup_development_container() {
  setup_production_container
  install_node
  install_ai_cli_tools
  install_neovim_container
}
