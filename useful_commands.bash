# to compare to files regardless the orden ,those tagged with * are missing in file1
while read line ;do if [[ $(grep -cw "${line}" file1) -gt 0 ]]; then echo ${line} ;else echo -e " * "${line} ;fi ; done< file2
