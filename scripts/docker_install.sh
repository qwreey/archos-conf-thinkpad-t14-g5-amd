#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

echo "Enabling docker"
sudo systemctl enable --now docker |& indent
