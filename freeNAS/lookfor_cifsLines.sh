#! /bin/bash

down=`echo $1-$2 | bc`
down=$1 #beging
up=`echo $1+$2 | bc`
#echo $down
#echo $up
options=`echo $down","$up"p"`
#echo $options
sed -n $options /usr/local/etc/smb.conf
