#!/bin/bash
count=20
mfcc_type=a
ark_type=copy_feats

rm -rf ${mfcc_type}_mfcc_${ark_type}_sdc.ark

for((i=1;i<=$count;i++))
do
	cat ${mfcc_type}_mfcc_${ark_type}_sdc_${i}.ark >> ${mfcc_type}_mfcc_${ark_type}_sdc.ark
done
