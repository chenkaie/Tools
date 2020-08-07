#!/usr/bin/env bash
#
# Usage:
#   $ ubnt-edge-switch-poe-on-off.sh 192.168.1.20 1

USR=ubnt
PWD=2rjudoru

IP="$1"
LANPORT="$2"

echo "===== Disable PoE port: ${LANPORT} at ${IP} ====="

# PoE Port Status
nc ${IP} 23 >&1 2>&1 << EOF
${USR}
${PWD}
enable
${PWD}
configure
show poe status 0/${LANPORT}
EOF

# Method 1
#(echo "${USR}"; echo "${PWD}"; echo "enable"; echo "${PWD}"; echo "configure" ; echo "interface 0/${LANPORT}" ; echo "poe opmode shutdown") | nc ${IP} 23

# Method 2
#echo -e ${USR}"\n"${PWD}"\n"en"\n"${PWD}"\n"config"\n"interface 0/${LANPORT}"\n"poe opmode shutdown | nc ${IP} 23
#echo -e "${USR}""\n""${PWD}""\n""enable""\n""${PWD}""\n""config""\n""interface 0/${LANPORT}""\n""poe opmode shutdown" | nc ${IP} 23 > /dev/null 2>&1

# Method 3
nc ${IP} 23 > /dev/null 2>&1 << EOF
${USR}
${PWD}
enable
${PWD}
configure
interface 0/${LANPORT}
poe opmode shutdown
EOF

# Sleep for 500ms
sleep 0.5

echo "===== Enable  PoE port: ${LANPORT} at ${IP} ====="
# Method 1
# (echo "${USR}"; echo "${PWD}"; echo "enable"; echo "${PWD}"; echo "configure" ; echo "interface 0/${LANPORT}" ; echo "poe opmode auto") | nc ${IP} 23

# Method 2
echo -e "${USR}""\n""${PWD}""\n""enable""\n""${PWD}""\n""config""\n""interface 0/${LANPORT}""\n""poe opmode auto" | nc ${IP} 23 > /dev/null 2>&1

