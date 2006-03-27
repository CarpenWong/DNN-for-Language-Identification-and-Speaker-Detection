#!/bin/bash

# calculate the accuracy
# usage: bash scripts/cal_acc.sh tmp result

tmpdir=$1
resultFile=$2
mapFile=$3

#mkdir $tmpdir
while read name remains;								\
do														\
	awk '/^'$name'/ 									\
		{												\
			print $2 >> "'$tmpdir/test.reflab'";			\
		}'	$mapFile;									\
done < $resultFile

cat $resultFile | sed "s/.*_\w* //g" > $tmpdir/test.logprob

echo "X=load('$tmpdir/test.logprob');" > $tmpdir/cal_result.m
echo "Y=load('$tmpdir/test.reflab');" >> $tmpdir/cal_result.m
echo "[~,YY]=max(X,[],2);" >> $tmpdir/cal_result.m
echo "YY=YY-1;" >> $tmpdir/cal_result.m
echo "acc=100*sum(Y==YY)/length(Y);" >> $tmpdir/cal_result.m
echo "fid = fopen('$tmpdir/test.acc','w');" >> $tmpdir/cal_result.m
echo "fprintf(fid,'%6.2f%%\n',acc);" >> $tmpdir/cal_result.m
echo "fclose(fid);" >> $tmpdir/cal_result.m

matlab < $tmpdir/cal_result.m

#rm -r $tmpdir/cal_result.m $tmpdir/test.logprob $tmpdir/test.reflab
