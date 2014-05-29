#! /bin/bash
df -h | awk '{print  $5 "\t" $6}' | grep -i --color -e "100%" -e "9[5-9]"
