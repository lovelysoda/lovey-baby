#!/bin/bash
#create table vip.user(id varchar(20) primary key,passwd varchar(41),money int unsigned default 100);
function spend_money(){
	old_money=`mysql -e  "select money from vip.user where id='$LOGIN_USER' "|awk 'NR>=2{print $1}'`;
    i=1
    echo “请输入要消费的金额：”
	while [ $i -eq 1 ];do
		read spendmoney
		[ $spendmoney -ge 0 ] &>/dev/null
    	[ $? -ne 0 ] &&echo -n "非法的金额数值,请重新输入:" &&continue
		now_money=$[$old_money-$spendmoney]
		[ $now_money -lt 0 ] &>/dev/null && echo "您没有这么多金钱！"&&break
        mysql -e "update vip.user set money=$now_money where id='$LOGIN_USER'"
        let i++
        echo "消费成功！您现在的余额为$now_money元"
	done
	sleep 1
	echo =====1 返回主菜单 2 退出=====
    echo -n "请输入选项："
    read spendselect
    case $spendselect in
    1)
        main_menu;
        ;;
    2)
        exit;
        ;;
    esac
}
function look_money(){
	money=`mysql -e  "select money from vip.user where id='$LOGIN_USER' "|awk 'NR>=2{print $1}'`;
	echo "您现在的余额为$money元"
	sleep 1
	echo =====1 返回主菜单 2 退出=====
    echo -n "请输入选项："
    read lookselect
    case $lookselect in
    1)
        main_menu;
        ;;
    2)
        exit;
        ;;
    esac
}
function add_money(){
   	old_money=`mysql -e  "select money from vip.user where id='$LOGIN_USER' "|awk 'NR>=2{print $1}'`;
	i=1
	echo  -n “请输入要充值的金额（充值金额必须为50的整数倍）：”
	while [ $i -eq 1 ];do
		read addmoney
		[ $addmoney -ge 50 ] &>/dev/null 
		[ $? -ne 0 ] &&echo -n "充值金额必须为50的整数倍,请重新输入:" &&continue
		[ $[$addmoney%50] -ne 0 ]  &&echo  -n "充值金额必须为50的整数倍，请重新输入：" &&continue
		now_money=$[$old_money+$addmoney]	
		mysql -e "update vip.user set money=$now_money where id='$LOGIN_USER'"
		let i++
		echo "充值成功！您现在的余额为$now_money元"
	done
    sleep 1
    echo =====1 返回主菜单 2 退出=====
    echo -n "请输入选项："
    read addselect
    case $addselect in
    1)
        main_menu;
        ;;
    2)
        exit;
        ;;
    esac
}
function  main_menu (){
	echo ==================================
	echo =======1 查询 2 充值 3 消费=======
	echo ==================================
	echo -n "请输入选项："
	read select
	case $select in
	1)
		look_money;
		;;
	2)
		add_money;
		;;
	3)
		spend_money;
		;;
	esac
}
function  open_menu (){
	echo ==================================
	echo =======1 注册 2 登录 3 退出=======
	echo ==================================
	echo -n "请输入选项："
	read open_select
	case $open_select in
	1)
		registere;
		;;
	2)
		login;
		;;
	3)
		exit;
		;;
	esac
}
function registere(){
	i=1
	while [ $i -eq 1 ] ;do
		echo -n "请输入要注册的用户名："
		read REG_USER
		mysql -e  "insert into vip.user set id='$REG_USER'" &>/dev/null
		[ $? -ne 0 ]&&echo "此用户名已注册，请重新输入！" &&continue
		let i++
	done

	read -s -p "请输入密码：" REG_pwd
	echo
	while  [ $i -eq 2 ]; do
		read -s -p "请确认密码：" REG_pwd2
		echo 
		[ $REG_pwd != $REG_pwd2 ] && echo "确认密码不一致，请重新输入"&&continue	
		mysql -e "update vip.user set passwd=password('$REG_pwd') where id='$REG_USER'"
		let i++
	done
	echo "注册成功！您的账户余额有100元,即将返回界面"
	sleep 2
	open_menu
}
function login(){
	i=1
	x=1
    while [ $i -eq 1 ] ;do
		echo -n "请输入用户名："
        read LOGIN_USER
		[ -n `mysql -e  "select id from vip.user where id='$LOGIN_USER' "|awk 'NR>=2{print $1}'`] &>/dev/null
        [ $? -eq 0 ]&&echo -n "此用户名不存在，请重新输入：" &&continue
        let i++
    done
    echo "请输入密码："
    while  [ $i -eq 2 ]; do
    	read -s  pwd
		[ $x -eq 4 ]&& echo "输入3次错误密码，退出系统！"&&exit
		Y_N=`mysql -e "select count(*) from vip.user where id='$LOGIN_USER' and passwd=password('$pwd')"|awk 'NR==2{print $1}'`
		echo 值是:$Y_N 
		[ $Y_N -eq 0 ] && echo -n "密码不一致，请重新输入：" && let x++ && continue
        let i++
    done
	echo "即将进入主界面"
	sleep 2 
	main_menu
}
open_menu
