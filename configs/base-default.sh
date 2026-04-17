#!/usr/bin/bash

# Content of /etc/environment
BASE_ENVIRONMENT=$(cat <<EOF
XMODIFIERS=@im=fcitx5
EDITOR=vim
PAGER=less
EOF
)

# Enabled locales
BASE_LOCALE_GEN_LIST=(
	"ko_KR.UTF-8 UTF-8"
	"en_US.UTF-8 UTF-8"
)
BASE_LOCALE_LANG="en_US.UTF-8"
BASE_LOCALE_LC_CTYPE="C.UTF-8"
