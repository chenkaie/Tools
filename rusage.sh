#!/bin/sh
#
# Usage: Add below line to your first line of Makefile to collect Resource Usage information
#        SHELL = rusage.sh /bin/bash

if [ $# -lt 1 ]; then
	echo "Usage: $0 COMMAND [ ARGS ]"
	exit 1
fi

# The shortest form used for Makefile debug (to printout each line been expanded)
#exec time -f 'argv="%C"' "$@"

# A full stack profiling argument :)
exec time -f 'rc=%x elapsed=%e user=%U system=%S maxrss=%M avgrss=%t ins=%I outs=%O minflt=%R majflt=%F swaps=%W avgmem=%K avgdata=%D argv="%C"' "$@"
