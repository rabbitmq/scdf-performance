#!/bin/sh

ps ax | grep java | grep scst-rabbitmq-performance | grep -v 'grep' | cut -d '?' -f1 | cut -d 'p' -f1 | xargs kill