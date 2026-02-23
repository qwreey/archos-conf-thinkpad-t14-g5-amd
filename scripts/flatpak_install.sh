#!/usr/bin/bash

echo "Script: Run flatpak after_install"

flatpak override --user --env=GTK_THEME=Breeze
flatpak override --user --env=QT_STYLE_OVERRIDE=Breeze
flatpak override --user --filesystem=xdg-data/themes
mkdir -p $HOME/.local/share/themes
cp -r /usr/share/themes/Breeze /usr/share/themes/Breeze-Dark $HOME/.local/share/themes

