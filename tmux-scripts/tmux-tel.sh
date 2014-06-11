#!/bin/sh

##############
# function() #
##############

Usage ()
{
	echo "Usage: `basename $0` [-n] <IP Address> <Count>"
	exit 1
}

##########
# main() #
##########

[ $# -lt 2 ] && Usage

if [ "$1" = "-n" ]; then
	readonly NEW_WINDOW=1; shift
fi

readonly IPADDR="$1"
readonly TELNET_COUNT="$2"

if [ "$NEW_WINDOW" = "1" ]; then
	# First new-window
	tmux new-window -k -n $IPADDR

	# Reset split-window except 1st one
	for (( i = 1; i < $TELNET_COUNT ; i++ )); do
		tmux split-window
	done

	# tiled layout
	tmux select-layout tiled
fi

# Not newly created, just send-keys to all target panes
for (( i = 1; i <= $TELNET_COUNT ; i++ )); do
	tmux send-keys -t $i "tel.sh $IPADDR" c-m
done

