#!/bin/sh
# Login by pem: ssh -i natty.pem ubuntu@ec2-50-18-83-73.us-west-1.compute.amazonaws.com
# 
# ==========================================================================
# Samba: \\amazon-ec2.no-ip.org\ubuntu
# NFS  : mount -t nfs -o tcp,nolock amazon-ec2.no-ip.org:/home /home
# 
# Samba:
#     Path: \\amazon-ec2.no-ip.org\ubuntu
#     config file: /etc/samba/smb.conf + sudo smbpasswd -a username
# 
# ==========================================================================
# 
# NFS  :
#     Path: mount -t nfs -o tcp,nolock amazon-ec2.no-ip.org:/home /home
#     config file: /etc/exports
# 
# ==========================================================================
# 
# Change default Ubuntu AMI password
# 
# --
# ubuntu@ip-10-146-13-248:~$ sudo passwd
# Enter new UNIX password:
# --
# 
# ==========================================================================
# Amazon Web Services™ are available in several regions. 
# Estimate the latency from your browser to each AWS™ region.
# 
# http://www.cloudping.info/
# 
# ==========================================================================


# 0. Use passowrd authentication
sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart

sudo dpkg-reconfigure bash
# sudo ln -s -n -i /bin/bash /bin/sh

# 1.
sudo passwd ubuntu

# 2.
sudo adduser vivotek
sudo adduser kent 
sudo adduser kent admin
sudo adduser kent adm


# 3. 
mkdir $HOME/Repos
cd $HOME/Repos

git clone git://github.com/chenkaie/DotFiles.git
git clone git://github.com/chenkaie/Tools.git
git clone git://github.com/chenkaie/rcfiles.git

ln -s $HOME/Repos/Tools $HOME/Tools
mv $HOME/.bashrc $HOME/.bashrc_ori

ln -s $HOME/Repos/rcfiles/ $HOME/Repos/DotFiles/
cd $HOME/Repos/DotFiles; git submodule update --init; ./deploy-links; cd $HOME

# packages
sudo aptitude install exuberant-ctags cscope lsb-release cowsay inadyn

