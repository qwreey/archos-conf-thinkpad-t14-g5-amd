#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"
require-nonroot

PLUGINS_PATH=$HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins

mkdir -p $PLUGINS_PATH

github-latest-release() {
	# $1 : repo
	curl -Ls -w %{url_effective} "https://github.com/$1/releases/latest" --no-progress-meter -o /dev/null | grep "[^/]*$"
}

github-release-get-file() {
	# $1 : repo
	# $2 : version (latest, ...)
	# $3 : file name regex
	# output : tmp file path
	local filesListURL="$(curl -L "https://github.com/$1/releases/$2" --no-progress-meter | grep -o 'https://.*/releases/expanded_assets/[^"]*')"
	local fileURL=$(curl "$filesListURL" --no-progress-meter | grep -o "/$1/releases/download/[^/]*/$3")
	[ -z "$fileURL" ] && return 1

	local filePath=$(mktemp)
	curl -Lo "$filePath" "https://github.com$fileURL"
	echo "$filePath"
}

plugin-version() {
	# $1 : plugin name
	[ ! -e "$PLUGINS_PATH/$1/_managed_version" ] && return
	cat "$PLUGINS_PATH/$1/_managed_version"
}

github-plugin-install() {
	# $1 : plugin name
	# $2 : repo
	# $3 : file regex
	local remoteLatestVersion="$(github-latest-release "$2")"

	if [ "$(plugin-version "$1")" == "$remoteLatestVersion" ]; then
		echo "Plugin '$1' is up-to-date"
		return 0
	fi
	
	local downloadedPath="$(github-release-get-file "$2" "latest" "$3")"
	if [ -z "$downloadedPath" ]; then
		echo "Failed to fetch object for plugin '$1' from github"
		return 1
	fi

	local pluginPath="$PLUGINS_PATH/$1"
	[ -e "$pluginPath" ] && rm -r "$pluginPath"
	if [ ! -z "$CUSTOM_INSTALL_EVAL" ]; then
		eval "$CUSTOM_INSTALL_EVAL"
	else
		tar xf "$downloadedPath" -C "$PLUGINS_PATH"
	fi
	echo "Installed plugin '$1'"
	rm "$downloadedPath"
	echo "$remoteLatestVersion" > "$PLUGINS_PATH/$1/_managed_version"
}

obs-plugin-install
