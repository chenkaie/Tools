#/bin/bash
case "$1" in
	*dd-wrt-proxy*)
    # -D [bind_address:]port
    #    Specifies a local "dynamic" application-level port forwarding.  This works by allocating a socket to listen to port on the local side, optionally bound
    #    to the specified bind_address.  Whenever a connection is made to this port, the connection is forwarded over the secure channel, and the application
    #    protocol is then used to determine where to connect to from the remote machine.  Currently the SOCKS4 and SOCKS5 protocols are supported, and ssh will
    #    act as a SOCKS server.  Only root can forward privileged ports.  Dynamic port forwardings can also be specified in the configuration file.

    autossh -M 0 -D 172.16.5.31:52525 -R 7322:rd1-2:22 root@chenkaie.no-ip.org -p2222 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*dd-wrt*)
    autossh -M 0 -R 7322:rd1-2:22 root@chenkaie.no-ip.org -p2222 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*totoro*)
    autossh -M 0 -R 7321:rd1-2:22 kent@140.118.155.113 -p3063 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*funp*)
    autossh -M 0 -R 7322:rd1-2:22 arnold@tcdevweb.funp.com -p22 -o TCPKeepAlive=no -o ServerAliveInterval=60
        ;;
	*)
	echo "Usage : $0 [dd-wrt|totoro|funp]"
	exit 1
	;;
esac
