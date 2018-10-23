#!/bin/bash
#
#manage domain disk
HELP(){
	echo "Usage: $(basename $0) -a size domain"
	echo "Usage: $(basename $0) -d device domain"
	echo "Options"
	echo -e "  -a size\tAdd disk for domain.Size must be a number.Danwei:G"
	echo -e "  -d device\tDelete disk-device from domain. eg:sdb"
	exit
}

DOMAIN_CHECK(){
	! virsh list --all|awk '{print $2}'|grep "^$1$" > /dev/null && echo "Domain "$1" is not exist" && exit
}

disk_dir="/var/lib/libvirt/images"
sufix=$(date +%Y-%m-%d-%H-%M-%S)
case "$1" in
-a)
	[[ ! "$2" =~ ^[0-9]+$ ]] && echo "Size must be a number" && exit
	DOMAIN_CHECK $3
	cd $disk_dir
	qemu-img create -f qcow2 $3-$sufix.qcow2 $2G > /dev/null
	devices=($(virsh domblklist $3|awk '/\.qcow2$/{print $1}'))
	device_type=($(echo ${devices[0]}|sed 's/.$//'))
	for i in {b..z};do
		! echo ${devices[*]}|grep $device_type$i > /dev/null && device=$device_type$i && break
	done
	bus=$(virsh dumpxml $3 |awk -F "'" '/'${devices[0]}'/{print $4}')
	echo "<disk type='file' device='disk'>" > /tmp/disk.xml
	echo "  <driver name='qemu' type='qcow2'/>" >> /tmp/disk.xml
	echo "  <source file='$disk_dir/$3-$sufix.qcow2'/>" >> /tmp/disk.xml
	echo "  <target dev='$device' bus='$bus'/>" >> /tmp/disk.xml
	echo "</disk>" >> /tmp/disk.xml
	virsh attach-device $3 /tmp/disk.xml --persistent
	;;
-d)
	DOMAIN_CHECK $3
	! virsh domblklist $3|grep "qcow2$"|grep "^$2" > /dev/null && echo "Device $2 is not exist!" && exit
	if echo $2|grep "a" > /dev/null;then 
		read -p "$2 maybe system disk,input \"yes\" to delete: " choise
		[ "$choise" != "yes" ] && exit
	fi
	disk_del=$(virsh domblklist $3|awk '/'^$2'/{print $NF}')
	virsh detach-disk $3 $disk_del --persistent
	read -p "Do you want delete the disk file of $2?(input yes to delete): " choise
	[ "$choise" != "yes" ] && exit
	rm -rf $disk_del
	;;
*)
	HELP
	;;
esac
