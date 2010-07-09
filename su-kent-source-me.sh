#!/bin/sh

# .bashrc
\cp -rf `readlink -f /home/kent/.bashrc` /tmp/.bashrc_kent
sed -i -e 's/$HOME/\/home\/kent/g' /tmp/.bashrc_kent
#sed -i -e 's/PS1=\(.*\)/PS1=[\\u@\\h \\W]\\$/g' /tmp/.bashrc_kent
source /tmp/.bashrc_kent

# .vimrc
\cp -rf `readlink -f /home/kent/.vimrc` /tmp/.vimrc_kent
sed -i -e '/backup/d' /tmp/.vimrc_kent
alias vim='vim -u /tmp/.vimrc_kent'

