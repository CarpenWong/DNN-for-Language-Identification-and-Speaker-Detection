#!/bin/bash
current_command_name=apply_cmvn
cmvn_path=/home/wzj/LID/cmvn
scp_path=/home/wzj/LID/scp
ark_path=/home/wzj/LID/ark
log_path=/home/wzj/LID/log

ccs=compute_cmvn_stats
cf=copy_feats
mfcc_type=b

rm -rf $ark_path/${current_command_name} $scp_path/${current_command_name} $log_path/${current_command_name}
mkdir -p $ark_path/${current_command_name} $scp_path/${current_command_name} $log_path/${current_command_name}

apply-cmvn --print-args=false --norm-vars=false "ark:$cmvn_path/${ccs}/${mfcc_type}_mfcc_${ccs}.cmvn" "scp:$scp_path/${cf}/${mfcc_type}_mfcc_${cf}.scp" "ark,t,scp:$ark_path/${current_command_name}/${mfcc_type}_mfcc_${current_command_name}.ark,$scp_path/${current_command_name}/${mfcc_type}_mfcc_${current_command_name}.scp" > $log_path/${current_command_name}/${current_command_name}.log 2>&1
