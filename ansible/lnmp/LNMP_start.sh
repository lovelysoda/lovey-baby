#!/bin/bash
service=$1
pack_dir=/etc/ansible/playbook/package
version_dir=/etc/ansible/playbook/Game_Service_version

version_file=test.version

nginx_version=`grep Nginx  ${version_dir}/${version_file} | awk -F'=' '{print $2}' `
php_version=`grep PHP  ${version_dir}/${version_file} | awk -F'=' '{print $2}' `
mysql_version=`grep MySQL  ${version_dir}/${version_file} | awk -F'=' '{print $2}' `
openssl_version=`grep Openssl  ${version_dir}/${version_file} | awk -F'=' '{print $2}' `
otp_version=`grep Otp  ${version_dir}/${version_file} | awk -F'=' '{print $2}' `

echo $nginx_version
echo $php_version
echo $mysql_version
echo $openssl_version
echo $otp_version

nginx_check_package(){
    [ -e ${pack_dir}/nginx/file/nginx-${nginx_version}.tar.gz ] || wget http://nginx.org/download/nginx-${nginx_version}.tar.gz -O ${pack_dir}/nginx/file/ && echo "下载nginx包成功"
}

php_check_package(){
    [ -e ${pack_dir}/php/file/php-${php_version}.tar.gz ] || wget https://www.php.net/distributions/php-${php_version}.tar.gz -O ${pack_dir}/php/file/ && echo "下载php包成功"
}


mysql_check_package(){
    [ -e ${pack_dir}/mysql/file/mysql-*${mysql_version}*.tar.gz ] || echo "指定版本包不存在，请手动下载至${pack_dir}/mysql/目录" && exit
    #wget https://downloads.mysql.com/archives/get/p/23/file/mysql-${mysql_version}-el7-x86_64.tar.gz -O ${pack_dir}/mysql/file/
}

openssl_check_package(){
    [ -e ${pack_dir}/erlang/file/openssl-${openssl_version}.tar.gz ] || wget https://www.openssl.org/source/openssl-${openssl_version}.tar.gz -O ${pack_dir}/erlang/file/ && echo "下载openssl包成功"
}

otp_check_package(){
    [ -e ${pack_dir}/erlang/file/otp_src_*${otp_version}.tar.gz ] || wget http://www.erlang.org/download/otp_src_${otp_version}.tar.gz -O ${pack_dir}/erlang/file/ && echo "下载otp包成功"
}



