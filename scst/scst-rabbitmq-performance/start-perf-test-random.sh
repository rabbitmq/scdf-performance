#!/bin/bash

#set -ex

source .env

encoded_vhost=`python -c "import urllib; print urllib.quote('${RABBITMQ_VHOST}', safe='')"`

${PERF_TEST_HOME}/bin/runjava com.rabbitmq.perf.PerfTest \
   --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_HOST:$RABBITMQ_PORT/$encoded_vhost \
   -x ${PARTITIONS} -y 0 --predeclared --size 1000 -exchange "scst.random" \
   --flag ${MSG_FLAG} --routing-key "" > perf-test.txt &