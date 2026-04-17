#!/usr/bin/bash

# Firewalld configuration
# To apply changes, run scripts/firewalld_install.sh

# allowed service list, run `firewall-cmd --get-services` to get
# list of all available services
FIREWALLD_SERVICE_LIST=(
	dhcpv6-client kdeconnect mdns ssh
	steam-streaming steam-lan-transfer minecraft
	rtsp rdp vnc-server
)

# Trust *all* connection from this interface
FIREWALLD_TRUSTED_INTERFACE_LIST=(
	tailscale0 # Trust all tailscale devices
)

# All user defined allowed port list
# ex: 80/tcp
FIREWALLD_PORT_LIST=(
	1234/tcp # LM studio
)
