#!/bin/bash

#set -ex

source .env

for (( i=0; i<$PARTITIONS; i++ ))
do
    nohup ${PERF_TEST_HOME}/bin/runjava com.rabbitmq.perf.PerfTest \
        -x 1 -y 0 --predeclared --size 1000 -exchange "scst.partition.$i" -routing-key "$i" &
done