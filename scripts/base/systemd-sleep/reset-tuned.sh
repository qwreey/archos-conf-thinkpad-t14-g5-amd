#!/usr/bin/sh
script="/etc/tuned/profiles/$(tuned-adm active | sed 's/^.*: //g')/script.sh"
[ -e "$script" ] && $script
