#!/bin/sh -

TEXT=`kldstat | awk 'BEGIN {print "16i 0";} NR>1 {print toupper($4) "+"} END {print "p"}' | dc`
DATA=`vmstat -m | sed -Ee '1s/.*/0/;s/.* ([0-9]+)K.*/\1+/;$s/$/1024*p/' | dc`
TOTAL=$((DATA + TEXT))

echo TEXT=$TEXT, `echo $TEXT | awk '{print $1/1048576 " MB"}'`
echo DATA=$DATA, `echo $DATA | awk '{print $1/1048576 " MB"}'`
echo TOTAL=$TOTAL, `echo $TOTAL | awk '{print $1/1048576 " MB"}'`
