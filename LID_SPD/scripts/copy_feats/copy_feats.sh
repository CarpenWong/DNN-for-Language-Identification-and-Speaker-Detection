#!/bin/bash
current_command_name=copy_feats
scp_path=/home/wzj/LID/scp
ark_path=/home/wzj/LID/ark
log_path=/home/wzj/LID/log

copy_feats_path=/home/wzj/LID/scripts/copy_feats
mfcc_config_type=(a b)

rm -rf $scp_path/${current_command_name} $ark_path/${current_command_name} $log_path/${current_command_name}
mkdir -p $scp_path/${current_command_name} $ark_path/${current_command_name} $log_path/${current_command_name}

for mfcc_type in ${mfcc_config_type[@]};
do
	copy-feats --htk-in scp:"${scp_path}/original/${mfcc_type}_original_mfcc.scp" "ark,t,scp:$ark_path/${current_command_name}/${mfcc_type}_mfcc_${current_command_name}.ark,$scp_path/${current_command_name}/${mfcc_type}_mfcc_${current_command_name}.scp" > ${log_path}/${current_command_name}/${mfcc_type}_${current_command_name}.log 2>&1
done
