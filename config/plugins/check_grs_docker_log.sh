#!/bin/bash

rm -r $hostMessage $error $warn $compressedLogs $summary_error

container=""
attachedFile=""
error="error.log"
warn="warn.log"
container=$1
compressedLogs="${container}logs.tar.gz"
summary_error="summary_error.log"
mailList="victor.lei@aspectgaming.com ligang.yao@aspectgaming.com eric.chang@aspectgaming.com"
level="WARN"
host="GRS Production Server"
hostMessage="hostMessage.txt"
echo -e "\
Service: $container\n\
Host: $host\n\
Date:$(date)\n\
detail:ref attached files\n\
Summary:\n\
" > $hostMessage


if [ $# -eq 0 ]
then
    echo -e "Arguments are missing!  Run $0 docker_name (login N mins) "
    echo -e "Eg:  $0  web_srv 10m"
    echo -e "Eg:  $0  web_srv"
    exit 1
fi

if [ $# -eq 2 ]; then
    args="--since $2"
fi

#prevent too many logs
docker logs $container $args 2>&1 | grep -E "ERROR" --color -A100 | grep -E "ERROR|at |--|EXCEPTION|Exception" > $error
docker logs $container $args | grep -E "WARN " > $warn

errorLogSize=$(du $error | sed -E "s/\t.*//g" )
warnLogSize=$(du $warn | sed -E "s/\t.*//g" )

if [ $errorLogSize -gt 10 ] ; then
    level="ERROR"
fi

if [ $(( $errorLogSize + $warnLogSize )) -gt 100 ]; then
    tar -zcf $compressedLogs $error $warn
    attachedFiles+=" --attach=$compressedLogs "
else
    if [ $errorLogSize -gt 10 ] ; then
        attachedFiles+=" --attach=$error "
    fi
    if [ $warnLogSize -gt 10 ] ; then
        attachedFiles+=" --attach=$warn "
    fi
fi

grep ERROR $error | sed "s/.* ERROR/ERROR/g" | sort | uniq -c | sort -hr > $summary_error

if [ ! -z $attachedFiles ]; then
    cat $hostMessage $summary_error | mailx -s "$host $container $level report" -t $mailList  -r ops@aspectgaming.com $attachedFiles
fi

grep ERROR $summary_error

if [ $? == 0 ]; then
    exit 1
fi

echo warn | grep WARN
 
if [ $? == 0 ]; then
    exit 1
fi
