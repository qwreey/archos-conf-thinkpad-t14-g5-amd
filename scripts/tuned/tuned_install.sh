#/usr/bin/bash

echo "Script: Run tuned after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

sudo mkdir -p /etc/tuned
sudo cp -r $SPATH/ppd.conf $SPATH/profiles /etc/tuned

sudo systemctl enable tuned tuned-ppd

