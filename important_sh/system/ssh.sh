#!/usr/bin/bash
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "请加入参数！第一个参数是IP，第二个参数是Password" &&echo "如：$0 192.168.2.123 xlx"&&exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null &&echo "请加入参数！第一个参数是IP，第二个参数是Password" &&echo "如：$0 192.168.2.123 xlx"&&exit
>ip.txt
#read -p "请输入IP地址和密码（如：172.16.119.1 root）" fip passwd
myip=`echo $1|sed -rn 's/(.*)(\..*$)/\1/p'`
rpm -q expect &>/dev/null
if [ $? -ne 0 ];then
	yum install -y expect
fi

if [ ! -f ~/.ssh/id_rsa  ];then
	ssh-keygen -P "" -f ~/.ssh/id_rsa
fi

for i in {2..245};do
	{
		ip=$myip.$i
		ping -c1 -W1 $ip &>/dev/null
		if [ $? -eq 0 ];then
			echo "$ip" >> ip.txt
			/usr/bin/expect <<-EOF
			set timeout 10
			spawn ssh-copy-id $ip
			expect {
					"yes/no" { send "yes\r"; exp_continue }
					"password:" { send "$2\r" }
			}
			expect eof
			EOF
		fi
	}&
	
done
