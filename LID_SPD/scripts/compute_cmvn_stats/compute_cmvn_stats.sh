#!/bin/bash
current_command_name=compute_cmvn_stats
scp_path=/home/wzj/LID/scp
cmvn_path=/home/wzj/LID/cmvn
log_path=/home/wzj/LID/log

cp_ft=copy_feats
mfcc_type=b

rm -rf $cmvn_path/${current_command_name} ${log_path}/${current_command_name}
mkdir -p $cmvn_path/${current_command_name} ${log_path}/${current_command_name}

compute-cmvn-stats --binary=false scp:"$scp_path/${cp_ft}/${mfcc_type}_mfcc_${cp_ft}.scp" "ark,t:$cmvn_path/${current_command_name}/${mfcc_type}_mfcc_${current_command_name}.cmvn" > ${log_path}/${current_command_name}/${current_command_name}.log 2>&1
