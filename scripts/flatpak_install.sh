#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

flatpak override --user --env=GTK_THEME=Breeze
flatpak override --user --env=QT_STYLE_OVERRIDE=Breeze
flatpak override --user --filesystem=xdg-data/themes
mkdir -p $HOME/.local/share/themes
cp -r /usr/share/themes/Breeze /usr/share/themes/Breeze-Dark $HOME/.local/share/themes
