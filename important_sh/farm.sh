#!/bin/bash
#============mysql==================
yum install gcc*  cmake  make  bison  ncurses  ncurses-devel  openssl-devel perl-Data-Dumper pcre-devel libxml2-devel  bzip2-devel -y
yum install mariadb-server -y
systemctl start mariadb
systemctl enable mariadb
mysql -e "create database farm;"
mysql -e "delete from mysql.user where user!='root';"
mysql -e "grant all on farm.* to xlx@'%' identified by 'xlx';"
#========apr====================
tar -xf apr-1.5.2.tar.gz
cd  apr-1.5.2
./configure --prefix=/usr/local/apr
make -j `grep 'processor' /proc/cpuinfo  |wc -l` && make install
cd
#=====apr-util==================
tar  xf apr-util-1.5.4.tar.gz
cd apr-util-1.5.4
./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
make -j `grep 'processor' /proc/cpuinfo  |wc -l` && make install
cd
#============apache==================
tar xf /root/httpd-2.4.23.tar.gz -C /usr/src/
cd /usr/src/httpd-2.4.23/
./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-modules=all --enable-mods-shared=all --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util/ --with-pcre --with-libxml2 --with-mpm=event --enable-mpms-shared=all 
make -j `grep 'processor' /proc/cpuinfo  |wc -l` && make install
cd
sed -r -i '271s/(.*)/\1 index.php/ ' /etc/httpd/httpd.conf
sed -r -i '272a AddHandler   php5-script   .php' /etc/httpd/httpd.conf
sed -r -i '273a AddType   text/html   .php' /etc/httpd/httpd.conf
#=============php-model====
tar xf php-5.5.30.tar.gz -C /usr/src
cd /usr/src/php-5.5.30
./configure --prefix=/usr/local/php --with-apxs2=/usr/local/apache/bin/apxs  --with-config-file-path=/etc/ --with-config-file-scan-dir=/etc/php.d/  --with-libxml-dir  --with-openssl  --with-pcre-regex   --with-zlib  --with-bz2  --with-libxml-dir  --with-pcre-dir --with-jpeg-dir  --with-png-dir  --with-zlib-dir  --with-freetype-dir --enable-mbstring  --with-mysql=mysqlnd  --with-mysqli=mysqlnd  --with-libxml-dir --enable-zip   --enable-maintainer-zts
make -j `grep 'processor' /proc/cpuinfo  |wc -l` && make install
#=========php-configure====
cp php.ini-production /etc/php.ini
sed -r -i '/^short/s/Off/On/p' /etc/php.ini
#======unzip-farm============
cd
yum install unzip -y
unzip farm-ucenter1.5.zip
rm -rf /usr/local/apache/htdocs/*
cp -r upload/  /usr/local/apache/htdocs/
chmod 777 /usr/local/apache/htdocs/* -R
mysql -D farm < /usr/local/apache/htdocs/upload/qqfarm.sql 
/usr/local/apache/bin/httpd -k start
echo  /usr/local/apache/bin/httpd -k start >> /etc/rc.local
chmod +x  /etc/rc.d/rc.local
