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

sudo apt-get install openssh-server vim curl git

# Run a 32-bit program on a 64-bit version of Ubuntu
sudo apt-get install lib32z1 lib32ncurses5 lib32bz2-1.0 lib32stdc++6

# 0. Use passowrd authentication
sudo sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config
sudo /etc/init.d/ssh restart

sudo dpkg-reconfigure dash
# sudo ln -s -n -i /bin/bash /bin/sh

# 1.
sudo passwd ubuntu

# 2.
sudo adduser vivotek
sudo adduser kent
sudo adduser kent admin
sudo adduser kent adm
sudo adduser kent sudo

mkdir -p $HOME/usr/bin
REPO_BIN=$HOME/usr/bin/repo
curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > $REPO_BIN
chmod +x $REPO_BIN

UNIX_ENV_DEPLY="$HOME/Repos/unix-env-deploy"

# 3.
mkdir -p ${UNIX_ENV_DEPLY}
cd ${UNIX_ENV_DEPLY}

$REPO_BIN init -u https://github.com/chenkaie/manifest-unix-env-deploy.git
$REPO_BIN sync

ln -s ${UNIX_ENV_DEPLY}/Tools $HOME/Tools
mv $HOME/.bashrc $HOME/.bashrc_ori

cd ${UNIX_ENV_DEPLY}/DotFiles; git submodule update --init; ./deploy-links; cd $HOME

# packages
sudo apt-get install exuberant-ctags cscope lsb-release cowsay silversearcher-ag id-utils

