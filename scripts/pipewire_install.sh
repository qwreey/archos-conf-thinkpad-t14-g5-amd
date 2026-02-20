#/usr/bin/bash

echo "Script: Run pipewire after_install"

mkdir -p ~/.config/pipewire/pipewire.conf.d
cat <<EOF | tee ~/.config/pipewire/pipewire.conf.d/custom.conf
context.properties = {
  default.clock.max-quantum = 2048
  default.clock.min-quantum = 2048
}
EOF

