 #! /bin/bash

##
## This a very simple script to monitor performance metrics of a linux flavor host 
## and write the output to CSV format file. 
##
## Feel free to use, modify and distribute this script as well as request  modify 
## privilege on this repository to improve it and make it more useful and valuable.
## blue.darkNautic@gmail.com



filePath=$HOME/performanceMetrics.csv



##############################################################
##                          Metrics                         ##
timeStamp=`date +%s`

#--- Memory
MemFree=`cat /proc/meminfo | grep MemFree  | awk '{print $2}'`
MemTotal=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
SwapTotal=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
SwapFree=`cat /proc/meminfo | grep SwapFree | awk '{print $2}'`

#--- CPU
#cpuUsage=`top -bn 1  | grep "Cpu(s)" | awk '{print $2 + $3 +  $4 + $6}'`
# 21 comes from number of frames proceced and at the end /20 it's an average
# it's 20 because the first value (firstframe ) it's removed
cpuUsage=`top -bn 21  | grep "Cpu(s)" | awk '{print $2 + $3 +  $4 + $6}' | tail -n +2 |  paste -sd+ | bc | awk '{print $1/20}'`


#--- Interfaces

###  interfaces to be monitored you can get them using :
###  cat /proc/net/dev  | awk '{print $1}' | grep eth
###  ifstat  -ntT  -i eth0,eth1,eth2,eth3 1 7
interfaces="eth0,eth1,eth2,eth3"

eth0_in=`ifstat  -n  -i eth0 5 7 |  tail -n +3 | awk '{print $1}' | paste -sd+ | bc | awk '{print $1/7}'`
eth0_out=`ifstat  -n  -i eth0 5 7 |  tail -n +3 | awk '{print $2}' | paste -sd+ | bc | awk '{print $1/7}'`

eth1_in=`ifstat  -n  -i eth1 5 7 |  tail -n +3 | awk '{print $1}' | paste -sd+ | bc | awk '{print $1/7}'`
eth1_out=`ifstat  -n  -i eth1 5 7 |  tail -n +3 | awk '{print $2}' | paste -sd+ | bc | awk '{print $1/7}'`

eth2_in=`ifstat  -n  -i eth2 5 7 |  tail -n +3 | awk '{print $1}' | paste -sd+ | bc | awk '{print $1/7}'`
eth2_out=`ifstat  -n  -i eth2 5 7 |  tail -n +3 | awk '{print $2}' | paste -sd+ | bc | awk '{print $1/7}'`

eth3_in=`ifstat  -n  -i eth3 5 7 |  tail -n +3 | awk '{print $1}' | paste -sd+ | bc | awk '{print $1/7}'`
eth4_out=`ifstat  -n  -i eth3 5 7 |  tail -n +3 | awk '{print $2}' | paste -sd+ | bc | awk '{print $1/7}'`


# ..   add your metrics
# .
#


#############################################################
##                          Functions                     ##


function sum (){
        local total=0
        for number in "$@"; do
                total=$(bc <<< "scale=2; $total+$number;")
        done
        echo $total
        }


function trim(){
        # with 2 decimals in this number 1234567890123456.123456789 starts to fail
        echo `echo $1 | awk  '{ myTrimNumber = sprintf("%.2f", $1); print myTrimNumber }'`
        }


function percentOf () {
        # percentage
        # $1 is what percent of $2 ?
        echo "scale=2;($1/$2)*100" | bc
        }


function percentOfInv () {
        # remaining percentage
        # 100 -( $1 is what percent of $2 ? )
        echo "100-`percentOf $1 $2`" | bc
        }


function printCSV () {
        #echo $@
        csvLine=""
        for args in $@
        do
                csvLine=$csvLine$args","
        done
        echo $csvLine >> $filePath
        }






##############################################################
##                          Calcs                           ##
memUsedPercent=`trim $(percentOfInv $MemFree $MemTotal)`
memFreePercent=`trim $(percentOf $MemFree $MemTotal)`
swapUsedPercent=`trim $(percentOfInv $SwapFree $SwapTotal)`
totalInterfazIN=`trim $(sum $eth0_in $eth1_in $eth2_in $eth3_in)`
totalInterfazOut=`trim $(sum $eth0_out $eth1_out $eth2_out $eth3_out)`





#############################################################
## write  CSV

#echo -e "MemUtil : "$memUsedPercent
#echo -e "MemFreePer: "$memFreePercent

printCSV $timeStamp $memUsedPercent $swapUsedPercent $cpuUsage $totalInterfazIN $totalInterfazOut

