#!/bin/zsh
set -euo pipefail

DOTFILES_DIR="${0:A:h}"
source "$DOTFILES_DIR/install-common.sh"

echo "Bootstrapping development container dotfiles..."

setup_development_container

echo "Development container dotfiles installed."
