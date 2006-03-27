#!/bin/bash
count=20
sdc=sdc
for((i=1;i<=$count;i++))
do
	matlab < ${sdc}_${i}.m &
done
