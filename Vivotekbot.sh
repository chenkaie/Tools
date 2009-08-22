#!/bin/sh
#This is a Vivotekbot (similar to Googlebot), to automatically request something from camera!

echo -n "Network-Camera login:"
read username
echo -n "Password:"
read password
echo -n "Camera IP Address:"
read ipaddr

#$RANDOM -> /dev/random (0~32767)
declare -i randomNumber

cgi_array=(system network ipfilter ddns videoin image motion security privacymask event server media recording ircutctrl capability layout)
wagpage_array=(system security https network ddns accesslist video motin tampering homelayout application recording syslog parafile maintain)

# get length of an array
#echo "${#cgi_array[@]}"
#echo "${#wagpage_array[@]}"

RandomSleep()
{
    #let randomNumber belong to 0~60
    randomNumber=$RANDOM*60/32767
    echo "sleep $randomNumber"
    randomNumber=1
    sleep $randomNumber
}

while [ 1 ]
do
    #Get a video.jpg
    echo "GET: /cgi-bin/viewer/video.jpg"
    curl -u $username:$password http://$ipaddr/cgi-bin/viewer/video.jpg -o /dev/null > /dev/null 2>&1 &
    RandomSleep
    
    #Get a cgi command
    ranNumCgi=$RANDOM*${#cgi_array[@]}/32767
    echo "CGI: /cgi-bin/admin/getparam.cgi?${cgi_array[$ranNumCgi]}"
    curl -u $username:$password http://$ipaddr/cgi-bin/admin/getparam.cgi?${cgi_array[$ranNumCgi]} -o /dev/null > /dev/null 2>&1 &
    #echo "curl -u $username:$password http://$ipaddr/cgi-bin/admin/getparam.cgi?${cgi_array[$ranNumCgi]} -o /dev/null > /dev/null 2>&1 &"
    RandomSleep
   
    #Get a webpage.html
    ranNumWebpage=$RANDOM*${#wagpage_array[@]}/32767
    echo "GET: /setup/${wagpage_array[$ranNumWebpage]}.html"
    curl -u $username:$password http://$ipaddr/setup/$wagpage_array[$ranNumWebpage].html -o /dev/null > /dev/null 2>&1 &
    #echo "curl -u $username:$password http://$ipaddr/setup/${wagpage_array[$ranNumWebpage]}.html -o /dev/null > /dev/null 2>&1 &"
    RandomSleep
done
