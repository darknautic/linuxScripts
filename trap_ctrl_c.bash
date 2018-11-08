#! /bin/bash


trap ctrl_c INT

function ctrl_c(){
 echo " Ok,  goodbye !  CTRL+C  trapped   "
 exit 0
}

for ((x = 0 ; x <= 100 ; x++)); do
  echo "Counter: $x"
  sleep 1
done
