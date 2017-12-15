#!/bin/bash

#set -ex

source .env

encoded_vhost=`python -c "import urllib; print urllib.quote('${RABBITMQ_VHOST}', safe='')"`

for (( i=0; i<$PARTITIONS; i++ ))
do
    ${PERF_TEST_HOME}/bin/runjava com.rabbitmq.perf.PerfTest \
        --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_HOST:$RABBITMQ_PORT/$encoded_vhost \
        -x 1 -y 0 --predeclared --size 1000 -exchange "scst.partition.$i" --routing-key "$i" > perf-test-$i.txt &
done