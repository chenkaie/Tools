#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Usage: $0 <device ip> <user> <pass>"
	exit
fi

SERVER="$1"
[ -n "$2" ] && USERNAME="$2" || USERNAME="ubnt"
PASSWORD="$3"


expect -c "
set timeout 3
spawn telnet $SERVER
expect \"User:*\"
send \"$USERNAME\r\"

if { \"$PASSWORD\" != \"\" } {
	expect \"?assword:*\"
	send \"$PASSWORD\r\"
}

interact timeout 60 { send -null }
"

# FIXME: It's weird/buggy to rewrite as below well-known form
# expect << EOF
# ...
# ...
# EOF

