#!/usr/bin/bash

if ! lscpu | grep "AMD Ryzen" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description="Run ryzenadj-battery-powersave.service after 2sec waitting"

[Timer]
OnActiveSec=2
Unit=ryzenadj-battery-powersave.service
EOF
