#! /bin/bash
##  goal :  a tool which intents to read a big file,  parse  it and extract text
f_in="${1}"
tag_start="${2}"
tag_end="${3}"
f_out="${4}"
flag=0
n=0
line_number=0
echo -n "" > ${f_out}
echo -n "" > ${f_out}".aux"

while read line;
do
 n=$((n+1))
 #if (( ! ( $n % 100 ) ));then echo $n ;fi ## Show progress 

 if [[ $flag -eq 0 && $( echo "${line}" | grep -c "${tag_start}" ) -ge 1 ]];then
	flag=1
	line_number=$n
  fi

  if [[ $flag -eq 1 ]];then
  	echo "${line}" >> ${f_out}".aux"
  fi

  if [[ $flag -eq 1 && $( echo "${line}" | grep -c "${tag_end}" ) -ge 1 ]] && [[ $line_number != $n ]];then
  	flag=0
  	exit 0
  fi
 done < ${f_in}

cat ${f_out}".aux" | tr "\n" " " | sed "s/></>\n</g" > ${f_out}
rm  ${f_out}".aux"


### --- how to
#  > bash readFile.bash <inputFile> <initialStringPattern> <endStringPattern> <outputFile>
#  > bash readFile.bash "dummy.xml" "<c>" "</c>" "output.xml"
#  > bash readFile.bash "dummy.xml" "<w>" "</w>" "output.xml"
#  > bash readFile.bash "dummy.xml" "<c id=\"xyz\">" "</c>" "output.xml"
#  > bash readFile.bash "dummy.xml" "id=\"xyz\"" "</c>" "output.xml"

### --- demo file
# <a>
#	<b>
#		<c>
#			<z1>sajid</z1>
#			<z2>sajid</z2>
#			<z3>sajid</z3>
#		</c>
#		<c id="xyz">
#			<y1 id="xyz">sajid</y1>
#			<y2>sajid</y2>
#			<y3>
#				<w>austria</w>
#			</y3>
#		</c>
#	</b>
# </a>
