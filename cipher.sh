#! /bin/bash

## cipher ##
# Cipher intends to help you to keep your personal information safe by this easy and simple CLI, PI such as passwords, SSN, accounts, and more.
# Run : $ ./cipher.sh
# Feedback  : blue.darknautric@gmail.com @N4ut1c



## Please customize below constants as you require.
plain_file="/mnt/c/Documents and Settings/user/secret.note"
cipher_file="/mnt/c/Documents and Settings/user/secret.note.cipher"



## ---  Functions -------------------

encrypt () {
	openssl aes-256-cbc -a -salt -in "${1}" -out "${2}" -k $3	
}


decrypt () {
	openssl aes-256-cbc -d -a -in "${1}" -out "${2}" -k $3
}


## to obtain word after lookup or l , eg l:X should return X
getWord () {
	word=`echo $1 | sed  's/:/ /g' | awk '{print $2}'`	
	echo $word
}



## Decrypts the secret file in runtime in order to find rows that match with the pattern.
## This function does not write the decrypted file to disk  , it just lives during this execution.
lookup () {
	
	cipherText=`cat "${1}"`
	echo $cipherText | openssl aes-256-cbc -d -a -k $3 | grep -i --color $4
	echo -e "\n"

}

## verify if files exist
file_status () {
	if [[ -f "${plain_file}" ]];then		
		if [[ -f "${cipher_file}" ]];then
			#echo "both file exist";
			echo "both";
		else
			#echo "only plain text file exists";
			echo "plain";
		fi		
	else
		if [[ -f "${cipher_file}" ]];then
			#echo "only cipher text file exists";
			echo "cipher";
		fi 			
	fi
}




while true; do
	
	if [[ -z $CIPHER ]];then
		
		#read -s -p "PassWord ? :"  PassWord ## hide what you type
		read -p "Password ? :"  PassWord  ## display what you type
		echo -e "\n"		
    	if [[ -n $PassWord  ]];then
    		CIPHER=$PassWord    		
    	fi
	fi


	if [[ -n $CIPHER ]];then
		read -p "> " commands
		case "$commands" in			

			lookup:*|l:*)
				word=`getWord $commands`;
				echo "the Pattern : "$word;	
				lookup "${cipher_file}" "${plain_file}" $CIPHER $word;			
				;;

			decrypt|d)
				echo -e "\n (plain) decrypting file ...\n";								
				decrypt "${cipher_file}" "${plain_file}" $CIPHER;
				rm -rf "${cipher_file}";	
				echo -e "\n Ready to be manually edited.";;		

			encrypt|e)
				echo -e "\n (cipher) encrypting file ...\n";		
				encrypt "${plain_file}" "${cipher_file}" $CIPHER;
				rm -rf "${plain_file}";;	

			help|h)
				#echo -e "\n options : encrypt|e  decrypt|d  lookup:[your search]|l:[your search] help|h  bye|exit \n";
				echo -e "\n ---  CLI usage --- \n"
				echo -e " > encrypt (e)   : Encrypt the plain text file defined in \"plain_file\" .\n"
				echo -e " > decrypt (d)   : Decrypt the chiper file defined in \"cipher_file\" , useful for editing whole file.\n" 
				echo -e " > lookup  (l)   : Look your words up in the cipher file without writing plain-text file to disk. "
				echo -e "\t\t Display matching rows.  e.g  lookup:myWord   , it is not case sensitive.\n"	
				echo -e " > help    (h)   : Show this message.\n"
				echo -e " > exit    (q)   : Exit from CLI . Verifies if the file was encrypted again before to leave,"
				echo -e "\t\t that's because the goal is to keep your personal and sensitive information safe.\n"	
				echo ""
				;;			
				
			bye|exit|q)				
				if [[ `file_status` == 'plain' ]];then
					echo -e "\n*** It is recommended to encrypt your file  before to exit. Your personal information is in plain text.\n"					
					read -p " Do you really want exit ? [Y|N] : " want2exit
					if [[ $want2exit == "Y" ]];then 	
						exit 1
					fi
					


				else
					exit 1
				fi
				;;
			*)
				## No command found !!
				;;
		esac	
	fi
	
 done



###### How to install. #######

# 1 ) Get  bash enviroment  and OpenSSL. For instance ( Linux folks : standar terminal , Windows folks : MobaXterm  )
#
# 2 ) In case Linux , install openssl library  according to your platform .
#	 
#     In case of using MobaXterm .
#     apt-cyg show ; apt-cyg find ssl ; apt-cyg install openssl
#
# 3 ) Download this script and give proper permissions.
#     # chmod 700 cipher.sh
# 
# 4 ) Create your plain-text file and set your own values to constants plain_file and cipher_file.
#
# 5 ) $ sh cipher.sh 
#	  Password ? :     <----- Type your password for encrypting and decrypting your file, keep it in your mind and do not forget it.
#							  There is no back without it.
#     >
#     >
#     >
#
# 6 ) Any feedback is welcome , blue.darknautic@gmail.com https://github.com/darknautic
#
# 7 ) Enjoy !!



## Troubleshooting for Devs-----------------------------------


## encrypt
# openssl aes-256-cbc -a -salt -in secrets.txt -out secrets.txt.enc
# openssl aes-256-cbc -a -salt -in secrets.txt -out secrets.txt.enc -k qaz

## decrypt
# openssl aes-256-cbc -d -a -in secrets.txt.enc -out secrets.txt.new
# openssl aes-256-cbc -d -a -in file.txt.enc -out secrets.txt -k qaz

## Workaround for paths with spaces   --- no longer required
# ln -s /mnt/c/Documents\ and\ Settings/esajaus/0/docs/notes/secret.note  secret.note

## Handle paths with spaces 
# secret_file="/mnt/c/Documents and Settings/esajaus/0/docs/notes"
# ls "${secret_file}"


## make available as a command in MobaXterm
# ln -s ~/bin/cipher.sh /bin/cipher


