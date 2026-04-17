#!/usr/bin/bash

obs-plugin-install() {
	# Application audio capture
	flatpak override --user --filesystem=xdg-run/pipewire-0 com.obsproject.Studio
	github-plugin-install linux-pipewire-audio dimtpap/obs-pipewire-audio-capture "linux-pipewire-audio-[^-]*-flatpak-[^.]*.tar.gz"

	# Global shortcuts
	CUSTOM_INSTALL_EVAL='mkdir -p "$pluginPath/bin/64bit/"; cp "$downloadedPath" "$pluginPath/bin/64bit/obs-wayland-hotkeys.so"' github-plugin-install obs-wayland-hotkeys codycwiseman/wayland-hotkeys-plus "obs-wayland-hotkeys.so"
}
