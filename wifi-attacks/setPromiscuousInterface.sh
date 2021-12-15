#!/bin/bash
#
# It just create a promiscuous interface
#
# Gabriel Richter <gabrielrih@gmail.com>
# Last Modification: 
#
# More information: http://gabrielrih.wixsite.com/wiki/invadir-rede-wi-fi-com-criptografia-wep
#

# USAGE
USE="Usage: $0 [interface] 

[Parameters]
interface       Fill wi-fi interface (Eg. wlan0)

Example:	$0 wlan0"

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

# Variable
interface=$1

# Start interface in promiscuous mode
airmon-ng start $interface

echo "IT'S DONE :)"

exit 0
