#!/usr/bin/bash

if ! lspci | grep "Qualcomm Technologies, Inc QCNFA765 Wireless Network Adapter" > /dev/null; then
    exit 1
fi

cat <<EOF
[Unit]
Description=Fix irregular wifi issue after suspend and resume: rmmod ath11k_pci
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rmmod ath11k_pci

[Install]
WantedBy=sleep.target
EOF
