#!/bin/bash

#set -ex

source .env

for (( i=0; i<$PARTITIONS; i++ ))
do
    java -jar target/scst-rabbitmq-performance-0.0.1-SNAPSHOT.jar \
    --spring.cloud.stream.binders.rabbit.environment.spring.rabbitmq.host=${RABBITMQ_HOST} \
    --spring.cloud.stream.binders.rabbit.environment.spring.rabbitmq.port=${RABBITMQ_PORT} \
    --spring.cloud.stream.binders.rabbit.environment.spring.rabbitmq.virtualHost=${RABBITMQ_VHOST} \
    --spring.cloud.stream.binders.rabbit.environment.spring.rabbitmq.username=${RABBITMQ_USERNAME} \
    --spring.cloud.stream.binders.rabbit.environment.spring.rabbitmq.password=${RABBITMQ_PASSWORD} \
    --non.declarative=true \
    --num.messages=${SCST_NB_MESSAGES} \
    --print.on.every=${SCST_PRINT_ON_EVERY} \
    --spring.cloud.stream.bindings.input.destination=${SCST_DESTINATION} \
    --spring.cloud.stream.bindings.input.group=random \
    --spring.cloud.stream.rabbit.bindings.input.consumer.exchangeType=direct \
    --spring.cloud.stream.rabbit.bindings.input.consumer.exchangeDurable=false \
    --spring.cloud.stream.rabbit.bindings.input.consumer.exchangeAutoDelete=false \
    --spring.cloud.stream.rabbit.bindings.input.consumer.maxConcurrency=${SCST_MAX_CONCURRENCY} \
    --spring.cloud.stream.rabbit.bindings.input.consumer.prefetch=${SCST_PREFETCH} \
    --spring.cloud.stream.rabbit.bindings.input.consumer.txSize=${SCST_TX_SIZE} \
    --logging.level.root=WARN \
    --spring.cloud.stream.bindings.input.consumer.partitioned=true \
    --spring.cloud.stream.instanceCount=${PARTITIONS} \
    --spring.cloud.stream.instanceIndex=$i --server.port=808$i > random-$i.txt &
done