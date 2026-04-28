#!/bin/zsh
set -euo pipefail

DOTFILES_DIR="~/dotfiles"

echo "Bootstrapping dotfiles..."

sudo apt update
sudo apt install -y \
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

# Target directories
mkdir -p ~/.config

# Shell
echo "Configuting Zsh..."
cp ~/.zshrc ~/.zshrc.bak
rm -rf ~/.zshrc
cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
rm -rf ~/.zsh
mkdir -p ~/.zsh/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
mkdir -p ~/.zsh/fzf
curl -sS -o ~/.zsh/fzf/key-bindings.zsh https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh
curl -sS -o ~/.zsh/fzf/completion.zsh https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh

# Starship
echo "Configuring Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
eval "$(starship init zsh)"
cp ~/.config/starship.toml ~/.config/starship.toml.bak
rm -rf ~/.config/starship.toml
cp "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml

# Kitty
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

# FZF
echo "Configuring FZF..."
source <(fzf --zsh)

# NodeJS
echo "Configuring NodeJS..."
# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 24

# Verify the Node.js version:
node -v # Should print "v24.15.0".

# Verify npm version:
npm -v # Should print "11.12.1".


# Neovim
echo "Linking Neovim..."
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv tool install --upgrade pynvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
rm -rf ~/.config/nvim
cp -r "$DOTFILES_DIR/nvim" ~/.config/nvim
nvim --headless "+Lazy! sync" +qa

echo "Dotfiles installed."
