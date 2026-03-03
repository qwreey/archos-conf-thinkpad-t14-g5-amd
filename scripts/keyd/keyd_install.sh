#!/usr/bin/bash

echo "Script: Run keyd after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

# Fix menu position after hotplug monitor
sudo mkdir -p /etc/keyd
sudo cp $SPATH/conf/* /etc/keyd/

# Enable keyd
sudo systemctl enable --now keyd
sudo keyd reload

