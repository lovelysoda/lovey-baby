#!/bin/bash
#16年11月14号修改,centos ,mysql,php,nginx 都替换成当前最新版本.
if [ "$1" = "" ] ; then
	echo "没有输入服务器主机名：平台标识_IP最后一个数字.sksy.com"
	exit 1
fi
#######################
host www.sina.com.cn &> /dev/null
if [ "$?" == 1 ];then
  echo "DNS地址失效"
  exit 2
fi
# mysql版本5.7.16  #  php版本5.6.4   #nginx 1.13.3
#------------------------------------------------------------------------------------------------
date > /tmp/time.txt

#公钥登录
mkdir -p /root/.ssh/
chmod -R 700 /root/.ssh/

cat > /root/.ssh/authorized_keys << "EOF"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDAuXopc+W/m8f+9pejc34IVKEvWFm4qCBYJ+OfBL+SCvG1v8kXaTTBUrIJA8HdpcShGk9vzdTxJkG0/4Xf6iPg74EhIKG+8HRHf5HMFCR2CBjoIRuIYwabKPGyeqmTAELEcWWiO7g4zj64nj14jwEFIxcp25qYPzsBHtC9cq985Q== niaoge
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAIEAsvKxszl+O258u8yceZgsw3MTs5946fDWeosqRprS0l2+PSNrZwRpJmmqkkx5HcoNL3uE/GV/TOMDzaGLF9kv8mhN7kgjf0/eBbjTU9RHaimtMAvb231Kwi1emqh4xoXkXCIVoso76efPB0oz4gpwuqBZWCmznFMXR3vnDArahNs= shubo
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAIEAltkFe/V4VE3MUw/218TQnsnVbGAnRe7Rr7AdDP7bdIe0fV5caQnVjXsuhnYni9zu9d7WDDcZyYnbSExN3yGNnLfr5oT+4NblWsTUlmihXOE6vn2XOYoIeanPBI/65KcFW/p4okc83FUysdfbz2pjwHcNY8PdJ4RxJxg5wSci6HU= weihanjing
ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAw9FVBMGCGtwWs2rTdCxBzfDY/YT2GRvpVBZaxvuxUo6YWLHrJ72pCOWRqZ4Un84ZVG+vHm/5BtexBpd2ndFcjuL/edxgbOnRHFesSHoNCbJnMmbv0jRoqutVuf5VoPHgGK0VgSZ91ifLjKEFj3tX27ByAZ/58hDZy2q/Fo1DlGdMUxk4B8L40Dw2bc7x1M/rlbaW32GNPdji9P4q/yPogCgMni3U9y/nHidGrNWn0QSF84yXvvgLmvm8mn68dkX+C658SuqK2DkLDgRhfmAGWrWa/uFt6Jg12l7wyaFg2J9irfebEkDCpzsFcDkX15UQTtURP7SAFRn/DnAS+U0Tsw== root@jstm_dev_115.159.86.159
EOF
echo "@37eRGZT@xx8889" | passwd --stdin root
chmod -R 700 /root/.ssh/
service sshd restart
# 停掉selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
#防火墙规则,停掉新的firewalld服务,改用iptables
systemctl stop firewalld.service && systemctl disable firewalld.service
yum -y install iptables-services
systemctl enable iptables && systemctl start iptables
cat > /etc/sysconfig/iptables << "EOF"
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:RH-Firewall-1-INPUT - [0:0]
-A INPUT -j RH-Firewall-1-INPUT
-A FORWARD -j RH-Firewall-1-INPUT
-A RH-Firewall-1-INPUT -i lo -j ACCEPT
-A RH-Firewall-1-INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A RH-Firewall-1-INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 843 -j ACCEPT
#-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 4369 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 2020 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A RH-Firewall-1-INPUT -p tcp -m state --state NEW -m tcp --dport 40000:44000 -j ACCEPT
COMMIT
EOF
systemctl restart iptables

