#!/bin/bash

#set -ex

source .env

for (( i=0; i<$PARTITIONS; i++ ))
do
    ./rabbitmqadmin purge queue name=scst.hash-$i
done