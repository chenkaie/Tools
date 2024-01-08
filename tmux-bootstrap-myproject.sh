#!/bin/sh

###########
# General #
###########

# Setup some variables needed for bootstrapping the environment
ROOT=$HOME/project

##########
# S:Main #
##########

# Bootstrap a new session called "Main"
tmux new-session     -d -s Main

# Rename the first window (using the session-name:id notation)
tmux rename-window      -t Main:1 "dev"
tmux new-window         -t Main:2 -n "gen2"
tmux new-window         -t Main:3 -n "gen3l"
tmux new-window         -t Main:4 -n "gen3m"
tmux new-window         -t Main:5 -n "gen4l"
tmux new-window         -t Main:6 -n "gen4c"
tmux new-window         -t Main:7 -n "gen3s"
tmux new-window         -t Main:8 -n "owrt"
tmux new-window         -t Main:9 -n "vvtk"
tmux new-window         -t Main:10 -n "avahi"
tmux new-window         -t Main:11 -n "mbpr"
tmux new-window         -t Main:12 -n "nvr"
tmux new-window         -t Main:13 -n "amba-bsp"
tmux split-window    -v -t Main:13
tmux new-window         -t Main:14 -n "mcu"
tmux new-window         -t Main:15 -n "go"
tmux new-window         -t Main:16 -n "ufp"
tmux new-window         -t Main:17 -n "eot"
tmux split-window    -v -t Main:17

# Send commands to the windows, use "C-m" to emulate "enter"

tmux send-keys          -t Main:1 "cd ${ROOT}/unifi-video-firmware/;      source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:2 "cd ${ROOT}/unifi-video-firmware-gen2/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:3 "cd ${ROOT}/unifi-video-firmware-gen3l/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:4 "cd ${ROOT}/unifi-video-firmware-gen3m/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:5 "cd ${ROOT}/unifi-video-firmware-gen4/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:6 "cd ${ROOT}/unifi-video-firmware-gen4c/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:7 "cd ${ROOT}/unifi-video-firmware-gen3s/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:8 "cd ${ROOT}/OpenWrt" C-m
tmux send-keys          -t Main:9 "cd ${ROOT}/VVTK" C-m
tmux send-keys          -t Main:10 "avahi-browse-domains -a -v -r" C-m
tmux send-keys          -t Main:11 "ssh kent-mbpr16-ubnt.local" C-m
tmux send-keys          -t Main:12 "cd ${ROOT}/unifi-video; ant -projecthelp" C-m
tmux send-keys          -t Main:13.top    "cd ${ROOT}/BSP/amba-s2lm; source ./ambarella/build/env/Linaro-multilib-gcc4.9.env" C-m
tmux send-keys          -t Main:13.bottom "cd ${ROOT}/BSP/amba-s5lm; source ./ambarella/build/env/aarch64-linaro-gcc.env" C-m
tmux send-keys          -t Main:14 "cd ${ROOT}/unicam-mcu-firmware" C-m
tmux send-keys          -t Main:15 "cd $GOPATH/src/github.com/ubiquiti/uvcbox/" C-m
tmux send-keys          -t Main:16 "cd ~/project/unifi-protect" C-m
tmux send-keys          -t Main:17.top    "cd ~/project/protect-eot-firmware; source ubnt-devel-eot_sfl" C-m
tmux send-keys          -t Main:17.bottom "cd ~/project/protect-eot-firmware-radar; source ubnt-devel-eot_radar" C-m

# Switch to window 1
tmux select-window      -t Main:1

############
# S:Tunnel #
############
tmux new-session     -d -s Tunnel

tmux rename-window      -t Tunnel:1 "ddwrt"
tmux new-window         -t Tunnel:2
tmux split-window    -v -t Tunnel:2
tmux new-window         -t Tunnel:3 -n "hfs"
tmux new-window         -t Tunnel:4 -n "dropbox"
tmux new-window         -t Tunnel:5 -n "iperf"
tmux split-window    -h -t Tunnel:5
tmux new-window         -t Tunnel:6
tmux split-window    -v -t Tunnel:6
tmux new-window         -t Tunnel:7 -n "ddwrt-tunnel"
tmux new-window         -t Tunnel:8 -n "sshuttle"
tmux split-window    -v -t Tunnel:8

tmux send-keys          -t Tunnel:1 'cd $TOOLS; ./test.expect' C-m
tmux send-keys          -t Tunnel:2.top "watch ccache -s" C-m
tmux send-keys          -t Tunnel:2.top "sudo atop" C-m
tmux send-keys          -t Tunnel:2.bottom "htop -d 10" C-m
#tmux send-keys          -t Tunnel:3 "cd ${HOME}/ArmTools/UVC; ./SimpleHTTPServerWithUpload.py 8888" C-m
tmux send-keys          -t Tunnel:3 "cd ${HOME}/ArmTools/UVC; gohttpserver -r ./ --port 8888 --upload" C-m
#tmux send-keys          -t Tunnel:4 "dropboxd.py start" C-m
tmux send-keys          -t Tunnel:5.left "iperf -s -i1 -m -fk" C-m
tmux send-keys          -t Tunnel:5.right "iperf3 -s -i1" C-m
tmux send-keys          -t Tunnel:6.top "dstat -cdlmnpsy --top-cpu --top-bio --top-mem --top-latency" C-m
tmux send-keys          -t Tunnel:6.bottom "sudo atop" C-m
#tmux send-keys          -t Tunnel:7 'cd $TOOLS; ./test2.expect' C-m
tmux send-keys          -t Tunnel:8.top 'sshuttle -r root@10.2.0.152 192.168.1.0/24 -v' C-m
tmux send-keys          -t Tunnel:8.bottom 'sshuttle -r root@10.2.1.123 192.168.6.0/24 -v' C-m

# Switch to window 1
tmux select-window      -t Tunnel:1

#########
# S:SSH #
#########
tmux new-session     -d -s SSH

tmux rename-window      -t SSH:1 "ttyUSB0"
tmux new-window         -t SSH:2 -n "ttyUSB1"
tmux new-window         -t SSH:3 -n "ttyUSB2"
tmux new-window         -t SSH:4 -n "PowerEdge"
tmux new-window         -t SSH:5 -n "uck+"
tmux new-window         -t SSH:6

#tmux send-keys          -t SSH:1 "miniterm.py --eol CR --raw /dev/ttyUSB0 9600" C-m
tmux send-keys          -t SSH:1 "miniterm.py --eol LF --raw /dev/ttyUSB0 115200" C-m
tmux send-keys          -t SSH:2 "miniterm.py --eol LF --raw /dev/ttyUSB1 115200" C-m
tmux send-keys          -t SSH:3 "miniterm.py --eol LF --raw /dev/ttyUSB2 115200" C-m
tmux send-keys          -t SSH:4 "ssh unifivideo@10.2.0.125" C-m
tmux send-keys          -t SSH:5 "ssh ufv4-ckplus" C-m

# Switch to window 1
tmux select-window      -t SSH:1

#########
# Final #
#########

# Force tmux to assume the terminal supports 256 colors and attach to the target session "Main"
tmux -2 attach-session -t Main

