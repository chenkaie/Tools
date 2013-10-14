#/bin/bash

# This is a really cool ssh login style
# Catch me if you can :)

VIMSSH="vim"
VIMSSH_PATH="$HOME/tmp/"
cd $VIMSSH_PATH
export PATH=.:$PATH

case "$1" in
	*dd-wrt-proxy*)
    # -D [bind_address:]port
    #    Specifies a local "dynamic" application-level port forwarding.  This works by allocating a socket to listen to port on the local side, optionally bound
    #    to the specified bind_address.  Whenever a connection is made to this port, the connection is forwarded over the secure channel, and the application
    #    protocol is then used to determine where to connect to from the remote machine.  Currently the SOCKS4 and SOCKS5 protocols are supported, and ssh will
    #    act as a SOCKS server.  Only root can forward privileged ports.  Dynamic port forwardings can also be specified in the configuration file.
	#
	# Note: -D mode only do a port fowarding on local side, i.e. works only on telnet localhost port, rather than telnet PUBLIC_IP port
	#       Therefore we have to do a public port fowarding e.g. 
	#			step 1. kent@hostname   $ ssh -R 7321:rd1-2:22 ubuntu@amazon-ec2.no-ip.org -o TCPKeepAlive=no -o ServerAliveInterval=60 
	#       	step 2. ubuntu@hostname $ ssh -D 8888 localhost -p7321 -lkent -vvv -N
	#       	step 3. ubuntu@hostname $ socat TCP-LISTEN:12345,fork TCP:localhost:8888
	#           step 4. Setup browser proxy settings as "SOCK v5" + "amazon-ec2.no-ip.org:12345"

    autossh -M 0 -D 172.16.5.31:52525 -R 7322:rd1-2:22 root@chenkaie.no-ip.org -p2222 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*dd-wrt*)
    #autossh -M 0 -R 7322:rd1-2:22 root@chenkaie.no-ip.org -p2222 -o TCPKeepAlive=no -o ServerAliveInterval=60
	$VIMSSH config_videoin.xml
        ;;
	*totoro*)
    autossh -M 0 -R 7321:rd1-2:22 kent@140.118.155.113 -p3063 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*funp*)
    autossh -M 0 -R 7322:rd1-2:22 arnold@tcdevweb.funp.com -p22 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*amazon*)
    autossh -M 0 -R 7322:rd1-2:22 ubuntu@amazon-ec2.no-ip.org -p22 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*ptt*)
	$VIMSSH config_system.xml
        ;;
	*rdp*)
	$VIMSSH config_ptzctrl.xml
        ;;
	*diskstation*)
	$VIMSSH config_ddns.xml
        ;;
	*)
	echo "Usage : $0 [dd-wrt|totoro|funp|ptt|rdp]"
	exit 1
	;;
esac
