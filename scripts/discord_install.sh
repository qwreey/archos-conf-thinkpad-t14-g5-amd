#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

# Add auto vencord patch
if which pacman &> /dev/null; then
	echo "Creating /etc/pacman.d/hooks/discord.hook"
	sudo mkdir -p /etc/pacman.d/hooks
	cat - <<EOF | sudo tee /etc/pacman.d/hooks/discord.hook | indent
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
fi

echo "Installing vencord"
sudo vencordinstallercli -install -branch auto |& indent

