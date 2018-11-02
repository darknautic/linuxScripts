#! /bin/bash


echo -e "\nRecovery \n"


RECOVERY_BASE="/home/recovery"
RECOVERY_BIN=$RECOVERY_BASE"/bin"
RECOVERY_TEMPLATES=$RECOVERY_BASE"/templates"
RECOVERY_TMP=$RECOVERY_BASE"/tmp"
LOCAL_LIST=$RECOVERY_TMP"/listOfFiles.txt"
LOCAL_BKP_DIR="/var/opt/vendor/recovery"
REMOTE_DIR_TARGET="/var/opt/vendor/seg/segments/XML"
REMOTE_FILE_PATH="/var/tmp/listOfFiles.txt"
REMOTE_SRV_USER="user"
REMOTE_SRV_IP="127.0.0.1"
REMOTE_BKP_DIR="/var/opt/vendor/recovery"



LS="/usr/xpg4/bin/ls"
SED="/usr/xpg4/bin/sed"
AWK="/usr/xpg4/bin/awk"
TR="/usr/xpg4/bin/tr"
TAR="/usr/sfw/bin/gtar"
LATEBACKLOG=$RECOVERY_BIN"/latelybacklog.sh"
#READ="/usr/bin/read"
BRIGHTLIST="brightList.sh"
DEBUG=0
REC_BACKLOG=""
PATTERN=""
PATTERNS_LIST=""

help () {
cat << EOF
	
	---------------------  HELP ---------------------
	$0  [ OPTIONS ][ ACTIONS ]
  					[-b | -p PATTERN | -r ROP1,ROP2,ROP3... ]

	Recovery  

OPTIONS

	-h --help	Show this help
	-d --debug	Show debug information

ACTIONS

	-b --backlog	Recover the most possible of backlog
	-p --pattern	Recover ROPs which matches pattern 
	-r --rop 		Recover specific  ROP(s)/pattern(s)
	-f --file 		Recover the ROPs listed in a file

PATTERN 
	
	A20100423, A20150417.08, A20100423.2330

USAGE

	$0 -d -b 
	$0 -d -p A20160820
	$0 -d -r A20100423.03,A20150417.03,A20160820.09,A20161119.1230
	$0 -d -f <file_path>



EOF
	return 0
}



log_msg () {
	echo "INFO - "`date '+%m/%d/%y %H:%M:%S'`" - " $*
	return 0
}

debug (){
	if [ $DEBUG == 1 ];then 
		log_msg $*
	fi
	return 0
}

error (){
	echo "ERROR - "`date '+%m/%d/%y %H:%M:%S'`" - " $*
	return 0
}


