#!/bin/bash
source /root/test_beifen/pass.txt
Datadir=/data/mysql/3306/data
Backup=/data/tmp

echo "$pass,$user,$db"

Prepare(){
    innobackupex  --defaults-file=/data/mysql/3306/my.cnf  --user=${user} --password=${pass} --apply-log --redo-only  ${Backup}/${db}
}
Get_DB_tables(){
    DB_tables=`mysql -u${user} -p${pass} -Ne "set session group_concat_max_len=8192;select GROUP_CONCAT(concat(table_schema,'.',table_name) SEPARATOR ' ') FROM information_schema.tables where table_schema='${db}' and table_name  not like 'log_%' and table_name not like 'mod_combat_replay'" | tr " " "\n"`
}

Rollback(){
    echo ${DB_tables}
    for i in ${DB_tables}
    do
        DBname=`echo $i |awk -F. '{print $1}'`
        DBtable=`echo $i |awk -F. '{print $2}'`
        echo "$DBname"
        echo "$DBtable"
        mysql -u${user} -p${pass} -e"ALTER TABLE ${i} DISCARD TABLESPACE;"    
        \cp ${Backup}/${db}/${db}/${DBtable}.*  ${Datadir}/${db}
        chown mysql.mysql ${Datadir}/${db}  -R
        mysql -u${user} -p${pass} -e"ALTER TABLE ${i} IMPORT TABLESPACE;"
    done
}
Prepare
Get_DB_tables
Rollback
