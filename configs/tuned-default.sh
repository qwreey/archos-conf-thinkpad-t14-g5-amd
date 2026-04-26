
export TUNED_RYZENADJ_BIN=/usr/bin/ryzenadj

# should tuned with `ryzenadj -i` for each profile. make empty in tuned-user.sh
# then test it first. the system will not damaged by this configuration due to hard limit
export TUNED_RYZENADJ_BATTERY_POWERSAVE_PARAMS="--slow-limit=5000 --power-saving --fast-limit=6000 --tctl-temp=51"
export TUNED_RYZENADJ_BATTERY_BALANCED_PARAMS="--slow-limit=12000 --power-saving --fast-limit=14000 --tctl-temp=60"
export TUNED_RYZENADJ_BATTERY_PERFORMANCE_PARAMS="--slow-limit=24000 --power-saving --fast-limit=32000 --tctl-temp=96"

export TUNED_RYZENADJ_PLUGGED_POWERSAVE_PARAMS="--slow-limit=6000 --power-saving --fast-limit=7000 --tctl-temp=53"
export TUNED_RYZENADJ_PLUGGED_BALANCED_PARAMS="--slow-limit=24000 --max-performance --fast-limit=32000 --tctl-temp=86"
export TUNED_RYZENADJ_PLUGGED_PERFORMANCE_PARAMS="--slow-limit=28000 --max-performance --fast-limit=40000 --tctl-temp=96"
