#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

echo "Adding steam flatpak link binary to /usr/local/bin/stream"
sudo mkdir -p /usr/local/bin
cat <<EOF | sudo tee /usr/local/bin/steam | indent
#!/bin/bash
flatpak run com.valvesoftware.Steam \$@
EOF
sudo chmod a+x /usr/local/bin/steam

echo "Updating flatpak permissions for com.valvesoftware.Steam"
flatpak --user override --filesystem=xdg-data/icons com.valvesoftware.Steam
flatpak --user override --filesystem=xdg-data/applications com.valvesoftware.Steam
flatpak --user override --filesystem=xdg-desktop com.valvesoftware.Steam
# always allow gamepad mouse input
flatpak permission-set kde-authorized remote-desktop com.valvesoftware.Steam yes
