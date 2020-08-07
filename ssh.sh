#!/bin/sh

# If you fully UNDERSTAND what you are doing, it won't be annoying anymore
#
# $HOME/.ssh/config
# Host 10.*.*.*
#   StrictHostKeyChecking no
#   UserKnownHostsFile /dev/null

if [ $# -lt 1 ]; then
	echo "Usage: $0 <device ip> <args>"
	exit
fi

# load credentials if exists
[ -r ~/.creds ] && . ~/.creds

DEVICE_IP="$1"
[ -n "$2" ] && ARGS="$2"

echo "Waiting for device to go online"
until nc -vzw 2 $DEVICE_IP 22 2>/dev/null; do sleep 0.3; done

# Put .bashrc for busybox file on remote server
BASHRC_BB=".bashrc_bb_u"
SSH_OPTION_IGNORE_CHECK="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
for passwd in ${SSH_PASS:-ubnt}; do
	sshpass -p ${passwd} scp $SSH_OPTION_IGNORE_CHECK `dirname $0`/$BASHRC_BB ${SSH_USER:-ubnt}@$DEVICE_IP:/tmp/
	[ $? -eq 0 ] && break || echo "try next..."
done

expect -c "
set timeout 3
spawn sshpass -p $passwd ssh $SSH_OPTION_IGNORE_CHECK ${SSH_USER:-ubnt}@$DEVICE_IP

send \"FROM_ID='`whoami`'\r\"
send \"source /tmp/$BASHRC_BB\r\"

send \"$ARGS\r\"

interact timeout 60 { }
"

# FIXME: It's weird/buggy to rewrite as below well-known form
# expect << EOF
# ...
# ...
# EOF

