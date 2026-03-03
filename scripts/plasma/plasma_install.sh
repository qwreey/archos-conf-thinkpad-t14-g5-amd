#!/usr/bin/bash

echo "Script: Run plasma after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

# Fix menu position after hotplug monitor
mkdir -p $HOME/.local/bin
cp $SPATH/bin/fix-plasma-monitor-hotplug-menuissue $HOME/.local/bin/
cp $SPATH/autostart/fix-plasma-monitor-hotplug-menuissue.desktop $HOME/.config/autostart/

