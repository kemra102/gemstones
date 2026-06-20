#!/bin/bash

set -ouex pipefail

shopt -s nullglob


# Disable Discover notifier as we automate updates in the background
if [[ -f /etc/xdg/autostart/org.kde.discover.notifier.desktop ]]; then
    rm -f /etc/xdg/autostart/org.kde.discover.notifier.desktop
fi


# Enable automatic firmware metadata updates
ln -s /usr/lib/systemd/system/fwupd-refresh.timer \
	/usr/lib/systemd/system/timers.target.wants/fwupd-refresh.timer


# Enable install to /opt
# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system.
optfix_dir="/usr/lib/opt"
echo "Preparing system for optfix..."
mkdir -pv "${optfix_dir}"
echo "Linking /opt => ${optfix_dir}"
ln -fs "${optfix_dir}" /opt


# We're gonna get Firefox from Flathub so remove the native version.
dnf5 --assumeyes remove firefox firefox-langpacks


# Install RPM packages
## cdrskin - Media ripping support
## flac - Media ripping/playback support
## fuse-libs - Suppoort AppImage
## k3b - Media ripping tool (not on Flathub)
## libburn - Media ripping suport
## solar - Manage Logitech mice
## zsh - my shell of choice

dnf5 --assumeyes config-manager addrepo \
    --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo

dnf5 --assumeyes config-manager addrepo --id=vscodium \
    --set=baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ \
    --set=gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    --set=repo_gpgcheck=true

dnf5 --assumeyes install cdrskin codium flac fuse-libs k3b libburn mullvad-vpn \
    solaar zsh


# Install the Cosmic Desktop
# dnf5 --assumeyes install @cosmic-desktop-environment


# Install Atuin
ATUIN_VERSION='18.16.1'
ATUIN_FILE_NAME="atuin-x86_64-unknown-linux-gnu" # without file extension
TMP_DIR=$(mktemp -d)

curl -sL "https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VERSION}/${ATUIN_FILE_NAME}.tar.gz" \
    --output - | tar -xzf - -C "$TMP_DIR"

install "${TMP_DIR}/${ATUIN_FILE_NAME}/atuin" /usr/bin

# Shell completions no longer included in release tarball
# So generate them now
/usr/bin/atuin gen-completions --shell zsh --out-dir /usr/share/zsh/site-functions/
rm -rf "$TMP_DIR" # cleanup atuin tmpdir

# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/bin

# Install YADM
curl -fLo /usr/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && \
    chmod a+x /usr/bin/yadm


# Complete setup for packages installed to /opt
# Create symlinks for each directory specified

# needs nullglob, so that this array is empty if /opt is empty
optdirs=("${optfix_dir}"/*) # returns a list of directories in /opt
if [[ -n "${optdirs[*]}" ]]; then
    echo "Creating symlinks to fix packages that installed to /opt:"
    for optdir in "${optdirs[@]}"; do
        opt=$(basename "${optdir}")
        lib_opt_dir="${optfix_dir}/${opt}"
        link_opt_dir="/opt/${opt}"
        echo "Linking ${link_opt_dir} => ${lib_opt_dir}"
        echo "L+?  \"${link_opt_dir}\"  -  -  -  -  ${lib_opt_dir}" | \
            tee "/usr/lib/tmpfiles.d/99-optfix-${opt}.conf"
    done
fi
