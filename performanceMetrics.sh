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
MemFree=`cat /proc/meminfo | grep MemFree  | awk '{print $2}'`
MemTotal=`cat /proc/meminfo | grep MemTotal | awk '{print $2}'`
SwapTotal=`cat /proc/meminfo | grep SwapTotal | awk '{print $2}'`
SwapFree=`cat /proc/meminfo | grep SwapFree | awk '{print $2}'`
#cpuUsage=`top -bn 1  | grep "Cpu(s)" | awk '{print $2 + $3 +  $4 + $6}'`
# 21 comes from number of frames proceced and at the end /20 it's an average
# it's 20 because the first value (firstframe ) it's removed
cpuUsage=`top -bn 21  | grep "Cpu(s)" | awk '{print $2 + $3 +  $4 + $6}' | tail -n +2 |  paste -sd+ | bc | awk '{print $1/20}'`

# ..   add your metrics
# .
#


#############################################################
##                          Functions                     ##


function percentOf () {
        # percentage
        # $1 is what percent of $2 ?
        echo "scale=3;($1/$2)*100" | bc
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
memUsedPercent=`percentOfInv $MemFree $MemTotal`
memFreePercent=`percentOf $MemFree $MemTotal`
swapUsedPercent=`percentOfInv $SwapFree $SwapTotal`





#############################################################
## write  CSV

#echo -e "MemUtil : "$memUsedPercent
#echo -e "MemFreePer: "$memFreePercent

printCSV $timeStamp $memUsedPercent $swapUsedPercent $cpuUsage

