#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

echo "Updating paru.conf"
mkdir -p ~/.config/paru
cat - <<EOF | tee ~/.config/paru/paru.conf | indent
[options]
RemoveMake = yes
SudoLoop = true
InstallDebug = false
SortBy = popularity
MakepkgConf = $HOME/.config/paru/makepkg.conf
PacmanConf = $HOME/.config/paru/pacman.conf
EOF

echo "Adding makepkg.conf, pacman.conf to paru"
cp /etc/makepkg.conf ~/.config/paru/makepkg.conf
cp /etc/pacman.conf ~/.config/paru/pacman.conf
sed "s/OPTIONS=(.*)/OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)/" -i ~/.config/paru/makepkg.conf
sed "s/#* *Color/Color/" -i ~/.config/paru/pacman.conf

