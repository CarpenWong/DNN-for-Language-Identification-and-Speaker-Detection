#!/bin/bash
mfc_path=/home/wzj/LID/mfc
scp_path=/home/wzj/LID/scp
mfcc_config=(a b)
i=1

rm -rf ${scp_path}/original
mkdir -p ${scp_path}/original

if test $# == 3; then
	for mfcc_type in ${mfcc_config[@]};
	do
		for arg in $@
		do
			ls $mfc_path/$arg/${mfcc_type}_mfcc_original > tmp
			((i=1))
			rm -rf $arg.scp;
			while read line
			do
				echo $((i++))_$arg $mfc_path/$arg/${mfcc_type}_mfcc_original/$line >> $arg.scp
			done < tmp ;
		rm -rf tmp;
		cat $arg.scp >> ${scp_path}/original/${mfcc_type}_original_mfcc.scp
		rm -rf $arg.scp;
		done
	done
else
echo "There is not enough parameters."
fi
