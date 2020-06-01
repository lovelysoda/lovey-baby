#!/bin/bash
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "请加入参数！第一个参数是主机名，第二个参数是IP地址" &&echo "如：$0 hostname 192.168.2.123"&&exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null &&echo "请加入参数！第一个参数是主机名，第二个参数是IP地址" &&echo "如：$0 hostname 192.168.2.123"&&exit

#第一个参数是主机名，第二个参数是IP地址

#配置本地yum源
cd /etc/yum.repos.d/
mkdir repo
mkdir /mnt/cdrom
mv * repo/
cat >>local.repo<<eof
[centos7]
name=centos7.3
baseurl=file:///mnt/cdrom
enabled=1
gpgcheck=0
eof
cd
#设置开机挂载
mount /dev/sr0 /mnt/cdrom
echo mount /dev/sr0 /mnt/cdrom >> /etc/rc.local
chmod +x /etc/rc.d/rc.local
#安装vim
yum clean all
yum repolist
yum install vim -y
#关闭防火墙和selinux
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -r -i '/^SELINUX=/s/(.*)([\=])(.*)/\1\2disabled/' /etc/selinux/config
#vim编辑器tab宽度设置
echo set ts=4 >>/etc/vimrc
#修改时区
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
#修改主机名
hostname $1
echo $1.localdomain > /etc/hostname
#修改ip地址
rm -rf /etc/sysconfig/network-scripts/ifcfg-ens33
cat>>/etc/sysconfig/network-scripts/ifcfg-ens33<<eof
TYPE=Ethernet
BOOTPROTO=static
DEVICE=ens33
ONBOOT=yes
IPADDR=$2
eof
ifdown ens33;ifup ens33
