#!/bin/bash
[[ "$1" == "-h" || "$1" == "--help" || $# = 0 ]] && echo "Usage $(basename $0) domain clone-name" && exit
! virsh list --all|awk '{print $2}'|grep "^$1$" > /dev/null && echo "Domain "$1" is not exist" && exit
virsh list --all|awk '{print $2}'|grep "^$2$" > /dev/null && echo "Domain "$2" is exist" && exit
####create guest disk file
xml_dir="/etc/libvirt/qemu"
base_img=$(virsh domblklist $1|awk '/qcow2$/{print $2}')
for i in $base_img;do
	qemu-img create -f qcow2 -b $i $(echo $i|sed "s/$1/$2/") > /dev/null ||exit
done
virsh dumpxml $1 > $xml_dir/$2.xml
####modify xml
sed -i "s/$1/$2/g" $xml_dir/$2.xml
sed -i "/uuid/d" $xml_dir/$2.xml
sed -i "/mac add/d" $xml_dir/$2.xml
virsh define $xml_dir/$2.xml > /dev/null
virsh start $2
