#!/bin/bash
MF=(40a 20l 40b 40c 40d 01p 20b 023 027 40m)
file_path=/home/wzj/LID/Data/English/Wavform
i=0
flag=M
for var in ${MF[@]};
do

	find $file_path -name 0_sitrs_${var}*.wav > filelist

	if [[ $var = "01p" || $var = "20b" || $var = "023" || $var = "027" || $var = "40m" ]]; then
		flag=F
	else
		flag=M
	fi

	((i=1))
	while read line
	do
		mv $line $file_path/${flag}${var}_$i.wav
		((i++))
	done < filelist
done
rm -rf filelist
