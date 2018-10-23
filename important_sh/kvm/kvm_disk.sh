#!/bin/bash
function HELP(){
	echo "Usage: $(basename $0) -a domain size"
	echo "Usage: $(basename $0) -d domain device"
	echo "Options"
	echo -e "  -a size\tAdd disk for domain.size must be a number.Unit:G"
	echo -e "  -d device\tDelete disk-device from domain,eg:vdb"
}
function add(){ 	#$1是域名 $2是增加的大小  $who是即将增加的磁盘vd[b-z]
qcow2_dir=/kvm/disk
xml_dir=/etc/libvirt/qemu
cd $qcow2_dir
#查询磁盘是sda还是vda，取前两位
prifix=`virsh domblklist mysql1 |awk '/sda|vda/{print $1}'|sed 's/.$//'`

disk=({b..z})
#查看域名中的磁盘,依次遍历从b到z的磁盘,$who是取sd[b-z]或者vd[b-z]的最后字母
j=0
while :;do
    who=${disk[$j]}
    virsh  domblkinfo $1 $prifix$who &>/dev/null
    [ $? -ne 0 ]&&break
    let j++
done
#查看源虚拟机的磁盘类型
bus=`virsh  dumpxml mysql1 |awk -F "'" '/vda|sda/{print $4}'`

qemu-img create -f qcow2 $1_disk-$prifix$who.qcow2 $2G > /dev/null
cat >>$1_disk.xml<<-eof 
<disk type='file' device='disk'>
   <driver name='qemu' type='qcow2'/> 
   <source file='$qcow2_dir/$1_disk-$prifix$who.qcow2'/> 
   <target dev='$prifix$who' bus='$bus'/>
</disk>
eof
virsh attach-device $1 $1_disk.xml --persistent
rm -rf $1_disk.xml
}
function delete(){
	qcow2_dir=/kvm/disk
	[[ "$2" =~ "a" ]] && echo "系统磁盘不允许删除!" && exit
	if [[ "$2" =~ "a" ]] ;then
		echo "$2 maybe system disk,input \"yes\" to delete ?"
		read choise
		[ "$choise" != "yes" ]&&exit
	fi
	virsh detach-disk $1 $qcow2_dir/$1_disk-$2.qcow2 --persistent
	rm -rf $qcow2_dir/$1_disk-$2.qcow2
}
function DOMAIN_CHECK(){
    ! virsh dominfo $1 &>/dev/null   && echo "Domain is not exist" &&exit
}
function NUM_CHECK(){
    [[ ! $1 =~ ^[0-9]+$ ]] && echo "Size must be a number" &&exit
}
function DEV_CHENK(){
	! virsh  domblkinfo $1 $2 &>/dev/null && echo "Device is not exist" &&exit
}
case $1 in
    -a)		#$2是域名 $3是要增加磁盘的大小
	DOMAIN_CHECK $2
    NUM_CHECK $3
    add $2 $3;
        ;;
    -d)		#$2是域名 $3是要删除的设备名
	DOMAIN_CHECK $2
	DEV_CHENK $2 $3
    delete $2 $3;
        ;;
    *)
	HELP;
        ;;
esac
