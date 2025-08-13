#!/bin/sh
ryzenadj --max-performance
echo auto | tee /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level
echo powersave | tee /sys/module/pcie_aspm/parameters/policy
