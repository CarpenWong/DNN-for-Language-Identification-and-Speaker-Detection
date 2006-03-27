#!/bin/bash
home_path=/home/wzj/LID
versionum=version1.0
current_path=$home_path/scripts/randomCutData/$versionum

#for a mfcc type
#mfcc_type=a
#scp_type=copy_feats

#for b mfcc type
mfcc_type=b
scp_type=apply_cmvn

scp_path=$home_path/scp
cv_scp_path=$scp_path/$versionum/cv/$mfcc_type
test_scp_path=$scp_path/$versionum/test/$mfcc_type
train_scp_path=$scp_path/$versionum/train/$mfcc_type

label_path=$home_path/label
cv_label_path=$label_path/$versionum/cv/$mfcc_type
test_label_path=$label_path/$versionum/test/$mfcc_type
train_label_path=$label_path/$versionum/train/$mfcc_type

data_path=$home_path/Data
data_head_path=$data_path/DataHead/$versionum

i=0
head_count=0
segflag=0

rm -rf $cv_scp_path $test_scp_path $train_scp_path $cv_label_path $test_label_path $train_label_path
mkdir -p $cv_scp_path $test_scp_path $train_scp_path $cv_label_path $test_label_path $train_label_path
cp $scp_path/${scp_type}/${mfcc_type}_mfcc_${scp_type}.scp $train_scp_path/${mfcc_type}_mfcc_train.scp
cp $label_path/frame/frame.lab $train_label_path/frame_train.lab

