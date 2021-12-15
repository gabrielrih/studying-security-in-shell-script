#!/bin/bash
#
# It creates a file from a wordlist with some hashes
#
# Created on				May 17, 2017
# Modified on				May 17, 2017
#
# Gabriel Richter		<gabrielrih@gmail.com>

version=1.0
lastmodification="Wed May 17 19:51:59 BRT 2017"

# Usage
usage="USAGE: $0 [action] [wordlist] [algorithm]
Action:
  [-r  | --run]     Run
  [-v  | --version] Show version
  [-h  | --help]    Show help

Algorithm:
  [md5], [base64], [sha256], [sha512], [all]"

# Variables
action=$1
wordlist=$2
algorithm=$3

# Run function
run () {
  # Check parameters
  if [ $wordlist == "" ]; then
     echo "$usage";
     echo
     echo "ERROR: You have to enter the wordlist file!"
     exit 1;
  fi

  if [[ $algorithm == "" ]]; then
    algorithm="all" # Default value
  fi

  # Change CRLF caracter to LF
  dos2unix $wordlist >> /dev/null

  # Print wordlist
  for word in $(cat $wordlist)
  do

    # Check which algorithm to use
    if [[ "$algorithm" == "md5" ]]; then
      md5="$(echo -n "$word" | md5sum | cut -d " " -f1)"
      crypt=$md5
    elif [[ "$algorithm" == "base64" ]]; then
      base64="$(echo -n "$word" | base64)"
      crypt=$base64
    elif [[ "$algorithm" == "sha256" ]]; then
      sha256="$(echo -n "$word" | sha256sum | cut -d" " -f1)"
      crypt=$sha256
    elif [[ "$algorithm" == "sha512" ]]; then
      sha512="$(echo -n "$word" | sha512sum | cut -d" " -f1)"
      crypt=$sha512
    elif [[ "$algorithm" == "all" ]]; then
      md5="$(echo -n "$word" | md5sum | cut -d " " -f1)"
      base64="$(echo -n "$word" | base64)"
      sha256="$(echo -n "$word" | sha256sum | cut -d" " -f1)"
      sha512="$(echo -n "$word" | sha512sum | cut -d" " -f1)"
      crypt=$md5:$base64:$sha256:$sha512
    fi

    echo $word:$crypt

  done | column -s: -t > wordlist.crypt # Column is used just to print better

  # Print result
  cat wordlist.crypt
}

# Check ACTION
case $action in

	-r | --run)
    run
	;;

	-v | --version)
		echo "Version: $version"
		echo "$lastmodification"
		exit 0
	;;

	-h | --help)
		echo "$usage"
		exit 0
	;;

	*)
		echo "$usage"

		# If there is an invalid parameter
		if [ ! -f $1 ]
		then
			echo
			echo "ERROR: Parameter $1 not found!"
		fi

		exit 1
	;;
esac

exit 0
