#!/usr/bin/env bash

SHELLY_IPS=("192.168.89.51" "192.168.89.50")

declare -A outputAssignments
outputAssignments[dut1]=0
outputAssignments[dut2]=1
outputAssignments[dut3]=2
outputAssignments[builder]=6
outputAssignments[power]=7

if [ ${outputAssignments[$2]+_} ]; then
	channel_raw=${outputAssignments[$2]}
	echo "output $2 found, mapping to $channel_raw"
else
	channel_raw="$2"
fi

CHANNELS_PER_SHELLY=4
MAX_CHANNEL=$((${#SHELLY_IPS[@]} * CHANNELS_PER_SHELLY - 1))

cmd="help"
channel=""
shelly=""
power=""

get_addresses () {
	if [ -z $channel_raw ]; then
		echo "no channel given, aborting"
		exit 1
	fi
	if [ $channel_raw -lt 0 ] || [ $channel_raw -gt $MAX_CHANNEL ]; then
		echo "channel $channel_raw is outside of supported range for this configuration"
		exit 1
	fi
	echo "given target channel is $channel_raw"
	channel="$((channel_raw % CHANNELS_PER_SHELLY))"
	shelly="${SHELLY_IPS[$((channel_raw / CHANNELS_PER_SHELLY))]}"
	echo "adresses are shelly $shelly, channel $channel"
}

call_shelly () {
	curl -X POST -d "{\"id\":"$channel", \"on\":$power}" http://$shelly/rpc/Switch.Set
}

print_help () {
	echo "script used to switch power on and off through a number of shelly relays"
	echo "commands:"
	echo "  power.sh on CHANNEL    - switches on power channel number CHANNEL"
	echo "  power.sh off CHANNEL   - switches off power channel number CHANNEL"
	echo "  power.sh config        - prints the current configuration of the script"
	echo "  power.sh help          - prints this help text"
}

case $1 in
  on)
	get_addresses
	power="true"
    echo "Will switch on"
	call_shelly
    ;;

  off)
	get_addresses
	power="false"
    echo "Will switch off"
	call_shelly
    ;;

  config)
    echo "${#SHELLY_IPS[@]} relay units are configured, resulting in $((${#SHELLY_IPS[@]} * CHANNELS_PER_SHELLY)) channels."
	echo "configured relay units:"
	for i in ${SHELLY_IPS[@]}; do
	  echo "    $i"
	done
	;;

  help | *)
    print_help
    ;;
esac

