#!/usr/bin/bash

device="$(grep -i ".*touchpad" -A 1 /proc/bus/input/devices | tail -n1 | sed "s/^P: Phys=//")"

if [ ! -z "$device" ]; then
    echo "KERNEL==\"$device\", DRIVERS==\"i2c_hid_acpi\", SUBSYSTEM==\"i2c\", ATTR{power/wakeup}=\"disabled\""
fi
# KERNEL=="PNP0C0E:00", SUBSYSTEM=="acpi", DRIVERS=="button", ATTRS{path}=="\_SB_.SLPB", ATTR{power/wakeup}="disabled"