# --delete : delete files that don't exist on sender (system)
# -v : Verbose (try -vv for more detailed information)
# -e "ssh options" : specify the ssh as remote shell
# -a : archive mode
# -r : recurse into directories
# -z : compress file data
# -l : links, When symlinks are encountered, recreate the symlink on the destination.
# -R : --relative, begin from /home/kent/...

#To Mac
echo "##################################################"
echo "##            sync RD1-2 To iMac                ##"
echo "##################################################"
rsync -avHlr --delete --timeout=999 -e "ssh -l kent -p6622" ~/Tools ~/.vim ~/.bashrc ~/.vimrc ~/.screenrc ~/practice chenkaie.no-ip.org:RD1-2
rsync -avHlr --delete --timeout=999 -e "ssh -l kent -p6622" ~/.vim chenkaie.no-ip.org:

#To RD1-3
echo "##################################################"
echo "##            sync RD1-2 To RD1-3               ##"
echo "##################################################"
#rsync -avHlr --delete --timeout=999 -e "ssh -l kent" ~/Tools ~/.vim ~/.bashrc ~/.vimrc ~/practice rd1-3:/
