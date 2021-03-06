#!/bin/bash

container=""

if [ $# -eq 0 ]
then
    echo -e "Arguments are missing!  Run $0 docker_name (login N mins) "
    echo -e "Eg:  $0  web_srv 10m"
    echo -e "Eg:  $0  web_srv"
    exit 1
fi

container=$1

if [ $# -eq 2 ]; then
    args="--since $2"
fi

#prevent too many logs
docker logs $container $args 2>&1 | grep ERROR | sed "s/.* ERROR/ERROR/g" | sort | uniq -c | sort -hr | grep ERROR

if [ $? == 0 ]; then
    exit 1
fi
 
docker logs $container $args | grep -E "WARN "

if [ $? == 0 ]; then
    exit 1
fi
