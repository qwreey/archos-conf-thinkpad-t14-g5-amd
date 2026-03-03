#!/usr/bin/bash

echo "Script: Run chrome after_install"

sudo mkdir -p /usr/local/bin
cat <<EOF | sudo tee /usr/local/bin/chrome
#!/bin/bash
flatpak run com.google.Chrome \$@
EOF
cat <<EOF > .var/app/com.google.Chrome/config/chrome-flags.conf
--user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0"

--ignore-gpu-blocklist
--enable-zero-copy
--enable-quic
--ozone-platform-hint=auto

--enable-features=AcceleratedVideoEncoder,VaapiVideoDecoder,VaapiVideoEncoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,TouchpadOverscrollHistoryNavigation,FluentOverlayScrollbar,OverlayScrollbar,TreesInViz,UseStructuredDnsErrors
EOF
sudo chmod a+x /usr/local/bin/chrome

flatpak --user override --filesystem=xdg-data/icons com.google.Chrome
flatpak --user override --filesystem=xdg-data/applications com.google.Chrome
flatpak --user override --filesystem=xdg-desktop com.google.Chrome

