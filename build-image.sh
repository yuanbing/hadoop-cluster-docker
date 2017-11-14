#!/bin/bash

echo ""

echo -e "\nbuild docker hadoop image\n"
docker build -t com.huawei.video/hadoop-base:3.0.0.beta1 .

echo ""