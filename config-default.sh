#!/usr/bin/bash

# Chrome flags, add +Feature to enable feature, !Feature to disable feature and
# add --flag to provide command-line argument
# this configuration will be appied to $HOME/.var/app/com.google.Chrome
# > Note: please use just stable google-chrome flatpak, NO UNGOOGLED CHROME OR CHROMIUM OR CHROME-DEV
# >       if you don't use google-chrome, sadly, you may struggle with widevine library
# > Note: unlike firefox, currently chrome has very bad flatpak support. using system side
# >       google chrome package is much better than flatpak's one
# To apply changes, run scripts/chrome_install.sh
CHROME_FLAG_LIST=(
	# Hardware rendering / Improve performance
	#--ignore-gpu-blocklist # shouldn't used on modern gpu ENABLE WHEN REALLY YOU NEED
	#--use-gl=angle # maybe chrome use angle as default, but it doesn't work, try enforcing angle
	+TreesInViz
	--enable-zero-copy
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
	# '--user-agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 OPR/127.0.0.0"'

	# Vulkan shouldn't be enabled in wayland platform currently
	# [73:73:0305/024044.603422:ERROR:ui/ozone/platform/wayland/gpu/wayland_surface_factory.cc:251] '--ozone-platform=wayland' is not compatible with Vulkan. Consider switching to '--ozone-platform=x11' or disabling Vulkan
	!Vulkan
	!DefaultANGLEVulkan
	!VulkanFromANGLE
)
CHROME_FLAG_LIST_PATH=(
	"$HOME/.config/chrome-flags.conf"
	# .var/app/com.google.Chrome/config/chrome-flags.conf
)
CHROME_FLATPAK_IDS=(
	# com.google.Chrome
)
# Install chrome extension ['background runner'](https://chromewebstore.google.com/detail/chrome-background-runner/cfpbjggdmogjceodagocpbmikhdoaokn?hl=en-US)
# for faster PWA launching and keep all flags working in PWA
# make empty to disable autostart
CHROME_AUTOSTART="google-chrome-stable --no-startup-window"

# Firewalld configuration
# To apply changes, run scripts/firewalld_install.sh
FIREWALLD_SERVICE_LIST=(
	dhcpv6-client kdeconnect mdns ssh
	steam-streaming steam-lan-transfer minecraft
	rtsp rdp vnc
)
FIREWALLD_TRUSTED_INTERFACE_LIST=(
	tailscale0 # Trust all tailscale devices
)

obs-plugin-install() {
	flatpak override --user --filesystem=xdg-run/pipewire-0 com.obsproject.Studio
	github-plugin-install linux-pipewire-audio dimtpap/obs-pipewire-audio-capture "linux-pipewire-audio-[^-]*-flatpak-[^.]*.tar.gz"
	CUSTOM_INSTALL_EVAL='mkdir -p "$pluginPath/bin/64bit/"; cp "$downloadedPath" "$pluginPath/bin/64bit/obs-wayland-hotkeys.so"' github-plugin-install obs-wayland-hotkeys codycwiseman/wayland-hotkeys-plus "obs-wayland-hotkeys.so"
}
