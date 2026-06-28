#!/usr/bin/env bash

set -oeux pipefail


# Enable install to /opt
# On libostree systems, /opt is a symlink to /var/opt,
# which actually only exists on the live system.
optfix_dir="/usr/lib/opt"
echo "Preparing system for optfix..."
mkdir -pv "${optfix_dir}"
echo "Linking /opt => ${optfix_dir}"
ln -fs "${optfix_dir}" /opt
