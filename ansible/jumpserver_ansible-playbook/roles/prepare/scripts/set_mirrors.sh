#!/usr/bin/env bash
#

if grep -q 'mirror.centos.org' /etc/yum.repos.d/CentOS-Base.repo; then
  wget -qO /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
  sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo
  yum clean all
fi

if grep -q 'mirrors.fedoraproject.org' /etc/yum.repos.d/epel.repo; then
  wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
  sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/epel.repo
  yum clean all
fi
