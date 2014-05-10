#! /bin/bash

echo "Backing Log Files."


##  /bin/bash /mnt/backup_log_files.sh

##------- define constants ---------##
path="/var/log"
bkpPath="/mnt/poolAux/logs"
size="+1M"
Now=$(date +"%Y%m%d-%H%M")



pathVerifier () {

  ## -- Verify a full path for a file and create it if that not exist (with all required subfolders )----##
  ## -- examples  pathVerifier "/NewFolder/folderA/a.txt" "/var" -->  create route /var/NewFolder/folderA

   string=`echo $1`
  #string=${string#"/"}

   arrStrings=`echo $string | tr "/" " "`
   arrStrings=(`echo $arrStrings`)
   arrLength=${#arrStrings[@]}
  #echo $arrLength
  #echo $string

   newString=''
   for (( i=0; i<${arrLength}-1; i++));
     do
      newString=${newString}"/"${arrStrings[$i]}
     done
   fullNewPath=${2}${newString}
   #echo ${fullNewPath}

   if [ ! -d ${fullNewPath} ] ; then
   mkdir -p ${fullNewPath}
   echo "path created : "${fullNewPath}
   fi
   }




echo $path
echo $size
echo ""

files=`find $path/* -name '*' -size $size`
files=`echo  $files |  tr ' ' '\n' | sed -e 's/\/var\/log//g'`
files=(`echo $files`)
filesLength=${#files[@]}

#echo $files
#echo ${files[0]}
#echo "Length :" ${#files[@]}
echo "All elemnts :" ${files[@]}
echo ${filesLength}

for (( ii=0; ii<${filesLength}; ii++ ));
do
  echo ${files[$ii]}
  pathVerifier ${files[$ii]} ${bkpPath}
  cp  $path${files[$ii]} $bkpPath${files[$ii]}'_'$Now
  echo "" > $path${files[$ii]}
done
