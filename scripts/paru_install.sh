#!/usr/bin/bash

echo "Script: Run paru after_install"

mkdir -p ~/.config/paru
cat - <<EOF | tee ~/.config/paru/paru.conf
[options]
RemoveMake = yes
SudoLoop = true
InstallDebug = false
SortBy = popularity
MakepkgConf = $HOME/.config/paru/makepkg.conf
PacmanConf = $HOME/.config/paru/pacman.conf
EOF

cp /etc/makepkg.conf ~/.config/paru/makepkg.conf
cp /etc/pacman.conf ~/.config/paru/pacman.conf
sed "s/OPTIONS=(.*)/OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug lto)/" -i ~/.config/paru/makepkg.conf
sed "s/#* *Color/Color/" -i ~/.config/paru/pacman.conf

