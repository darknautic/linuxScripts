#!  /bin/bash

## How to run 
## chmod 774 dnsPerformanceTest.sh
## ./dnsPerformanceTest.sh <file>


fileName=$1
targetName="Name "
targetIP="IP must be got"
dns="IP of Server"
frequency=5

while [ 1 ]
do

    START=$(date +%s.%N)
    result=$(nslookup $targetName  $dns | grep $targetIP | wc -l)
    END=$(date +%s.%N)
    executionTime=$(echo "$END - $START" | bc)


    if [ $result -eq 1 ]
    then
        echo -e "Ok,"$executionTime >> $fileName
        echo -e "Ok,"$executionTime
    else
        echo -e "TimeOut,"$executionTime >> $fileName
        echo -e "TimeOut,"$executionTime
    fi


    sleep frequency
done
