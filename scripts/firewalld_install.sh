#!/usr/bin/bash

echo "Script: Run firewalld after_install"

SERVICE_LIST_ARR=( dhcpv6-client kdeconnect mdns ssh steam-streaming steam-lan-transfer )
TRUSTED_INTERFACE_LIST_ARR=( tailscale0 )

CHANGED=no
sync_trust() {
	CURR_TRUST_LIST="$(sudo firewall-cmd --list-interfaces --zone=trusted)"
	IFS=" " read -r -a CURR_TRUST_LIST_ARR <<< "$CURR_TRUST_LIST"
	TRUSTED_INTERFACE_LIST="${TRUSTED_INTERFACE_LIST_ARR[@]}"

	echo "Current trusted interfaces [$CURR_TRUST_LIST]"
	for INTERFACE in ${TRUSTED_INTERFACE_LIST_ARR[@]}; do
		if ! grep "$INTERFACE" <<< "$CURR_TRUST_LIST" > /dev/null; then
			echo -n "Trust interface '$INTERFACE' "
			sudo firewall-cmd --permanent --add-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
	for INTERFACE in ${CURR_TRUST_LIST_ARR[@]}; do
		if ! grep "$INTERFACE" <<< "$TRUSTED_INTERFACE_LIST" > /dev/null; then
			echo -n "Untrust interface '$INTERFACE' "
			sudo firewall-cmd --permanent --remove-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
}

sync_services() {
	CURR_SERVICE_LIST="$(sudo firewall-cmd --list-services)"
	IFS=" " read -r -a CURR_SERVICE_LIST_ARR <<< "$CURR_SERVICE_LIST"
	SERVICE_LIST="${SERVICE_LIST_ARR[@]}"

	echo "Current enabled services [$CURR_SERVICE_LIST]"
	for SERVICE in ${SERVICE_LIST_ARR[@]}; do
		if ! grep "$SERVICE" <<< "$CURR_SERVICE_LIST" > /dev/null; then
			echo -n "Add service '$SERVICE' "
			sudo firewall-cmd --permanent --add-service=$SERVICE
			CHANGED=yes
		fi
	done
	for SERVICE in ${CURR_SERVICE_LIST_ARR[@]}; do
		if ! grep "$SERVICE" <<< "$SERVICE_LIST" > /dev/null; then
			echo -n "Remove service '$SERVICE' "
			sudo firewall-cmd --permanent --remove-service=$SERVICE
			CHANGED=yes
		fi
	done
}

sync_services
sync_trust
if [ "$CHANGED" = "yes" ]; then
	echo "Restart firewalld"
	sudo firewall-cmd --reload
else
	echo "Noting changed"
fi

