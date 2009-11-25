#!/bin/sh
# ---------------------------------------------------------------------------
# valgrind-run.sh - easy wrapper for running valgrind with common arguments.
# Copyright (c) 2007-2009, Jeff Hung
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#  - Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  - Neither the name of the copyright holders nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ----------------------------------------------------------------------------

__exe_name__=`basename $0`;
__revision__=`echo '$Rev: 470 $' | cut -d' ' -f2`;
__rev_date__=`echo '$Date: 2009-05-09 01:32:22 +0800 (Sat, 09 May 2009) $' | cut -d' ' -f2`;

usage()
{
	echo >&2 "\
Usage: $__exe_name__ [ <option> ... ] <program> <arg> ...

Run executable <program> with arguments <arg>s by valgrind(1) for catching
memory leaks and other errors.

Options:

  --help                     Show this help message.
  -v,--verbose               Show verbose messages.
  -s,--suppress <supp-file>  Use valgrind suppression file <supp-file>.
  -S,--gen-suppress          Srint suppressions for errors detected.
  -d,--debug[=<debugger>]    Lauch with debugger.  (default <debugger>: gdb)
  -N,--no-action             Do not do any thing, print final command only.

Revision: r$__revision__ ($__rev_date__)
";
}

msg_exit()
{
	local ex="$1"; shift;
	while [ $# -gt 0 ]; do
		echo >&2 "ERROR: $1"; shift;
	done;
	echo >&2 "\
Usage: $__exe_name__ [ <option> ... ] <program> <arg> ...
Type '$__exe_name__ --help' for help messages.";
	exit $ex;
}

opt_verbose='no';
opt_val_supp_options='';
opt_val_gen_supp='no';
opt_debug_run='no';
opt_debug_with='gdb';
opt_no_action='no';
arg_program='';
arg_arguments='';
while [ $# -gt 0 ]; do
	arg="$1"; shift;
	case "$arg" in
	-h|--help)
		usage; exit;
		;;
	-v|--verbose)
		opt_verbose='yes';
		;;
	-s|--suppress)
		if [ $# -gt 0 ]; then
			opt_val_supp_options="$opt_val_supp_options --suppressions=$1";
			shift;
		else
			msg_exit 1 'Missing <supp-file>.';
		fi;
		;;
	-S|--gen-suppress)
		opt_val_gen_supp='yes';
		;;
	-d|--debug)
		opt_debug_run='yes';
		;;
	--debug=gdb)
		opt_debug_run='yes';
		opt_debug_with='gdb';
		;;
	-N|--no-action)
		opt_no_action='yes';
		;;
	-*)
		msg_exit 1 "Unknown option: $arg";
		;;
	*)
		if [ -z "$arg_program" ]; then
			arg_program="$arg";
		else
			arg_arguments="$arg_arguments $arg";
		fi;
		;;
	esac;
done;
if [ -z "$arg_program" ]; then
	msg_exit 1 'Missing <program>.';
fi;
if [ ! -x "$arg_program" ]; then
	msg_exit 1 '<program> is not an executable.';
fi;

#valgrind_cmd=`whereis -bq valgrind`;
valgrind_cmd=`which valgrind`;
if [ -z "$valgrind_cmd" ]; then
	msg_exit 2 'Missing valgrind.';
fi;

program_name=`basename "$arg_program"`;

valgrind_options='--leak-check=yes --show-reachable=yes --leak-resolution=high --num-callers=20';
if [ "x$opt_verbose" = 'xyes' ]; then
	valgrind_options="--verbose $valgrind_options";
fi;
valgrind_options="$valgrind_options $opt_val_supp_options";
if [ "x$opt_val_gen_supp" = 'xyes' ]; then
	valgrind_options="$valgrind_options --gen-suppressions=yes";
else
	valgrind_options="$valgrind_options --log-file=log-$program_name";
fi;

if [ "x$opt_debug_run" = 'xyes' ]; then
	case "$opt_debug_with" in
	gdb)
#		debug_cmd=`mktemp /tmp/$__exe_name__.XXXXXX`;
#		echo "GDB> $valgrind_cmd $valgrind_options $arg_program $arg_arguments";
#		echo "file $valgrind_cmd"                                     >> "$debug_cmd";
#		echo "set args $valgrind_options $arg_program $arg_arguments" >> "$debug_cmd";
#		echo "run"                                                    >> "$debug_cmd";
#		gdb -x "$debug_cmd";
#		rm -f "$debug_cmd";
##		gdb -se "$valgrind_cmd" --args $valgrind_options $arg_program $arg_arguments;
		valgrind_options="--db-attach=yes --wait-for-gdb=yes $valgrind_options";
		echo "CMD> $valgrind_cmd $valgrind_options $arg_program $arg_arguments";
		if [ "x$opt_no_action" != 'xyes' ]; then
			"$valgrind_cmd" $valgrind_options $arg_program $arg_arguments;
		fi;
		;;
	*)
		msg_exit 1 'Unknown <debugger>.';
		;;
	esac;
else
	echo "CMD> $valgrind_cmd $valgrind_options $arg_program $arg_arguments";
	if [ "x$opt_no_action" != 'xyes' ]; then
		"$valgrind_cmd" $valgrind_options $arg_program $arg_arguments;
	fi;
fi;


