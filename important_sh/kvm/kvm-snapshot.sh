#!/bin/bash
#
HELP(){
	echo "Usage:$(basename $0) -c domain [-m \"description\"]"
	echo "Usage:$(basename $0) -d domain snapshot-name"
	echo "Usage:$(basename $0) -r domain snapshot-name"
	echo "Usage:$(basename $0) -l domain"
	echo "Options"
	echo -e "  -l domain\t\t\tList all snapshots of the domain"
	echo -e "  -c domain\t\t\tCreate snapshot for the domain"
	echo -e "  -m description\t\tDescription of the snapshot.Only used after '-c domain'"
	echo -e "  -d domain snapshot-name\tDelete snapshot of the domain"
	echo -e "  -r domain snapshot-name\tRevert domain from snapshot"
	echo
	exit
}

DOMAIN_CHECK(){
	! virsh list --all|awk '{print $2}'|grep "^$1$" > /dev/null && echo "Domain "$1" is not exist" && exit
}
SNAP_CHECK(){
	! virsh snapshot-list $1 |grep "\<$2\>" > /dev/null && echo "Snapshot $2 is not exist" && exit
}

case "$1" in
-c)
	DOMAIN_CHECK $2
	domain=$2
	shift 2
	if [ "$1" == "-m" ];then
		shift
		virsh snapshot-create-as $domain $domain-`date +%F-%H-%M-%S`.snap --description "$*" && exit
	fi
	virsh snapshot-create-as $domain $domain-`date +%F-%H-%M-%S`.snap
	;;
-l)
	DOMAIN_CHECK $2
	virsh snapshot-list $2
	;;
-d)
	DOMAIN_CHECK $2
	SNAP_CHECK $2 $3
	virsh snapshot-delete $2 $3
	;;
-r)
	DOMAIN_CHECK $2
    SNAP_CHECK $2 $3
	virsh destroy $2 &> /dev/null
	virsh snapshot-revert $2 $3
	;;
*)
	HELP
esac
