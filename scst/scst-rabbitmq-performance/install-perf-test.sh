#!/bin/bash

#set -ex

source .env

rm -rf rabbitmq-perf-test
git clone https://github.com/rabbitmq/rabbitmq-perf-test.git
cd rabbitmq-perf-test
git checkout ${PERF_TEST_TAG}
cd ..
./mvnw -f ./rabbitmq-perf-test/pom.xml clean package -P assemblies -DskipTests -Dgpg.skip

tar xzf rabbitmq-perf-test/target/rabbitmq-perf-test-${PERF_TEST_VERSION}-bin.tar.gz -C rabbitmq-perf-test/target