#------------------------------------------------------------------------------------------------
# 更新机器
if ping -f -c 1 10.133.193.110 &> /dev/null;then
    echo "10.133.193.110		center.fswy.com" >> /etc/hosts
else
    echo "182.254.155.64                center.fswy.com" >> /etc/hosts
fi
#设置.bashrc,系统当前位置提示
cat > /root/.bashrc << EOF
# .bashrc
# User specific aliases and functions
alias vi='vim'
alias rm='/usr/local/bin/rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias dstat='dstat -cndymlp -N total -D total 5 25'
# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
export LANG=en_US.UTF-8
export PS1='[\u@\H \W]\\$ '
EOF
#更新hostname
sed -i '/HOSTNAME/d' /etc/sysconfig/network
echo "${1}" > /etc/hostname
hostname -F /etc/hostname
echo "HOSTNAME=${1}" >> /etc/sysconfig/network
#----------------------------------------------------
#配置服务器时区和时间
/bin/rm -f /etc/localtime
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
cat > /etc/sysconfig/clock <<"EOF"
ZONE="Asia/Shanghai"
UTC=false
ARC=false
EOF

#-----------------------------------------------------------------
#让history加上时间
echo "# add history time" >> /etc/bashrc
echo "export HISTTIMEFORMAT=\"%F %T \"" >> /etc/bashrc

#----------------------------------------------------------------------------------------------------------------------------------
#登陆显示磁盘空间
echo "echo '=========================================================='" >> /root/.bash_profile
echo "cat /etc/redhat-release" >> /root/.bash_profile
echo "echo '=========================================================='"  >> /root/.bash_profile
echo "df -lh" >> /root/.bash_profile
echo "ulimit -SHn 65535" >> /root/.bash_profile
echo "stty -ixon" >> /root/.bash_profile   #去掉终端ctrl+s 界面死锁状态

#升级所需的程序库
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel glibc glibc-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel  krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel  openldap-clients openldap-servers perl-CPAN mysql-devel unixODBC unixODBC-devel lrzsz ntp screen libtool-ltdl-devel cmake svn git unzip


#更改ssh配置
sed -i "s#PasswordAuthentication yes#PasswordAuthentication no#g"  /etc/ssh/sshd_config
sed -i "s/#Port 22/Port 2020/"  /etc/ssh/sshd_config
sed -i 's/GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
##增大系统打开文件数限制
echo '* soft nofile 65535' >> /etc/security/limits.conf
echo '* hard nofile 65535' >> /etc/security/limits.conf
echo 'session required /lib64/security/pam_limits.so' >> /etc/pam.d/login
echo "*          soft    nproc     65535" >> /etc/security/limits.d/90-nproc.conf
echo "*          hard    nproc     65535" >> /etc/security/limits.d/90-nproc.conf
echo "ulimit -SHn 65535" >> /root/.bash_profile
cat > /etc/sysctl.conf << "EOF"
# Add
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.ipv4.tcp_max_syn_backlog = 65536
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 262144
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
kernel.shmmni = 4096
kernel.shmall = 2097152
kernel.shmmax = 134217728
#net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.ip_local_port_range = 10024 39999
#net.ipv4.ip_conntrack_max=655360
#net.ipv4.netfilter.ip_conntrack_max=655360
#net.ipv4.netfilter.ip_conntrack_tcp_timeout_established = 1200
net.netfilter.nf_conntrack_max = 150000
net.nf_conntrack_max = 150000
vm.swappiness = 10
EOF

/sbin/sysctl -p

# 安装工具

#safe-rm
cd /usr/local/src
tar zxvf safe-rm-0.8.tar.gz
cd safe-rm-0.8
mv safe-rm /usr/local/bin/rm
echo "/" >> /etc/safe-rm.conf
echo "/boot" >> /etc/safe-rm.conf

#-----------------------------------------------------
#-----------------------------------------------------
systemctl stop postfix
systemctl stop acpid
systemctl stop chronyd
systemctl disable postfix.service
systemctl disable acpid.service
systemctl disable chronyd.service
######################################
date >> /tmp/time.txt
reboot
