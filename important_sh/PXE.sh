#!/bin/bash
read -p "输入本机IP：如（172.16.119.12）" ip
#============DHCP的配置========================
yum install dhcp -y
go=`echo $ip|sed -r 's/(.*)(\..*)/\1/'`
cat >> /etc/dhcp/dhcpd.conf <<eof
subnet $go.0 netmask 255.255.255.0 {
range $go.2 $go.254;
next-server $ip;    
filename "pxelinux.0";            
}
eof
systemctl start dhcpd
#==============TFTP的配置=======================
yum install tftp-server -y
sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp
systemctl restart tftp
#======安放PXE所需要的文件======

#==引导文件pxelinux.0======
yum install syslinux -y
cp /usr/share/syslinux/pxelinux.0  /var/lib/tftpboot/pxelinux.0
#==内核文件，虚拟镜像文件==
cd /mnt/cdrom/isolinux/
cp initrd.img vmlinuz /var/lib/tftpboot/
#==default文件============
cp isolinux.cfg  /var/lib/tftpboot/default
cd /var/lib/tftpboot/
mkdir pxelinux.cfg
mv default  pxelinux.cfg/
sed -i  -r '1s/vesamenu.c32/linux/' /var/lib/tftpboot/pxelinux.cfg/default
ks=`awk -F "inst" 'NR==64{print $1}' /var/lib/tftpboot/pxelinux.cfg/default`
sed -i -r  "64c append initrd=initrd.img ks=http://$ip/ks/ks.cfg" /var/lib/tftpboot/pxelinux.cfg/default
#==============HTTP的配置==========================
yum install  httpd -y
cd /var/www/html/
mkdir ks  iso
umount /mnt/cdrom
mount /dev/sr0  /var/www/html/iso/
cat >>/var/www/html/ks/ks.cfg <<eoc
#platform=x87, AMD64, 或 Intel EM64T
#version=DEVEL
# Install OS instead of upgrade
install
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted $1$/bgTFrCS$4HsLqdngObx8AJh3FgIXb/
# Use network installation
url --url="http://$ip/iso"
# System language
lang en_US
# Firewall configuration
firewall --disabled
# System authorization information
auth  --useshadow  --passalgo=sha512
# Use graphical install
graphical
firstboot --disable
# SELinux configuration
selinux --disabled

# Network information
network  --bootproto=dhcp --device=eth0
# Reboot after installation
reboot
# System timezone
timezone Asia/Shanghai --isUtc
# System bootloader configuration
bootloader --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --size=200
part swap --fstype="swap" --size=1000
part / --fstype="xfs" --grow --size=1

%packages
@base

%end
eoc
systemctl start httpd
echo "安装成功！xlx like sleep！！！！！！！！！！！"
