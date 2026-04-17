#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

echo "Updating /etc/conf.d/wireless-regdom"
sudo sed "s|^#*WIRELESS_REGDOM|#WIRELESS_REGDOM|g" -i /etc/conf.d/wireless-regdom
sudo sed "s|^#*WIRELESS_REGDOM=\"${WIRELESSREGDB_DOMAIN}\"|WIRELESS_REGDOM=\"${WIRELESSREGDB_DOMAIN}\"|g" -i /etc/conf.d/wireless-regdom
sudo set-wireless-regdom
