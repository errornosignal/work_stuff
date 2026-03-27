#!/bin/bash
# snsl
# sequential nslookup for multiple entries (works both ways IP>NAME / NAME>IP)


RED='\033[0;31m'
NC='\033[0m' # No Color
rx='([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

run_nslookup () {
  NAME=$(nslookup $INPUT | sed -n 's/.*arpa.*name = \(.*\)/\1/p')
  IP=$(nslookup $INPUT | sed -n -e 's/^.*Address: //p')
  if [[ -n "$NAME" ]]; then
    echo -e "$INPUT\t$NAME"
  elif [[ -n "$IP" ]]; then
    echo -e "$IP\t$INPUT"
  elif [[ -z "$IP" ]] && [[ -z "$NAME" ]] && [[ $PRINT_NULLS -eq 1 ]]; then
    if [[ $INPUT =~ ^$rx\.$rx\.$rx\.$rx$ ]]; then
      echo -e "$INPUT"
    else
      echo -e "\t\t${RED}$INPUT${NC}"
    fi
  fi
}


if [[ $# -eq 0 ]] ; then
    echo 'arg [required] (ex: snsl 192.168.1.1 OR snsl hostname.domain.com OR snsl 192.168.1.1 hostname.domain.com)'
    echo '[optional] -f, input list from file, print all, (ex: snsl -f input_file.txt)'
    echo '[optional] -n, run on a CIDR network, print all, (ex: snsl -n 192.168.1.0/24)'
    echo '[optional] -nr, run on a CIDR network, print only resolved, (ex: snsl -nr 192.168.1.0/24)'
    exit 0
fi

if [ $1 = "-f" ]; then
  FILE=$2
  while IFS= read -r line
    do
      INPUT=$line
      run_nslookup INPUT
  done < $FILE
elif [ $1 = "-n" ]; then
  PRINT_NULLS=1
  NET=$2
  LIST=$(nmap -sL -n $NET | awk '/Nmap scan report/{print $NF}')
  for line in $LIST
    do
      INPUT=$line
      run_nslookup INPUT PRINT_NULLS
  done
elif [ $1 = "-nr" ]; then
  PRINT_NULLS=0
  NET=$2
  LIST=$(nmap -sL -n $NET | awk '/Nmap scan report/{print $NF}')
  for line in $LIST
    do
      INPUT=$line
      run_nslookup INPUT PRINT_NULLS
  done
else
  PRINT_NULLS=1
  for arg in $@
    do
      INPUT=$arg
      run_nslookup INPUT PRINT_NULLS
  done
fi

#end
