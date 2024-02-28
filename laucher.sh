#!/bin/bash

if [ $# -ne 1 ];
then
	echo "Usage $0 <config_dir>"
	exit 1
fi

if [ ! -d $1 ];
then
	echo "Need config as directory"
	exit 1
fi

./builder.sh $1

docker compose -f ./srcs/docker-compose.yml up
