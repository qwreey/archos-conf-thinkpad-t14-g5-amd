# qwreey/archos-conf

qwreey 가 arch-linux 에서 사용하고 있는 설정에 관한 거의 모든것을 담는 저장소입니다.

## 자동설정 스크립트

arch-linux 를 설치 후 번거로운 설정을 자동으로 고쳐주는 도구 모음입니다.

스크립트로 자동 설정되는 옵션은 `config-default.sh` 에서 확인할 수 있습니다, 만일 옵션 값을 다른 값으로 덮어쓰려는 경우 config-user.sh 를 생성한 뒤 원하는 값을 입력하세요(`config-default.sh` 뒤에 실행됩니다)

### scripts/firewalld_install.sh

firewall-cmd 를 통해 설정에 지정된 신뢰 인터페이스 목록과 서비스 목록을 자동으로 제거, 추가합니다

### scripts/chrome_install.sh

flatpak 으로 설치된 `com.google.Chrome` 에 대한 모딩을 수행합니다. 주요 변경은
- kwallet 세션 버스 권한 추가
- xdg-desktop, ~/.local/share/icons, ~/.local/share/applications 권한추가 (For PWA support)
- chrome 바이너리 링크 생성 (/usr/local/bin/chrome)
- chrome-flags.conf 생성을 통한 flag 적용

적용되는 flag 에 대해서는 `config-default.sh`의 CHROME_FLAG_LIST 섹션을 확인하세요

### scripts/steam_install.sh

flatpak 으로 설치된 스팀에 대한 모딩을 수행합니다. 주요 변경은
- xdg-desktop, ~/.local/share/icons, ~/.local/share/applications 권한추가 (For game .desktop files)
- deskop 파일 호환용 steam 바이너리 링크 생성 (/usr/local/bin/steam)

### scripts/flatpak_install.sh

시스템의 breeze 테마를 `~/.local/share/themes` 에 복사하여 내부에 강제 적용시킵니다. 그러한 이유로 breeze 테마의 변경이 생길 때 다시 수행해야합니다.

### scripts/discord_install.sh

`vencordinstallercli -install -branch auto`를 수행하여 vencord 패치를 적용하고 이를 pacman hook으로 등록하여 discord 업데이트 시 다시 적용되도록 합니다.

### scripts/avahi_install.sh

자동 주변 장치 찾기를 통해 `devicename.local` 형태로 연결이 가능하도록 avahi 에 필요한 요소를 설정합니다.

변경되는 요소는 다음과 같습니다
- /etc/nsswitch.conf 에 mdns4_minimal 와 필요한 것을 추가합니다.
- /etc/systemd/resolved.conf.d/00-disable-mdns.conf 를 생성하여 systemd-resolved 와 avahi 가 충돌하지 않도록 합니다.
- avahi-daemon.service systemd unit 을 활성화합니다.

### scripts/networkmanager_install.sh

NetworkManager 를 설정합니다. 변경되는 요소는 다음과 같습니다.

- /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf 를 생성하여 일반적으로 성능에 문제가 생겨 제거하는 와이파이 절전 기능을 비활성화 합니다
- NetworkManager.service unit 을 활성화합니다.

### scripts/pipewire_install.sh

`default.clock.max-quantum`, `default.clock.min-quantum` 을 변경하여 pipewire 가 더 많은 cpu 시간을 사용할 수 있도록 허용하여 easyeffects 와 무거운 작업이 돌아가더라도 시스템 음향이 깨지거나 버벅이지 않도록 합니다.
> TODO: config-user.sh 에서 이를 변경 가능하도록 구성합니다.

### scripts/plymouth_install.sh

undocumented.

### scripts/base/base_install.sh

undocumented.

### scripts/grub/grub_install.sh

undocumented.

### scripts/keyd/keyd_install.sh

undocumented.

### scripts/plasma/plasma_install.sh

undocumented.

### scripts/tuned/tuned_install.sh

undocumented.

## 유틸리티 스크립트

> TODO: pkg-... 에 대해 flatpak 이나 다른 패키지 관리자가 사용 가능토록 하며 pacman 이 있는지 확인합니다.

### utils/patch-jetbrains-vmoptions

로컬 유저에 설치된 모든 jetbrains 도구들의 vmoptions 를 수정하여 WLToolKit 을 사용하도록 합니다. 이는 jetbrains 의 도구들이 wayland 에서 실행되도록 만들며 fcitx5 와 같은 입력기가 잘 작동하도록합니다.

### utils/plasmalogin-apply-kwinoutputconfig

현 로컬 유저의 모니터 설정을 plasmalogin 에 적용합니다. kde-plasma de 를 사용하며 plasmalogin 을 사용하는 경우에만 유효합니다. (no sddm)

### utils/plasmashell-reload

현 plasmashell 을 종료하고 다시 시작합니다. 쉘에 문제가 생길 때 유용합니다.
