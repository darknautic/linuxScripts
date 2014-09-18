#! /bin/bash
echo -e "\n scannig network .....\n"
#ping 10.29.214.31 -c 1 -W 1 | grep received | awk '{print $4}' 
#ping 10.29.214.51 -c 1 -W 1 | grep received | awk '{print $4}'

pingFunction()
{
  received=`ping $i  -c 1 -W 1 | grep received | awk '{print $4}'`
  if [ $received -eq 1 ]; then
	#echo $received " >> " $i  
	echo $i
  fi

}


for i in 10.29.214.{1..126} 
do
  pingFunction $i
done

echo -e "\n\n......End"
