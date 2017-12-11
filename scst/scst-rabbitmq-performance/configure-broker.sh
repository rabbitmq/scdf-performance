#!/bin/bash

#set -ex

source .env

${RABBITMQ_CTL} add_vhost ${RABBITMQ_VHOST}
${RABBITMQ_CTL} add_user ${RABBITMQ_USERNAME} ${RABBITMQ_PASSWORD} || true
${RABBITMQ_CTL} set_permissions -p ${RABBITMQ_VHOST} ${RABBITMQ_USERNAME} ".*" ".*" ".*"
${RABBITMQ_CTL} set_user_tags ${RABBITMQ_USERNAME} monitoring

${RABBITMQ_PLUGINS} enable rabbitmq_management rabbitmq_sharding rabbitmq_consistent_hash_exchange rabbitmq_random_exchange rabbitmq_top

rm rabbitmqadmin
wget http://localhost:15672/cli/rabbitmqadmin
chmod u+x rabbitmqadmin

for (( i=0; i<$PARTITIONS; i++ ))
do
    ./rabbitmqadmin declare exchange name=scst.partition.$i type=direct durable=true
    ./rabbitmqadmin declare queue name=scst.partition-$i durable=true
    ./rabbitmqadmin declare binding source=scst.partition.$i destination=scst.partition-$i routing_key=$i
done