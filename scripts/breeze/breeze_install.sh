#!/bin/bash

echo "Script: Run breeze after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

DESKTOPTHEME_PATH=~/.local/share/plasma/desktoptheme/moe.qwreey.default
mkdir -p ~/.local/share/plasma/desktoptheme
[ -e $DESKTOPTHEME_PATH ] && rm -r $DESKTOPTHEME_PATH
cp -r /usr/share/plasma/desktoptheme/default $DESKTOPTHEME_PATH
cp -r $SPATH/desktoptheme/* $DESKTOPTHEME_PATH
