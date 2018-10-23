#!/bin/bash
#一天nginx的日志分析,源码安装的nginx，目录在/usr/local/nginx
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "请加入参数！参数是nginx访问日志的时间戳" &&echo "如：$0 22/Sep/2017"&&exit
[ -z  "$1" ] &>/dev/null &&echo "请加入参数！参数是nginx访问日志的时间戳" &&echo "如：$0  22/Sep/2017"&&exit
[ -r "/usr/local/nginx/logs/access.log" ]
[ $? -ne 0 ] && echo "找不到nginx日志，请确认是否已源码安装nginx或确认nginx的access.log位置，并修改脚本。"&&exit
nginx_log=/usr/local/nginx/logs/access.log
day=`echo $1|awk -F "/" '{print $1}' `
month=`echo $1|awk -F "/" '{print $2}' `
year=`echo $1|awk -F "/" '{print $3}' `
today="$day\/$month\/$year"
echo $nginx_log
#PV量(Page View)页面浏览量或者点击量,用户每次对网站的访问均被记录1次。用户对同一页面的多次访问，访问量值累计.
while true; do
	select input in PV量 ip-top10 访问大于100次的IP 访问最多的10个页面 每个URL访问内容总大小 每个IP访问状态码数量 IP访问状态码为404及出现次数 各种状态码数量 退出;do
		case $input in
			PV量)
			awk  '/'$today'/{print $0}' $nginx_log |awk 'END{print NR}'
			echo
			break
			;;
			ip-top10)
			awk  '/'$today'/ {print $0}' $nginx_log |awk '{ips[$1]++}END{for(i in ips){print i,ips[i]}}' |sort -k2 -rn |head -n10
			echo
			break
			;;
            访问大于100次的IP)
			awk   '/'$today'/ {print $0}' $nginx_log |awk '{ips[$1]++}END{for(i in ips){if (ipa[i]>100){print i,ips[i]}}}' |sort -k2 -rn |head -n10
			echo
			break
            ;;
            访问最多的10个页面)
            awk   '/'$today'/{print $0}' $nginx_log |awk '{urls[$7]++}END{for(i in urls){print i,urls[i]}}' |sort -k1 -rn |head -n10
			echo
			break
            ;;
            每个URL访问内容总大小)
			 awk '/'$today'/{size[$7]+=$10} END{for(i in size) {print i,size[i]}}' $nginx_log  |sort -k2rn |head
			echo
			break
            ;;
            每个IP访问状态码数量)
            awk   '/'$today'/{print $0}' $nginx_log |awk '{ip_code[$1" "$9]++}END{for(i in ip_code){print i,ip_code[i]}}' |sort -k1 -rn |head -n10
			echo
			break
            ;;
            IP访问状态码为404及出现次数)
			awk   '/'$today'/{print $0}' $nginx_log |awk '{if($9=="404"){ip_code[$1" "$9]++}}END{for(i in ip_code){print i,ip_code[i]}}'
			echo
			break
            ;;
            各种状态码数量)
			awk   '/'$today'/{print $0}' $nginx_log |awk '{code[$9]++;total++}END{for(i in code){printf i" "; printf code[i]"\t"; printf "%.2f",code[i]/total*100;print "%"}}'
			break
            ;;
            退出)
			exit
            ;;
            *)
	        echo "---------------------------------------"
	        echo "Please enter the number." 
	        echo "---------------------------------------"
	        break
	        ;;
		esac
	done
done
