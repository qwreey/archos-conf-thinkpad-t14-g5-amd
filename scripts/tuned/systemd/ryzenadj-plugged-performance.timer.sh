#!/usr/bin/bash

if ! lscpu | grep "AMD Ryzen" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description="Run ryzenadj-plugged-performance.service after 2sec waitting"

[Timer]
OnActiveSec=2
Unit=ryzenadj-plugged-performance.service
EOF
