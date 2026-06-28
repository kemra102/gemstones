#!/bin/bash

set -ouex pipefail

pacman -Syu --noconfirm atuin dolphin flatpak fwupd k3b konsole mullvad-vpn \
    neovim plasma-meta solaar starship zsh

# For k3b:
#   - cdparanoia, cdrdao
pacman -S --noconfirm --asdeps cdparanoia cdrdao
