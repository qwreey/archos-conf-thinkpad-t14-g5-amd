#!/usr/bin/bash

echo "Script: Run avahi after_install"

sudo sed -E 's|^hosts: mymachines( *mdns[^ ]+)?( *\[NOTFOUND=return\])? *(.+)|hosts: mymachines mdns4_minimal [NOTFOUND=return] \3|' -i /etc/nsswitch.conf
sudo systemctl enable avahi-daemon

sudo mkdir -p /etc/systemd/resolved.conf.d
cat - <<EOF | sudo tee /etc/systemd/resolved.conf.d/00-disable-mdns.conf
[Resolve]
MulticastDNS=no
LLMNR=no
EOF

