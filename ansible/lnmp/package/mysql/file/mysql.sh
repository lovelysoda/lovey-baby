#!/bin/sh

mysql_port=3306
mysql_username="admin"
mysql_password="37eJZR8RGZTd42l5l3hrUBqi"

function_start_mysql()
{
    printf "Starting MySQL...\n"
    /bin/sh  /data/mysql/bin/mysqld_safe --defaults-file=/data/mysql/${mysql_port}/my.cnf &> /dev/null &
    }

function_stop_mysql()
{
    printf "Stoping MySQL...\n"
    /data/mysql/bin/mysqladmin -u ${mysql_username} -p${mysql_password} -S /tmp/mysql.sock shutdown
}

function_restart_mysql()
{
    printf "Restarting MySQL...\n"
    function_stop_mysql
    sleep 5
    function_start_mysql
}

function_kill_mysql()
{
    kill -9 `ps -ef &#124; grep 'bin/mysqld_safe' &#124; grep ${mysql_port} &#124; awk '{printf $2}'`
    kill -9 `ps -ef &#124; grep 'libexec/mysqld' &#124; grep ${mysql_port} &#124; awk '{printf $2}'`
}

if [ "$1" = "start" ]; then
    function_start_mysql
elif [ "$1" = "stop" ]; then
    function_stop_mysql
elif [ "$1" = "restart" ]; then
function_restart_mysql
elif [ "$1" = "kill" ]; then
function_kill_mysql
else
    printf "Usage: /data/mysql/${mysql_port}/mysql {start&#124;stop&#124;restart&#124;kill}\n"
fi
