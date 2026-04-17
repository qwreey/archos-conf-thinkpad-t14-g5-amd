#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

# Modify breeze theme
# Default is global.title.text = "Arch Linux ";
echo "Making empty global.title.text"
sudo sed "s/global.title.text *= *.*;/global.title.text = \" \";/" -i /usr/share/plymouth/themes/breeze/breeze.script
if which pacman &> /dev/null; then
	echo "Creating /etc/pacman.d/hooks/breeze-plymouth.hook"
	sudo mkdir -p /etc/pacman.d/hooks
	cat - <<EOF | sudo tee /etc/pacman.d/hooks/breeze-plymouth.hook | indent
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Target = breeze-plymouth

[Action]
Description = Update global.title.text
When = PostTransaction
Exec = /usr/bin/sed 's/global.title.text *= *.*;/global.title.text = " ";/' -i /usr/share/plymouth/themes/breeze/breeze.script
EOF
fi

# Update plymouth theme
echo "Updating plymouthd.conf"
sudo mkdir -p /etc/plymouth
cat <<EOF | sudo tee /etc/plymouth/plymouthd.conf | indent
[Daemon]
Theme=breeze
EOF

# Update mkinitcpio flags (Add plymmouth)
echo "Updating mkinitcpio.conf : HOOKS"
sudo sed "s|HOOKS=(.*)|HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard keymap sd-vconsole block filesystems fsck)|g" -i /etc/mkinitcpio.conf

# Update initcpio
echo "Runing mkinitcpio"
sudo mkinitcpio -p linux | indent

