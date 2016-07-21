#!/bin/sh

if [ $# -lt 2 ]; then
	echo "Usage: $0 <DEVICE_IP> <FILE_1> <FILE_2>...<FILE_N>"
	exit 0
fi

DEVICE_IP="$1"

sshpass -p ${SCP_PASS:-ubnt} scp -r ${@:2} ${SCP_USER:-ubnt}@$DEVICE_IP:/tmp/
