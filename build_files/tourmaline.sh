#!/bin/bash

set -ouex pipefail


# We're gonna get Firefox from Flathub so remove the native version.
dnf5 --assumeyes remove firefox firefox-langpacks


# Disable Discover notifier as we automate updates in the background
if [[ -f /etc/xdg/autostart/org.kde.discover.notifier.desktop ]]; then
    rm -f /etc/xdg/autostart/org.kde.discover.notifier.desktop
fi


# Enable install to /opt
echo "Creating symlinks to fix packages that install to /opt"
# Create symlink for /opt to /var/opt since it is not created in the image yet
install -d "/var/opt"
ln -fs "/var/opt"  "/opt"

# Create symlinks for each directory specified
OPTFIX=(Mullvad\ VPN)
for OPTPKG in "${OPTFIX[@]}"; do
    OPTPKG="${OPTPKG%\"}"
    OPTPKG="${OPTPKG#\"}"
    install -d "/usr/lib/opt/${OPTPKG}"
    ln -fs "/usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
    echo "Created symlinks for ${OPTPKG}"
done


# Install simple packages
## solar - Manage Logitech mice
## zsh - my shell of choice
dnf5 --assumeyes install solaar zsh


# Install Media ripping tools
dnf5 --assumeyes install k3b flac libburn cdrskin


# Install the Cosmic Desktop
# dnf5 --assumeyes install @cosmic-desktop-environment


# Enable automatic firmware updates
ln -s /usr/lib/systemd/system/fwupd-refresh.timer \
	/usr/lib/systemd/system/timers.target.wants/fwupd-refresh.timer


# Install Atuin
ATUIN_VERSION='18.15.2'
ATUIN_FILE_NAME="atuin-x86_64-unknown-linux-gnu" # without file extension
TMP_DIR=$(mktemp -d)

curl -sL "https://github.com/atuinsh/atuin/releases/download/v${ATUIN_VERSION}/${ATUIN_FILE_NAME}.tar.gz" --output - | tar -xzf - -C "$TMP_DIR"

install "${TMP_DIR}/${ATUIN_FILE_NAME}/atuin" /usr/bin

# Shell completions no longer included in release tarball
# So generate them now
/usr/bin/atuin gen-completions --shell zsh --out-dir /usr/share/zsh/site-functions/

rm -rf "$TMP_DIR"


# Install Mullvad VPN
dnf5 --assumeyes config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 --assumeyes install mullvad-vpn


# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir /usr/bin


# Install VSCodium
dnf5 --assumeyes config-manager addrepo --id=vscodium --set=baseurl=https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/rpms/ --set=gpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg --set=repo_gpgcheck=true
dnf5 --assumeyes install codium


# Install YADM
curl -fLo /usr/bin/yadm https://github.com/TheLocehiliosan/yadm/raw/master/yadm && chmod a+x /usr/bin/yadm
