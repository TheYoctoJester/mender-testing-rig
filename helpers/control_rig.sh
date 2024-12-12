#!/bin/bash

cmd="help"

FULL_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
#echo "FULL_PATH_TO_SCRIPT: $FULL_PATH_TO_SCRIPT"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"
#echo "SCRIPT_DIRECTORY: $SCRIPT_DIRECTORY"

source $SCRIPT_DIRECTORY/rig_lib.sh

setup_rig

print_help () {
	echo "script used for variouts DUT tasks"
	echo "commands:"
	echo "  control_rig.sh power_on      - switches on DUT power"
	echo "  control_rig.sh power_off     - switches off DUT power"
	echo "  control_rig.sh sdmux_host    - switches the DUT SD mux to host"
	echo "  control_rig.sh sdmux_dut     - switches the DUT SD mux to dut"
	echo "  control_rig.sh flash IMAGE   - writes the given IMAGE file to usb-sd-mux storage"
	echo "                                 NOTE: this does not involve power or sdmux settings"
	echo "  control_rig.sh help          - prints this help text"
}

case $1 in
  power_on)
    power_on
    ;;

  power_off)
    power_off
    ;;

  sdmux_host)
    set_host
    ;;

  sdmux_dut)
    set_dut
    ;;

  flash)
	dd if=$IMAGE of=$STORAGE status=progress bs=1M conv=fsync
    ;;

  help | *)
    print_help
    ;;
esac

exit 0

