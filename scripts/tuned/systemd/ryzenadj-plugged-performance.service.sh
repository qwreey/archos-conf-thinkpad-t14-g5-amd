#!/usr/bin/bash

if ! lscpu | grep "AMD Ryzen" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description="Update ryzen smu options to plugged performance"

[Service]
Type=oneshot
ExecStart=$TUNED_RYZENADJ_BIN $TUNED_RYZENADJ_PLUGGED_PERFORMANCE_PARAMS
EOF
