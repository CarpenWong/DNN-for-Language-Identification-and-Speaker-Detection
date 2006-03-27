#!/bin/bash
home_path=/home/wzj/LID
current_path=$home_path/scripts/shifted_delta_cepstra
ark_path=$home_path/ark
mfcc_type=b
ark_type=apply_cmvn
#mfcc_type=a
#ark_type=copy_feats
ark_file=$ark_path/$ark_type/${mfcc_type}_mfcc_${ark_type}.ark
nid_map_dim_out_dir=$current_path/nid_map_dim
dim_out_dir=$current_path/dim
ark_matrix_out_dir=$current_path/ark_matrix

rm -rf $nid_map_dim_out_dir $dim_out_dir $ark_matrix_out_dir
mkdir -p $nid_map_dim_out_dir $dim_out_dir $ark_matrix_out_dir

count=1
tmpfile=null

cat $ark_file | sed "s/]//g" > $ark_matrix_out_dir/data_mat.tmp
while read head body
do
	if test `expr match "$head" [0-9]*_[A-Za-z]*` != 0; then
		if test $count != 1; then
			echo "$tmpfile $count" >> $nid_map_dim_out_dir/data.itod
			echo "$count" >> $dim_out_dir/data.dim
			((count=0))
			tmpfile=$head
		else
			((count=0))
			tmpfile=$head
		fi
	else
		((++count))
		echo "$head $body" >> $ark_matrix_out_dir/$tmpfile.mat
	fi
done < $ark_matrix_out_dir/data_mat.tmp
rm -rf $ark_matrix_out_dir/data_mat.tmp

echo "$tmpfile $count" >> $nid_map_dim_out_dir/data.itod
echo "$count" >> $dim_out_dir/data.dim
