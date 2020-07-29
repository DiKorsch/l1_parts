#!/usr/bin/env bash
source 00_config.sh

docker build -f Dockerfile2 --tag chainer-cuda101-opencv4.1.1 .

docker-compose build $@ && docker-compose config
