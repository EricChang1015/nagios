# nagios

## Run nagios

~~~
docker-compose up -d
~~~


## Open in web browser
[Check on browser](https://devops.aspectgaming.com/)


## monitor a new server
1. add server config to ./config/etc/objects

~~~
vim ./config/etc/objects/demo.aspectgaming.com.cfg

define host{
        use                     linux-server
        host_name               demoHost
        alias                   Demo Server
        address                 demo.aspectgaming.com
}

define service{
        use                             local-service,graphed-service
        host_name                       demoHost
        service_description             Root Partition
        check_command                   check_disk!70!90!/
        }

define service{
        use                             local-service,graphed-service
        host_name                       demoHost
        service_description             CPU Usage
        check_command                   check_cpu!50!80
        }
~~~

2. add a setting line to enable demoHost.cfg

~~~
vim ./config/etc/nagios.cfg
cfg_file=/opt/nagios/etc/objects/demo.aspectgaming.com.cfg
~~~

## Account setting
1. add user and password to http authorization

~~~
htpasswd -c /opt/nagios/etc/htpasswd.users  aspect
~~~

2. add user authorization for cgi

~~~
$ vim ./config/etc/cgi.cfg
authorized_for_system_information=nagiosadmin,aspect
authorized_for_system_commands=nagiosadmin,aspect
authorized_for_all_services=nagiosadmin,aspect
authorized_for_all_hosts=nagiosadmin,aspect
authorized_for_all_service_commands=nagiosadmin,aspect
authorized_for_all_host_commands=nagiosadmin,aspect
~~~

### setup for ssh connect for new server. (if you want to use ssh)

~~~
$ docker exec -it nagios bash
# su - nagios
$ ssh-copy-id -i user@hostname
~~~


## history will keep in two place
1. nagios:/opt/nagios/var/status.dat (for nagios status)
2. nagios:/opt/nagiosgraph/var/rrd (for nagios graphic status history)
