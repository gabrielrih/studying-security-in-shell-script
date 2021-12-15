#!/bin/bash
#
# Scanner all network looking for devices and features
#
# Gabriel Richter <gabrielrih@gmail.com>
# Last Modification: Wed Jan 25 01:33:45 BRST 2017
#

# CHANGELOG
#v1     Basic functions
#v1.1	Logfile name / Mode

# USAGE
USE="Usage: $0 [range] [temp] [mode]

[Parameters]
range		Network range (Eg. 192.168.0.0/24)
temp		Delete temporales files? (yes or no)
mode		Selected mode: lite/normal/advanced

Example:	$0 192.168.0.0/24 yes lite"

# Arguments variables
RANGE=$1
TEMP=$2
MODE=$3

# Less than three parameters
if [ $# != 3 ]
then
        echo "$USE"
        exit 1
fi

# Validating arguments
if [ $TEMP != 'yes' ] && [ $TEMP != 'no' ]
then
    echo "$USE"
    echo ""
    echo "ERROR: $TEMP argument invalid!"
    exit 1
fi

if [ $MODE != 'lite' ] && [ $MODE != 'normal' ] && [ $MODE != 'advanced' ]
then
    echo "$USE"
    echo ""
    echo "ERROR: $MODE argument invalid!"
    exit 1
fi

###############################
# Config files
##############################

# Create history archive
LOGFILE="scannerNetwork$(date +%Y%m%d).log"

if [ -f $LOGFILE ]
then
        rm $LOGFILE
fi
touch $LOGFILE

echo "$(date +%d-%m-%Y-%H:%M:%S) Starting files configuration..."

# Create temporary directory
TMPDIR="tmp"

if [ ! -d $TMPDIR ]
then
	mkdir $TMPDIR
fi

# Create scanner Windows Version File
if [ -f $TMPDIR/scannerWinVersion.rc ]
then
	rm $TMPDIR/scannerWinVersion.rc
fi
touch $TMPDIR/scannerWinVersion.rc

echo "use scanner/smb/smb_version
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerWinVersion.rc

# Create scanner SSH File
if [ -f $TMPDIR/scannerSSH.rc ]
then
	rm $TMPDIR/scannerSSH.rc
fi
touch $TMPDIR/scannerSSH.rc

echo "use scanner/ssh/ssh_version
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerSSH.rc

# Create scanner SQL Server in the local network file
if [ -f $TMPDIR/scannerSQLServer.rc ]
then
	rm $TMPDIR/scannerSQLServer.rc
fi
touch $TMPDIR/scannerSQLServer.rc

echo "use scanner/mssql/mssql_ping
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerSQLServer.rc

# Create scanner FTP file
if [ -f $TMPDIR/scannerFTP.rc ]
then
	rm $TMPDIR/scannerFTP.rc
fi
touch $TMPDIR/scannerFTP.rc

echo "use scanner/ftp/ftp_version
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerFTP.rc

# Create VNC without password file
if [ -f $TMPDIR/scannerVNCwithoutPass.rc ]
then
	rm $TMPDIR/scannerVNCwithoutPass.rc
fi
touch $TMPDIR/scannerVNCwithoutPass.rc

echo "use auxiliary/scanner/vnc/vnc_none_auth
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerVNCwithoutPass.rc

# Create FTP Anonimous Authentication file
if [ -f $TMPDIR/scannerAnonimousFTP.rc ]
then
	rm $TMPDIR/scannerAnonimousFTP.rc
fi
touch $TMPDIR/scannerAnonimousFTP.rc
 
echo "use auxiliary/scanner/ftp/anonymous
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerAnonimousFTP.rc

# Create Open Ports file
if [ -f $TMPDIR/scannerFindOpenPorts.rc ]
then
	rm $TMPDIR/scannerFindOpenPorts.rc
fi
touch $TMPDIR/scannerFindOpenPorts.rc

echo "use auxiliary/scanner/portscan/tcp
set RHOSTS $RANGE
set THREADS 50
set PORTS 1-1000
set VERBOSE false
run
quit" >> $TMPDIR/scannerFindOpenPorts.rc

# Create IMAP Server file
if [ -f $TMPDIR/scannerIMAPServer.rc ]
then
	rm $TMPDIR/scannerIMAPServer.rc
fi
touch $TMPDIR/scannerIMAPServer.rc

echo "use auxiliary/scanner/imap/imap_version
set RHOSTS $RANGE
set THREADS 50
run
quit" >> $TMPDIR/scannerIMAPServer.rc

# Create POP3 server WITHOUT SSL file
if [ -f $TMPDIR/scannerPOP3.rc ]
then
	rm $TMPDIR/scannerPOP3.rc
fi
touch $TMPDIR/scannerPOP3.rc

echo "use auxiliary/scanner/pop3/pop3_version
set RHOSTS $RANGE
set RPORT 110
set SSL false
set THREADS 50
set VERBOSE false
run
quit" >> $TMPDIR/scannerPOP3.rc

# Create POP3 server WITH SSL file
if [ -f $TMPDIR/scannerPOP3WithSSL.rc ]
then
	rm $TMPDIR/scannerPOP3WithSSL.rc
fi
touch $TMPDIR/scannerPOP3WithSSL.rc

echo "use auxiliary/scanner/pop3/pop3_version
set RHOSTS $RANGE
set RPORT 995
set SSL true
set THREADS 50
set VERBOSE false
run
quit" >> $TMPDIR/scannerPOP3WithSSL.rc

# Create MySQL file
if [ -f $TMPDIR/scannerMySQL.rc ]
then
	rm $TMPDIR/scannerMySQL.rc
fi
touch $TMPDIR/scannerMySQL.rc

echo "use exploit/linux/mysql/mysql_yassl_hello
set RHOST $RANGE
set RPORT 3306
run
quit" >> $TMPDIR/scannerMySQL.rc


echo "$(date +%d-%m-%Y-%H:%M:%S) End files configuration."

###############################
# Starting scanner
###############################

# If LITE MODE is set
lite_mode () {

	# Starting nmap
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Starting nmap... looking for devices" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Starting nmap... looking for devices"
	echo "###############################################################" >> $LOGFILE

	nmap -sP $RANGE >> $LOGFILE

	# Looking for Windows Devices
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for Windows Devices..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for Windows Devices..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerWinVersion.rc >> $LOGFILE
}

# If NORMAL MODE is set
normal_mode () {

	# Looking for SSH
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for SSH Server..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for SSH Server..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerSSH.rc >> $LOGFILE

	# Looking for SQL Server
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for SQL Server..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for SQL Server..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerSQLServer.rc >> $LOGFILE

	# Looking for FTP Server
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for FTP Server..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for FTP Server..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerFTP.rc >> $LOGFILE	

	# Looking for FTP Anonimous Authentication
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for FTP Anonimous Authentication..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for FTP Anonimous Authentication..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerAnonimousFTP.rc >> $LOGFILE

	# Looking for VNC without password
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for VNC without password..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for VNC without password..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerVNCwithoutPass.rc >> $LOGFILE

	# Find IMAP Server
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for IMAP Servers..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for IMAP Servers..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerIMAPServer.rc >> $LOGFILE

	# Find POP3 without SSL
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for POP3 without SSL Servers..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for POP3 without SSL Servers..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerPOP3.rc >> $LOGFILE

	# Find POP3 with SSL
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for POP3 with SSL Servers..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for POP3 with SSL Servers..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerPOP3WithSSL.rc >> $LOGFILE
	
	# Find MySQL server
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for MySQL Servers..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for MySQL Servers..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerMySQL.rc >> $LOGFILE
}

# If ADVANCED Mode is set
advanced_mode () {

	# Find open ports
	echo "" >> $LOGFILE
	echo "###############################################################" >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for open ports..." >> $LOGFILE
	echo "$(date +%d-%m-%Y-%H:%M:%S) Looking for open ports..."
	echo "###############################################################" >> $LOGFILE
	echo "" >> $LOGFILE

	msfconsole -q -r $TMPDIR/scannerFindOpenPorts.rc >> $LOGFILE
}


# START MODE
if [ $MODE == 'lite' ]
then
	lite_mode
fi

if [ $MODE == 'normal' ]
then
	lite_mode
	normal_mode
fi

if [ $MODE == 'advanced' ]
then
	lite_mode
	normal_mode
	advanced_mode
fi


# END
echo "" >> $LOGFILE
echo "$(date +%d-%m-%Y-%H:%M:%S) It's done ;)" >> $LOGFILE
echo "$(date +%d-%m-%Y-%H:%M:%S) It's done ;)"


###############################
# Deleting files
###############################
if [ $TEMP == "yes" ]
then	
	rm -R $TMPDIR
fi

exit 0