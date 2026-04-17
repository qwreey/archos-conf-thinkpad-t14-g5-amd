#!/usr/bin/bash

if ! lspci | grep "Qualcomm Technologies, Inc QCNFA765 Wireless Network Adapter" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description=Fix irregular wifi issue after suspend and resume: modprobe ath11k_pci
After=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/modprobe ath11k_pci

[Install]
WantedBy=suspend.target suspend-then-hibernate.target hibernate.target hybrid-sleep.target
EOF