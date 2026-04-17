#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

echo "Updating /etc/nsswitch.conf : hosts"
sudo sed -E 's|^hosts: mymachines( *mdns[^ ]+)?( *\[NOTFOUND=return\])? *(.+)|hosts: mymachines mdns4_minimal [NOTFOUND=return] \3|' -i /etc/nsswitch.conf

echo "Creating /etc/systemd/resolved.conf.d/00-disable-mdns.conf"
sudo mkdir -p /etc/systemd/resolved.conf.d
cat - <<EOF | sudo tee /etc/systemd/resolved.conf.d/00-disable-mdns.conf | indent
[Resolve]
MulticastDNS=no
LLMNR=no
EOF

echo "Enabling avahi-daemon"
sudo systemctl enable --now avahi-daemon |& indent
