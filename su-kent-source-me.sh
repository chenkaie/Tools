#!/bin/sh

TMPDIR=/dev/shm

# .bashrc
\cp -rf `readlink -f /home/kent/.bashrc` $TMPDIR/.bashrc_kent
sed -i -e 's/$HOME/\/home\/kent/g' $TMPDIR/.bashrc_kent
#sed -i -e 's/PS1=\(.*\)/PS1=[\\u@\\h \\W]\\$/g' $TMPDIR/.bashrc_kent
source $TMPDIR/.bashrc_kent

# .vimrc
\cp -rf `readlink -f /home/kent/.vimrc` $TMPDIR/.vimrc_kent
sed -i -e '/backup/d' $TMPDIR/.vimrc_kent
alias vim='vim --cmd "set rtp+=~kent/.vim,~kent/.vim/vundle/,~kent/.vim/bundle/" -u '$TMPDIR'/.vimrc_kent'

