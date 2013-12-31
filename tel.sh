#!/bin/sh

if [ $# -lt 1 ]; then
	echo "Usage: $0 <device ip> <user> <pass>"
	exit
fi

SERVER="$1"
USERNAME="$2"
PASSWORD="$3"

# Enable telnet
curl "http://$USERNAME:$PASSWORD@$SERVER:80/cgi-bin/admin/mod_inetd.cgi?telnet=on"


# Put .bashrc for busybox file on remote server
BASHRC_BB=".bashrc_bb"
lftp -e "put `dirname $0`/$BASHRC_BB; bye" -u $USERNAME,$PASSWORD $SERVER

# expect script, auto login to remote server and source $BASHRC_BB file

expect -c "
set timeout 3
spawn telnet $SERVER
expect \"?ogin:*\"
send \"$USERNAME\r\"

if { \"$PASSWORD\" != \"\" } {
	expect \"?assword:*\"
	send \"$PASSWORD\r\"
}

send \"FROM_ID='`whoami`'\r\"
send \"source ~/$BASHRC_BB\r\"

interact timeout 60 { send -null }
"

# FIXME: It's weird/buggy to rewrite as below well-known form
# expect << EOF
# ...
# ...
# EOF

