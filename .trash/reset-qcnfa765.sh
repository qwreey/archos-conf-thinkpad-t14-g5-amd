#!/usr/bin/bash
[ "$1" != "post" ] && exit

while IFS= read -r line; do
    if [[ $line =~ ([0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]\.[0-9a-f]).*QCNFA765 ]]; then
        device="/sys/bus/pci/devices/0000:${BASH_REMATCH[1]}/reset"
        echo Reset $device
        echo 1 > $device
    fi
done <<< "$(lspci)"

