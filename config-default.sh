#!/usr/bin/bash

# Chrome flags, add +Feature to enable feature, !Feature to disable feature and
# add --flag to provide command-line argument
# this configuration will be appied to $HOME/.var/app/com.google.Chrome
# > Note: please use just stable google-chrome flatpak, NO UNGOOGLED CHROME OR CHROMIUM OR CHROME-DEV
# >       if you don't use google-chrome, sadly, you may struggle with widevine library
# To apply changes, run scripts/chrome_install.sh
CHROME_FLAG_LIST=(
	# Hardware rendering / Improve performance
	#--ignore-gpu-blocklist # shouldn't used on modern gpu ENABLE WHEN REALLY YOU NEED
	#--use-gl=angle # maybe chrome use angle as default, but it doesn't work, try enforcing angle
	+TreesInViz
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

	# For netflix 1080p streaming, use opera's user-agent
	'--user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0"'

	# Vulkan shouldn't be enabled in wayland platform currently
	# [73:73:0305/024044.603422:ERROR:ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc:251] '--ozone-platform=wayland' is not compatible with Vulkan. Consider switching to '--ozone-platform=x11' or disabling Vulkan
	!Vulkan
	!DefaultANGLEVulkan
	!VulkanFromANGLE
)

# Firewalld configuration
# To apply changes, run scripts/firewalld_install.sh
FIREWALLD_SERVICE_LIST=(
	dhcpv6-client kdeconnect mdns ssh
	steam-streaming steam-lan-transfer
)
FIREWALLD_TRUSTED_INTERFACE_LIST=(
	tailscale0 # Trust all tailscale devices
)

