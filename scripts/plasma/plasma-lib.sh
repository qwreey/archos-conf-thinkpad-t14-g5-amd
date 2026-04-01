#!/bin/bash

SPATH="$(dirname "$(readlink -f "$0")")"

has-kwin-instance() {
	[ -z "$(ps -A --user $UID | grep kwin)" ] && return 1
	return 0
}

kwin-plugin-enable() {
	kwriteconfig6 --file kwinrc --group "Plugins" --key "${1}Enabled" "true"
	if has-kwin-instance; then
		qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure
	fi
}
kwin-plugin-disable() {
	kwriteconfig6 --file kwinrc --group "Plugins" --key "${1}Enabled" "false"
	if has-kwin-instance; then
		qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure
	fi
}
kwin-plugin-check-enabled() {
	if [ "$(kreadconfig6 --file kwinrc --group "Plugins" --key "${1}Enabled")" = "true" ]; then
		return 0
	fi
	return 1
}

effect-unload() {
	echo "unloading effect '$1'"
	if has-kwin-instance; then
		if [ "$(qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.isEffectLoaded "$1")" = "true" ]; then
			qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect "$1"
		fi
	fi
	if ! package-is-installed effect "$1"; then
		echo "effect '$1' is not installed" >&2
		return 1
	fi
	if ! kwin-plugin-check-enabled "$1"; then
		echo "effect '$1' is not loaded" >&2
		return 0
	fi
	kwin-plugin-disable "$1"
}

effect-reload() {
	if ! package-is-installed effect "$1"; then
		echo "effect '$1' is not installed" >&2
		return 1
	fi

	if has-kwin-instance; then
		local supported=$(qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.isEffectSupported "$1")
		if [ "$supported" != "true" ]; then
			echo "Effect '$1' is not supported" >&2
			return 1
		fi
		local enabled=$(qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.isEffectLoaded "$1")
		if [ "$enabled" = "true" ]; then
			echo "unloading effect '$1'"
			qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.unloadEffect "$1" > /dev/null
		fi
	fi

	echo "loading effect '$1'"
	qdbus6 org.kde.KWin /Effects org.kde.kwin.Effects.loadEffect "$1" > /dev/null
	kwin-plugin-enable "$1"
}

script-unload() {
	echo "unloading script '$1'"
	if ! package-is-installed script $1; then
		echo "script '$1' is not installed" >&2
		return 1
	fi
	if ! kwin-plugin-check-enabled "$1"; then
		echo "script '$1' is not loaded" >&2
		return 0
	fi
	kwin-plugin-disable "$1"
	if has-kwin-instance; then
		while true; do
			enabled=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded "$1")
			[ "$enabled" = "false" ] && break
			sleep 1
		done
	fi
}

script-reload() {
	if ! package-is-installed script $1; then
		echo "script '$1' is not installed" >&2
		return 1
	fi
	if has-kwin-instance; then
		local enabled=$(qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.isScriptLoaded "$1")
		[ "$enabled" = "true" ] && script-unload "$1"
	fi
	echo "loading script '$1'"
	kwin-plugin-enable "$1"
}

parse-packagetype() {
	case "$1" in
		script)
			echo "KWin/Script"
		;;
		effect)
			echo "KWin/Effect"
		;;
		sensorface)
			echo "KSysguard/SensorFace"
		;;
		*)
			echo "Failed to parse package type '$1'" >&2
			return 1
		;;
	esac
	return 0
}

package-is-installed() {
	local packageType=$(parse-packagetype $1)
	[ -z "$packageType" ] && return 1
	local common="$(comm -12 <(kpackagetool6 --type $packageType --list | tail +2 | sort) <(echo "$2"))"
	[ -z "$common" ] && return 1
	return 0
}

package-install() {
	local packageType=$(parse-packagetype $1)
	[ -z "$packageType" ] && return 1

	local packagePath="$2"
	if [ -e "$SPATH/packages/$2" ]; then
		packagePath="$SPATH/packages/$2"
	fi

	if ! kpackagetool6 --type $packageType --upgrade $packagePath; then
		echo "upgrade failed, try installing"
		kpackagetool6 --type $packageType --install $packagePath
	fi
}

