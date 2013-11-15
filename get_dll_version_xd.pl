#!/bin/sh

NORMAL='\033[0m'
GOOD='\033[32;01m'
WARN='\033[33;01m'
BAD='\033[31;01m'

echo -e "" 
echo -e "+-------------------------------------------------------------+"
echo -e "|  ${BAD}[WARNING] get_dll_version_xd.pl is totally out of FASHION${NORMAL}  |"
echo -e "+-------------------------------------------------------------+"
echo -e "|          The charge for the patch is 0.99 USD               |"
echo -e "|          Pay once for a lifetime membership ˊ_>ˋ            |"
echo -e "|          Please Enter Your Credit Card Number:              |"
echo -e "|          ${WARN}____ - ____ - ____ - ____  ${GOOD}CVC: ___ ${NORMAL}               |"
#read -p "|          Press [Enter] key to continue...              |"
echo -e "+-------------------------------------------------------------+"
/home/kent/usr/bin/cowsay -e "><" -W 100 "Just Sync It: svn log -v -r138970 http://rd1-1/subversion/"

echo "`date`, `whoami`, $PRODUCTVER" >> /home/kent/tmp/CreditCardList
mail -s "[VIVOTEK Store] CreditCardList" kent.chen@vivotek.com < /home/kent/tmp/CreditCardList

exit 1
