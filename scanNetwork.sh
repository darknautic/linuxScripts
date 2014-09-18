#! /bin/bash
echo -e "\n scannig network .....\n"

pingFunction()
{
  received=`ping $i  -c 1 -W 1 | grep received | awk '{print $4}'`
  if [ $received -eq 1 ]; then
	#echo $received " >> " $i  
	echo $i
  fi

}


for i in 10.10.127.{1..254} 
do
  pingFunction $i
done

echo -e "\n\n......End"
