#!/usr/bin/bash

echo "Script: Run solaar after_install"

mkdir -p $HOME/.config/autostart

cat - <<EOF | tee $HOME/.config/autostart/solaar-autostart.desktop
[Desktop Entry]
Comment=Start solaar with tray menu
Exec=/usr/bin/flatpak run io.github.pwr_solaar.solaar --window hide
Name=solaar-autostart
StartupNotify=false
Terminal=false
Type=Application
Version=1.0
X-Flatpak=io.github.pwr_solaar.solaar
Icon=io.github.pwr_solaar.solaar
EOF

