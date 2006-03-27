#!/bin/bash
# all paths must be absolute, and please execute this script on the directory $(tools)

work_path=/home/wzj/LID
versionum=spd
 
#mfcc_type=a
mfcc_type=b
log_path=$work_path/log/$versionum
scp_path=$work_path/scp/$versionum
label_path=$work_path/label/$versionum

train_scp=$scp_path/train/${mfcc_type}/${mfcc_type}_mfcc_train.scp
cv_scp=$scp_path/cv/${mfcc_type}/cv.scp
train_label=$label_path/train/${mfcc_type}/frame_train.lab
cv_label=$label_path/cv/${mfcc_type}/cv.lab
tools=$work_path/DBN_DNN
dbn_dir=$work_path/gen/$versionum/$mfcc_type/dbn
mlp_dir=$work_path/gen/$versionum/$mfcc_type/mlp
label_num=30
log_dir=$log_path/$mfcc_type/DBN_DNN

rm -rf $log_dir $dbn_dir $mlp_dir
mkdir -p $log_dir $dbn_dir $mlp_dir

#train_scp=feats_train_n3_noise.scp
#cv_scp=feats_cv_train_n3_noise.scp
#train_label=train_n3_clean_ali_stat.pdf
#cv_label=cv_n3_clean_ali_stat.pdf
#tools=/home/xxr/DBN_DNN
#dbn_dir=test_dbn
#mlp_dir=test_mlp
#label_num=179
#log_dir=/home/xxr/DBN_DNN



cd ${tools}

bash $tools/dbn_train.sh $dbn_dir $train_scp >& $log_dir/dbn.log

dbn_depth=`cat $dbn_dir/nn_depth`

bash $tools/mlp_train_label.sh \
 --hid-layers 0 \
 --dbn $dbn_dir/$dbn_depth.dbn \
 --feature-transform $dbn_dir/final.feature_transform \
 $mlp_dir $train_scp $cv_scp $train_label $cv_label $label_num >& $log_dir/mlp.log
