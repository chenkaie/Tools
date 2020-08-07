#! /bin/bash

# Sets up outgoing dummynet in pf firewall suitable for use to throttle outgoing network
# connections. gtihub.com/tylertreat/comcast is a much nicer tool but I couldn't get it to work due
# to shell issues and more - it seemed to only setup inbound rules in pf which don't affect outbound
# TCP connections in my tests.

TARGET=$1
PIPECFG=${2:-"plr 1"}

if [ -z "$1" ]; then
  echo "Usage: $0 <target> <pipe config - leave blank to drop all>"
  echo ''
  echo "EXAMPLES:"
  echo ''
  echo "$0 'port 12345'"
  echo "  - drops all outgoing packets to port 12345 silently"
  echo ''
  echo "$0 'example.com' 'plr 0.1'"
  echo "  - simulates packet loss of 10% for traffic to example.com (IP looked up)"
  echo ''
  echo "$0 '192.168.2.3 port 443' 'bw 300Kbit/s delay 100'"
  echo "  - simulates 300Kb/s bandwidth and round trip time of 100ms for traffic to 192.168.2.3:443"
  echo ''
  echo 'For more details on target syntax refer to `man pf.conf` under PACKET FILTERING.'
  echo 'For more details on traffic throttling syntax refer to `man dnutil`.'
  echo ''
  echo 'You can inspect the rules added using `sudo pfctl -sa` and `sudo dnctl list`.'
  exit 1
fi

# Enable firewall if necessary
sudo pfctl -e 2>/dev/null

# Setup dummy net
{
    cat /etc/pf.conf
    echo "dummynet-anchor \"mop\""
    echo "anchor \"mop\""
    #echo "dummynet out from any to $TARGET pipe 1"
    echo "dummynet in quick from $TARGET to any pipe 1"
# Supress noisy ALTQ nonsense but keep stderr messages from bad filter syntax
} | sudo pfctl -f - 2> >(grep -v 'ALTQ\|pf.conf\|flushing of rules\|present in the main ruleset\|^$')

# Create pipe
sudo dnctl pipe 1 config $PIPECFG

# Wait for input
read -p "Press any key to stop throttling traffic"

# Teardown Pipe
sudo dnctl -q flush

# Reset pf
sudo pfctl -f /etc/pf.conf 2> >(grep -v 'ALTQ\|pf.conf\|flushing of rules\|present in the main ruleset\|^$')

echo "Finished shaping traffic"

