#!/bin/bash
COUNTER_FILE="counter.tmp"

if [ ! -f $COUNTER_FILE ]; then
    count=0
else
    count=`cat $COUNTER_FILE`
fi
next=$(expr $count + 1)


echo $next >$COUNTER_FILE
echo -n  $next

