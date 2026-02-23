#!/usr/bin/bash

echo "Script: Run discord after_install"

# Add auto vencord patch
sudo mkdir -p /etc/pacman.d/hooks
cat - <<EOF | sudo tee /etc/pacman.d/hooks/discord.hook
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = discord

[Action]
Description = Update vencord asar
When = PostTransaction
Exec = /usr/bin/vencordinstallercli -install -branch auto
EOF
sudo vencordinstallercli -install -branch auto
