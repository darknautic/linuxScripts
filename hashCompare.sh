  #! /bin/bash

## < hash-function-command > <file> | compare.sh < signature-string-to-compare >
## hash functions :
##     md5sum
##     sha1sum 128,256,512...
##
## HELP :  sha256sum VirtualBox-5.2.12-122591-Win.exe | compare d039d27bd27937db7489dfefc854975573828ee066e37fec908579db37b6c2a0
##

read hashResult
signature=$( echo ${hashResult} | awk '{print $1}' )
fileName=$( echo ${hashResult} | awk '{print $2}' )
signatureCheck=${1}

if [[ "${signature}" == "${signatureCheck}" ]]; then
        flag="OK"
else
        flag="FAIL"
fi



(
echo -e "File Name:\t[ "${fileName}" ]"
echo -e "Signature:\t[ "${signature}" ]"
echo -e "CheckString:\t[ "${signatureCheck}" ]"
echo -e "Result:\t\t[ "${flag}" ]"
)

