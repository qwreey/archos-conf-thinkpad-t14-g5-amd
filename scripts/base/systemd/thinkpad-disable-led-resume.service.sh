#!/usr/bin/bash

if ! lsmod | grep thinkpad_acpi &> /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description=Disables the red logo LED at resume
After=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "echo 0 > /sys/class/leds/tpacpi::lid_logo_dot/brightness ; echo 0 > /sys/class/leds/tpacpi::power/brightness"

[Install]
WantedBy=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target
EOF
