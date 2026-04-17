#!/usr/bin/bash

PIPEWIRE_PIPEWIRE_CONF=$(cat <<EOF
context.properties = {
  default.clock.max-quantum = 2048
  default.clock.min-quantum = 2048
}
EOF
)
PIPEWIRE_ENABLE_HW_VOLUME=false
