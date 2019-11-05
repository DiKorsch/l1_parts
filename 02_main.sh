#!/usr/bin/env bash
source 00_config.sh

docker-compose config
docker-compose run --rm experiment $@
# docker-compose up
