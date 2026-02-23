#!/usr/bin/bash

echo "Script: Run NetworkManager after_install"

# Create wifi powersave disable setting
sudo mkdir -p /etc/NetworkManager/conf.d
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf
[connection]
wifi.powersave = 2
EOF

# Enable service
sudo systemctl enable --now NetworkManager

