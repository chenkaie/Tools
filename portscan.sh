#!/bin/sh
# http://www.cyberciti.biz/faq/linux-port-scanning/
# Introduction:
#    If nmap is not installed try nc / netcat command. 
#    The -z flag can be used to tell nc to report open ports, rather than initiate a connection.
#    e.g. nc -z 172.16.2.54 1-65535

IP="$1"
PORT="1-65535"

if [ -z "$1" ] ; then
    echo "Usage: $0 [IP ADDR] [PORT RANGE]"
    exit
fi

[ -n "$2" ] && PORT="$2"

nc -z $IP $PORT

