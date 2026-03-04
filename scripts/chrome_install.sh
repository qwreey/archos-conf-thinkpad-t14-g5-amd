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

