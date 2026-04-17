#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

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
	echo "Update chrome flags"
	CONFIG_CONTENT=$(cat <<EOF
$(extract_optns)
$(extract_disable_feats)
$(extract_enable_feats)
EOF
	)
	echo "Compiling options" | indent
	echo "$CONFIG_CONTENT" | indent-2
	for path in "${CHROME_FLAG_LIST_PATH[@]}"; do
		echo "Applying to $path" | indent
		mkdir -p "$(dirname "$path")"
		tee "$path" <<< "$CONFIG_CONTENT" > /dev/null
	done
}

update_flatpak_perm() {
	echo "Updating flatpak overrides"
	for x in "${CHROME_FLATPAK_IDS[@]}"; do
		echo "Update for '$x'" | indent
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
	echo "Adding autostart target 'chrome-autostart.desktop'"
	cat <<EOF | tee ~/.config/autostart/chrome-autostart.desktop | indent
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

