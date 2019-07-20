#!/usr/bin/env bash
#
# Usage:
#   $ ubnt-unifi-switch-poe-on-off.sh 192.168.1.20 1

SSH_OPTION_IGNORE_CHECK="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

CMD=".cmd.txt"
USR=ubnt
PWD=ubnt

IP="$1"
LANPORT="$2"

echo "===== Disable PoE port: ${LANPORT} at ${IP} ====="

cat > $CMD << EOF
(echo "enable" ; echo "configure" ; echo "interface 0/$LANPORT" ; echo "poe opmode shutdown"; echo exit; echo exit; echo exit) | telnet localhost 23
EOF

# poe off
sshpass -p $PWD ssh $SSH_OPTION_IGNORE_CHECK -q $USR@$IP $(cat $CMD)

# Sleep for 3000ms
sleep 3

echo "===== Enable  PoE port: ${LANPORT} at ${IP} ====="

cat > $CMD << EOF
(echo "enable" ; echo "configure" ; echo "interface 0/$LANPORT" ; echo "poe opmode auto"; echo exit; echo exit; echo exit) | telnet localhost 23
EOF

# poe auto
sshpass -p $PWD ssh $SSH_OPTION_IGNORE_CHECK -q $USR@$IP $(cat $CMD)

# link up
sshpass -p $PWD ssh $SSH_OPTION_IGNORE_CHECK -q $USR@$IP "swctrl port set up id $LANPORT"

rm $CMD

