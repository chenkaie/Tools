#!/bin/sh
# Login by pem: ssh -i natty.pem ubuntu@ec2-50-18-83-73.us-west-1.compute.amazonaws.com
#

# 0. Use passowrd authentication
sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart

sudo ln -s -n -i /bin/bash /bin/sh

# 1.
sudo ubuntu

# 2.
sudo adduser vivotek
sudo adduser kent 

# 3. 
mkdir $HOME/Repos
cd $HOME/Repos

git clone git://github.com/chenkaie/DotFiles.git
git clone git://github.com/chenkaie/Tools.git
git clone git://github.com/chenkaie/rcfiles.git

ln -s $HOME/Repos/Tools $HOME/Tools
mv $HOME/.bashrc $HOME/.bashrc_ori

ln -s $HOME/Repos/rcfiles/ $HOME/Repos/DotFiles/
cd $HOME/Repos/DotFiles; ./deploy-links; cd $HOME

# packages
sudo aptitude install exuberant-ctags cscope lsb-release cowsay

