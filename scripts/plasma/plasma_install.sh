#!/usr/bin/bash
echo "Script: Run $(basename "$(readlink -f "$0")")"
SPATH="$(dirname "$(readlink -f "$0")")"
source "$SPATH/../../config-loader.sh"
require-nonroot

source $SPATH/plasma-lib.sh

package-install effect moe.qwreey.animate
package-install effect moe.qwreey.gammaeffect
package-install sensorface moe.qwreey.simpletext

kwin-plugin-disable fadingpopups
kwin-plugin-disable maximize
# effect-reload moe.qwreey.animate
# effect-reload moe.qwreey.gammaeffect
