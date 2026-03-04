#!/usr/bin/bash

echo "Script: Run chrome after_install"

FLAG_LIST=(
	# Hardware rendering / Improve performance
	+TreesInViz
	#--ignore-gpu-blocklist shouldn't used on modern gpu
	--enable-zero-copy
	--enable-quic
	--ozone-platform-hint=auto

	# Video acceleration
	+AcceleratedVideoEncoder
	+AcceleratedVideoDecodeLinuxGL
	+AcceleratedVideoDecodeLinuxZeroCopyGL
	+VaapiVideoDecoder
	+VaapiVideoEncoder
	+VaapiIgnoreDriverChecks

	# Fix buggy fcitx5 ime
	--disable-gtk-ime
	--enable-wayland-ime
	--wayland-text-input-version=3

	# UI
	+TouchpadOverscrollHistoryNavigation
	+FluentOverlayScrollbar
	+OverlayScrollbar

	# ETC
	+UseStructuredDnsErrors
	'--user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0"'

	# Vulkan shouldn't be enabled in wayland platform
	# [73:73:0305/024044.603422:ERROR:ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc:251] '--ozone-platform=wayland' is not compatible with Vulkan. Consider switching to '--ozone-platform=x11' or disabling Vulkan
	#!Vulkan
	#!DefaultANGLEVulkan
	#!VulkanFromANGLE
	#--use-gl=angle
)

extract_optns() {
	for x in "${FLAG_LIST[@]}"; do
		if [[ "$x" == "--"* ]]; then
			printf "%s\n" "$x"
		fi
	done
}
extract_enable_feats() {
	local first=yes
	for x in "${FLAG_LIST[@]}"; do
		if [[ "$x" == "+"* ]]; then
			if [ "$first" == "yes" ]; then
				first=no
				printf "%s" "--enable-features="
			else
				printf ","
			fi
			printf "%s" "${x#+}"
		fi
	done
}
extract_disable_feats() {
	local first=yes
	for x in "${FLAG_LIST[@]}"; do
		if [[ "$x" == "!"* ]]; then
			if [ "$first" == "yes" ]; then
				first=no
				printf "%s" "--disable-features"
			else
				printf ","
			fi
			printf "%s" "${x#!}"
		fi
	done
}

mkdir -p .var/app/com.google.Chrome/config
cat <<EOF > .var/app/com.google.Chrome/config/chrome-flags.conf
$(extract_optns)
$(extract_disable_feats)
$(extract_enable_feats)
EOF

flatpak --user override --filesystem=xdg-data/icons com.google.Chrome
flatpak --user override --filesystem=xdg-data/applications com.google.Chrome
flatpak --user override --filesystem=xdg-desktop com.google.Chrome
flatpak override --user --talk-name=org.kde.kwalletd6 com.google.Chrome

if [ ! -e /usr/local/bin/chrome ]; then
	sudo mkdir -p /usr/local/bin
	cat <<EOF | sudo tee /usr/local/bin/chrome
#!/bin/bash
flatpak run com.google.Chrome \$@
EOF
	sudo chmod a+x /usr/local/bin/chrome
fi

