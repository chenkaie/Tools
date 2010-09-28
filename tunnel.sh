#/bin/bash
case "$1" in
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
	exit 1
	;;
esac
