#!/bin/bash
#qcow2_dir=/var/lib/libvirt/images
qcow2_dir=/kvm/disk
xml_dir=/etc/libvirt/qemu
function HELP(){
	echo "Usage: $(basename $0) -a domain domain-clone"
	echo "Usage: $(basename $0) -d domain "
	echo "Options"
	echo -e "  -a size\tadd disk for domain.domain-clone must not exits"
	echo -e "  -d domain must exits"
	exit
}
function add(){
virsh destroy $1 &>/dev/null
#创建链接克隆
cd $qcow2_dir
cp -a  $xml_dir/$1.xml $xml_dir/$2.xml
qemu-img create -f qcow2 -b $1.qcow2 $2.qcow2 &>/dev/null
base_img=$(virsh domblklist $1|awk '/qcow2$/{print $2}')
for i in $base_img;do
	qemu-img create -f qcow2 -b $i $(echo $i|sed "s/$1/$2/") >/dev/null||exit
done
sed -i -r "/$1/s/$1/$2/g" $xml_dir/$2.xml

#modify guest uuid 删除了会自动匹配
sed -r -i  "/uuid/ d" $xml_dir/$2.xml
#sed -r -i "/uuid/s/(.*>)(.*)(<.*)/\1`uuidgen`\3/" $xml_dir/$2.xml

##modify guest mac 删除了会自动匹配
sed -r -i  "/mac address/ d" $xml_dir/$2.xml
#sed -r -i  "/uuid/s/(.*)(.)(.)(<)/\1$rom$rom2\4/" $xml_dir/$2.xml

virsh define $xml_dir/$2.xml
virsh start $2
}
function delete(){
	read -p " Are you sure you want to delete $1 ,input \"yes\" to delete: " choise
    [ "$choise" != "yes" ] && exit
	virsh destroy $1 &>/dev/null
	virsh undefine $1 &>/dev/null
	#删除snapshot快照
	snap=`virsh snapshot-list $1 &>/dev/null |awk '/snap/{print $1}'`
	if [ -n "$snap" ];then
		for i in $snap ;do
			virsh snapshot-delete $1 $i &>/dev/null 
			[ $? -ne  ] && echo "快照删除失败！删除虚拟机失败" && exit
		done
	fi
	#删除磁盘文件
	rm -rf $xml_dir/$1.xm*
	rm -rf $qcow2_dir/$1*.qcow2
	virsh start $1 &>/dev/null || echo "成功删除!"
}
function DOMAIN_CHECK(){
	! virsh dominfo $1 &>/dev/null   && echo "Domain is not exist" &&exit
}
function DOMAIN_CLONE_CHECK(){
	 virsh dominfo $1 &>/dev/null   && echo "Domain-clone is exist" &&exit
}
case $1 in
	-a)
	DOMAIN_CHECK $2
	DOMAIN_CLONE_CHECK $3
	add $2 $3;
		;;
	-d)
	DOMAIN_CHECK $2
	delete $2;
		;;
	*)
	HELP;
		;;
esac
