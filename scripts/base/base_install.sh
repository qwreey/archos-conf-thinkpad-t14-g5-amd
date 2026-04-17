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

# Create udev rules
echo "Applying udev rules..."
sudo mkdir -p /etc/udev/rules.d
sudo cp $SPATH/udev-rules/*.rules /etc/udev/rules.d/
for i in $SPATH/udev-rules/*.sh; do
	filename=$(basename "$i")

	echo "Execute $filename" | indent
	output=$($SPATH/udev-rules/$filename)
	if [ "$?" = 0 ] && [ ! -z "$output" ]; then
		sudo tee "/etc/udev/rules.d/${filename%.*}.rules" <<< "$output" | indent-2
	fi
done

# Create modules-load.d
echo "Applying module-load..."
sudo mkdir -p /etc/modules-load.d
sudo cp $SPATH/modules-load/* /etc/modules-load.d/

# Disable leds for thinkpad, if thinkpad_acpi loaded
if lsmod | grep thinkpad_acpi &> /dev/null; then
	echo "Applying thinkpad disable idle led services..."
	sudo mkdir -p /etc/systemd/system
	sudo cp $SPATH/systemd/thinkpad-disable-led.service /etc/systemd/system/
	sudo systemctl enable thinkpad-disable-led |& indent-2
fi

if lscpu | grep "AMD Ryzen" > /dev/null; then
	echo "Installing amd ryzenadj service"
	sudo cp $SPATH/systemd/ryzenadj-* /etc/systemd/system/
fi

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

# Inject sleep workarounds
echo "Applying sleep workarounds..."
sudo mkdir -p /lib/systemd/system-sleep
sudo cp $SPATH/systemd-sleep/* /lib/systemd/system-sleep

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
