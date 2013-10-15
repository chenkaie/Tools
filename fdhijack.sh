#!/bin/sh
#
# Redirect stdin, stdout, stderr of a daemon to /dev/pts/#
#
#################################################################################################################
# Ref: stdio buffering: http://www.pixelbeat.org/programming/stdio_buffering/
# Default Buffering modes:
#	 stdin  -> is always buffered
#	 stderr -> is always unbuffered
#	 if stdout is a terminal then buffering is automatically set to line buffered, else it is set to buffered
#################################################################################################################
# Therefore if we set stdout, stderr unbuffered by setvbuf(), we don't need flush (-f) feature.
# However buffered mode stdio is more efficient.
#################################################################################################################

if [ "$2" = "" ]; then
	echo "Usage: $0 PID /path/to/pts"
	echo "Example: $0 \`pidof Daemon\` /dev/pts/1"
	echo "         $0 \`pidof Daemon\` \`tty\`"
	exit 0
fi

SLEEP_DURATION=5

case "$0" in
	*dm365*)
		# Finetune SLEEP_DURATION to avoid gdb output "Hangup detected on fd 0, error detected on stdin"
		SLEEP_DURATION=3
		GDB="/home/kent/ArmTools/gdb-dm365-v6-montavista"

		#SLEEP_DURATION=8
		#GDB="/home/kent/ArmTools/gdb-dm365-v7"
		;;
esac

GDB=${GDB:-gdb}

if ${GDB} --version > /dev/null 2>&1; then
	true
else
	echo "Unable to find gdb."
	exit 1
fi

pid=$1
dst=$2

# -f : flushes all open output streams to avoid buffered IO
if [ "${2}" = "-f" ]; then
	(
		echo "attach $pid"
		echo 'call fflush(0)'
		echo 'detach'
		echo 'quit'
		sleep 5
	) | ${GDB} -q -x -
else
	(
		echo "attach $pid"
		echo 'call open("'$dst'", 66, 0666)'
		#echo 'call dup2($1,0)' # stdin
		echo 'call dup2($1,1)'  # stdout, $1 derived from previous open() by gdb
		echo 'call dup2($1,2)'  # stderr
        # NOTE: setvbuf cause SIGSEGV in some situation,
        #       uncomment them if you needed.
        #echo 'p setvbuf(stdout, 0, 2, 0)' #set _IONBF unbuffered
        #echo 'p setvbuf(stderr, 0, 2, 0)' #set _IONBF unbuffered
		echo 'call close($1)'
		echo 'detach'
		echo 'quit'
		sleep $SLEEP_DURATION
	) | ${GDB} -q -x -
fi

