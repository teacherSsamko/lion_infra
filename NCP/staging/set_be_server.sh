#!/bin/sh

docker login \
    lion-cr.kr.ncr.ntruss.com \
    -u "" \
    -p ""
docker pull lion-cr.kr.ncr.ntruss.com/lion-app:latest

docker run -p 8000:8000 -d \
    --name lion-app \
    -v ~/.aws:/root/.aws:ro \
    --env-file .env \
    lion-cr.kr.ncr.ntruss.com/lion-app:latest