if test $# == 3; then
	for arg in $@
	do
		rm -rf $current_path/tmp/$arg
		mkdir -p $current_path/tmp/$arg

		ls $data_path/$arg/Wavform/* > $current_path/tmp/$arg/_$arg.tmp #list all file for each language
		((i=1))
		while read _tmpline
		do
			echo "`basename $_tmpline` $((i++))" >> $current_path/tmp/$arg/$arg.tmp
		done < $current_path/tmp/$arg/_$arg.tmp
		rm -rf $current_path/tmp/$arg/_$arg.tmp

		((head_count=1))
		while read headline
		do
			ls $data_path/$arg/Wavform/${headline}* > $current_path/tmp/$arg/${headline}.tmp # list files for each person on the same language
			((i=1))
			while read tmpline
			do
				echo "$((i++)) `basename $tmpline`" >> $current_path/tmp/$arg/${headline}_to_order.tmp  #fine the map between each person and his vocie file
			done < $current_path/tmp/$arg/${headline}.tmp
			rm -rf $current_path/tmp/$arg/${headline}.tmp
			
			((segflag=1))
			sed -n ''$((head_count++)),$head_count'p' $current_path/seg/$arg.seg | while read segline
			do
				case $((segflag++ % 2)) in
					0)
						for segword in $segline
						do
							echo $segword >> $current_path/tmp/$arg/${headline}.testnum
						done
					;;
					1)
						for segword in $segline
						do
							echo $segword >> $current_path/tmp/$arg/${headline}.cvnum
						done
					;;
				esac
			done
##########################################################################################################
			while read testnumberline
			do
				awk '$1 ~ /^'$testnumberline'$/ {print $2 >> "'$current_path/tmp/$arg/${headline}.testfile'"}' $current_path/tmp/$arg/${headline}_to_order.tmp
			done < $current_path/tmp/$arg/${headline}.testnum

			while read cvnumberline
			do
				awk '$1 ~ /^'$cvnumberline'$/ {print $2 >> "'$current_path/tmp/$arg/${headline}.cvfile'"}' $current_path/tmp/$arg/${headline}_to_order.tmp
			done < $current_path/tmp/$arg/${headline}.cvnum

##########################################################################################################
			while read testfileline
			do
				_testfileline=`basename $testfileline .wav`
				awk '$1 ~ /'$_testfileline'\.wav/ {print $2 >> "'$current_path/tmp/$arg/${arg}.tdata'"}' $current_path/tmp/$arg/${arg}.tmp
			done < $current_path/tmp/$arg/${headline}.testfile

			while read cvfileline
			do
				_cvfileline=`basename $cvfileline .wav`
				awk '$1 ~ /'$_cvfileline'\.wav/ {print $2 >> "'$current_path/tmp/$arg/${arg}.cvdata'"}' $current_path/tmp/$arg/${arg}.tmp
			done < $current_path/tmp/$arg/${headline}.cvfile
##########################################################################################################
		done < $data_head_path/$arg/$arg.hd # this file includes each person's name for the same language

########this is for mfcc a-type
		while read languageline  #for scp and label
		do
			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$test_scp_path/test.scp'"}' $scp_path/${scp_type}/${mfcc_type}_mfcc_${scp_type}.scp
			sed '/^'${languageline}_${arg}'/'d $train_scp_path/${mfcc_type}_mfcc_train.scp > $train_scp_path/${mfcc_type}_mfcc_train_tmp.scp
			rm -rf $train_scp_path/${mfcc_type}_mfcc_train.scp
			mv $train_scp_path/${mfcc_type}_mfcc_train_tmp.scp $train_scp_path/${mfcc_type}_mfcc_train.scp

			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$test_label_path/test.lab'"}' $label_path/frame/frame.lab
			sed '/^'${languageline}_${arg}'/'d $train_label_path/frame_train.lab > $train_label_path/frame_train_tmp.lab
			rm -rf $train_label_path/frame_train.lab
			mv $train_label_path/frame_train_tmp.lab $train_label_path/frame_train.lab
		done < $current_path/tmp/$arg/${arg}.tdata

		while read languageline
		do
			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$cv_scp_path/cv.scp'"}' $scp_path/${scp_type}/${mfcc_type}_mfcc_${scp_type}.scp
			sed '/^'${languageline}_${arg}'/'d $train_scp_path/${mfcc_type}_mfcc_train.scp > $train_scp_path/${mfcc_type}_mfcc_train_tmp.scp
			rm -rf $train_scp_path/${mfcc_type}_mfcc_train.scp
			mv $train_scp_path/${mfcc_type}_mfcc_train_tmp.scp $train_scp_path/${mfcc_type}_mfcc_train.scp

			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$cv_label_path/cv.lab'"}' $label_path/frame/frame.lab
			sed '/^'${languageline}_${arg}'/'d $train_label_path/frame_train.lab > $train_label_path/frame_train_tmp.lab
			rm -rf $train_label_path/frame_train.lab
			mv $train_label_path/frame_train_tmp.lab $train_label_path/frame_train.lab
		done < $current_path/tmp/$arg/${arg}.cvdata

#		cp $label_path/frame/frame.lab $train_label_path/frame_train.lab
#		while read languageline  #for label
#		do
#			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$test_label_path/test.lab'"}' $label_path/frame/frame.lab
#			sed '/'${languageline}_${arg}'/'d $train_label_path/frame_train.lab > $train_label_path/frame_train_tmp.lab
#			rm -rf $train_label_path/frame_train.lab
#			mv $train_label_path/frame_train_tmp.lab $train_label_path/frame_train.lab
#		done < $current_path/tmp/$arg/${arg}.tdata

#		while read languageline
#		do
#			awk '$1 ~ /^'${languageline}_${arg}'$/ {print $0 >> "'$cv_label_path/cv.lab'"}' $label_path/frame/frame.lab
#			sed '/'${languageline}_${arg}'/'d $train_label_path/frame_train.lab > $train_label_path/frame_train_tmp.lab
#			rm -rf $train_label_path/frame_train.lab
#			mv $train_label_path/frame_train_tmp.lab $train_label_path/frame_train.lab
#		done < $current_path/tmp/$arg/${arg}.cvdata

	done
else
	echo "Usage: command English NorthMandarin Uighur"
fi
