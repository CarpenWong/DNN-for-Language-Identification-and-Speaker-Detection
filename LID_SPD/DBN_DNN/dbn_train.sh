#!/bin/bash

tools=/home/wzj/LID/DBN_DNN

export PATH=${tools}/utils/:$PATH



num_hid=(128 128 128)
rbm_iter=10
rbm_drop_data=0.0
rbm_lrate=0.4
rbm_lrate_low=0.01
rbm_l2penalty=0.0002
rbm_extra_opts=
copy_feats=true
feature_transform=
delta_order=
splice=3
splice_step=3
verbose=1
use_gpu_id=-2



. parse_options.sh || exit 1;


if [ $# != 2 ]; then
   echo "Usage: $0 <dbn_dir> <data_scp>"
   echo "main options (for others, see top of script file)"
   echo "  --config <config-file>           # config containing options"
   echo ""
   echo "  hid_dim=(h1 h2 h3 ... hN)		# directly modify on the script, number of hidden units each hidden layer, N is the hidden layer number"
   echo "  --rbm-iter <N>                   # number of CD-1 iterations per layer"
   echo "  --dbm-drop-data <float>          # probability of frame-dropping,"
   echo "                                   # can be used to subsample large datasets"
   echo "  --rbm-lrate <float>              # learning-rate for Bernoulli-Bernoulli RBMs"
   echo "  --rbm-lrate-low <float>          # learning-rate for Gaussian-Bernoulli RBM"
   echo ""
   echo "  --copy-feats <bool>              # copy features to /tmp, to accelerate training"
   echo "  --splice <N>                     # splice +/-N frames of input features"
   exit 1;
fi

dir=$1
data_scp=$2



nn_depth=${#num_hid[@]}

mkdir -p $dir/log

echo $nn_depth > $dir/nn_depth

cat $data_scp | ${tools}/utils/shuffle_list.pl --srand ${seed:-777} > $dir/train.scp

wc -l $dir/train.scp

if [ "$copy_feats" == "true" ]; then
  tmpdir=$(mktemp -d); mv $dir/train.scp $dir/train.scp_non_local
  ${tools}/utils/nnet/copy_feats.sh $dir/train.scp_non_local $tmpdir $dir/train.scp
  trap "echo \"Removing features tmpdir $tmpdir @ $(hostname)\"; rm -r $tmpdir" EXIT
fi

head -n 10000 $dir/train.scp > $dir/train.scp.10k



feats="ark:copy-feats scp:$dir/train.scp ark:- |"



if [ "$delta_order" != "" ]; then
  feats="$feats add-deltas --delta-order=$delta_order ark:- ark:- |"
  echo "$delta_order" > $dir/delta_order
fi

echo -n "Getting feature dim : "

feat_dim=$(feat-to-dim --print-args=false "$feats" -)

echo $feat_dim



if [ ! -z "$feature_transform" ]; then
  echo Using already prepared feature_transform: $feature_transform
  cp $feature_transform $dir/final.feature_transform
else
  # Generate the splice transform
  echo "Using splice +/- $splice , step $splice_step"
  feature_transform=$dir/tr_splice$splice-$splice_step.nnet
  utils/nnet/gen_splice.py --fea-dim=$feat_dim --splice=$splice --splice-step=$splice_step > $feature_transform

  # Renormalize the MLP input to zero mean and unit variance
  feature_transform_old=$feature_transform
  feature_transform=${feature_transform%.nnet}_cmvn-g.nnet
  echo "Renormalizing MLP input features into $feature_transform"
  nnet-forward ${use_gpu_id:+ --use-gpu-id=$use_gpu_id} \
    $feature_transform_old "$(echo $feats | sed 's|train.scp|train.scp.10k|')" \
    ark:- 2>$dir/log/cmvn_glob_fwd.log |\
  compute-cmvn-stats ark:- - | cmvn-to-nnet - - |\
  nnet-concat --binary=false $feature_transform_old - $feature_transform

  # MAKE LINK TO THE FINAL feature_transform, so the other scripts will find it ######
  [ -f $dir/final.feature_transform ] && unlink $dir/final.feature_transform
  (cd $dir; ln -s $(basename $feature_transform) final.feature_transform )
fi

num_fea=$(feat-to-dim --print-args=false "$feats nnet-forward --use-gpu-id=-1 $feature_transform ark:- ark:- |" - 2>/dev/null)



for depth in $(seq 1 $nn_depth); do
  echo
  echo "# PRE-TRAINING RBM LAYER $depth"
  RBM=$dir/$depth.rbm
  [ -f $RBM ] && echo "RBM '$RBM' already trained, skipping." && continue

  #The first RBM needs special treatment, because of Gussian input nodes
  if [ "$depth" == "1" ]; then
    #This is Gaussian-Bernoulli RBM
    #initialize
    echo "Initializing '$RBM.init'"
    utils/nnet/gen_rbm_init.py --dim=${num_fea}:${num_hid[0]} --gauss --vistype=gauss --hidtype=bern > $RBM.init
    #pre-train
    echo "Pretraining '$RBM' (reduced lrate and 2x more iters)"
    rbm-train-cd1-frmshuff --learn-rate=$rbm_lrate_low --l2-penalty=$rbm_l2penalty \
      --num-iters=$((2*$rbm_iter)) --drop-data=$rbm_drop_data --verbose=$verbose \
      --feature-transform=$feature_transform \
      $rbm_extra_opts \
      $RBM.init "$feats" $RBM 2>$dir/log/rbm.$depth.log
  else
    #This is Bernoulli-Bernoulli RBM
    #cmvn stats for init
    echo "Computing cmvn stats '$dir/$depth.cmvn' for RBM initialization"
    if [ ! -f $dir/$depth.cmvn ]; then 
      nnet-forward ${use_gpu_id:+ --use-gpu-id=$use_gpu_id} \
       "nnet-concat $feature_transform $dir/$((depth-1)).dbn - |" \
        "$(echo $feats | sed 's|train.scp|train.scp.10k|')" \
        ark:- 2>$dir/log/cmvn_fwd.$depth.log | \
      compute-cmvn-stats ark:- - 2>$dir/log/cmvn.$depth.log | \
      cmvn-to-nnet - $dir/$depth.cmvn
    else
      echo compute-cmvn-stats already done, skipping.
    fi
    #initialize
    echo "Initializing '$RBM.init'"
    utils/nnet/gen_rbm_init.py --dim=${num_hid[$((depth-2))]}:${num_hid[$((depth-1))]} --gauss --vistype=bern --hidtype=bern --cmvn-nnet=$dir/$depth.cmvn > $RBM.init
    #pre-train
    echo "Pretraining '$RBM'"
    rbm-train-cd1-frmshuff --learn-rate=$rbm_lrate --l2-penalty=$rbm_l2penalty \
      --num-iters=$rbm_iter --drop-data=$rbm_drop_data --verbose=$verbose \
      --feature-transform="nnet-concat $feature_transform $dir/$((depth-1)).dbn - |" \
      $rbm_extra_opts \
      $RBM.init "$feats" $RBM 2>$dir/log/rbm.$depth.log
  fi

  #Create DBN stack
  if [ "$depth" == "1" ]; then
    rbm-convert-to-nnet --binary=false $RBM $dir/$depth.dbn
  else 
    rbm-convert-to-nnet --binary=false $RBM - | \
    nnet-concat --binary=false $dir/$((depth-1)).dbn - $dir/$depth.dbn
  fi

done

