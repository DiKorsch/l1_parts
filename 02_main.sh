#!/usr/bin/env bash
source 00_config.sh

docker-compose config
docker-compose run experiment $@
# docker-compose up
