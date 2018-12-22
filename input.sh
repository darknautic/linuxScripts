#! /bin/bash

if [[ $( echo $1 | grep -wE '[0-9]{10}' ) > 0 ]] && [ -n $1 ] ; then 
	echo "Match!!!" 
else 
	echo "Naaa" 
fi
