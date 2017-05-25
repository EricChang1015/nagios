#!/bin/bash

help()
{
    clear
    echo "=============How to Use=============="
    echo -e "$0 containerID"
    guessContainerID=$(docker ps | grep nagios4 -i | awk '{print $1 }')
    if [ ! -z $guessContainerID ]; then
        echo "I guess you can use following command"
        echo -e "$0 $guessContainerID"
    fi
    echo "====================================="
}

main()
{
    containerID=$(docker ps | grep $1 -o -m1)
    if [ $# -eq 0 ]; then
        help
        return 1
    fi 
    if [ -z $containerID ]; then
        echo "plz check your container ID"
        return 1
    fi
    
    mkdir -p config/plugins/
    mkdir -p config/apache2/
    docker cp $containerID:/opt/nagios/etc ./config/.
    docker cp $containerID:/opt/nagios/var ./config/.
    docker cp $containerID:/opt/Custom-Nagios-Plugins ./config/plugins
    docker cp $containerID:/etc/apache2/sites-available/nagios.conf ./config/apache2/.
    sudo chmod 777 ./config -R
}

main $@
