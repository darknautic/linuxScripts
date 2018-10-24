#! /bin/bash

#############################################################################
# NAME: brightList.sh
# Description: Get a list of files full path  from a given path
#              without using  find or ls ( with lock option) commands.
#              Lock options such as ls -l .
# Date: May/17/2016
# Version: 1.1
#############################################################################



LS="/usr/xpg4/bin/ls"
SED="/usr/xpg4/bin/sed"
AWK="/usr/xpg4/bin/awk"
#LS="/bin/ls"
#SED="/bin/sed"
#AWK="/bin/awk"


DEBUG=0



help () {
cat << EOF
	
	---------------------  HELP ---------------------
	$0  [options ...] -p /target/path -o /output/list.txt
  		

	Get a list of files from a given path.

	-h --help	Show this help
	-p --path 	Target path to be scanned (required)
	-o --output	Filename to store the list  (required)	
	-d --debug	Show debug information


EOF
	return 0
}




getList(){
	debug "Getting list ..."
	$LS -Rp1 $1 > $2
	debug "List completed and stored in : "$2
	
	debug "Parsing  and Formatting ..."
	#$SED  -e '/\/$/d' -e '/^$/d' -e 's/://g' $2 > $2"aux"
	## correction to only remove ":" from the end of the line for folders , it is usuful when files contain this caracter as part of name 
	$SED  -e '/\/$/d' -e '/^$/d' -e 's/:$//g' $2 > $2"aux"
	debug "Format completed."
	
	debug "Adding path ..."
	rPath=""
	$AWK -v var=$rPath '/^\// {var=$0} !/^\// {print var"/"$0}' $2"aux" > $2
	debug "File is completed and ready."
	
	rm -rf $2"aux"
	debug "Aux file removed."

	return 0
	}

log_msg () {
	echo "INFO - "`date '+%m/%d/%y %H:%M:%S'`" - REMOTE - " $*
	return 0
}

debug (){
	if [ $DEBUG == 1 ];then 
		log_msg $*
	fi
	return 0
}




# Main ---------------------------

echo -e "\n"
debug  "Hostname :"`hostname`
debug  "SHELL :"`echo $SHELL`
debug  "Executed from (pwd) :"`pwd`
debug  "PID:["$$"]"
debug  "Command:["$0"]" "options:["$*"]"
debug  "Path : "${dirTarget}


while getopts "hp:o:d" option
do
	case $option in
		
		h ) help
			exit 0
			;;

		p ) dirTarget=${OPTARG}
			;;
		
		o ) outputFile=${OPTARG}
			;;

		d ) DEBUG=1
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


if [ -z "${dirTarget}" ] || [ -z "${outputFile}" ]; then
    help
    exit 1
fi


# pending trap implementation ..


getList ${dirTarget} ${outputFile}

debug  "Total of files :"`cat ${outputFile} | wc -l`
debug "Finished."

