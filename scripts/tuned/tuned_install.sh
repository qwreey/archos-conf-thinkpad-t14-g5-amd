#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../../config-loader.sh"

echo "Coping profiles to /etc/tuned"
sudo mkdir -p /etc/tuned
sudo cp -r $SPATH/ppd.conf $SPATH/profiles /etc/tuned

echo "Enabling tuned, tuned-ppd"
sudo systemctl enable tuned tuned-ppd |& indent
