#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-loader.sh"

echo "Enabling firewalld"
sudo systemctl enable --now firewalld |& indent

CHANGED=no
sync_trust() {
	echo "Sync trust list"
	CURR_TRUST="$(sudo firewall-cmd --list-interfaces --zone=trusted)"
	IFS=" " read -r -a CURR_TRUST_LIST <<< "$CURR_TRUST"
	TRUSTED_INTERFACE="${FIREWALLD_TRUSTED_INTERFACE_LIST[@]}"

	echo "Current trusted interfaces [$CURR_TRUST]" | indent
	for INTERFACE in ${FIREWALLD_TRUSTED_INTERFACE_LIST[@]}; do
		if ! grep "$INTERFACE" <<< "$CURR_TRUST" > /dev/null; then
			echo -n "Trust interface '$INTERFACE' " | indent-2
			sudo firewall-cmd --permanent --add-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
	for INTERFACE in ${CURR_TRUST_LIST[@]}; do
		if ! grep "$INTERFACE" <<< "$TRUSTED_INTERFACE" > /dev/null; then
			echo -n "Untrust interface '$INTERFACE' " | indent-2
			sudo firewall-cmd --permanent --remove-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
}

sync_services() {
	echo "Sync service list"
	CURR_SERVICE="$(sudo firewall-cmd --list-services)"
	IFS=" " read -r -a CURR_SERVICE_LIST <<< "$CURR_SERVICE"
	SERVICE_LIST="${FIREWALLD_SERVICE_LIST[@]}"

	echo "Current enabled services [$CURR_SERVICE]" | indent
	for SERVICE in ${FIREWALLD_SERVICE_LIST[@]}; do
		if ! grep "$SERVICE" <<< "$CURR_SERVICE" > /dev/null; then
			echo -n "Add service '$SERVICE' " | indent-2
			sudo firewall-cmd --permanent --add-service=$SERVICE
			CHANGED=yes
		fi
	done
	for SERVICE in ${CURR_SERVICE_LIST[@]}; do
		if ! grep "$SERVICE" <<< "$SERVICE_LIST" > /dev/null; then
			echo -n "Remove service '$SERVICE' " | indent-2
			sudo firewall-cmd --permanent --remove-service=$SERVICE
			CHANGED=yes
		fi
	done
}

sync_ports() {
	echo "Sync port list"
	CURR_PORT="$(sudo firewall-cmd --list-port)"
	IFS=" " read -r -a CURR_PORT_LIST <<< "$CURR_PORT"
	PORT_LIST="${FIREWALLD_PORT_LIST[@]}"

	echo "Current enabled ports [$CURR_PORT]" | indent
	for PORT in ${FIREWALLD_PORT_LIST[@]}; do
		if ! grep "$PORT" <<< "$CURR_PORT" > /dev/null; then
			echo -n "Add port '$PORT' " | indent-2
			sudo firewall-cmd --permanent --add-port=$PORT
			CHANGED=yes
		fi
	done
	for PORT in ${CURR_PORT_LIST[@]}; do
		if ! grep "$PORT" <<< "$PORT_LIST" > /dev/null; then
			echo -n "Remove port '$PORT' " | indent-2
			sudo firewall-cmd --permanent --remove-port=$PORT
			CHANGED=yes
		fi
	done
}

sync_services
sync_ports
sync_trust
if [ "$CHANGED" = "yes" ]; then
	echo "Restart firewalld"
	sudo firewall-cmd --reload
else
	echo "Noting changed"
fi
