#!/usr/bin/env bash

set -oeux pipefail

shopt -s nullglob


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
