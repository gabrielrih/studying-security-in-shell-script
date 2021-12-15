#!/bin/bash
#
# Check hash from files and recover it if the files changed. Or, you can also use it to identify if the index file from a website was chagend.
#
# Created on				May 24, 2017
# Modified on				Oct 27, 2017
#
# Gabriel Richter <gabrielrih@gmail.com>

# Usage
usage="USAGE: $0 [parameter] [file/directory/website]
Parameter:
	[-f  | --file]        It's to protect an only file. If the file is changed it'll be recovered.
	[-d  | --directory]   It's to protect all the files from a directory. If the directory is changed it'll be recovered.
  [-w  | --website ]    It's to identify when the INDEX file from a Website is changed.
	[-v  | --version]     Show version
	[-h  | --help]        Show help

File/Directory/Website:
  The name of the File, Directory or Website

Examples:
  $0 -f test.list
  $0 -d directoryName
  $0 -w https://www.google.com.br"

# General variables
version=2.0
lastmodification="Fri Oct 27 21:25:35 BRST 2017"
backupDir="./backup" # Backup directory
modifiedDir=".//modifiedDir" # Modified files directory

# Check if file exists
check_file () {
  file=$1
  if [ ! -f $file ]; then
    echo "$usage"
    echo
    echo "Error: The file [$file] was not found!"
    exit 1
  fi
}

# Check if directory exists
check_directory () {
  dir=$1
  if [ ! -d $dir ]; then
    echo "$usage"
    echo
    echo "Error: The directory [$dir] was not found!"
    exit 1
  fi
}

# Configuring
configuring() {
  # Creating directories
  if [ ! -d $backupDir ]; then
    mkdir $backupDir
  fi

  if [ ! -d $modifiedDir ]; then
    mkdir $modifiedDir
  fi

}

# Starting file protection
run_file_protecting () {

  # Setting variables
  baseFile=$1
  baseFileBackup=$(echo $baseFile.bak | rev | cut -d/ -f1 | rev)  #keep just the file's name

  cp $baseFile $backupDir/$baseFileBackup # doing the backup here
	originalHash=$(md5sum $baseFile | cut -d" " -f1)

  # Starting monitoring
	clear
  echo "[+] Monitoring $baseFile..."
  echo

  while :; do

    # Calculating new hash
    newHash="$(md5sum $baseFile 2>/dev/null | cut -d" " -f1)"

    # If hash doesn't match
    if [ "$newHash" != "$originalHash" ]; then
      getDate=$(date +%Y%m%d%H%M%S)
      echo "[-] Bad News: $(date +%Y-%m-%d:%H:%M:%S)"

      # If original file was delete
      if [[ ! -f $baseFile ]]; then
        echo "[-] The [$baseFile] was deleted!"
      else
        tmpBaseFile=$(echo $baseFile | rev | cut -d/ -f1 | rev)  #keep just the file's name)
        modifiedFile=$getDate$tmpBaseFile
        echo "[-] The [$baseFile] file was changed (hash doesn't match)"
        echo "[-] The modified file is [$modifiedFile]"
        cp $baseFile $modifiedDir/$modifiedFile
      fi

      cp $backupDir/$baseFileBackup $baseFile
      echo "[+] Recovering [$baseFile]"
      echo
    fi

    # If the directory is deleted during the proccess
    if [ ! -d $modifiedDir ]; then
      mkdir $modifiedDir
    fi

    sleep 1
  done
}

