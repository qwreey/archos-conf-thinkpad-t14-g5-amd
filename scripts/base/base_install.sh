#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../../config-loader.sh"

# Create environment file
echo "Applying environment variable..."
environment_header=$(cat $SPATH/environment)
cat <<EOF | sudo tee /etc/environment | indent
$environment_header
$BASE_ENVIRONMENT
EOF

# Create local bin
sudo mkdir -p /usr/local/bin
sudo cp $SPATH/local-bin/* /usr/local/bin

# Create udev rules
echo "Applying udev rules..."
sudo mkdir -p /etc/udev/rules.d
for i in $SPATH/udev-rules/*.rules; do
	[ ! -e "$i" ] && continue
	echo "Install $(basename "$i")"
	sudo cp $i /etc/udev/rules.d/
done
for i in $SPATH/udev-rules/*.sh; do
	[ ! -e "$i" ] && continue
	filename=$(basename "$i")

	echo "Execute $filename" | indent
	output="$($SPATH/udev-rules/$filename)"
	if [ "$?" = 0 ] && [ ! -z "$output" ]; then
		sudo tee "/etc/udev/rules.d/${filename%.*}.rules" <<< "$output" | indent-2
	fi
done

# Create modules-load.d
echo "Applying module-load..."
sudo mkdir -p /etc/modules-load.d
sudo cp $SPATH/modules-load/* /etc/modules-load.d/

# Apply /etc/systemd/system
echo "Applying systemd services..."
execute_hook_for() {
	filename=$(basename "$1")
	filename="${filename%.sh}"
	filename="${filename%.service}"
	filename="${filename%.timer}"
	filename="${filename}.hook.sh"

	[ ! -e "$SPATH/systemd/$filename" ] && return
	echo "Execute hook $filename" | indent
	sudo "$SPATH/systemd/$filename" | indent-2
}
for i in $SPATH/systemd/*.service $SPATH/systemd/*.timer; do
	[ ! -e "$i" ] && continue
	echo "Install $(basename "$i")" | indent
	sudo cp "$i" /etc/systemd/system/
	execute_hook_for "$i"
done
for i in $SPATH/systemd/*.service.sh $SPATH/systemd/*.timer.sh; do
	filename=$(basename "$i")

	echo "Execute $filename" | indent
	output="$($SPATH/systemd/$filename)"
	if [ "$?" = 0 ] && [ ! -z "$output" ]; then
		sudo tee "/etc/systemd/system/${filename%.sh}" <<< "$output" | indent-2
		execute_hook_for "$i"
	fi
done

# Setup locale
echo "Applying locales..."
sudo sed "s|^#*|#|g" -i /etc/locale.gen
for x in "${BASE_LOCALE_GEN_LIST[@]}"; do
	sudo sed "s|#* *$x|$x|g" -i /etc/locale.gen
done
sudo locale-gen |& indent-2
sudo localectl set-locale LANG="$BASE_LOCALE_LANG" LC_CTYPE="$BASE_LOCALE_LC_CTYPE" |& indent-2

# Enable ssd trim timer
echo "Enabling ssd trim timer"
sudo systemctl enable fstrim.timer |& indent

# Add /etc/sudoers.d/config
echo "Applying sudoers..."
if [ ! -e /etc/sudoers.d ]; then
	sudo mkdir -p /etc/sudoers.d
	sudo chmod 0750 /etc/sudoers.d
fi
cat <<EOF | sudo tee /etc/sudoers.d/config | indent
%wheel ALL=(ALL:ALL) ALL
Defaults passwd_tries=5
EOF
sudo chmod 0440 /etc/sudoers.d/config
