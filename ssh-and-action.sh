#!/bin/bash
# - Description: A simple fork-join model ssh utility
# - Author: Kent Chen <chenkaie at gmail.com>
# - GitHub: http://github.com/chenkaie/
# - version: 0.3

if [ $# -lt 1 ]; then
	echo "Usage: $0 <thread#> <timeout>"
	exit 0
fi

# Please modify below 2 files

CMD="cmd.txt"
##################
# cmd.txt sample #
##################
# $ cat cmd.txt
# env | grep SSH; touch /tmp/iamhere; ls /tmp/iamhere; uname -a

LIST="server.txt"
############################
# server.txt syntax format #
############################
# $ cat server.txt
# root:pass:192.168.1.1:22
# $USER:$PASS:$IP:$PORT
############################

# CLI arguments
ARG_THREAD_NO=${1:-1}
ARG_TIMEOUT=${2:-60}

# Default not verifying host and hostkey
SSH_OPTION_IGNORE_CHECK="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

SSH_OPTIONS="-o ConnectTimeout=$ARG_TIMEOUT $SSH_OPTION_IGNORE_CHECK"

pidlist=
tmpdir=$(mktemp -d)
tmplog='$tmpdir/$camip.txt'

echo ">>> Start: $(date)"

while IFS=':' read -r user pass ip port; do
	echo ========================================================================
	echo IP: $ip

	(
	sshpass -p $pass ssh -p ${port:-22} ${SSH_OPTIONS} $user@$ip $(cat $CMD) > $tmpdir/.$ip.ssh.log 2>&1
	if [ $? -eq 0 ]; then
		echo --------------------------------- >> $tmpdir/$ip.txt
		echo Date: $(date)                     >> $tmpdir/$ip.txt
		echo Server: $user:$pass:$ip:$port     >> $tmpdir/$ip.txt
		cat $tmpdir/.$ip.ssh.log               >> $tmpdir/$ip.txt
		echo --------------------------------- >> $tmpdir/$ip.txt
		flock .good.lock cat $tmpdir/$ip.txt >> good.txt
	else
		echo --------------------------------- >> $tmpdir/$ip.txt
		echo Date: $(date)                     >> $tmpdir/$ip.txt
		echo Server: $user:$pass:$ip:$port     >> $tmpdir/$ip.txt
		echo --------------------------------- >> $tmpdir/$ip.txt
		flock .bad.lock cat $tmpdir/$ip.txt >> bad.txt
	fi
	) &
	pidlist="$pidlist $!"
	echo ========================================================================
done < $LIST

wait $pidlist
rm -rf $tmpdir .*.lock

echo "<<< DONE: $(date)"

