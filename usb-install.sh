#!/usr/bin/bash

MOUNT_ROOT=/mnt/extn_root
USERNAME=yaeji

pacstrap -K $MOUNT_ROOT base-devel linux linux-firmware linux-headers grub sudo openssh mandoc arch-install-scripts \
efibootmgr smartmontools ntfs-3g dosfstools networkmanager keyd wireless-regdb mesa vulkan-radeon tuned-ppd tuned \
pipewire pipewire-pulse pipewire-jack pipewire-alsa \
plasma-meta qt6-multimedia-ffmpeg noto-fonts noto-fonts-cjk noto-fonts-emoji \
fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-hangul fcitx5-qt \
gparted firefox konsole \
fzf gdu git less unzip 7zip vim zip zsh btop nmap bind



pacman -Scc

# Systemd unit enable
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable keyd
systemctl enable plasmalogin

# User add
if passwd -S root | grep '^root NP'; then
    echo 'Change root password'
    passwd
fi
chsh root --shell /usr/bin/zsh
if ! id $USERNAME; then
    useradd -m $USERNAME
fi
if passwd -S $USERNAME | grep "^$USERNAME NP"; then
    echo "Change $USERNAME password"
    passwd $USERNAME
fi
usermod $USERNAME -aG wheel
chsh $USERNAME --shell /usr/bin/zsh

# Sudo setup
sed 's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' -i /etc/sudoers

# Grub install
grub-install --efi-directory=/boot --removable --bootloader-id=ARCH_LIVEBOOT --target=x86_64-efi
grub-mkconfig -o /boot/grub/grub.cfg
