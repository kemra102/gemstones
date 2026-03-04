#!/bin/bash

set -ouex pipefail

# We're gonna get Firefox from Flathub so remove the native version.
dnf5 --assumeyes remove firefox firefox-langpacks

# Disable Discover notifier as we automate updates in the background.
if [[ -f /etc/xdg/autostart/org.kde.discover.notifier.desktop ]]; then
    rm -f /etc/xdg/autostart/org.kde.discover.notifier.desktop
fi
