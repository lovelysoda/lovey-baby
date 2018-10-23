#!/bin/bash
read -p "请输入你要检查的脚本的文件名->" file
if [ -f $file ]; then
sh -n $file > /dev/null 2>&1
	if [ $? -ne 0 ]; then
	read -p "脚本 $file 有语法错误,请输入q退出或vim直接编辑脚本" answer
	case $answer in
	q | Q)
		exit 0;;
	vim )
		vim $file;;
	*)
		exit 0;;
	esac
	fi
else
echo "$file not exist"
exit 1
fi
