#!/bin/bash
#在第三台机器上运行
#第一个参数是主服务器ip
#第二个参数是从服务器ip
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "请加入参数！第一个参数是主服务器IP，第二个参数是从服务器IP地址" &&echo "如：$0 192.168.2.122 192.168.2.123"&&exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null &&echo "请加入参数！第一个参数是主服务器IP，第二个参数是从服务器IP地址" &&echo "如：$0 192.168.2.122 192.168.2.123"&&exit
echo "请输入主服务器的密码： "
read -s masterpw
echo "请输入从服务器的密码： "
read -s slavepw


#ssh互信
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
#主服务器的配置
SSH_TWO $1 $masterpw  &>/dev/null
ssh $1 2>/dev/null <<eeooff
yum install mariadb-server -y  &>/dev/null
rm -rf /etc/my.cnf
cat >> /etc/my.cnf <<eof
[mysqld]
server-id=3     
log-bin=log-bin
eof
systemctl start mariadb
systemctl disable mariadb
#必要时可去设置自己的授权用户和密码,这里默认用户slave 密码xlx
mysql -u root -e "delete from mysql.user where user!='root'"
mysql -u root -e "grant replication slave on *.* to slave@'%' identified by '$slavepw'"
mysql -u root -e "flush privileges"
mysql -u root  -e 'reset slave'
mysql -u root  -e 'reset master'
eeooff

#从服务器的配置
SSH_TWO $2 $slavepw &>/dev/null
ssh $2 2>/dev/null  <<eeooff
yum install mariadb-server -y &>/dev/null
rm -rf /etc/my.cnf
cat >> /etc/my.cnf <<eof
[mysqld]
server-id=2
eof
systemctl start mariadb
systemctl disable mariadb
mysql -u root  -e 'stop slave'
mysql -u root   -e "CHANGE MASTER TO MASTER_HOST='$1',MASTER_USER='slave',MASTER_PASSWORD='$masterpw',MASTER_PORT=3306,MASTER_LOG_FILE='log-bin.000001',MASTER_LOG_POS=245,MASTER_CONNECT_RETRY=10"
mysql -u root  -e 'start slave'
mysql -u root -e "show slave status\G"|sed -n -r '/Running/p'|sed -n -r 's/ +//p'
eeooff
