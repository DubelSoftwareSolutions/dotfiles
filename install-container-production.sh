#!/bin/zsh
set -euo pipefail

DOTFILES_DIR="${0:A:h}"
source "$DOTFILES_DIR/install-common.sh"

echo "Bootstrapping production container dotfiles..."

setup_production_container
install_aider

echo "Production container dotfiles installed."
