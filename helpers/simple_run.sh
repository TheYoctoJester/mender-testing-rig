#!/bin/bash

cmd="help"

FULL_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
#echo "FULL_PATH_TO_SCRIPT: $FULL_PATH_TO_SCRIPT"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"
#echo "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY"

source $SCRIPT_DIRECTORY/rig_lib.sh

setup_rig

# start dut
set_dut
power_on

# set serial port 
stty -F /dev/ttyUSB0 115200
timeout 10m cat /dev/ttyUSB0 | tee run.txt

# done
power_off
set_host

exit 0