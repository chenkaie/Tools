#!/bin/sh

TMPDIR=/dev/shm

# Read $ME from environment variable first.
[ -z "$ME" ] && ME="kent.chen"

# .bashrc
\cp -rf `readlink -f /home/$ME/.bashrc` $TMPDIR/.bashrc_kent
sed -i -e 's/$HOME/\/home\/$ME/g' $TMPDIR/.bashrc_kent
#sed -i -e 's/PS1=\(.*\)/PS1=[\\u@\\h \\W]\\$/g' $TMPDIR/.bashrc_kent
source $TMPDIR/.bashrc_kent

# .vimrc
\cp -rf `readlink -f /home/$ME/.vimrc` $TMPDIR/.vimrc_kent
sed -i -e '/backup/d' $TMPDIR/.vimrc_kent
alias vim="vim --cmd 'set rtp+=~$ME/.vim,~$ME/.vim/vundle/,~$ME/.vim/bundle/' -u '$TMPDIR'/.vimrc_kent"

