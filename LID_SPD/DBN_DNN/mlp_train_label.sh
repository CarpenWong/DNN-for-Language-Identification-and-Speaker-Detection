#!/bin/bash

tools=/home/wzj/LID/DBN_DNN

export PATH=${tools}/utils/:$PATH



config=

mlp_init=
feature_transform=

model_size=8000000
hid_layers=1
bn_dim=
hid_dim=128
dbn=

init_opts=

copy_feats=true
delta_order=
splice=3
splice_step=3
feat_type=plain

learn_rate=0.008
train_opts=
train_tool=

use_gpu_id=-2
seed=777



. parse_options.sh || exit 1;


if [ $# != 6 ]; then
   echo "Usage: $0 <mlp_dir> <data_scp> <data_cv_scp> <class> <class_cv> <class_num>"
   echo "main options (for others, see top of script file)"
   echo "  --config <config-file>					# config containing options"
   echo ""
   echo "  --mlp-init <mlp-file>					# MLP initialization"
   echo "  --hid-dim <N>							# dimension of the (additional) hidden layer"
   echo "  --hid-layers <N>							# number of the (additional) hidden layer"
   echo ""
   echo "  --learn-rate <float>						# learning-rate for MLP"
   echo ""
   echo "  --feature-transform <transform-file>		# transform for input"
   echo "  --dbn <dbn-file>							# DBN as initialization"
   echo ""
   echo "  --copy-feats <bool>						# copy features to /tmp, to accelerate training"
   echo "  --splice <N>								# splice +/-N frames of input features"
   exit 1;
fi



dir=$1

data_scp=$2

data_cv_scp=$3

alidir=$4

alidir_cv=$5

num_tgt=$6



labels_tr=ark:${alidir}
labels_cv=ark:${alidir_cv}

mkdir -p $dir/{log,nnet}

cat $data_scp | ${tools}/utils/shuffle_list.pl --srand ${seed:-777} > $dir/train.scp

cp $data_cv_scp $dir/cv.scp

wc -l $dir/train.scp $dir/cv.scp

if [ "$copy_feats" == "true" ]; then
  tmpdir=$(mktemp -d); mv $dir/train.scp $dir/train.scp_non_local
  utils/nnet/copy_feats.sh $dir/train.scp_non_local $tmpdir $dir/train.scp
  trap "echo \"Removing features tmpdir $tmpdir @ $(hostname)\"; rm -r $tmpdir" EXIT
fi

head -n 10000 $dir/train.scp > $dir/train.scp.10k



feats_tr="ark:copy-feats scp:$dir/train.scp ark:- |"
feats_cv="ark:copy-feats scp:$dir/cv.scp ark:- |"



if [ "$delta_order" != "" ]; then
  feats_tr="$feats_tr add-deltas --delta-order=$delta_order ark:- ark:- |"
  feats_cv="$feats_cv add-deltas --delta-order=$delta_order ark:- ark:- |"
  echo "$delta_order" > $dir/delta_order
  echo "add-deltas (delta_order $delta_order)"
fi

echo "Getting feature dim : "

feat_dim=$(feat-to-dim --print-args=false "$feats_tr" -)

echo "Feature dim is : $feat_dim"



if [ ! -z "$feature_transform" ]; then
  echo "Using pre-computed feature-transform : '$feature_transform'"
  tmp=$dir/$(basename $feature_transform) 
  cp $feature_transform $tmp; feature_transform=$tmp
else
  # Generate the splice transform
  echo "Using splice +/- $splice , step $splice_step"
  feature_transform=$dir/tr_splice$splice-$splice_step.nnet
  utils/nnet/gen_splice.py --fea-dim=$feat_dim --splice=$splice --splice-step=$splice_step > $feature_transform

  # Choose further processing of spliced features
  echo "Feature type : $feat_type"
  case $feat_type in
    plain)
    ;;
  esac
  # keep track of feat_type
  echo $feat_type > $dir/feat_type

  # Renormalize the MLP input to zero mean and unit variance
  feature_transform_old=$feature_transform
  feature_transform=${feature_transform%.nnet}_cmvn-g.nnet
  echo "Renormalizing MLP input features into $feature_transform"
  nnet-forward ${use_gpu_id:+ --use-gpu-id=$use_gpu_id} \
    $feature_transform_old "$(echo $feats_tr | sed 's|train.scp|train.scp.10k|')" \
    ark:- 2>$dir/log/nnet-forward-cmvn.log |\
  compute-cmvn-stats ark:- - | cmvn-to-nnet - - |\
  nnet-concat --binary=false $feature_transform_old - $feature_transform
fi

(cd $dir; [ ! -f final.feature_transform ] && ln -s $(basename $feature_transform) final.feature_transform )



if [ ! -z "$mlp_init" ]; then
  echo "Using pre-initalized network $mlp_init";
else
  echo "Getting input/output dims :"
  #initializing the MLP, get the i/o dims...
  #input-dim
  num_fea=$(feat-to-dim "$feats_tr nnet-forward $feature_transform ark:- ark:- |" - )
  { #optioanlly take output dim of DBN
    [ ! -z $dbn ] && num_fea=$(nnet-forward "nnet-concat $feature_transform $dbn -|" "$feats_tr" ark:- | feat-to-dim ark:- -)
    [ -z "$num_fea" ] && echo "Getting nnet input dimension failed!!"
  }

  #run the MLP initializing script
  mlp_init=$dir/nnet.init
  utils/nnet/init_nnet.sh --model_size $model_size --hid_layers $hid_layers \
    ${bn_dim:+ --bn-dim $bn_dim} \
    ${hid_dim:+ --hid-dim $hid_dim} \
    --seed $seed ${init_opts} \
    ${config:+ --config $config} \
    $num_fea $num_tgt $mlp_init

  #optionally prepend dbn to the initialization
  if [ ! -z $dbn ]; then
    mlp_init_old=$mlp_init; mlp_init=$dir/nnet_$(basename $dbn)_dnn.init
    nnet-concat $dbn $mlp_init_old $mlp_init 
  fi
fi



bash ${tools}/train_nnet_scheduler.sh \
  --feature-transform $feature_transform \
  --learn-rate $learn_rate \
  --seed $seed \
  ${train_opts} \
  ${train_tool:+ --train-tool "$train_tool"} \
  ${config:+ --config $config} \
  ${use_gpu_id:+ --use-gpu-id $use_gpu_id} \
  $mlp_init "$feats_tr" "$feats_cv" "$labels_tr" "$labels_cv" $dir








