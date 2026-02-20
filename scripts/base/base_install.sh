#/usr/bin/bash

echo "Script: Run base after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

# Create environment file
sudo cp $SPATH/environment /etc/

# Create udev rules
sudo mkdir -p /etc/udev/rules.d
sudo cp $SPATH/udev-rules/*rules /etc/udev/rules.d/

# Disable leds
sudo mkdir -p /etc/systemd/system
sudo cp $SPATH/thinkpad-disable-led.service /etc/systemd/system/
sudo systemctl enable thinkpad-disable-led

# Setup locale
sudo localectl set-locale LANG=en_US.UTF-8

# Update mkinitcpio flags
sudo sed "s|HOOKS=(.*)|HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard keymap sd-vconsole block filesystems fsck)|g" -i /etc/mkinitcpio.conf

