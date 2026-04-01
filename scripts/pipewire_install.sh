#!/usr/bin/bash

echo "Script: Run pipewire after_install"

mkdir -p ~/.config/pipewire/pipewire.conf.d
cat <<EOF | tee ~/.config/pipewire/pipewire.conf.d/custom.conf
context.properties = {
  default.clock.max-quantum = 2048
  default.clock.min-quantum = 2048
}
EOF

mkdir -p ~/.config/wireplumber/wireplumber.conf.d
cat <<EOF | tee ~/.config/wireplumber/wireplumber.conf.d/80-bluez-disable-hw-volume.conf
monitor.bluez.properties = {
  bluez5.enable-hw-volume = false
}
EOF

