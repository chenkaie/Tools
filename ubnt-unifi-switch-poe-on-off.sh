#!/usr/bin/env bash
#
# Usage:
#   $ ubnt-unifi-switch-poe-on-off.sh 192.168.1.20 1

USR=ubnt
PWD=ubnt

IP="$1"
LANPORT="$2"

echo "===== Disable PoE port: ${LANPORT} at ${IP} ====="

CMD='(echo "enable" ; echo "configure" ; echo "interface 0/'$LANPORT'" ; echo "poe opmode shutdown"; echo exit; echo exit; echo exit) | nc localhost 23'

sshpass -p $PWD ssh -q $USR@$IP $(echo $CMD)

# Sleep for 500ms
sleep 0.5

echo "===== Enable  PoE port: ${LANPORT} at ${IP} ====="

CMD='(echo "enable" ; echo "configure" ; echo "interface 0/'$LANPORT'" ; echo "poe opmode auto"; echo exit; echo exit; echo exit) | nc localhost 23'

sshpass -p $PWD ssh -q $USR@$IP $(echo $CMD)

