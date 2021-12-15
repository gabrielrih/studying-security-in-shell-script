#!/bin/bash

netAddress=$(echo $(ifconfig | grep "Bcast" | cut -d" " -f12 | cut -d":" -f2 | cut -d"." -f1-3).0/24)
echo "Starting nmap..."

# Ip List
ipList=$(nmap -sN -p 21,22,80 $netAddress | grep "report for" | cut -d"(" -f2 | cut -d")" -f1) # Print just Ip Address

echo

# For which IP do...
for ip in $(echo $ipList)
do
    nmap -sS -F -O $ip > tmpResult
    ports=$(cat tmpResult | grep "/tcp" | cut -d"/" -f1 | tr "\n" " ")
    os=$(cat tmpResult | grep "OS Details")

    echo "Active ip: $ip | Open ports: $ports | OS: $os"
    rm tmpResult
done

exit 0
