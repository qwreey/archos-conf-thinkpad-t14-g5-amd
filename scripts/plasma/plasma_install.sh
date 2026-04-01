#!/bin/bash

echo "Script: Run plasma after_install"

SPATH="$(dirname "$(readlink -f "$0")")"

source $SPATH/plasma-lib.sh

package-install effect moe.qwreey.animate
package-install effect moe.qwreey.gammaeffect
package-install sensorface moe.qwreey.simpletext

kwin-plugin-disable fadingpopups
kwin-plugin-disable maximize
# effect-reload moe.qwreey.animate
# effect-reload moe.qwreey.gammaeffect
