#!/bin/sh
tee /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level <<< "low"
tee /sys/module/pcie_aspm/parameters/policy <<< "powersave"

if [ -e "/etc/systemd/system/ryzenadj-plugged-powersave.timer" ]; then
	systemctl stop ryzenadj-battery-powersave.timer ryzenadj-battery-balanced.timer ryzenadj-battery-performance.timer ryzenadj-plugged-powersave.timer ryzenadj-plugged-balanced.timer ryzenadj-plugged-performance.timer
	systemctl start ryzenadj-plugged-powersave.timer
fi
