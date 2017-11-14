#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [ $# = 0 ]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# change slaves file
i=1
rm config/workers
while [ $i -lt $N ]
do
	echo "hadoop-slave$i" >> config/workers
	((i++))
done 

echo ""

echo -e "\nbuild docker hadoop image\n"

# rebuild com.huawei.video/hadoop-base:3.0.0.beta1 image
docker build --rm -t com.huawei.video/hadoop-base:3.0.0.beta1 .

echo ""
