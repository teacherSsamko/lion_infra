#!/bin/bash

docker pull postgres:13

docker run -d -p 5432:5432 --name db \
    -v postgres_data:/var/lib/postgresql/data \
    --env-file .env \
    postgres:13
