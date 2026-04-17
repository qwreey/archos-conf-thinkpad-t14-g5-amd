#!/bin/sh
if [ "$1" == "post" ]; then
	echo 0 > /sys/class/leds/tpacpi::lid_logo_dot/brightness
	echo 0 > /sys/class/leds/tpacpi::power/brightness
fi
