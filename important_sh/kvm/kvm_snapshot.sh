#!/bin/bash
#存储池路径
dir=/var/lib/libvirt/images/
cd $dir
#========添加 查看 恢复 删除==============
HELP(){
	echo "	-l,--list   --> Exmple: $(basename $0) -l domain"
	echo "	-c,--create --> Exmple: $(basename $0) -c domain  -m \"description\""
	echo "	-d,--create --> Exmple: $(basename $0) -d domain domain.snap"
	echo "	-r,--revert --> Exmple: $(basename $0) -r domain domain.snap"
	echo "Options"
	echo -e "	-l domain\t\tList all snapshots for domain"
	echo -e "	-c domain\t\tCreate sanpshot for domain"
	echo -e "	-m description\t\tDescription of the snapshot.only userd after '-c domain'"
	echo -e "	-d domain snapshot-name\tDelete snapshot for domain"
	echo -e "	-r domain snapshot-name\tRevert domain for snapshot"
	echo
	exit
}
function DOMAIN_CHECK(){
    ! virsh dominfo $1 &>/dev/null   && echo "Domain is not exist" &&exit
}
function SNAP_CHECK(){
	! virsh snapshot-list $1|grep "\<$2\>" >/dev/null && echo "Snap $2 is not exist" &&exit
}
#================快照操作===============
case  $1 in
-c)
	DOMAIN_CHECK $2
	domain=$2
	shift 2 
	if [ "$1" == "-m"  ];then
		shift
		virsh snapshot-create-as $domain $domain-`date +%F-%H-%M-%S`.snap --description "$*" && exit
	fi
	virsh snapshot-create-as $domain $domain-`date +%F-%H-%M-%S`.snap  
	;;
-l)
	DOMAIN_CHECK $2
	virsh snapshot-list $2
	;;
-r)
	DOMAIN_CHECK $2
	SNAP_CHECK $2 $3
	virsh destroy $2 &>/dev/null
	virsh snapshot-revert $2 $3
	[ $? -eq 0 ]&&echo "Seccess!"||echo "No!"
	;;
-d)
	DOMAIN_CHECK $2
	SNAP_CHECK $2 $3
	virsh snapshot-delete $2 $3
	;;
*)
	HELP
	;;
esac
