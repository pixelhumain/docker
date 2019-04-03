#!/bin/sh
set -e

TAG="latest"
# TAG="testing"

cd docker-front/
# docker build --no-cache --rm -t communecter/co2-front-dev:$TAG .
docker build --rm -t communecter/co2-front-dev:$TAG .
docker tag communecter/co2-front-dev:$TAG communecter/co2-front-dev:$TAG
docker push communecter/co2-front-dev:$TAG

cd ..
cd docker-install/
# docker build --no-cache --rm -t communecter/co2-install-dev:$TAG .
docker build --rm -t communecter/co2-install-dev:$TAG .
docker tag communecter/co2-install-dev:$TAG communecter/co2-install-dev:$TAG
docker push communecter/co2-install-dev:$TAG