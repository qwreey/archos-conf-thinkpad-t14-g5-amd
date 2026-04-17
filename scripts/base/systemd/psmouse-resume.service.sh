#!/usr/bin/bash

if ! lsmod | grep "psmouse" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description=Fix irregular trackpoint issue after suspend and resume: modprobe psmouse
After=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/modprobe psmouse

[Install]
WantedBy=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target
EOF
