#! /bin/bash

smbConfFile=/usr/local/etc/smb.conf

case "$1" in
 -l)
        echo -e "\nList all Shares :\n";
        grep -e "\[*\]" $smbConfFile | grep -v global ;
        ;;

 -ln)   echo -e "\nList all Shares (print line number)";
        grep -e "\[*\]" $smbConfFile | grep -v global | nl;
        ;;

 -ls)
        echo -e "\nList all Shares (alphabetically sorted) :\n";
        grep -e "\[*\]" $smbConfFile | grep -v global | sort --ignore-case;
        ;;


 -lsn)
        echo -e "\nList all Shares (alphabetically sorted) :\n";
        grep -e "\[*\]" $smbConfFile | grep -v global | sort --ignore-case | nl;
        ;;

 -name)
        #Show all configured attributes for the shared resource

        case "$3" in


        -attr)

                if [ -n $4 ]
                 then
                    sh $0 -name $2 | grep -Ri --color $4
                 else
                    sh $0 -name $2
                fi;

                ;;


        *)
                echo -e "\nShow all configured attributes for the shared resource : \"$2\"\n ";

                upLimit=`grep -Rin -e "\[*\]" $smbConfFile  | tr ":" " " | nl | grep "\["$2"\]" | awk '{print $2}'`;
                lineNumber=`grep -Rin -e "\[*\]" $smbConfFile  | tr ":" " " | nl | grep "\["$2"\]" | awk '{print $1}'`;

                nextLine=`echo $lineNumber+1 | bc`;
                sedOption1=`echo  -e $nextLine"q;d"`;
                lowLimit=`grep -Rin -e "\[*\]" $smbConfFile  | tr ":" " " | nl | sed $sedOption1  | awk '{print $2}'`;
                lowLimit=`echo $lowLimit-1 | bc`;

                sedOption2=`echo $upLimit","$lowLimit"p"`;
                sed -n $sedOption2 $smbConfFile;
                ;;


         esac;
        ;;






 *)
        echo "default";
        ;;
esac
