#!/bin/bash

# so far this script makes a couple of happy path assumptions:
# - being sudo-able
# - having usbsdmux and curl on the path

FULL_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
#echo "FULL_PATH_TO_SCRIPT: $FULL_PATH_TO_SCRIPT"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"
#echo "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY"

source $SCRIPT_DIRECTORY/flash_lib.sh

MAYBE_IMAGE="$1"

if [ -z "$MUX" ]; then
	MUX_DIR="/dev/usb-sd-mux"
	COUNT_MUXES=$(ls -1 /dev/usb-sd-mux/ | wc -l)
	#echo "found $COUNT_MUXES usb-sd-muxes"

	if [ "$COUNT_MUXES" -eq "1" ]; then
		MUX="$MUX_DIR/$(ls -1 $MUX_DIR)"
		#echo "only one MUX connected, defaulting to it: $MUX"
	fi
fi

if [ -z "$STORAGE" ]; then
	COUNT_STORAGE=$(ls -1 /dev/disk/by-id/usb-LinuxAut_sdmux_* | grep -v '\-part.*$' | wc -l)
	if [ "$COUNT_STORAGE" -eq "1" ]; then
		STORAGE="$(ls -1 /dev/disk/by-id/usb-LinuxAut_sdmux_* | grep -v '\-part.*$')"
		#echo "only one SD mux storage connected, defaulting to it: $STORAGE"
	fi
fi

if [ -z "$MUX" ] | [ -z "$STORAGE" ] ; then
	echo "MUX not set nor identifiable by default logic, aborting"
	exit 1
fi

# the relay identifiers are serial number dependent, so we need to extract them
# notes:
# - the usbrelay command doesn't respect -q, so stderr is dropped
# - then extract the listed relays via grep
# - last, cut out the relay identifier
REL_1=$(usbrelay 2>&- | grep -o ".*_1=" | cut -d= -f1)
REL_2=$(usbrelay 2>&- | grep -o ".*_2=" | cut -d= -f1)
if [ ! -z "$REL_1" ] & [ ! -z "$REL_2" ]; then
	#echo "using REL_1=$REL_1, REL_2=$REL_2"
	:
else
	#echo "could not identify relays, aborting"
	exit 1
fi

set_host() {
	#echo "selecting host for SD-MUX"
	sleep 3 # to be sure the last thing is all done
	usbsdmux $MUX host
	sleep 3 # required to settle in 
}

set_dut() {
	#echo "selecting dut for SD-MUX"
	sleep 3 # to be sure the last thing is all done
	usbsdmux $MUX dut
	sleep 3 # required to settle in 
}

power_on() {
	#echo "switching dut on"
	usbrelay 2>&- $REL_1=1
}

power_off() {
	#echo "switching dut off"
	usbrelay 2>&- $REL_1=0
}

check_arguments $MAYBE_IMAGE

# be certain
power_off
set_host

# write image
dd if=$IMAGE of=$STORAGE status=progress bs=1M conv=fsync

# start dut
set_dut
power_on

# set serial port 
stty -F /dev/ttyUSB0 115200
timeout 10m cat /dev/ttyUSB0 | tee run.txt

power_off
set_host

exit 0

