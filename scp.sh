#!/bin/sh

if [ $# -lt 2 ]; then
	echo "Usage: $0 <DEVICE_IP> <FILE_1> <FILE_2>...<FILE_N>"
	exit 0
fi

# load credentials if exists
[ -r ~/.creds ] && . ~/.creds

DEVICE_IP="$1"

SSH_OPTION_IGNORE_CHECK="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

for passwd in ${SSH_PASS:-ubnt}; do
	sshpass -p ${passwd} scp -O -P ${SSH_PORT:-22} $SSH_OPTION_IGNORE_CHECK -r "${@:2}" ${SSH_USER:-ubnt}@$DEVICE_IP:/tmp/
	[ $? -eq 0 ] && { echo "done"; exit 0; } || echo "try next..."
done
