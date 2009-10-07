#/bin/bash
autossh -M 0 -R 7322:rd1-2:22 root@chenkaie.no-ip.org -p2222 -o TCPKeepAlive=no -o ServerAliveInterval=15
