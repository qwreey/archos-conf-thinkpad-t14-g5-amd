#/usr/bin/bash

echo "Script: Run plymouth after_install"

# Default is global.title.text = "Arch Linux ";
sudo sed "s/global.title.text *= *.*;/global.title.text = \" \";/" -i /usr/share/plymouth/themes/breeze/breeze.script

sudo mkdir -p /etc/plymouth
cat <<EOF | sudo tee /etc/plymouth/plymouthd.conf
[Daemon]
Theme=breeze
EOF

sudo mkinitcpio -p linux