verify_pattern_format () {
	
	
	if(( ${#1}<9 || ${#1}>14 ));then error "Wrong Format : LENGTH"; exit 1 ; fi	
		
	if [[ ${#1} == 9 ]];then
		if [[ "$1" =~ ^A([[:digit:]]{8})$ ]];then 
			debug "Pattern :"$1" matches 1 day"; 
		else
			error  "Wrong Format : Invalid Character"
			exit 1; 
		fi
	elif [[ ${#1} == 12 ]]; then
		if [[ "$1" =~ ^A([[:digit:]]{8})\.[[:digit:]]{2}$ ]];then 
			debug "Pattern :"$1" matches 1 Hour"; 
		else
			error  "Wrong Format : Invalid Character" 
			exit 1; 
		fi
	elif [[ ${#1} == 14 ]]; then
		if [[ "$1" =~ ^A([[:digit:]]{8})\.[[:digit:]]{4}$ ]];then 
			debug "Pattern :"$1" matches 1 ROP (15 minutes)"; 
		else 
			error  "Wrong Format : Invalid Character" 
			exit 1; 
		fi
	else
		error "Wrong Format - Not Match a day, hour or ROP."
		exit 1
	fi


 return 0
}


split_list_of_patterns (){

		#IFS=',' $READ -r -a PATTERNS_LIST <<< "$PATTERNS_LIST"
		PATTERNS_LIST=($(tr ',' ' ' <<< $1))
		debug "Length :"${#PATTERNS_LIST[@]}
		for ((a_pattern_idx = 0; a_pattern_idx < ${#PATTERNS_LIST[@]}; a_pattern_idx++));
		do
			echo $a_pattern_idx"-"${PATTERNS_LIST[$a_pattern_idx]}
			verify_pattern_format "${PATTERNS_LIST[$a_pattern_idx]}"
		done
		return 0
}


brightListing (){

debug "Generating brightList from template."
$SED -e 's/{REMOTE_DIR_TARGET}/'$(echo $REMOTE_DIR_TARGET | $SED 's/\//\\\//g')'/' -e 's/{REMOTE_FILE_PATH}/'$(echo $REMOTE_FILE_PATH | $SED 's/\//\\\//g')'/' $RECOVERY_TEMPLATES"/"$BRIGHTLIST > $RECOVERY_BIN"/"$BRIGHTLIST

debug "Sending brightList task to remote server...\n"
ssh -q ${REMOTE_SRV_USER}@${REMOTE_SRV_IP} < ${RECOVERY_BIN}"/"${BRIGHTLIST}
echo -e "\n"

 return 0
}



build_bkp_script (){

#echo "#! /bin/bash" > ${RECOVERY_TMP}"/backup.sh"
cat ${RECOVERY_TEMPLATES}"/backup.sh" > ${RECOVERY_TMP}"/backup.sh"

for ((list_index=0;list_index<${#PATTERNS_LIST[@]};list_index++));
do
	# making backup directories	 
	echo "mkdir -p "${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$list_index]} >> ${RECOVERY_TMP}"/backup.sh"
	echo "debug \"Backup directory ${PATTERNS_LIST[$list_index]} was created.\"" >> ${RECOVERY_TMP}"/backup.sh"
	debug "BUILD : cmd-mkdir  ${REMOTE_BKP_DIR}/${PATTERNS_LIST[$list_index]}"

	# fetching list of files
	matchedFiles=($(grep ${PATTERNS_LIST[$list_index]} ${LOCAL_LIST}))
	debug "BUILD : Number of Files Found for Pattern "${PATTERNS_LIST[$list_index]}" : "${#matchedFiles[@]}
	
	# making cmd for exact/accurate copy ( to avoid any other search under target directory )
	for ((file_idx=0;file_idx<${#matchedFiles[@]};file_idx++));
	do
		echo "cp "${matchedFiles[$file_idx]} ${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$list_index]}"/" >> ${RECOVERY_TMP}"/backup.sh"
 	done
 	echo "debug \"Copy of ${PATTERNS_LIST[$list_index]} files is completed.\"" >> ${RECOVERY_TMP}"/backup.sh"
 	
 	# making cmd for tar.gz : tar -cvEzf  == verbose mode
 	echo $TAR" -czf "${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$list_index]}".tar.gz  -C "${REMOTE_BKP_DIR}" "${PATTERNS_LIST[$list_index]}"" >> ${RECOVERY_TMP}"/backup.sh"
	echo "debug \"Archive and compress for  ${PATTERNS_LIST[$list_index]} files is completed.\"" >> ${RECOVERY_TMP}"/backup.sh"

	echo "rm -rf "${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$list_index]}	>> ${RECOVERY_TMP}"/backup.sh"

done

debug "BUILD : backup-script is completed : " ${RECOVERY_TMP}"/backup.sh"

return 0	
}

filesystem_check (){
	avail_space=`df -k ${LOCAL_BKP_DIR} | awk '{print $4}' | tail -1`
	avail_space=$(echo $avail_space/1024*0.7 | bc | awk -F. '{print $1 }')
	required_space=$(echo $1*800 | bc)

	echo "avail_space: "$avail_space
	echo "required_space: "$required_space

	
	if [ $required_space -gt $avail_space ]
		then 
		echo $required_space "-" $avail_space;
		debug "There is NOT enough space available in /var/opt/vendor";
		exit 0;
	else 
		debug "Enough space available in /var/opt/vendor"
	fi

}


## --- MAIN  ---


while getopts "hdr:p:f:b" option
do
	case $option in
		
		h ) help
			exit 0
			;;

		d ) DEBUG=1
			;;

		b ) REC_BACKLOG=1
			PATTERN=""
			PATTERNS_LIST=()
			debug "ACTION : Recover the most possible of backlog"
						
			#hours=`echo $hours | $TR " " ","`
			#echo $hours
			#PATTERNS_LIST=${hours}
			#debug "backlog )))))))))))))))"${PATTERNS_LIST}"*****"
			#split_list_of_patterns "${PATTERNS_LIST}"
			#debug "backlog )))))))))))))))"${PATTERNS_LIST}"*****"
			#PATTERNS_LIST=()
			;;

		p ) PATTERN=${OPTARG}
			REC_BACKLOG=""
			PATTERNS_LIST=()
			#debug "ACTION : Recover pattern "${PATTERN}
			;;

		r ) PATTERNS_LIST=${OPTARG}
			REC_BACKLOG=""
			PATTERN=""
			#debug "ACTION : Recover list of ROP(s) "${PATTERNS_LIST}
			;;

		f )	varr=${OPTARG}
			echo "varr:"$varr
			debug "ACTION : Recover pattern "${PATTERN}
			#REC_BACKLOG=1
			#PATTERN=""
			PATTERNS_LIST=()
			debug "Taking ROPS from a file"
			;;

    	\? )
      		echo "Invalid Option: $OPTARG" >&2
      		exit 1
      		;;

      	: )
      		echo "Option -$OPTARG requires an argument." >&2
      		exit 1
      		;;
    	
	esac
done
shift $((OPTIND-1))



if [[ -z "${PATTERN}" && -z "${PATTERNS_LIST}" && -z "${REC_BACKLOG}" ]];
	then 
		help
		exit 1;
	
	elif [[ -n "${PATTERN}" ]];
		then
		debug "Pattern: ${PATTERN}"		
		verify_pattern_format "${PATTERN}"
		PATTERNS_LIST=${PATTERN}		

	elif [[ -n "${PATTERNS_LIST}" ]];
		then
		debug "List of Patterns: ${PATTERNS_LIST}"
		split_list_of_patterns "${PATTERNS_LIST}"
		debug "Array Pattern Length :"${#PATTERNS_LIST[@]}
		
	elif [[ -n "${REC_BACKLOG}" ]];
		then
		echo REC_BACKLOG: "${REC_BACKLOG}"
		hours=`ssh -q perfUser@perfsysservice ". /perfsys/home/perfUser/.profile; echo -e \"select B from (select count(*) as A,'A'+dateformat(DATETIME_ID,'yyyymmdd.hh:mm') as B from DC_E_ERBS_EUTRANCELLFDD_RAW where DATETIME_ID between dateadd(hh,-12,getdate()) AND getdate() and DATETIME_ID < dateadd(hh,-3,getdate()) group by DATETIME_ID ) x where A < 36000 order by B ASC \ngo \nexit\" | iqisql -Udc  -Pdc -Sdwhdb  | sed '1,2d'  | sed '$ d' | sed '$ d' | sed 's/://g' "`
		hours=`echo $hours| $TR " " ","`
		echo "hours :"$hours
		echo "array :"${arrHours}
		split_list_of_patterns ${hours}
		debug "Array Pattern Length :"${#PATTERNS_LIST[@]}
		debug "List of Patterns: ${PATTERNS_LIST}"
		#PATTERNS_LIST=() # to test 

	else
		error "Incorrect Options/Actions."
		exit 1;
fi

if [[ ${#PATTERNS_LIST[@]} > 0 ]]; then

#recover statements-------------------------------------------

# Check FS utilization 
filesystem_check ${#PATTERNS_LIST[@]}


#Remove one day old files in /perfsys/archive/double and Failed
debug "Remove files older than 6 hours in /perfsys/archive/double and /perfsys/archive/double/failed"

ssh -q perfUser@perfsysservice  "find /perfsys/archive/perfsys_ems_5/lterbs/double/ -type f -mtime +.25 -exec rm {} \;"
ssh -q perfUser@perfsysservice  "find /perfsys/archive/perfsys_ems_5/lterbs/failed/ -type f -mtime +.25 -exec rm {} \;"

# removing proviuos file (cache) ## think how to reuse it .
>${LOCAL_LIST}
# creating the list.
brightListing



# Retrieving list from remote server.
debug "Retrieving file "${REMOTE_FILE_PATH} " from remote server... \n"
scp ${REMOTE_SRV_USER}@${REMOTE_SRV_IP}:${REMOTE_FILE_PATH}  ${LOCAL_LIST}
echo -e "\n"
debug "Creating local file "${LOCAL_LIST}
debug "Removing file "${REMOTE_FILE_PATH}" from remote server... \n"
ssh -q ${REMOTE_SRV_USER}@${REMOTE_SRV_IP} << EOF
rm -rf  ${REMOTE_FILE_PATH}
EOF


# auto-generated backup-script
build_bkp_script 


debug "Sending backup task to remote server ...";echo ""
ssh -q ${REMOTE_SRV_USER}@${REMOTE_SRV_IP} < ${RECOVERY_TMP}"/backup.sh"
debug "Backup task was completed in remote server."



##  bring compressed files and remove them from remote server.
for ((scp_idx=0; scp_idx < ${#PATTERNS_LIST[@]}; scp_idx ++));
do
	#echo ${PATTERNS_LIST[$scp_idx]}
	scp ${REMOTE_SRV_USER}@${REMOTE_SRV_IP}:${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$scp_idx]}".tar.gz" ${LOCAL_BKP_DIR}	
	ssh -q ${REMOTE_SRV_USER}@${REMOTE_SRV_IP} << EOF
rm -rf ${REMOTE_BKP_DIR}"/"${PATTERNS_LIST[$scp_idx]}".tar.gz"
EOF
	
	#( cd /srv/local/store/ ; tar xzvf - ) < /srv/local/store/A20160417.tar.gz
	(cd ${LOCAL_BKP_DIR} ; $TAR xzf -) < ${LOCAL_BKP_DIR}"/"${PATTERNS_LIST[$scp_idx]}".tar.gz"
	rm -rf ${LOCAL_BKP_DIR}"/"${PATTERNS_LIST[$scp_idx]}".tar.gz"
	debug "# Files stored locally for pattern ${PATTERNS_LIST[$scp_idx]} :"$(ls -1 ${LOCAL_BKP_DIR}"/"${PATTERNS_LIST[$scp_idx]} | wc -l)
	
	ssh -q nmsadm@172.21.116.193 << EOF
$LATEBACKLOG ${PATTERNS_LIST[$scp_idx]} ${PATTERNS_LIST[$scp_idx]} 200
EOF

rm -rf $LOCAL_BKP_DIR"/"${PATTERNS_LIST[$scp_idx]}
	
done


#----------------------------------------------

else
	error "No patterns given to be recovered."
	exit 1;
fi







#echo "##############################"
#cat ${RECOVERY_TMP}"/backup.sh"
#echo "##############################"

#cmd : make a folder by every given pattern 
#cmd : create list of copy commands (use grep over ${LOCAL_LIST} ) by every given pattern 
#cmd : debug files found by every given pattern 
#cmd : tar and compress every pattern  folder after copy
# ssh -q  send the whole script to remote server 
# then , bring all compressed files for (());do scp xx xx done
# untar nd uncompres files
# runs roberts's script .





#ssh -q ${REMOTE_SRV_USER}@${REMOTE_SRV_IP} << EOF
#grep ${PATTERN} ${REMOTE_FILE_PATH} | wc -l
#for ((a_idx = 0; a_idx < ${#PATTERNS_LIST[@]}; a_idx++));
#do
	#grep ${PATTERN} ${REMOTE_FILE_PATH} | wc -l
#echo $a_idx"-"${PATTERNS_LIST[$a_idx]}
#done
#echo ${#PATTERNS_LIST[@]}
#for ((i=0;i<10;i++));
#do
#	echo "# "$i
#done

#EOF

debug "Recovery process has finished."
echo -e "\nEND"

exit 0
