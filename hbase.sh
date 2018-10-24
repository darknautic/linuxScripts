#! /bin/bash


##  - notes improvement -
##  include status of hbase loaders (ESR and EDCR)
##   Regions servers in faulty 

# Import Libraries
#----------------------------------------------------------
source /home/user/da/YARNAPPSMonitor/functions.sh
source /home/user/da/monitoringScriptsOps/lib/alv.sh

## Settings
##----------------------------------------------------------
sensorsHome="/home/user/da/YARNAPPSMonitor/sensors"
output=${sensorsHome}"/hbase.output"
tmpFile=${sensorsHome}"/hbase.output.tmp"

SCRIPTSHOME="/home/user/da/monitoringScriptsOps"
hbaseCompation=${SCRIPTSHOME}"/logs/hbase_compaction.output" #; echo -n "" > ${OUTPUT}
hbaseSplit=${SCRIPTSHOME}"/logs/hbase_split.output"  #; echo -n "" > ${OUTPUT2}
#outputPrevious=${sensorsHome}"/maprAlarms.output.previous"
#maprAlarmReport="python /home/user/da/YARNAPPSMonitor/sensors/maprAlarms.py --report"

#----------------------------------------------------------




##  Functions
## -------------------------------------------------------
networkAvailability(){
srv="${1}"
count=$(ssh -q  root@servera200 "ping -c3  "${srv}" | grep received " | awk '{print $4}')

if [[ $count -eq 3 ]];then
	echo ${srv}" : OK"
else 
	echo ${srv}" : NOK"
	emailNotification=1
	alarm.new "YARNAPPS" "HBase Connectivity Issue to ${srv}" "Connectivity to ${srv} is failing. (ping test)." "Critical" "Shehzad"
fi
}



## Main #####################
## -----------------------------------------------------------
currentTS=$(date +%s)
emailNotification=0
waitProcesses=0


if [ $(date +%M) -lt 3 ];then
	waitProcesses=1;
	output=${sensorsHome}"/hbase.output2"
fi

echo -n "" > ${output}

## copy library for jmx calls
lib_exists=$(ssh root@servere004 " if [ -e /tmp/jmxterm-1.0-alpha-4-uber.jar ];then echo "YES" ; else echo "NO" ; fi ")
if [ ${lib_exists} == "NO" ];then
	scp /home/user/da/monitoringScriptsOps/lib/jmxterm-1.0-alpha-4-uber.jar  root@servere004:/tmp
fi 


## Getting the master 
M204=$(ssh root@servere004 "echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.isActiveMaster | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url servera204-ds:10101 -v silent -n ")
M205=$(ssh root@servere004 "echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.isActiveMaster | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url servera205-ds:10101 -v silent -n ")
M206=$(ssh root@servere004 "echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.isActiveMaster | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url servera206-ds:10101 -v silent -n ")
HMASTER=""

if [ ${M204} = "true" ];then 
	HMASTER="servera204-ds"
elif [ ${M205} = "true" ]; then
	HMASTER="servera205-ds"
elif [ ${M206} == "true"]; then
	HMASTER="servera205-ds"
else
	echo "ERROR - getting master hostname from JMX call "  >> ${output}
	emailNotification=1
	alarm.new "YARNAPPS" "HBase Monitoring Script Error" "Monitoring JMX call error when trying to get master server." "High" "Sajid"
fi


#ssh -qt root@servera200 ssh -q zookeeper.analytics "uname -n"
# /opt/mapr/zookeeper/zookeeper-3.4.5/bin/zkCli.sh -server 127.0.0.1:5181

## getMaster 
#get /hbase/master



## New records in HBase
#==================================
hbaseInserts=$(ssh root@servera200 "docker exec redis0 /opt/redis/bin/redis-cli -c -h servera200-ds -p 7000 hmget edcr-hbase-loader-suite:edcr-hbase-loader:Statistics processedEventCounter:SumStrategy")
# above command depends on crontab job as WA /root/runforrest/hbase_loading_monitor_check.sh  in servera200 hbase connection to redis.

insertsTS=$(echo $hbaseInserts | awk -F":" '{print $1}')
insertsTS=${insertsTS::(-3)}
insertsCount=$(echo $hbaseInserts | awk -F":" '{print $2}')

deltaTS=$(echo ""$currentTS" "$insertsTS"" | awk '{delta=($1 - $2)/60;printf("%.1f",delta)}' )


if [[ $deltaTS > 6 ]]; then
	echo "Critical - No new records in the last 5 minutes. "  >> ${output}
	emailNotification=1 #### 1
	######################
	alarm.new "YARNAPPS" "HBase EDCR Loader Delay" "HBase EDCR loader ( edcr-hbase-loader ) has delayed more than 5 minutes to insert new data." "Medium" "Shehzad"
fi

#insertsCount=0
if [[ $insertsCount -le 0 ]]; then
	echo "Critical - No records to be inserted. "  >> ${output}
	emailNotification=1
	alarm.new "YARNAPPS" "HBase EDCR Loader No Records" "HBase EDCR loader ( edcr-hbase-loader ) has not received new data to inserts into DB." "Critical" "Shehzad"
fi



#HBase Version and Status 
version=$(ssh -q root@servera200 "curl --silent http://rest.hbase.analytics:28080/version/cluster")
status=$(ssh -q root@servera200 "curl --silent  http://rest.hbase.analytics:28080/status/cluster" | head -1 )
#deadSrvrs=$(echo $status | awk '{print $4}')
deadSrvrs=$(ssh root@servere004 " echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.deadRegionServers  | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url ${HMASTER}:10101 -v silent -n " | tr ";" "\n" | awk -F"," '{print $1}' | tr "\n" " ")
#echo $deadSrvrs

