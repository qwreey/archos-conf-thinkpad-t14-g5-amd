#!/usr/bin/bash

echo "Script: Run base after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

# Create environment file
sudo cp $SPATH/environment /etc/

# Create udev rules
# TODO: copy freq setting when lscpu including amdcpu
sudo mkdir -p /etc/udev/rules.d
sudo cp $SPATH/udev-rules/*rules /etc/udev/rules.d/

# Create modules-load.d
sudo mkdir -p /etc/modules-load.d
sudo cp $SPATH/modules-load/* /etc/modules-load.d/

# Disable leds for thinkpad, if thinkpad_acpi loaded
if lsmod | grep thinkpad_acpi &> /dev/null; then
	sudo mkdir -p /etc/systemd/system
	sudo cp $SPATH/thinkpad-disable-led.service /etc/systemd/system/
	sudo systemctl enable thinkpad-disable-led
fi

# Setup locale
sudo sed "s|#* *ko_KR.UTF-8 UTF-8|ko_KR.UTF-8 UTF-8|g" -i /etc/locale.gen
sudo sed "s|#* *en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|g" -i /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG="en_US.UTF-8" LC_CTYPE="C.UTF-8"

# Enable ssd trim timer
sudo systemctl enable fstrim.timer

