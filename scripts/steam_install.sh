#!/usr/bin/bash

echo "Script: Run steam after_install"

sudo mkdir -p /usr/local/bin
cat <<EOF | sudo tee /usr/local/bin/steam
#!/bin/bash
flatpak run com.valvesoftware.Steam \$@
EOF
sudo chmod a+x /usr/local/bin/steam

flatpak --user override --filesystem=xdg-data/icons com.valvesoftware.Steam
flatpak --user override --filesystem=xdg-data/applications com.valvesoftware.Steam
flatpak --user override --filesystem=xdg-desktop com.valvesoftware.Steam

# always allow gamepad mouse input
flatpak permission-set kde-authorized remote-desktop com.valvesoftware.Steam yes
