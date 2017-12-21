#!/bin/bash

#set -ex

source .env

# user configuration
${RABBITMQ_CTL} add_vhost ${RABBITMQ_VHOST}
${RABBITMQ_CTL} delete_user ${RABBITMQ_USERNAME}
${RABBITMQ_CTL} add_user ${RABBITMQ_USERNAME} ${RABBITMQ_PASSWORD}
${RABBITMQ_CTL} set_permissions -p ${RABBITMQ_VHOST} ${RABBITMQ_USERNAME} ".*" ".*" ".*"
${RABBITMQ_CTL} set_user_tags ${RABBITMQ_USERNAME} administrator

# plugins activation
${RABBITMQ_PLUGINS} enable rabbitmq_management rabbitmq_sharding rabbitmq_consistent_hash_exchange rabbitmq_random_exchange rabbitmq_top

# rabbitmqadmin
rm rabbitmqadmin
wget http://localhost:15672/cli/rabbitmqadmin
chmod u+x rabbitmqadmin

# some cleaning
# deleting sharding policy
${RABBITMQ_CTL} clear_policy -p ${RABBITMQ_VHOST} scst.sharding
# deleting all queues
encoded_vhost=`python -c "import urllib; print urllib.quote('${RABBITMQ_VHOST}', safe='')"`
mapfile -t queues < <(${RABBITMQ_CTL} list_queues name)
for queue in "${queues[@]}"
do
    encoded_queue=`python -c "import urllib; print urllib.quote('${queue}', safe='')"`
    curl --silent -X "DELETE" http://${RABBITMQ_USERNAME}:${RABBITMQ_PASSWORD}@${RABBITMQ_HOST}:15672/api/queues/${encoded_vhost}/${encoded_queue} > /dev/null
done

# partition workload
for (( i=0; i<$PARTITIONS; i++ ))
do
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare exchange name=scst.partition.$i type=direct durable=true
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare queue name=scst.partition-$i durable=true
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare binding source=scst.partition.$i destination=scst.partition-$i routing_key=$i
done

# random workload
./rabbitmqadmin declare exchange name=scst.random type=x-random durable=true
for (( i=0; i<$PARTITIONS; i++ ))
do
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare queue name=scst.random-$i durable=true
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare binding source=scst.random destination=scst.random-$i
done

# sharding workload
./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare exchange name=scst.sharding type=x-modulus-hash durable=true
sharding_policy_json_document="{'shards-per-node': ${PARTITIONS}}"
${RABBITMQ_CTL} set_policy -p ${RABBITMQ_VHOST} scst.sharding "^scst.sharding$" "$sharding_policy_json_document"

# consistent hash workload
./rabbitmqadmin declare exchange name=scst.hash type=x-consistent-hash durable=true
for (( i=0; i<$PARTITIONS; i++ ))
do
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare queue name=scst.hash-$i durable=true
    ./rabbitmqadmin --vhost ${RABBITMQ_VHOST} declare binding source=scst.hash destination=scst.hash-$i routing_key=10
done
