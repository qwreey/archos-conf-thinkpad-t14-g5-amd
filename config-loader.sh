#!/usr/bin/bash

for i in $(dirname "${BASH_SOURCE[0]}")/configs/*-default.sh; do
	[ -e "$i" ] && source "$i"
done
for i in $(dirname "${BASH_SOURCE[0]}")/configs/*-user.sh; do
	[ -e "$i" ] && source "$i"
done

# lib
execute-systemd-hook() {
	local filename=$(basename "$1")
	local dir=$(dirname "$1")
	filename="${filename%.sh}"
	filename="${filename%.service}"
	filename="${filename%.timer}"
	filename="${filename}.hook.sh"

	[ ! -e "$dir/$filename" ] && return
	echo "Execute hook $filename" | indent
	sudo "$dir/$filename" | indent-2
}
apply-systemd-unit() {
	local filename=$(basename "$i")
	local extension=${filename##*.}
	local dir=$(dirname "$1")

	[ ! -e "$1" ] && return

	if [ "$extension" != "sh" ]; then
		echo "Install $filename"
		sudo cp "$1" /etc/systemd/system/
		execute-systemd-hook "$1"
	else
		echo "Execute $filename"
		output="$($1)"
		if [ "$?" = 0 ] && [ ! -z "$output" ]; then
			sudo tee "/etc/systemd/system/${filename%.sh}" <<< "$output" | indent-2
			execute-systemd-hook "$1"
		fi
	fi
}

indent() {
	sed "s/^/ | /g"
}
indent-2() {
	sed "s/^/ | > /g"
}
require-nonroot() {
	if [ "0" = "$UID" ]; then
		echo "This script requires executed by non-root user!"
	fi
}