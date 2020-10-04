#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "usage: $0 <dir-to-be-mapped-to-/user/work>"
	exit -1
fi
WORK_DIR=$1
docker run --rm -it --name flutter --privileged -v /dev/bus/usb:/dev/bus/usb -h flutter \
	-e COLUMNS="`tput cols`" \
	-e LINES="`tput lines`" \
	-v ${WORK_DIR}:/user/work \
	flutter-dev:1.0 /bin/bash
