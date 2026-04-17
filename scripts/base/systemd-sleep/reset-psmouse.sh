#!/bin/sh
if [ "$1" == "post" ]; then
	/usr/bin/rmmod psmouse
	/usr/bin/modprobe psmouse
fi