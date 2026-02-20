#/usr/bin/bash

echo "Script: Run chrome after_install"

sudo mkdir -p /usr/local/bin
cat <<EOF | sudo tee /usr/local/bin/chrome
#!/bin/bash
flatpak run com.google.Chrome \$@
EOF
sudo chmod a+x /usr/local/bin/chrome

flatpak --user override --filesystem=xdg-data/icons com.google.Chrome
flatpak --user override --filesystem=xdg-data/applications com.google.Chrome
flatpak --user override --filesystem=xdg-desktop com.google.Chrome

