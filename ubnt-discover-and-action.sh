#!/usr/bin/env bash

# A simple way to batch upload camera fw:
#    $ discover | grep UVC | cut -d ' ' -f 2` > uvc_list.txt
#    $ for i in $(cat uvc_list.txt); do upload_bin $i UVC.bin; done

# A fancy way to get managed & connected UVC
# wget --no-check-certificate -qO- 'https://10.0.0.1:7443/api/2.0/camera?apiKey=ooxx&managed=true&state=CONNECTED' | jq '.data[].host'


if [ $# -lt 1 ]; then
	echo "Usage: $0 <command>"
	exit 0
fi

SSHCMD="$1"

# get ssh command from STDIN
[ "$SSHCMD" == "-" ] && SSHCMD="$(cat)"

SSH_OPTION_IGNORE_CHECK="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

tmpdir=$(mktemp -d)
deviceresults="${tmpdir}/ubnt_device_results.json"
devicelist="${tmpdir}/ubnt_device_list.json"

# filter out results other than UVC
echo '{ "devices": ['     >> $deviceresults
discover -j | grep "UVC." >> $deviceresults
echo ']}'                 >> $deviceresults

jq . $deviceresults > $devicelist

cat $devicelist | jq '.devices[].fwversion' | nl -v 0 > "${tmpdir}/uvc_list.json"

for i in $(cat "${tmpdir}/uvc_list.json" | awk '{print $1}'); do
	camip=$(cat $devicelist | jq ".devices[${i}].ipv4" | tr -d '"')
	fwversion=$(cat $devicelist | jq ".devices[${i}].fwversion" | tr -d '"')

	echo IP: $camip
	echo FW: $fwversion
	
	#sshpass -p ${SSH_PASS:-ubnt} ssh $SSH_OPTION_IGNORE_CHECK ${SSH_USER:-ubnt}@$camip "${SSHCMD}"
	ssh.sh $camip "${SSHCMD}"
	echo ========================================================================
done

rm -rf  $tmpdir
