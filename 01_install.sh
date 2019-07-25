#!/usr/bin/env bash
source 00_config.sh

docker-compose build --no-cache && docker-compose config
