#!/usr/bin/env bash

IP="$1"

if [ -z "$IP" ] ; then
    echo "Usage: $0 [IP ADDR RANGE: 192.168.1.0/24 192.168.1.1-254]"
    exit
fi

nmap -v -sn $IP

