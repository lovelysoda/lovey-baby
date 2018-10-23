#!/bin/bash
#第一个参数是主服务器ip
#第二个参数是从服务器ip

#在主服务上运行
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "请加入参数！第一个参数是主服务器IP，第二个参数是从服务器IP地址" &&echo "如：$0 192.168.2.122 192.168.2.123"&&exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null &&echo "请加入参数！第一个参
数是主服务器IP，第二个参数是从服务器IP地址" &&echo "如：$0 192.168.2.122 192.168.2.123"&&exit
echo "请输入主服务器的密码： "
read -s masterpw
echo "请输入从服务器的密码： "
read -s slavepw

function SSH_TWO(){
yum install expect -y &>/dev/null
rm -rf /root/.ssh/{id_rsa,id_rsa.pub,known_hosts}
/usr/bin/expect <<EOF
spawn ssh-keygen
expect "Enter file in which to save the key (/root/.ssh/id_rsa):"
send "\n"
expect "Enter passphrase (empty for no passphrase):"
send "\n"
expect "Enter same passphrase again:"
send "\n"
spawn  ssh-copy-id  root@$1
expect {
    "yes/no" { send "yes\n"; exp_continue }
    "password:" { send "$2\n"}
}
expect eof
EOF
}
SSH_TWO $2 $slavepw
#主服务器的配置
yum install mariadb-server -y  
rm -rf /etc/my.cnf
cat >> /etc/my.cnf <<eof
[mysqld]
server-id=3     
log-bin=log-bin
eof
systemctl start mariadb
systemctl disable mariadb
position=`mysql -e "show master status;"|awk 'NR>1{print $2}'`
filename=`mysql -e "show master status;"|awk 'NR>1{print $1}'`
rm -rf /tmp/master.txt
cat >>/tmp/master.txt<<AA
$position
$filename
AA
mysqldump -A -x -F >/tmp/all.sql
#必要时可去设置自己的授权用户和密码,这里默认用户slave 密码服务器的密码
mysql -u root -e "delete from mysql.user where user!='root'"
mysql -u root -e "grant replication slave on *.* to slave@'%' identified by '$slavepw'"
mysql -u root -e "flush privileges"
ip a

#编写从服务器的脚本
rm -rf /tmp slave.sh
cat >>/tmp/slave.sh<<BB
#!/bin/bash
#$position
#$filename
yum install mariadb-server -y 
rm -rf /etc/my.cnf
cat >> /etc/my.cnf <<eof
[mysqld]
server-id=2
eof
systemctl start mariadb
systemctl disable mariadb
mysql -u root  < /tmp/all.sql
mysql -u root  -e 'stop slave'
mysql -u root   -e "CHANGE MASTER TO MASTER_HOST='$1',MASTER_USER='slave',MASTER_PASSWORD='$masterpw',MASTER_PORT=3306,MASTER_LOG_FILE='$filename',MASTER_LOG_POS=$position,MASTER_CONNECT_RETRY=10"
mysql -u root  -e 'start slave'
mysql -u root -e "show slave status\G"|sed -n -r '/Running/p'|sed -n -r 's/ +//p'
a=0
mysql -u root -e "show slave status\G" |grep "Slave_IO_Running: Yes" 
[ \$? -eq 1 ] && echo "IO线程出错了！"&&a=1 
mysql -u root -e "show slave status\G" |grep "Slave_SQL_Running: Yes" 
[ \$? -eq 1 ] && echo "SQL线程出错了！"&&a=1

[ \$a -eq 0 ] && echo "配置成功了！"
BB
#加权限,发送脚本并执行
chmod +x /tmp/slave.sh
scp /tmp/slave.sh $2:/tmp/slave.sh
scp /tmp/all.sql $2:/tmp/all.sql
ssh root@$2  '/tmp/slave.sh'
