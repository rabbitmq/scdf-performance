#!/bin/bash

#set -ex

sudo curl -sSL "https://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc" | sudo -E apt-key add -
echo "deb https://packages.erlang-solutions.com/ubuntu trusty contrib" | sudo tee -a /etc/apt/sources.list > /dev/null
sudo -E apt-get -yq update &>> ~/apt-get-update.log
sudo -E apt-get -yq --no-install-suggests --no-install-recommends --force-yes install esl-erlang=1:20.1

sudo apt-get install -y init-system-helpers socat adduser logrotate

wget https://dl.bintray.com/rabbitmq/rabbitmq-server-deb/rabbitmq-server_3.7.0-1_all.deb
sudo dpkg --install rabbitmq-server_3.7.0-1_all.deb
sudo rm rabbitmq-server_3.7.0-1_all.deb

sudo apt-get install haproxy
sudo cp etc/haproxy/haproxy.cfg /etc/haproxy/
sudo haproxy -f /etc/haproxy/haproxy.cfg


sleep 3

