#!/usr/bin/bash

echo "Script: Run firewalld after_install"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../config-default.sh"
[ -e "$SPATH/../config-user.sh" ] && source "$SPATH/../config-user.sh"

CHANGED=no
sync_trust() {
	CURR_TRUST="$(sudo firewall-cmd --list-interfaces --zone=trusted)"
	IFS=" " read -r -a CURR_TRUST_LIST <<< "$CURR_TRUST"
	TRUSTED_INTERFACE="${FIREWALLD_TRUSTED_INTERFACE_LIST[@]}"

	echo "Current trusted interfaces [$CURR_TRUST]"
	for INTERFACE in ${FIREWALLD_TRUSTED_INTERFACE_LIST[@]}; do
		if ! grep "$INTERFACE" <<< "$CURR_TRUST" > /dev/null; then
			echo -n "Trust interface '$INTERFACE' "
			sudo firewall-cmd --permanent --add-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
	for INTERFACE in ${CURR_TRUST_LIST[@]}; do
		if ! grep "$INTERFACE" <<< "$TRUSTED_INTERFACE" > /dev/null; then
			echo -n "Untrust interface '$INTERFACE' "
			sudo firewall-cmd --permanent --remove-interface=$INTERFACE --zone=trusted
			CHANGED=yes
		fi
	done
}

sync_services() {
	CURR_SERVICE="$(sudo firewall-cmd --list-services)"
	IFS=" " read -r -a CURR_SERVICE_LIST <<< "$CURR_SERVICE"
	SERVICE_LIST="${FIREWALLD_SERVICE_LIST[@]}"

	echo "Current enabled services [$CURR_SERVICE]"
	for SERVICE in ${FIREWALLD_SERVICE_LIST[@]}; do
		if ! grep "$SERVICE" <<< "$CURR_SERVICE" > /dev/null; then
			echo -n "Add service '$SERVICE' "
			sudo firewall-cmd --permanent --add-service=$SERVICE
			CHANGED=yes
		fi
	done
	for SERVICE in ${CURR_SERVICE_LIST[@]}; do
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

