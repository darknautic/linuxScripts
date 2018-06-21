#! /bin/bash

## script name : joins
## darkNautic
##
## options : left, right, outer, join
##

option=$1
file1=$2
file2=$3

if [[ "${option}" == "left" ]];then
  echo "[INFO] - Left Join"
  while read line ;do if [[ $(grep -cw "${line}" ${file2}) -le 0 ]]; then echo ${line} ;fi ; done< ${file1}
elif [[ "${option}" == "right" ]];then
 echo "[INFO] - Right Join"
 while read line ;do if [[ $(grep -cw "${line}" ${file1}) -le 0 ]]; then echo ${line} ;fi ; done< ${file2}
elif [[ "${option}" == "outer" ]];then
 echo "[INFO] - Outer Join"
 while read line ;do if [[ $(grep -cw "${line}" ${file2}) -le 0 ]]; then echo ${line} ;fi ; done< ${file1}
 while read line ;do if [[ $(grep -cw "${line}" ${file1}) -le 0 ]]; then echo ${line} ;fi ; done< ${file2}
elif [[ "${option}" == "join" ]];then
 echo "[INFO] - Simply prints the matchess."
 while read line ;do if [[ $(grep -cw "${line}" ${file2}) -gt 0 ]]; then echo ${line} ;fi ; done< ${file1}
else
 echo "[ERROR] : \"left\" \"right\"  \"outer\"  \"join\" "
fi

#while read line ;do if [[ $(grep -cw "${line}" f1.txt) -gt 0 ]]; then echo ${line} ;else echo -e " * "${line} ;fi ; done< f2.txt

##
##  how to install
#> wget --no-check-certificate  https://raw.githubusercontent.com/darknautic/linuxScripts/master/joins.bash
#> mv joins.bash /bin/joins
#> echo "alias joins=\"bash /bin/joins\"" >> /home/mobaxterm/.bashrc
#> cd /home/mobaxterm/ ; . .bashrc
