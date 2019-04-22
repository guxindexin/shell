#!/bin/bash
echo -n "input saltid:"
read saltid
echo -n "input hostip:"
read hostip

echo '#关闭防火墙'
systemctl stop firewalld  && systemctl disable firewalld
setenforce 0
sed -i s/"SELINUX=enforcing"/"SELINUX=disable"/ /etc/selinux/config 

echo '修改主机名'
echo 'export PS1="[\u@\H \W]\\$ \[\e[m\]"' >> /etc/profile
source /etc/profile
hostnamectl set-hostname $saltid 
echo "$hostip $saltid" >> /etc/hosts
echo "alias ce='curl vortex-eureka:8761 |grep '" >> ~/.bashrc
source ~/.bashrc

echo '修改yum源，安装常用软件'
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak  
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo 
yum clean all
yum makecache
yum install dos2unix net-tools httpie ftp wget vim htop lrzsz zip unzip ntpdate  -y
echo '*/30 * * * * /usr/sbin/ntpdate time7.aliyun.com >/dev/null 2>&1' > /tmp/crontab2.tmp
crontab /tmp/crontab2.tmp

chmod +x /etc/rc.d/rc.local