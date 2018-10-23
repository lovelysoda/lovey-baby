#!/bin/bash
#mysql for zabbix (无密码状态，如有密码请自行修改脚本)
#正常运行时间
Uptime(){
	mysqladmin status|awk '{print $2}'
}

#慢查询
Slow_queries(){
	mysqladmin status|awk '{print $9}'
}
Com_delete(){
	mysqladmin extend-status|awk '/\<Com_delete\>/{print $4}'
}
Com_insert(){
	mysqladmin extend-status|awk '/\<Com_insert\>/{print $4}'
}
Com_update(){
	mysqladmin extend-status|awk '/\<Com_update\>/{print $4}'
}
Com_select(){
	mysqladmin extend-status|awk '/\<Com_select\>/{print $4}'
}

#提交
Com_commit(){
	mysqladmin extend-status|awk '/\<Com_commit\>/{print $4}'
}

#回滚
Com_rollback(){
	mysqladmin extend-status|awk '/\<Com_rollback\>/{print $4}'
}
$1
