#!/bin/bash
current_command_name=HCopy
data_path=/home/wzj/LID/Data
mfc_path=/home/wzj/LID/mfc
config_path=/home/wzj/LID/config
log_path=/home/wzj/LID/log

mfcc_config_type=(a b)

rm -rf $log_path/$current_command_name
mkdir $log_path/$current_command_name
rm -rf $mfc_path

if test $# == 3; then
	for mfcc_type in ${mfcc_config_type[@]};
	do

		for arg in $@
		do
		find $data_path/$arg/Wavform -name *.wav > filelist_$arg
		mkdir -p $mfc_path/$arg/${mfcc_type}_mfcc_original

		while read line
			do
			filename=`basename $line .wav`
			HCopy -A -D -V -T 1 -C ${config_path}/${mfcc_type}_config-mfc $line $mfc_path/$arg/${mfcc_type}_mfcc_original/$filename.mfc >> ${log_path}/${current_command_name}/${current_command_name}_${mfcc_type}_mfcc.log 2>&1
			done < filelist_$arg
		rm -rf filelist_$arg
		done
	done
else
	echo "There is not enough parameters."
fi
