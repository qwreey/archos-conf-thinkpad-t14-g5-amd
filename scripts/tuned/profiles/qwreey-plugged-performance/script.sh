#!/bin/sh
echo auto | tee /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level
echo performance | tee /sys/module/pcie_aspm/parameters/policy

systemctl stop ryzenadj-powersave.timer ryzenadj-performance.timer
systemctl start ryzenadj-performance.timer
