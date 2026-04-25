#!/bin/bash

echo "🚀 Bootstrapping ROS2 Engineering Environment..."

# Ensure target directories exist
mkdir -p ~/.config
mkdir -p ~/.local/bin

# 1. Zsh Configuration
echo "Linking Zsh..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# 2. Starship Prompt
echo "Linking Starship..."
ln -sf ~/dotfiles/starship.toml ~/.config/starship.toml

# 3. Kitty Configuration
echo "Linking Kitty..."
# Remove default kitty dir if it exists to avoid symlink nesting
rm -rf ~/.config/kitty
ln -sf ~/dotfiles/kitty ~/.config/kitty

# 4. Neovim Configuration (LazyVim + ROS2)
echo "Linking Neovim..."
rm -rf ~/.config/nvim
ln -sf ~/dotfiles/nvim ~/.config/nvim

# 5. Custom Binaries (ttyplot joint visualizer)
echo "Linking local binaries..."

echo "✅ Dotfiles successfully installed!"
