#!/usr/bin/bash

if lscpu | grep "AMD Ryzen" > /dev/null; then
    cat <<EOF
SUBSYSTEM=="cpu", KERNEL=="cpu[0-9]|cpu[0-9][0-9]", ACTION=="add|change", RUN="/usr/bin/bash -c 'cat /sys/devices/system/cpu/%k/cpufreq/cpuinfo_min_freq > /sys/devices/system/cpu/%k/cpufreq/scaling_min_freq'"
EOF
fi