# Starting directory protection
run_dir_protecting () {

  # Setting variables
  baseDirectory=$1
	baseDirectoryName=$(echo $baseDirectory | rev | cut -d/ -f1 | rev) #keep just the directory's name
  #baseDirectoryBackup=$(echo $baseDirectory.tar | rev | cut -d/ -f1 | rev) #keep just the file's name

  # Doing backup from directory
  #tar -cf $backupDir/$baseDirectoryBackup $baseDirectory
	cp -R $baseDirectory $backupDir

  # Calculating the hash from each file from the directory
  index=0
  for eachFile in $(find $1 -type f)
  do
    FILE[$index]="$eachFile"
    HASH[$index]=$(md5sum $eachFile 2>/dev/null | cut -d" " -f1)
    index=$index+1 #Incremeting the index file
  done

  fileAmount=$(($index)) # Amount of files founded

  clear
  echo "[+] Monitoring $fileAmount files in [$baseDirectory] directory..."
  echo

  while :; do

    # Calculating the hash from each new file founded
    index=0 # reset
    for eachNewFile in $(find $1 -type f)
    do
      NEWFILE[$index]="$eachNewFile"
      NEWHASH[$index]=$(md5sum $eachNewFile 2>/dev/null | cut -d" " -f1)

      # Navega por cada arquivo original e verifica
      for (( i=0; i<$fileAmount; i++ ))
      do
          # Searching for the file
          if [ ${NEWFILE[$index]} == ${FILE[$i]} ]; then
            #echo "${NEWFILE[$index]} founded in the original directory"

            # Check if hashes match
            if [ ${NEWHASH[$index]} != ${HASH[$i]} ]; then
                getDate=$(date +%Y%m%d%H%M%S)
                modified=$getDate$baseDirectoryName
                echo "[-] Bad News: $(date +%Y-%m-%d:%H:%M:%S)"
                echo "[-] The [${NEWFILE[$index]}] file was changed (hash doesn't match)"
                echo "[-] The modified directory is [$modified]"
                #tar -cf $modifiedDir/$modified $baseDirectory >> /dev/null #compressing
								cp -R $baseDirectory $modifiedDir/$modified # copy changed directory to other place

                # Recovering directory
                #tar -xf $backupDir/$baseDirectoryBackup #extracting files
								modified=$(echo $baseDirectory | rev | cut -d/ -f2-9999 | rev)
								cp -R $backupDir/$baseDirectoryName $modified
                echo "[+] Recovering directory [$baseDirectory]"
                echo
            fi

          fi
      done

      index=$index+1 #Incremeting the index file
    done

    newFileAmount=$(($index)) # Amount of new files founded

    # Check the amount of files
    if [[ $fileAmount != $newFileAmount ]]; then
      getDate=$(date +%Y%m%d%H%M%S)
      modified=$getDate$baseDirectoryName
      echo "[-] Bad News: $(date +%Y-%m-%d:%H:%M:%S)"
      echo "[-] One file was deleted or added!"
      echo "[-] The modified directory is [$modified]"
      #tar -cf $modifiedDir/$modified $baseDirectory
      #rm -R $baseDirectory
			cp -R $baseDirectory $modifiedDir/$modified # copy changed directory to other place

      # Recovering files
      #tar -xf $backupDir/$baseDirectoryBackup
			modified=$(echo $baseDirectory | rev | cut -d/ -f2-9999 | rev)
			rm -R $baseDirectory # deleted before to eliminate new files added
			cp -R $backupDir/$baseDirectoryName $modified
			echo "[+] Recovering directory [$baseDirectory]"
			echo

    fi

    sleep 1
  done

}

# Starting index file from website protection
run_website_protecting () {

  # Setting variables
  baseWebsite=$1
  isIndexBad=0  #control variable, don't change it

  # Starting monitoring
  originalHash=$(lynx -source $baseWebsite 2>/dev/null | md5sum | cut -d" " -f1)
  clear
  echo "[+] Monitoring index file from $baseWebsite..."
  echo

  while :; do

    # When the index file is OK
    if [ $isIndexBad == 0 ]
    then

      # Calculating new hash
      newHash=$(lynx -source $baseWebsite 2>/dev/null | md5sum | cut -d" " -f1)

      # If hash doesn't match
      if [ "$newHash" != "$originalHash" ]; then
        isIndexBad=1 #index is bad
        getDate=$(date +%Y%m%d%H%M%S)
        echo "[-] Bad news: $(date +%Y-%m-%d:%H:%M:%S)"
        echo "[-] The index file from [$baseWebsite] was changed (hash doesn't match)"
        lynx -source $baseWebsite 2>/dev/null # show modified file
        echo
      fi

    # When index file was changed
    else

      # Calculating new hash
      newHash=$(lynx -source $baseWebsite 2>/dev/null | md5sum | cut -d" " -f1)

      # If the new hash is equal the original, it means that the index file was recovered
      if [ "$newHash" == "$originalHash" ]; then
        isIndexBad=0 #index is OK
        getDate=$(date +%Y%m%d%H%M%S)
        echo "[+] Good news: $(date +%Y-%m-%d:%H:%M:%S)"
        echo "[+] The index file was recovered! "
        echo
      fi

    fi

    sleep 1
  done

}

case $1 in

	-f | --file)
    if [ -z $2 ]; then echo "$usage"; exit 1; fi # Check second parameter
    check_file $2
    configuring
    run_file_protecting $2
	;;

	-d | --directory)
    if [ -z $2 ]; then echo "$usage"; exit 1; fi # Check second parameter
    check_directory $2
    configuring
    run_dir_protecting $2
	;;

  -w | --website)
    if [ -z $2 ]; then echo "$usage"; exit 1; fi # Check second parameter
    run_website_protecting $2
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
		exit 1
	;;
esac

exit 0
