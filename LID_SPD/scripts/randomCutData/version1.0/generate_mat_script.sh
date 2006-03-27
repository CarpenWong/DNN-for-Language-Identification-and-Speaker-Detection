#!/bin/bash
home_path=/home/wzj/LID
versionum=version1.0
current_path=$home_path/scripts/randomCutData/$versionum
data_path=$home_path/Data
data_head_path=$data_path/DataHead/$versionum

cv_percentage=0.05
test_percentage=0.15

rm -rf $current_path/matscripts $current_path/seg
mkdir -p $current_path/matscripts $current_path/seg

if test $# == 3; then
	for arg in $@
	do
		echo "fid=fopen('$current_path/seg/$arg.seg','w');"  >> $current_path/matscripts/$arg.m
		while read line
		do
			number=`ls $data_path/$arg/Wavform/${line}* | wc -w`;
			echo "x=randperm($number)"     >>   $current_path/matscripts/$arg.m
			echo "%fprintf(fid,'${line} of ${arg} picks up cv data sequence : ');"   >>   $current_path/matscripts/$arg.m
			echo "for i = 1:1:ceil($number*${cv_percentage})"    >>   $current_path/matscripts/$arg.m
			echo "    fprintf(fid,'%d ',x(i));"    >> $current_path/matscripts/$arg.m
			echo "end"                     >> $current_path/matscripts/$arg.m
			echo "fprintf(fid,'\n');"  >> $current_path/matscripts/$arg.m
			echo ""   >>  $current_path/matscripts/$arg.m

			echo "%fprintf(fid,'$line of ${arg}  picks up test data sequence : ');"   >>   $current_path/matscripts/$arg.m
			echo "for i = ceil($number*${cv_percentage})+1:1:ceil($number*${test_percentage})+ceil($number*${cv_percentage})"    >>   $current_path/matscripts/$arg.m
			echo "    fprintf(fid,'%d ',x(i));"    >> $current_path/matscripts/$arg.m
			echo "end"                     >> $current_path/matscripts/$arg.m
			echo "fprintf(fid,'\n');"  >> $current_path/matscripts/$arg.m
			echo ""   >>  $current_path/matscripts/$arg.m
		done < $data_head_path/$arg/$arg.hd
		echo "fclose(fid);"         >>  $current_path/matscripts/$arg.m
		echo "quit;"         >>  $current_path/matscripts/$arg.m
	done
else
	echo "Usage: command English NorthMandarin Uighur"
fi
