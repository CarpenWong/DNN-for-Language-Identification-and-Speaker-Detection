#!/bin/bash

home_path=/home/wzj/LID
current_path=$home_path/SPD
mfcc_type=a    #or b
scp_path=$home_path/scp
original_scp_path=$scp_path/original
label_path=$home_path/label
frame_label_path=$label_path/frame
map_path=$current_path/map
each_data_id_dir=$map_path/each_data_id
person_id_path=$map_path/person_id
spd_label_dir=$label_path/spd

rm -rf $each_data_id_dir $spd_label_dir
mkdir -p $each_data_id_dir $spd_label_dir

while read name id;				\
do			\
	awk '/'$name'/ {print $1 " " '$id' >> "'$each_data_id_dir/data.id'"}' $original_scp_path/${mfcc_type}_original_mfcc.scp;			\
done < $person_id_path/data.pid

while read name id;						\
do			\
	awk 'BEGIN{ORS=""} /^'$name'/ 		\
								{		\
									print $1 >> "'$spd_label_dir/spd.lab'";		\
									for (i=2;i<=NF;i++)			\
									{			\
										print " " '$id' >> "'$spd_label_dir/spd.lab'";			\
									}			\
									print "\n" >> "'$spd_label_dir/spd.lab'";				\
								}' $frame_label_path/frame.lab;					\
done < $each_data_id_dir/data.id
