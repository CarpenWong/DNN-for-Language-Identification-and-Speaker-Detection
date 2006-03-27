#!/bin/bash

# calculate the accuracy
# usage: bash scripts/cal_acc.sh tmp result

tmpdir=$1
resultFile=$2

#mkdir $tmpdir

cat $resultFile | sed "s/.*English.*/0/g" | sed "s/.*NorthMandarin.*/1/g" | sed "s/.*Uighur.*/2/g" > $tmpdir/test.reflab
cat $resultFile | sed "s/.*_\w* //g" > $tmpdir/test.logprob

echo "X=load('$tmpdir/test.logprob');" > $tmpdir/cal_result.m
echo "Y=load('$tmpdir/test.reflab');" >> $tmpdir/cal_result.m
echo "[~,YY]=max(X,[],2);" >> $tmpdir/cal_result.m
echo "YY=YY-1;" >> $tmpdir/cal_result.m
echo "fid = fopen('$tmpdir/test.rid','w');"   >> $tmpdir/cal_result.m
echo "for i = 1:1:length(Y)"     >>    $tmpdir/cal_result.m
echo "fprintf(fid,'%d\n',YY(i));"      >>    $tmpdir/cal_result.m
echo "end"         >>       $tmpdir/cal_result.m
echo "fclose(fid);" >> $tmpdir/cal_result.m
echo "acc=100*sum(Y==YY)/length(Y);" >> $tmpdir/cal_result.m
echo "fid = fopen('$tmpdir/test.acc','w');" >> $tmpdir/cal_result.m
echo "fprintf(fid,'%6.2f%%\n',acc);" >> $tmpdir/cal_result.m
echo "fclose(fid);" >> $tmpdir/cal_result.m

matlab < $tmpdir/cal_result.m

#rm -r $tmpdir/cal_result.m $tmpdir/test.logprob $tmpdir/test.reflab
