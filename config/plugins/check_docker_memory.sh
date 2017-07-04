#!/bin/bash

declare -i Number=$(docker ps | wc -l)
declare -i sum=0
Number=$Number-1

#for line in `docker ps | awk '{print $1}' | grep -v CONTAINER`; do docker ps | grep $line | awk '{printf $NF" "}' && echo -n $(( (`cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` + 512 ) / 1024 / 1024 ))MB ; done
for line in `docker ps | awk '{print $1}' | grep -v CONTAINER`; do 
    memoryMiB=$(echo -n $(((`cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` + 512 ) / 1024 / 1024 ))) ;
    sum=$(($sum + $memoryMiB ));
    #sum=$(docker ps | grep $line | echo -n $(($sum + (`cat /sys/fs/cgroup/memory/docker/$line*/memory.usage_in_bytes` + 512 ) / 1024 / 1024 ))) ; 
    performance=$performance$(docker ps | grep $line | awk '{printf $NF}' && echo -n "=${memoryMiB}MB;;;; ")
done



echo "$Number containers use: ${sum}MB | $performance "
