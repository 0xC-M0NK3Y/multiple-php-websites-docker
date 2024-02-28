#!/bin/bash

echo "Don't forget to build first !!!"
echo ""
sleep 1

docker compose -f ./srcs/docker-compose.yml up
