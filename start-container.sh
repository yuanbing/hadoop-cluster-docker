#!/bin/bash

# the default node number is 2
N=${1:-3}


# start hadoop master container
docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop \
                -p 9870:9870 \
                -p 8088:8088 \
                --name hadoop-master \
                --hostname hadoop-master \
                com.huawei.video/hadoop-base:3.0.0.beta1 &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                com.huawei.video/hadoop-base:3.0.0.beta1 &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container
docker exec -it hadoop-master bash
