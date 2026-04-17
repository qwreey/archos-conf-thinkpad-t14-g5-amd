#!/usr/bin/bash

if ! lscpu | grep "AMD Ryzen" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description="Run ryzenadj-performance.service after 3sec waitting"

[Timer]
OnActiveSec=3
Unit=ryzenadj-performance.service
EOF
