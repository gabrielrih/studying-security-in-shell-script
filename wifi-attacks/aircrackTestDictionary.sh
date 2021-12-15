#!/bin/bash
#
# It's to test AIRCRACK-NG with WAP CAP and multiples dictionaries
#
# Gabriel Richter <gabrielrih@gmail.com>
#

# CHANGELOG.
# v1     	Basic functions

# USAGE
USE="Usage: $0 [CAP file] [wordlist]

[Parameters]
CAP file        Informe CAP file to aircrack to check
wordlist				Informe wordlist

Example:	$0 tmpWPA/CrackMeWPA.cap"

# Checking parameters number
if [ $# != 2 ]
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
capFile=$1
wordlist=$2

# While there's wordlist to check
while read i
do
	sudo aircrack-ng $capFile -w $i
done < $wordlist

exit 0
