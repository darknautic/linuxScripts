## CSV
######
find ./  -type f  -print0 | xargs -0 md5sum | awk '{ printf $1","; for (i=2; i <= NF; i++) printf FS$i; print NL}'

find ./  -type f  -print0 | xargs -0 md5sum | awk '{printf  "\"" ;for (i=2; i <= NF; i++) printf $i; printf "\"" FS "," FS "\""$1"\"" ; print NL}'




