#!/bin/bash
# for check nginx connection number

hostname=$1
user=$2
password=$3

connections=$(curl https://$hostname/nginx_status -u $user:$password  2>&1 | grep connection )
return=$?


if [ $return -eq 0 ];then
    performance=$(echo $connections | awk '{printf "%s %s=%d;;;;\n",$1,$1,$3 }')
    echo "$connections | $performance"
else
    echo "FAIL | Active Active=0;;;;"
fi
