#!/usr/bin/bash

echo "Script: Run plymouth after_install"

# Modify breeze theme
# Default is global.title.text = "Arch Linux ";
sudo sed "s/global.title.text *= *.*;/global.title.text = \" \";/" -i /usr/share/plymouth/themes/breeze/breeze.script

# Update plymouth theme
sudo mkdir -p /etc/plymouth
cat <<EOF | sudo tee /etc/plymouth/plymouthd.conf
[Daemon]
Theme=breeze
EOF

# Update mkinitcpio flags (Add plymmouth)
sudo sed "s|HOOKS=(.*)|HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard keymap sd-vconsole block filesystems fsck)|g" -i /etc/mkinitcpio.conf

# Update initcpio
sudo mkinitcpio -p linux

