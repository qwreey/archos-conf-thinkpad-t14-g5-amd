#!/usr/bin/bash

echo "Script: Run grub after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

[ ! -e /boot/grub ] && sudo grub-install --bootloader-id=GRUB --target=x86_64-efi --efi-directory=/boot --removable

cat <<EOF | sudo tee /boot/grub/custom.cfg
set menu_color_normal=light-gray/black
set menu_color_highlight=white/black
set color_normal=light-gray/black
set color_highlight=light-gray/black
EOF

sudo cp $SPATH/breeze-background.png /boot/grub/background.png

# Update /etc/default/grub
# Default is GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
sudo sed "s|#* *GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet splash nowatchdog acpi.ec_no_wakeup=1\"|g" -i /etc/default/grub
# Default is GRUB_TIMEOUT_STYLE=menu
sudo sed "s|#* *GRUB_TIMEOUT_STYLE=.*|GRUB_TIMEOUT_STYLE=countdown|" -i /etc/default/grub
# Default is GRUB_TIMEOUT=5
sudo sed "s|#* *GRUB_TIMEOUT=.*|GRUB_TIMEOUT=2|" -i /etc/default/grub
# Default is #GRUB_BACKGROUND="/path/to/wallpaper"
sudo sed "s|#* *GRUB_BACKGROUND=.*|GRUB_BACKGROUND=\"/boot/grub/background.png\"|" -i /etc/default/grub
# Default is GRUB_DISABLE_RECOVERY=true
sudo sed "s|#* *GRUB_DISABLE_RECOVERY=.*|#GRUB_DISABLE_RECOVERY=true|" -i /etc/default/grub

# Remove screen echo
sudo sed "s/[# ]*echo.*'\\\$(echo \"\\\$message\" | grub_quote)'/# echo '\$(echo \"\$message\" | grub_quote)'/g" -i /etc/grub.d/10_linux
sudo sed "s/.*# Use ELILO's generic \"efifb\" when it's known to be available.*/echo \"clear\" # Use ELILO's generic \"efifb\" when it's known to be available.'/g" -i /etc/grub.d/10_linux

sudo grub-mkconfig -o /boot/grub/grub.cfg

