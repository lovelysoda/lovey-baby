#!/bin/bash
#把zabbix要收集的数据写成函数
LISTEN(){
	#ss -an |grep '^tcp' |grep 'LISTEN'|wc -l
	ss -an|awk '/^tcp/{num[$2]++}END{for(i in num){if(i=="LISTEN"){print num[i]}}}'
}
SYN_RECV(){
	ss -an|awk '/^tcp/{num[$2]++}END{for(i in num){if(i=="SYN-RECV"){print num[i]}else if(i=="SYN_RECV"){print num[i]}}}'
}
ESTABLISHED(){
	ss -an|awk '/^tcp/{num[$2]++}END{for(i in num){if(i=="ESTAB"){print num[i]}}}'
}
TIME_WAIT(){
	ss -an|awk '/^tcp/{num[$2]++}END{for(i in num){if(i=="TIME-WAIT"){print num[i]}else if(i=="TIME_WAIT"){print num[i]}}}'
#	ss -an |grep '^tcp' |grep 'TIME[-_]WAIT'|wc -l
}
$1
