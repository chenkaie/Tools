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
tmux new-window         -t Main:5 -n "gen3m"
tmux new-window         -t Main:6 -n "issues"
tmux new-window         -t Main:7 -n "owrt"
tmux new-window         -t Main:8 -n "vvtk"
tmux new-window         -t Main:9 -n "avahi"
tmux new-window         -t Main:10 -n "mbpr"
tmux new-window         -t Main:11 -n "nvr"
tmux new-window         -t Main:12 -n "elektra"

# Send commands to the windows, use "C-m" to emulate "enter"

tmux send-keys          -t Main:1 "cd ${ROOT}/unifi-video-firmware/;      source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:2 "cd ${ROOT}/unifi-video-firmware-gen2/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:3 "cd ${ROOT}/unifi-video-firmware-gen3l/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:4 "cd ${ROOT}/unifi-video-firmware-gen3m/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:5 "cd ${ROOT}/unifi-video-firmware-gen3m/; source ubnt-devel-aircam" C-m
tmux send-keys          -t Main:6 "cd ${ROOT}/Issues" C-m
tmux send-keys          -t Main:7 "cd ${ROOT}/OpenWrt" C-m
tmux send-keys          -t Main:8 "cd ${ROOT}/VVTK" C-m
tmux send-keys          -t Main:9 "avahi-browse-domains -a -v -r" C-m
tmux send-keys          -t Main:10 "ssh kent-mbpr-ubnt.local" C-m
tmux send-keys          -t Main:11 "cd ${ROOT}/unifi-video; ant -projecthelp" C-m
tmux send-keys          -t Main:12 "cd ${ROOT}/bsp/amba-s2lm/ambarella; source build/env/Linaro-multilib-gcc4.9.env" C-m

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

tmux send-keys          -t Tunnel:1 'cd $TOOLS; ./test.expect' C-m
tmux send-keys          -t Tunnel:2.top "watch ccache -s" C-m
tmux send-keys          -t Tunnel:2.top "sudo atop" C-m
tmux send-keys          -t Tunnel:2.bottom "htop -d 10" C-m
tmux send-keys          -t Tunnel:3 "cd ${HOME}/ArmTools/UVC; server 8888" C-m
tmux send-keys          -t Tunnel:4 "dropboxd.py start" C-m
tmux send-keys          -t Tunnel:5.left "iperf -s -i1 -m -fk" C-m
tmux send-keys          -t Tunnel:5.right "iperf -s -u -i1 -m -fk" C-m
tmux send-keys          -t Tunnel:6.top "dstat -cdlmnpsy --top-cpu --top-bio --top-mem --top-latency" C-m
tmux send-keys          -t Tunnel:6.bottom "sudo atop" C-m

# Switch to window 1
tmux select-window      -t Tunnel:1

#########
# S:SSH #
#########
tmux new-session     -d -s SSH

tmux rename-window      -t SSH:1 "ttyUSB0"
tmux new-window         -t SSH:2 -n "ttyUSB1"
tmux new-window         -t SSH:3 -n "ttyS0"
tmux new-window         -t SSH:4
tmux new-window         -t SSH:5

tmux send-keys          -t SSH:1 "miniterm.py --lf /dev/ttyUSB0 115200" C-m
tmux send-keys          -t SSH:2 "miniterm.py --lf /dev/ttyUSB1 115200" C-m
tmux send-keys          -t SSH:3 "miniterm.py --lf /dev/ttyACM0 115200" C-m

# Switch to window 1
tmux select-window      -t SSH:1

#########
# Final #
#########

# Force tmux to assume the terminal supports 256 colors and attach to the target session "Main"
tmux -2 attach-session -t Main

