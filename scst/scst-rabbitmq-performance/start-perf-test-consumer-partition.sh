#!/bin/bash

#set -ex

source .env


if [ "$RABBITMQ_VHOST" == "/" ]
then
     encoded_vhost="%2f"
else
     encoded_vhost=$RABBITMQ_VHOST
fi


for (( i=0; i<$PARTITIONS; i++ ))
do
    ${PERF_TEST_HOME}/bin/runjava com.rabbitmq.perf.PerfTest \
        --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_HOST:$RABBITMQ_PORT/$encoded_vhost \
        -x 0 -y 1 --predeclared --size 1000 --queue scst.partition-$i --qos ${SCST_PREFETCH} > perf-test-consumer-partition-$i.txt &
done