#if [[ $deadSrvrs -gt 0 ]];then
if [[ "${deadSrvrs}" != " " ]];then
	emailNotification=1	
    alarm.new "YARNAPPS" "HBase Servers In Troubles" "Hbase  ${deadSrvrs} dead server(s), please check HBase master UI for more details." "Medium" "Kiran"
fi

# curl -s  "http://rest.hbase.analytics:28080/" | egrep "esr|edcr"  
# curl -s -vi -X GET  -H "Accept: text/xml"  "http://rest.hbase.analytics:28080/edcr/schema"




#compactionQueue=$(for regionSrv in $(ssh root@servere004 " echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.liveRegionServers  | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url ${HMASTER}:10101 -v silent -n " | tr ";" "\n" | awk -F"," '{print $1}' | tr "\n" " ") ;do ssh root@servere004 " echo get -s -b Hadoop:service=HBase,name=RegionServer,sub=Server compactionQueueLength | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url ${regionSrv}:10102 -v silent -n " ; done | paste -sd+ - | bc)
compactionQueue=$(cat ${hbaseCompation} | awk -F"," '{print $2}')
if [ ${compactionQueue} -ge 250000 ];then
	emailNotification=1
	echo "Critical - Compaction Queue Length has reached 250000 tasks - (Call MapR Support)" >> ${output} 
	alarm.new "YARNAPPS" "HBase Compaction" "HBase Compaction Queue Length has reached 250000 tasks" "Critical" "Shehzad"
fi

if [[ waitProcesses -eq 1 ]];then 
	#regionCount=$(for regionSrv in $(ssh root@servere004 " echo get -s -b Hadoop:service=HBase,name=Master,sub=Server tag.liveRegionServers  | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url ${HMASTER}:10101 -v silent -n " | tr ";" "\n" | awk -F"," '{print $1}' | tr "\n" " ") ;do ssh root@servere004 " echo get -s -b Hadoop:service=HBase,name=RegionServer,sub=Server regionCount | java -jar /tmp/jmxterm-1.0-alpha-4-uber.jar --url ${regionSrv}:10102 -v silent -n " ; done | paste -sd+ - | bc)
	regionCount=$(cat ${hbaseSplit} | awk -F"," '{print $2}')
	regionCount_pid=$!

	## if delta 15 % notification 1 and echo "more than 15 % t output"

	if [[ $(date +%H) -eq 21 ]];then
		echo -n "" > ${tmpFile}
		echo ${regionCount} > ${tmpFile}
	fi

	if [ -e ${tmpFile} ];then 
		refRegionCount=$(cat ${tmpFile} | tr -d "[[:alpha:]][:space:]:\t\r\n" )
		if [ ${refRegionCount} -gt 0 ];then 
			deltaRegionCount=$(echo "("${regionCount}"-"${refRegionCount}")*100/"${refRegionCount}"" | bc | tr -d "[[:alpha:]][:space:]:\t\r\n" )
			if [[ ${deltaRegionCount} -ge 15 ]];then
				emailNotification=1
				echo "Critical - Region Count Has Increased 15% - (Call MapR Support)" >> ${output} 
				alarm.new "YARNAPPS" "HBase Region Count" "Region Count Has Increased 15% . " "Critical" "Shehzad"
			fi
		fi
	else
		echo -n "" > ${tmpFile}
		echo ${regionCount} > ${tmpFile}
	fi
fi




## Building the Report

echo "HBase Version : "$version  >> ${output} 
echo "Master : "${HMASTER}  >> ${output} 

echo -e "\n<b>Status</b>" >> ${output} 
echo  $status  >> ${output} 

echo -e "\n<b>EDCR HBase Loader</b>" >> ${output} 
echo  "Last load : "$deltaTS" minutes ago"  >> ${output} 
echo  "Records loaded : "$insertsCount   >> ${output} 

echo -e "\n<b>Network Interfaces</b> " >> ${output} 
networkAvailability "servera203-ds"  >> ${output} 
networkAvailability "servera204-ds"  >> ${output} 
networkAvailability "servera205-ds"  >> ${output} 
networkAvailability "rest.hbase.analytics"  >> ${output} 
networkAvailability "node1.rest.hbase.analytics"  >> ${output} 
networkAvailability "node2.rest.hbase.analytics"  >> ${output} 
networkAvailability "node3.rest.hbase.analytics"  >> ${output} 

echo -e "\n<b>Compaction Queue</b>">> ${output} 
echo "compactionQueueLength:  "${compactionQueue} >> ${output} 


if [[ waitProcesses -eq 1 ]];then 
	echo -e "\n<b>Region Count</b>">> ${output} 
	echo "regionCount:  "${regionCount} "  delta : "${deltaRegionCount}" % " >> ${output} 
fi 


## highlight the putput report 
if [[ $deadSrvrs -gt 0 ]];then
	highlight "dead" ${output}
fi


if [ ${compactionQueue} -ge 250000 ];then
	highlight "compactionQueueLength" ${output}
fi



if [[ $emailNotification -eq 1 ]] || [[ waitProcesses -eq 1 ]];then	
	
	#if [ waitProcesses -eq 1 ];then 
	#	wait regionCount_pid
	#fi 

	
	highlight "Critical" ${output}	
	highlight "ERROR" ${output}
	highlight_ok "OK" ${output}
	highlight "NOK" ${output}
	
	if [[ $emailNotification -eq 1 ]];then
		sendMail "hbase."$(date +%s) "HBase Monitoring" " Status : NOK " ${output}
		#echo "send alert-email"
	else
		sendMail "hbase."$(date +%s) "HBase Monitoring" " Status : OK " ${output}
		#echo "send email "
	fi
	
fi

cat ${output}
