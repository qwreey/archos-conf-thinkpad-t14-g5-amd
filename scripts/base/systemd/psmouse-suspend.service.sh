#!/usr/bin/bash

if ! lsmod | grep "psmouse" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description=Fix irregular trackpoint issue after suspend and resume: rmmod psmouse
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rmmod psmouse

[Install]
WantedBy=sleep.target
EOF
