#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

echo "Updating pipewire.conf.d/custom.conf"
mkdir -p ~/.config/pipewire/pipewire.conf.d
tee ~/.config/pipewire/pipewire.conf.d/custom.conf <<< "$PIPEWIRE_PIPEWIRE_CONF" | indent

echo "Updating wireplumber/wireplumber.conf.d"
mkdir -p ~/.config/wireplumber/wireplumber.conf.d
cat <<EOF | tee ~/.config/wireplumber/wireplumber.conf.d/80-bluez-disable-hw-volume.conf | indent
monitor.bluez.properties = {
  bluez5.enable-hw-volume = $PIPEWIRE_ENABLE_HW_VOLUME
}
EOF

