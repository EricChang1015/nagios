#!/bin/bash
# Version 0.3
# Changelog: add ipv6 support (Thanks to Roger Sikorski for the inquire)
# Adopted Since Jan 2015 rewritten and maintained by Fabio Pardi

# Variables definition

# my PID
mypid="$$"
html_tmp="/tmp/tmp_html.$mypid"
rep_tmp="/tmp/tmp_rep.$mypid"
add_uri='https://'
end_uri='/'
PORT=''
exit_code=2

if [ $# -lt 1 ]
then
        echo "Arguments are missing!  Run ./check_https IP_or_DNS port (optional) "
	echo "Eg:  ./check_https  mywebsite.com"
	echo "Eg:  ./check_https  ::ffff:192.168.1.1 444"
	exit 1
fi

if [ $# -gt 1 ]
then
	PORT=:$2
fi

# Give some brain to this script. Detect yourself if we are checking an hostname, an ipv4 or an ipv6


if ipcalc -sc4 $1 
then
	target=ipv4
else if ipcalc -sc6 $1
	then 
		target=ipv6
	else
	# we consider here cases in which the passed argument is DNS name 
		target=DNS
	fi
fi

if [ ! "$target" == "ipv6" ] 
then
 	/usr/bin/wget --no-check-certificate --output-document=$html_tmp -S $add_uri$1$PORT$end_uri  2> $rep_tmp 
else
        /usr/bin/wget --no-check-certificate --output-document=$html_tmp -S $add_uri[$1]$PORT$end_uri  2> $rep_tmp

fi

case $? in 
	0) if grep -q "Invalid"  $rep_tmp ;   then 
		exit_code=2
		cat $rep_tmp
	   else	
	 	cat $rep_tmp | grep "HTTP/1" | grep "OK"
         	exit_code=0
	  fi
	;;

	1) echo Generic error code.
	cat $rep_tmp | grep "HTTP/1"
          exit_code=1
	;;

        2) echo  "Parse error, for instance, when parsing command-line options, the .wgetrc or .netrc..."
	 exit_code=1
	;;

        3) echo   "File I/O error"
          exit_code=1
	;;

        4) echo "Network failure, cannot contact website"
	cat $rep_tmp | grep "HTTP/1"
          exit_code=2
	;;

        7) echo  "Protocol errors"
	  exit_code=1
	;;

        8) #server is able to serve the page, but still something is wrong in the page
	 cat $rep_tmp | grep "HTTP/1"
	  exit_code=1
	;;
	*) echo "Unknown error"
	exit_code=2
	;;
	
esac
if [ -e $html_tmp ]
then
	rm $html_tmp
fi

if [ -e $rep_tmp ]
then
        rm $rep_tmp
fi
exit $exit_code
