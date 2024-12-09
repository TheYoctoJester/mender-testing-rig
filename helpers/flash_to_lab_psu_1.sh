#!/bin/sh

# so far this script makes a couple of happy path assumptions:
# - being sudo-able
# - having usbsdmux and curl on the path

SHELLY_IP="192.168.89.81"

if [ -z "$1" ]; then
	echo "please pass image path as first argument"
	exit 1
fi
IMAGE="$1"

if [ -z "$2" ]; then
	echo "please pass storage device as second argument"
	exit 1
fi
DEVICE="$2"

if [ -z "$3" ]; then
	echo "please pass usbsdmux device as third argument"
	exit 1
fi
MUX="$3"

curl -X POST -d "{\"id\":0, \"on\":false}" http://$SHELLY_IP/rpc/Switch.Set

usbsdmux "$MUX" host

sleep 3

sudo dd if="$IMAGE" of="$DEVICE" bs=1M conv=fsync

sleep 3

usbsdmux "$MUX" dut

curl -X POST -d "{\"id\":0, \"on\":true}" http://$SHELLY_IP/rpc/Switch.Set
