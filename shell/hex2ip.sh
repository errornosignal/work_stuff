#!/bin/bash
# hex2ip
# convert IP addresses in hex-format to dotted-decimal

dirty=$1
clean=${dirty//[[:punct:]]}
printf '%d.%d.%d.%d\n' $(echo $clean | sed 's/../0x& /g')
