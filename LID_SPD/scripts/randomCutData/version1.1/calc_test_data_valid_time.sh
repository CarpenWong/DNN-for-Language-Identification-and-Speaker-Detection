#!/bin/bash
home_path=/home/wzj/LID
versionum=version1.1
current_path=$home_path/scripts/randomCutData/$versionum

data_path=$home_path/Data
rm -rf $current_path/matscripts/calc_test_time.m

i=0

if test $# == 3; then
	echo "%calculate valid time of test data"			>>		$current_path/matscripts/calc_test_time.m
	echo "total_time = 0;"								>>		$current_path/matscripts/calc_test_time.m
	for arg in $@
	do

		rm -rf $current_path/tmp/$arg/$arg.map
		ls $data_path/$arg/Wavform/* > $current_path/tmp/$arg/_$arg.tmp #list all file for each language
		((i=1))
		while read _tmpline;				\
		do					\
			echo "$((i++))_$arg $_tmpline" >> $current_path/tmp/$arg/$arg.map;			\
		done < $current_path/tmp/$arg/_$arg.tmp
		rm -rf $current_path/tmp/$arg/_$arg.tmp

		while read numline;					\
		do									\
			awk '/^'${numline}_$arg'/		\
					{			\
						print "fprintf(1,'\''processing '${numline}_$arg'\\n'\'');"  >>  "'$current_path'/matscripts/calc_test_time.m";			\
						printf "[x,fs]=wavread('\''%s'\'');\n",$2    >>   "'$current_path'/matscripts/calc_test_time.m";								\
						print "total_time = total_time + size(x,1)/fs;"     >>      "'$current_path'/matscripts/calc_test_time.m";					\
						print " "     >>     "'$current_path'/matscripts/calc_test_time.m"
					}'					\
					$current_path/tmp/$arg/$arg.map;			\
		done < $current_path/tmp/$arg/$arg.tdata
	done
	echo "fprintf(1,'valid time of test data is: %f\n',total_time);"      >>      $current_path/matscripts/calc_test_time.m
	echo "quit;"     >>    $current_path/matscripts/calc_test_time.m
else
	echo "Usage: command English NorthMandarin Uighur"
fi
