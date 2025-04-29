#!/bin/sh
echo low | tee /sys/class/drm/card[0-9]/device/power_dpm_force_performance_level
echo powersupersave | tee /sys/module/pcie_aspm/parameters/policy

