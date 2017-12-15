#!/bin/bash

#set -ex

source .env

./rabbitmqadmin purge queue name=scst.sharding
