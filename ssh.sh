#!/bin/sh

# If you fully UNDERSTAND what you are doing, it won't be annoying anymore
#
# $HOME/.ssh/config
# Host 10.*.*.*
#   StrictHostKeyChecking no
#   UserKnownHostsFile /dev/null

if [ $# -lt 1 ]; then
	echo "Usage: $0 <device ip> <user> <pass>"
	exit
fi

SERVER="$1"
[ -n "$2" ] && USERNAME="$2" || USERNAME="ubnt"
[ -n "$3" ] && PASSWORD="$3" || PASSWORD="ubnt"


# Put .bashrc for busybox file on remote server
BASHRC_BB=".bashrc_bb_u"
sshpass -p $PASSWORD scp `dirname $0`/$BASHRC_BB $USERNAME@$SERVER:/tmp/

expect -c "
set timeout 3
spawn sshpass -p $PASSWORD ssh $USERNAME@$SERVER

send \"FROM_ID='`whoami`'\r\"
send \"source /tmp/$BASHRC_BB\r\"

interact timeout 60 { send -null }
"

# FIXME: It's weird/buggy to rewrite as below well-known form
# expect << EOF
# ...
# ...
# EOF
