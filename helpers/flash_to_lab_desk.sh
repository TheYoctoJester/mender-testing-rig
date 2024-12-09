#!/bin/sh

# so far this script makes a couple of happy path assumptions:
# - being sudo-able
# - having usbsdmux and curl on the path

source flash_lib.sh

check_arguments

SHELLY_IP="192.168.89.81"

curl -X POST -d "{\"id\":0, \"on\":false}" http://$SHELLY_IP/rpc/Switch.Set

usbsdmux "$MUX" host

sleep 3

sudo dd if="$IMAGE" of="$DEVICE" bs=1M conv=fsync

sleep 3

usbsdmux "$MUX" dut

curl -X POST -d "{\"id\":0, \"on\":true}" http://$SHELLY_IP/rpc/Switch.Set
