#!/bin/sh
echo auto | tee /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level
echo powersave | tee /sys/module/pcie_aspm/parameters/policy
sleep 0.3
ryzenadj --power-saving
