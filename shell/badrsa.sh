#!/bin/bash
# badRSA
# remove entries related to specified host or IP from known_hosts

INPUT=$1
file=".ssh/known_hosts"

run_nslookup () {
  NAME=$(nslookup $INPUT | sed -n 's/.*arpa.*name = \(.*\)/\1/p')
  IP=$(nslookup $INPUT | sed -n -e 's/^.*Address: //p')
  if [[ -n "$NAME" ]]; then
    cmd="sed -i '/${NAME}/d' ${file}"
  elif [[ -n "$IP" ]]; then
    cmd="sed -i '/${IP}/d' ${file}"
  else
    :
  fi
}

echo "Running cleanup on ${INPUT}..."

run_nslookup INPUT
echo "$cmd"
eval "$cmd"

echo "sed -i '/${INPUT}/d' ${file}"
eval "sed -i '/${INPUT}/d' ${file}"

#end
