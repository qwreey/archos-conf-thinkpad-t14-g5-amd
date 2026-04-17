#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../../config-loader.sh"

# Fix menu position after hotplug monitor
echo "Coping configs to /etc/keyd"
sudo mkdir -p /etc/keyd
sudo cp $SPATH/conf/* /etc/keyd/

# Enable keyd
echo "Enabling keyd"
sudo systemctl enable --now keyd |& indent
sudo keyd reload

