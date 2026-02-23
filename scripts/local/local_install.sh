#!/usr/bin/bash

echo "Script: Run local after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

# Clone local binaries
mkdir -p $HOME/.local/bin/
cp -r $SPATH/bin/* $HOME/.local/bin/
