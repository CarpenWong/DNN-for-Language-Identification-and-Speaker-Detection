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
ark_sdc_each_matrix_out_dir=$ark_matrix_out_dir/ark_sdc_each_matrix
matlab_scripts_dir=$current_path/matlab_scripts
cafs=calc_all_frame_sdc
sdc=sdc
count=20
feature_dim=13

#rm -rf $nid_map_dim_out_dir $dim_out_dir $ark_matrix_out_dir
#mkdir -p $nid_map_dim_out_dir $dim_out_dir $ark_matrix_out_dir

#count=1
#tmpfile=null

#cat $ark_file | sed "s/]//g" > $ark_matrix_out_dir/data_mat.tmp
#while read head body
#do
#	if test `expr match "$head" [0-9]*_[A-Za-z]*` != 0; then
#		if test $count != 1; then
#			echo "$tmpfile $count" >> $nid_map_dim_out_dir/data.itod
#			echo "$count" >> $dim_out_dir/data.dim
#			((count=0))
#			tmpfile=$head
#		else
#			((count=0))
#			tmpfile=$head
#		fi
#	else
#		((++count))
#		echo "$head $body" >> $ark_matrix_out_dir/$tmpfile.mat
#	fi
#done < $ark_matrix_out_dir/data_mat.tmp
#rm -rf $ark_matrix_out_dir/data_mat.tmp

#echo "$tmpfile $count" >> $nid_map_dim_out_dir/data.itod
#echo "$count" >> $dim_out_dir/data.dim
rm -rf $matlab_scripts_dir $ark_sdc_each_matrix_out_dir
mkdir -p $matlab_scripts_dir $ark_sdc_each_matrix_out_dir

#echo "%compute shifted delta cepstra code"						>> $matlab_scripts_dir/compute_sdc_feature.m
#echo "function compute_sdc_feature()"							>> $matlab_scripts_dir/compute_sdc_feature.m
#echo "    calc_all_frame_sdc();"								>> $matlab_scripts_dir/compute_sdc_feature.m
#echo "end"														>> $matlab_scripts_dir/compute_sdc_feature.m
#echo ""															>> $matlab_scripts_dir/compute_sdc_feature.m

for((i=1;i<=$count;i++))
do
	echo "%excute m-script"												>> $matlab_scripts_dir/${sdc}_${i}.m
	echo "calc_all_frame_sdc_${i}();"									>> $matlab_scripts_dir/${sdc}_${i}.m
	echo "quit;"									>> $matlab_scripts_dir/${sdc}_${i}.m
	echo "function calc_all_frame_sdc_${i}()"							>> $matlab_scripts_dir/${cafs}_${i}.m
	echo "    fid=fopen('$ark_sdc_each_matrix_out_dir/${mfcc_type}_mfcc_${ark_type}_sdc_${i}.ark','w');"			>> $matlab_scripts_dir/${cafs}_${i}.m

	while read head body
	do
		echo "    var=textread('$ark_matrix_out_dir/$head.mat');"		>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "    var=sdc(var,0,1,0,$body);"							>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "    fprintf(fid,'%s  [\n','$head');"						>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "    for i=1:1:$body"										>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        fprintf(fid,'  ');"								>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        for j=1:1:$feature_dim"										>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "            fprintf(fid,'%f ',var(i,j));"					>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        end"												>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        if i==$body"										>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "            fprintf(fid,']\n');"							>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        else"												>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "            fprintf(fid,'\n');"							>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "        end"												>> $matlab_scripts_dir/${cafs}_${i}.m
		echo "    end"													>> $matlab_scripts_dir/${cafs}_${i}.m
		echo ""															>> $matlab_scripts_dir/${cafs}_${i}.m
	done < $nid_map_dim_out_dir/data.itod${i}.scp

	echo "fclose(fid);"												>> $matlab_scripts_dir/${cafs}_${i}.m
	echo "end"														>> $matlab_scripts_dir/${cafs}_${i}.m
#	matlab < $matlab_scripts_dir/${sdc}_${i}.m &
done

echo "function [sdc_out_matrix] = sdc(matrix,N,d,P,k)"			>> $matlab_scripts_dir/${sdc}.m
echo "    matrix_head=matrix(1,:);"								>> $matlab_scripts_dir/${sdc}.m
echo "    matrix_tail=matrix(size(matrix,1),:);"				>> $matlab_scripts_dir/${sdc}.m
echo "    matrix_t = cat(1,repmat(matrix_head,d,1),matrix,repmat(matrix_tail,d,1));"				>> $matlab_scripts_dir/${sdc}.m
echo "    for i = 1+d:1:k+d"										>> $matlab_scripts_dir/${sdc}.m
echo "        sdc_out_matrix(i-d,:)=matrix_t(i+d,:) - matrix_t(i-d,:);"		>> $matlab_scripts_dir/${sdc}.m
echo "    end"													>> $matlab_scripts_dir/${sdc}.m
echo "end"														>> $matlab_scripts_dir/${sdc}.m
echo ""															>> $matlab_scripts_dir/${sdc}.m
