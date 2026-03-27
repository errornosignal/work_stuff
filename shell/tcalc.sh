#!/bin/bash
# tcalc
# calculate difference between two timestamps

if [ "$1" == "-h" ]; then
 echo "returns difference between t1 & t2"
 echo "'$0 'timestamp 1' 'timestamp 2'"
 exit 0
else

t1=$1
t2=$2

t1e=$(date -d "$t1" +%s)
t2e=$(date -d "$t2" +%s)

let tfe=$t1e-$t2e

if [ "$tfe" -ge 0 ]
then
 absval=$tfe
else
let absval=0-$tfe
fi

num=$absval
 min=0
 hour=0
 day=0
  if((num>59));then
     ((sec=num%60))
       ((num=num/60))
    if((num>59));then
       ((min=num%60))
         ((num=num/60))
       if((num>23));then
           ((hour=num%24))
             ((day=num/24))
       else
           ((hour=num))
       fi
     else
       ((min=num))
     fi
   else
     ((sec=num))
   fi

echo "$day"d "$hour"h "$min"m "$sec"s

fi
exit 0
