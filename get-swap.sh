#!/usr/bin/env bash
# Get current swap usage for all running processes in sorted results
# Original Author: Erik Ljungstrom 27/05/2011

RESULTS="/tmp/.getswap"
rm -f $RESULTS

SUM=0
OVERALL=0
for DIR in `find /proc/ -maxdepth 1 -type d | egrep "^/proc/[0-9]"`; do
	PID=`echo $DIR | cut -d / -f 3`
	PROGNAME=`ps -p $PID -o comm --no-headers`
	for SWAP in `grep Swap $DIR/smaps 2>/dev/null| awk '{ print $2 }'`
	do
		let SUM=$SUM+$SWAP
	done
	printf "Swap: %+7s\tPID:%+5s (%s)\n" $SUM $PID $PROGNAME >> $RESULTS
	let OVERALL=$OVERALL+$SUM
	SUM=0
done

cat $RESULTS | egrep -v "Swap: <defunct>|Swap:       0|Swap:  server" |sort -n -k 2

echo "Overall swap used: $OVERALL"

