#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

# Create wifi powersave disable setting
echo "Creating /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf"
sudo mkdir -p /etc/NetworkManager/conf.d
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf | indent
[connection]
wifi.powersave = 2
EOF

# Enable service
echo "Enabling NetworkManager service"
sudo systemctl enable --now NetworkManager |& indent
