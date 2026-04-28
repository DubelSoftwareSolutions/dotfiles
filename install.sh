#!/bin/zsh
set -euo pipefail

DOTFILES_DIR="${0:A:h}"
source "${0:A:h}/install-common.sh"

echo "Bootstrapping dotfiles..."

install_host_packages
setup_config_dir
setup_host_zsh
install_starship_config required
install_kitty_host
install_mdfried
configure_fzf_current_shell
install_node
install_neovim_host

echo "Dotfiles installed."
