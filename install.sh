#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Bootstrapping ROS2 Engineering Dotfiles..."

# 1. Create target directories just in case they don't exist
mkdir -p ~/.config/kitty
mkdir -p ~/.local/bin
mkdir -p ~/.zsh/plugins

# 2. Symlink configurations (forces overwrite if defaults exist)
echo "🔗 Creating symlinks..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sf ~/dotfiles/.config/kitty/kitty.conf ~/.config/kitty/kitty.conf

# Symlink custom scripts and make them executable
if [ -f ~/dotfiles/.local/bin/r2cam ]; then
    ln -sf ~/dotfiles/.local/bin/r2cam ~/.local/bin/r2cam
    chmod +x ~/.local/bin/r2cam
fi

# 3. Install user-level Rust tools (Starship & Zoxide)
# We install them locally to ~/.local/bin to avoid needing sudo in locked-down containers
echo "🦀 Installing Rust CLI tools..."

if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin
fi

if ! command -v zoxide &> /dev/null; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# 4. Clone Zsh plugins (Autosuggestions & Syntax Highlighting)
echo "🔌 Installing Zsh plugins..."
if [ ! -d "$HOME/.zsh/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.zsh/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/plugins/zsh-syntax-highlighting
fi

echo "✅ Dotfiles successfully installed!"
