#!/usr/bin/bash

if ! lscpu | grep "AMD Ryzen" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description="Change amd powermode to powersave"

[Service]
Type=oneshot
ExecStart=/usr/bin/ryzenadj --power-saving
EOF
