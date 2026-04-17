#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

echo "Adding autostart target 'solaar-autostart.desktop'"
mkdir -p $HOME/.config/autostart
cat - <<EOF | tee $HOME/.config/autostart/solaar-autostart.desktop | indent
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
