#!/bin/bash
#本地备份dets文件
hour=`date +"%H"` #当前小时数

#备份斗罗
function usr_backup_dets_jstm(){
	rm -rf /data/db_backup/${hour}
	dirs=( `ps aux|grep SCREEN |grep start.sh |grep -v grep |awk '{print $15}'|sed 's/start\.sh//g'|tr "\n" " "` ) #所有现在运行的目录
	for dir in ${dirs[@]}; do
		if [ -d "${dir}dets" ]; then
			mkdir -p /data/db_backup/${hour}
			rsync -avrR --bwlimit=4096 --include="*/" --include="*.dets" --exclude="*" ${dir}dets /data/db_backup/${hour}
		fi
	done
}

#备份西游
function usr_backup_dets_xjmr(){
	rm -rf /data/db_backup/${hour}
	dirs=( `ps aux|grep SCREEN |grep screenrc_tmp |grep -v grep |awk '{print $18}'|sed 's/screenrc_tmp//g'|tr "\n" " "` ) #所有现在运行的目录
	for dir in ${dirs[@]}; do
		if [ -d "${dir}var" ]; then
			mkdir -p /data/db_backup/${hour}
			rsync -avrR --bwlimit=4096 --include="*/" --include="*.dets" --exclude="*" ${dir}var /data/db_backup/${hour}
		fi
	done
}

#备份风色物语
function usr_backup_dets_fswy(){
	rm -rf /data/db_backup/${hour}
	#空间限制，不能每小时备份，只能2小时一次
	if [ $(($hour%2)) -eq 0 ];then #奇数小时备份
		exit 0
	fi
	dirs=( `ps aux|grep SCREEN |grep start.sh |grep -v grep |awk '{print $15}'|sed 's/start\.sh//g'|tr "\n" " "` ) #所有现在运行的目录
	for dir in ${dirs[@]}; do
		if [ -d "${dir}dets" ]; then
			mkdir -p /data/db_backup/${hour}
			rsync -avrR --bwlimit=4096 --exclude="robot_role.dets" --exclude="friend_role.dets" --exclude="combat_record_*.dets" ${dir}dets /data/db_backup/${hour}
		fi
	done
}

game=$1 #必须输入的参数，目前可接受 xjmr jstm fswy
if [ "${game}" = "" ]; then
	exit 0
fi
if [ "$2" = "install" ]; then #添加crond
	cron=`crontab -l|grep dets.sh`
	if [[ "$cron" == "" ]]; then
		echo "5 * * * * bash /root/sh/dets.sh $1" >> /var/spool/cron/root
	fi
	exit 0
fi
if [[ "(xjmr jstm fswy)" =~ "${game}" ]]; then #备份
	usr_backup_dets_${game}
fi
echo "ok"
