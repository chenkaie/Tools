#!/bin/sh
cp -rf /home/kent/Repos/DotFiles/.bashrc /tmp/.bashrc_kent
sed -i -e 's/$HOME/\/home\/kent/g' /tmp/.bashrc_kent
#sed -i -e 's/PS1=\(.*\)/PS1=[\\u@\\h \\W]\\$/g' /tmp/.bashrc_kent
source /tmp/.bashrc_kent
alias vim='vim -u /home/kent/.vimrc'
