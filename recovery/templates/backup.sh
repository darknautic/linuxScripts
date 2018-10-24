#! /bin/bash


log_msg () {
	echo "INFO - "`date '+%m/%d/%y %H:%M:%S'`" - REMOTE - " $*
	return 0
}

debug (){	
	log_msg $*
	return 0
}


error (){
	echo "ERROR - "`date '+%m/%d/%y %H:%M:%S'`" - " $*
	return 0
}


echo -e "\n"
debug  "Hostname :"`hostname`
debug  "SHELL :"`echo $SHELL`
debug  "Executed from (pwd) :"`pwd`
debug  "PID:["$$"]"
debug  "Command:["$0"]" "options:["$@"]"
