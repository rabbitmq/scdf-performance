#!/bin/bash

#set -ex

source .env

encoded_vhost=`python -c "import urllib; print urllib.quote('${RABBITMQ_VHOST}', safe='')"`

declare -a perftest_opts

if [ "$SCST_TX_SIZE" -gt "1" ]
then
    perftest_opts+=(--multi-ack-every "$SCST_TX_SIZE")
fi

for (( i=0; i<$PARTITIONS; i++ ))
do
    ${PERF_TEST_HOME}/bin/runjava com.rabbitmq.perf.PerfTest \
        --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_HOST:$RABBITMQ_PORT/$encoded_vhost \
        -x 0 -y 1 --predeclared --size 1000 --queue scst.partition-$i \
        --qos ${SCST_PREFETCH} "${perftest_opts[@]}" > perf-test-consumer-partition-$i.txt &
done