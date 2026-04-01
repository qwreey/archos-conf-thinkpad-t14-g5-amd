#!/usr/bin/bash

echo "Script: Run chrome after_install"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-default.sh"
[ -e "$SPATH/../config-user.sh" ] && source "$SPATH/../config-user.sh"

extract_optns() {
	for x in "${CHROME_FLAG_LIST[@]}"; do
		if [[ "$x" == "--"* ]]; then
			printf "%s\n" "$x"
		fi
	done
}

extract_enable_feats() {
	local first=yes
	for x in "${CHROME_FLAG_LIST[@]}"; do
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
	for x in "${CHROME_FLAG_LIST[@]}"; do
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

write_configs() {
	CONFIG_CONTENT=$(cat <<EOF
$(extract_optns)
$(extract_disable_feats)
$(extract_enable_feats)
EOF
	)
	for path in "${CHROME_FLAG_LIST_PATH[@]}"; do
		mkdir -p "$(dirname "$path")"
		tee "$path" <<< "$CONFIG_CONTENT"
	done
}

update_flatpak_perm() {
	for x in "${CHROME_FLATPAK_IDS[@]}"; do
		flatpak --user override --filesystem=xdg-data/icons "$x"
		flatpak --user override --filesystem=xdg-data/applications "$x"
		flatpak --user override --filesystem=xdg-desktop "$x"
		flatpak override --user --talk-name=org.kde.kwalletd6 "$x"
	done
}

update_autostart() {
	if [ -z "$CHROME_AUTOSTART" ]; then
		[ -e ~/.config/autostart/chrome-autostart.desktop ] && rm ~/.config/autostart/chrome-autostart.desktop
		return
	fi
	cat <<EOF | tee ~/.config/autostart/chrome-autostart.desktop
[Desktop Entry]
Comment=Start chrome background workers without main window
Exec=$CHROME_AUTOSTART
Name=chrome-autostart
StartupNotify=false
Terminal=false
Type=Application
Version=1.0
EOF
}

write_configs
update_flatpak_perm
update_autostart

