#!/usr/bin/bash

for i in $(dirname "${BASH_SOURCE[0]}")/configs/*-default.sh; do
	[ -e "$i" ] && source "$i"
done
for i in $(dirname "${BASH_SOURCE[0]}")/configs/*-user.sh; do
	[ -e "$i" ] && source "$i"
done

# lib

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