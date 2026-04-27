#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Bootstrapping dotfiles..."

# Target directories
mkdir -p ~/.config

# Shell
echo "Linking Zsh..."
ln -sf "$DOTFILES_DIR/.zshrc" ~/.zshrc

# Prompt
echo "Linking Starship..."
ln -sf "$DOTFILES_DIR/starship.toml" ~/.config/starship.toml

# Kitty
echo "Linking Kitty..."
rm -rf ~/.config/kitty
ln -sf "$DOTFILES_DIR/kitty" ~/.config/kitty

# Neovim
echo "Linking Neovim..."
rm -rf ~/.config/nvim
ln -sf "$DOTFILES_DIR/nvim" ~/.config/nvim

echo "Dotfiles installed."
